#ifndef LROUTER_MOVES_H
#define LROUTER_MOVES_H

typedef enum { X_DIR, Y_DIR } dir_t;

/*
 * all move functions must be preceded with a newtable function and be pushed
 * into a bigger table (e.g. with all the moves) in the end
 * to be put in a table around it to complete the whole route
 * e.g.:
 *
 *        lua_newtable(L);
 *        moves_create_via(L, -2);
 *        lua_rawseti(L, -2, 2);
 */

void moves_create_port(lua_State *L, const char *name, const char *port);
void moves_create_via(lua_State *L, int z, int is_draw);
void moves_create_delta(lua_State *L, dir_t dir, int dist);
void moves_create_shift(lua_State *L, int x, int y);

#endif //LROUTER_MOVES_H
