#include "lplacer_classic.h"

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <limits.h>
#include <stdint.h>
#include <math.h>

#include "lplacer_rand.h"

struct floorplan {
    unsigned int floorplan_width;
    unsigned int floorplan_height;
    unsigned int desired_row_width;
    // limiter window
    int limiter_width;
    int limiter_height;
};

struct cell {
    unsigned int instance;
    unsigned int reference;
    unsigned int width;
    struct net** nets;
    unsigned int* pinoffset;
    unsigned int num_conns;

    unsigned int pos_x;
    unsigned int pos_y;
};

struct net {
    unsigned int xmin, xmax;
    unsigned int ymin, ymax;
};

struct block {
    // cells
    struct cell* cells;
    unsigned int num_cells;

    // nets
    struct net* nets;
    unsigned int num_nets;
};

struct rollback {
    struct cell* c1;
    unsigned int x1;
    unsigned int y1;
    struct cell* c2;
    unsigned int x2;
    unsigned int y2;
};

static unsigned int calculate_total_wirelength(struct block* block)
{
    unsigned int total_wirelength = 0;
    unsigned int xweight = 1;
    unsigned int yweight = 1;
    for(size_t i = 0; i < block->num_nets; ++i)
    {
        struct net* net = block->nets + i;
        unsigned int length = xweight * (net->xmax - net->xmin) + yweight * (net->ymax - net->ymin);
        total_wirelength += length;
    }
    return total_wirelength;
}

static struct cell** get_cells_of_row(struct block* block, unsigned int cur_row, size_t* num_in_row)
{
    size_t capacity = 40;
    size_t cur_cell_idx = 0;
    struct cell** cells_in_row = calloc(capacity, sizeof(struct cell*));
    for(size_t i = 0; i < block->num_cells; ++i)
    {
        struct cell* c = block->cells + i;
        if(c->pos_y == cur_row)
        {
            if(cur_cell_idx == capacity - 1) // -1 for sentinel
            {
                capacity *= 2;
                cells_in_row = realloc(cells_in_row, capacity * sizeof(struct cell*));
            }
            cells_in_row[cur_cell_idx] = c;
            ++cur_cell_idx;
        }
    };
    cells_in_row[cur_cell_idx] = NULL; // sentinel
    if(num_in_row)
    {
        *num_in_row = cur_cell_idx;
    }
    return cells_in_row;
}

static unsigned int calculate_row_width_penalty(struct block* block, struct floorplan* floorplan)
{
    unsigned int penalty = 0;
    for(unsigned int row = 0; row < floorplan->floorplan_height; ++row)
    {
        unsigned int row_width = 0;
        struct cell** cells_in_row = get_cells_of_row(block, row, NULL);
        for(struct cell** c_p = cells_in_row; *c_p; c_p++)
        {
            row_width += (*c_p)->width;
        }
        if(row_width > floorplan->floorplan_width)
        {
            penalty += row_width - floorplan->floorplan_width;
        }
    }
    return penalty;
}

void undo(struct rollback* r)
{
    if(r->c1)
    {
        r->c1->pos_x = r->x1;
        r->c1->pos_y = r->y1;
    }
    if(r->c2)
    {
        r->c2->pos_x = r->x2;
        r->c2->pos_y = r->y2;
    }
}

static struct block* _initialize(lua_State* L, struct floorplan* floorplan, struct RanState* rstate)
{
    struct block* block = malloc(sizeof(struct block));

    block->num_nets = lua_tointeger(L, 1);

    lua_len(L, 2);
    unsigned int num_cells = lua_tointeger(L, -1);
    lua_pop(L, 1);

    // initialize nets
    block->nets = calloc(block->num_nets, sizeof(struct net));

    // initialize all_cells
    block->num_cells = num_cells;
    block->cells = calloc(block->num_cells, sizeof(*block->cells));

    for(size_t i = 1; i <= num_cells; ++i)
    {
        lua_geti(L, 2, i);

        struct cell* c = block->cells + i - 1;

        // instance
        lua_getfield(L, -1, "instance");
        c->instance = lua_tointeger(L, -1);
        lua_pop(L, 1);

        // reference
        lua_getfield(L, -1, "reference");
        c->reference = lua_tointeger(L, -1);
        lua_pop(L, 1);

        // width
        lua_getfield(L, -1, "width");
        c->width = lua_tointeger(L, -1);
        lua_pop(L, 1);

        // nets
        lua_getfield(L, -1, "nets");
        lua_len(L, -1);
        size_t num_conns = lua_tointeger(L, -1);
        lua_pop(L, 1);
        c->nets = calloc(num_conns, sizeof(*c->nets));
        c->pinoffset = calloc(num_conns, sizeof(*c->pinoffset));
        c->num_conns = num_conns;
        for(size_t j = 1; j <= num_conns; ++j)
        {
            lua_geti(L, -1, j);

            lua_getfield(L, -1, "index");
            int index = lua_tointeger(L, -1);
            c->nets[j - 1] = &block->nets[index - 1];

            lua_getfield(L, -2, "pinoffset");
            unsigned int pinoffset = lua_tointeger(L, -1);
            c->pinoffset[j - 1] = pinoffset;

            lua_pop(L, 3); // index, pinoffset and net table
        }
        lua_pop(L, 1);
    }

    // place all cells randomly
    for (unsigned int i = 0; i < block->num_cells; ++i)
    {
        struct cell* c = block->cells + i;
        c->pos_x = _lua_randi(rstate, 0, floorplan->floorplan_width - 1);
        c->pos_y = _lua_randi(rstate, 0, floorplan->floorplan_height - 1);
    }

    return block;
}

static struct floorplan* _create_floorplan(lua_State* L)
{
    lua_getfield(L, 3, "floorplan_width");
    unsigned int floorplan_width = lua_tointeger(L, -1);
    lua_pop(L, 1);
    lua_getfield(L, 3, "floorplan_height");
    unsigned int floorplan_height = lua_tointeger(L, -1);
    lua_pop(L, 1);
    lua_getfield(L, 3, "desired_row_width");
    unsigned int desired_row_width = lua_tointeger(L, -1);
    lua_pop(L, 1);

    struct floorplan* floorplan = malloc(sizeof(struct floorplan));
    floorplan->floorplan_width = floorplan_width;
    floorplan->floorplan_height = floorplan_height;
    floorplan->desired_row_width = desired_row_width;

    return floorplan;
}

static void _clean_up(struct block* block, struct floorplan* floorplan)
{
    for(unsigned int i = 0; i < block->num_cells; ++i)
    {
        free((block->cells + i)->nets);
        free((block->cells + i)->pinoffset);
    }
    free(block->cells);
    free(block->nets);
    free(block);
    free(floorplan);
}

static int _cell_cmp(const void* p1, const void* p2)
{
    struct cell* const * c1 = p1;
    struct cell* const * c2 = p2;
    if((*c1)->pos_x > (*c2)->pos_x)
    {
        return 1;
    }
    else if((*c1)->pos_x < (*c2)->pos_x)
    {
        return -1;
    }
    else
    {
        return 0;
    }
}

static void _create_lua_result(lua_State* L, struct block* block, struct floorplan* floorplan)
{
    // bring back results to lua
    lua_newtable(L);
    for(unsigned int cur_row = 0; cur_row < floorplan->floorplan_height; cur_row++)
    {
        size_t numcellrows;
        struct cell** cells_in_row = get_cells_of_row(block, cur_row, &numcellrows);
        qsort(cells_in_row, numcellrows, sizeof(struct cell*), &_cell_cmp);
        lua_newtable(L);
        int i = 1;
        for(struct cell** c = cells_in_row; *c; ++c)
        {
            lua_newtable(L);
            lua_pushstring(L, "reference");
            lua_pushinteger(L, (*c)->reference);
            lua_settable(L, -3);
            lua_pushstring(L, "instance");
            lua_pushinteger(L, (*c)->instance);
            lua_settable(L, -3);
            lua_seti(L, -2, i);
            ++i;
        }
        lua_seti(L, -2, cur_row + 1);
        free(cells_in_row);
    }
}

#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

static void _update_net_positions(struct block* block)
{
    // reset positions
    for(unsigned int i = 0; i < block->num_nets; ++i)
    {
        struct net* net = block->nets + i;
        net->xmin = UINT_MAX;
        net->xmax = 0;
        net->ymin = UINT_MAX;
        net->ymax = 0;
    }
    // update positions
    for(unsigned int i = 0; i < block->num_cells; ++i)
    {
        struct cell* c = block->cells + i;
        for(unsigned int i = 0; i < c->num_conns; ++i)
        {
            struct net* net = c->nets[i];
            unsigned int pinoffset = c->pinoffset[i];
            net->xmin = min(net->xmin, c->pos_x + pinoffset);
            net->xmax = max(net->xmax, c->pos_x+ pinoffset);
            net->ymin = min(net->ymin, c->pos_y);
            net->ymax = max(net->ymax, c->pos_y);
        }
    }
}

static struct cell* random_cell(struct block* block, struct RanState* rstate)
{
    return block->cells + _lua_randi(rstate, 0, block->num_cells - 1);
}

static inline void cell_place_random(struct cell* c, struct floorplan* floorplan, struct RanState* rstate)
{
    c->pos_x = _lua_randi(rstate, 0, floorplan->floorplan_width - 1);
    c->pos_y = _lua_randi(rstate, 0, floorplan->floorplan_height - 1);
}


void m1(struct cell* a, struct rollback* r, struct floorplan* floorplan, struct RanState* rstate)
{
    r->c1 = a;
    r->x1 = a->pos_x;
    r->y1 = a->pos_y;
    r->c2 = NULL;
    cell_place_random(a, floorplan, rstate);
}

void m2(struct cell* a, struct cell* b, struct rollback* r)
{
    r->c1 = a;
    r->x1 = a->pos_x;
    r->y1 = a->pos_y;
    r->c2 = b;
    r->x2 = b->pos_x;
    r->y2 = b->pos_y;

    // swap cell positions
    a->pos_x = b->pos_x;
    a->pos_y = b->pos_y;
    b->pos_x = r->x1;
    b->pos_y = r->y1;
}

static void _simulated_annealing(struct RanState* rstate, struct block* block, struct floorplan* floorplan, double coolingfactor, size_t moves_per_cell_per_temp, int verbose)
{
    (void) verbose;

    double temperature = 5000.0;
    double end_temperature = 0.01;
    unsigned int needed_steps = (unsigned int) log(temperature / end_temperature) / log(1.0 / coolingfactor) + 1;
    unsigned int steps = 1;
    unsigned int percentage_divisor = 10;
    unsigned int percentage = 0;
    unsigned int last_total_penalty = UINT_MAX;
    while(temperature > end_temperature)
    {
        for(size_t move_ctr = 0; move_ctr < moves_per_cell_per_temp * block->num_cells; move_ctr++)
        {
            struct rollback rollback;

            if(random_choice(rstate, 0.25))
            {
                m2(random_cell(block, rstate), random_cell(block, rstate), &rollback);
            }
            else
            {
                m1(random_cell(block, rstate), &rollback, floorplan, rstate);
            }

            _update_net_positions(block);
            unsigned int total_wirelength = calculate_total_wirelength(block);
            unsigned int too_wide_penalty = calculate_row_width_penalty(block, floorplan);

            unsigned int total_penalty = total_wirelength + 100 * too_wide_penalty;
            printf("temperature: %f\n", temperature);
            printf("last penalty / current penalty: %d / %d\n", last_total_penalty, total_penalty);

            /*
            if(move_ctr == 0 && verbose)
            {
                report_status(temperature, block, floorplan);
            }
            */

            if(move_ctr == 0)
            {
                if(steps * 100 / needed_steps >= percentage)
                {
                    printf("placement %2d %% done\n", percentage);
                    percentage += percentage_divisor;
                }
            }

            if(total_penalty > last_total_penalty)
            {
                undo(&rollback);
                //if(random_choice(rstate, exp(-(total_penalty - last_total_penalty) / temperature)))
                //{
                //    // accept
                //    last_total_penalty = total_penalty;    
                //}
                //else
                //{
                //    undo(&rollback);
                //}
            }
            else // last_total_penalty >= total_penalty
            {
                // accept
                last_total_penalty = total_penalty;
            }
        }
        ++steps;
        temperature = temperature * coolingfactor;
    }
}

int lplacer_place_classic(lua_State* L)
{
    struct RanState rstate;
    srand(time(NULL));
    //randseed(&rstate, rand(), rand());
    randseed(&rstate, 127, 42);

    struct floorplan* floorplan = _create_floorplan(L);

    struct block* block = _initialize(L, floorplan, &rstate);

    lua_getfield(L, 3, "movespercell");
    //const size_t moves_per_cell_per_temp = lua_tointeger(L, -1);
    const size_t moves_per_cell_per_temp = 1;
    lua_pop(L, 1);

    lua_getfield(L, 3, "coolingfactor");
    //const double coolingfactor = lua_tonumber(L, -1);
    const double coolingfactor = 0.95;
    lua_pop(L, 1);

    lua_getfield(L, 3, "report");
    const int verbose = lua_toboolean(L, -1);
    lua_pop(L, 1);

    _simulated_annealing(&rstate, block, floorplan, coolingfactor, moves_per_cell_per_temp, verbose);

    _create_lua_result(L, block, floorplan);

    _clean_up(block, floorplan); // AFTER _create_lua_result!

    return 1; // cells table is returned to lua
}

