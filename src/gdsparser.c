#include "gdsparser.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <string.h>
#include <assert.h>

#include "lua/lauxlib.h"

#include "filesystem.h"
#include "vector.h"
#include "point.h"
#include "hashmap.h"
#include "lua_util.h"

enum datatypes
{
    NONE                = 0x00,
    BIT_ARRAY           = 0x01,
    TWO_BYTE_INTEGER    = 0x02,
    FOUR_BYTE_INTEGER   = 0x03,
    FOUR_BYTE_REAL      = 0x04,
    EIGHT_BYTE_REAL     = 0x05,
    ASCII_STRING        = 0x06
};

enum recordtypes {
    HEADER, BGNLIB, LIBNAME, UNITS, ENDLIB, BGNSTR, STRNAME, ENDSTR, BOUNDARY, PATH, SREF, AREF, TEXT, LAYER, DATATYPE, WIDTH, XY, ENDEL, SNAME,
    COLROW, TEXTNODE, NODE, TEXTTYPE, PRESENTATION, SPACING, STRING, STRANS, MAG, ANGLE, UINTEGER, USTRING, REFLIBS, FONTS, PATHTYPE, GENERATIONS,
    ATTRTABLE, STYPTABLE, STRTYPE, ELFLAGS, ELKEY, LINKTYPE, LINKKEYS, NODETYPE, PROPATTR, PROPVALUE, BOX, BOXTYPE, PLEX, BGNEXTN, ENDEXTN,
    TAPENUM, TAPECODE, STRCLASS, RESERVED, FORMAT, MASK, ENDMASKS, LIBDIRSIZE, SRFNAME, LIBSECUR
};

const char* recordnames[] = {
    "HEADER", "BGNLIB", "LIBNAME", "UNITS", "ENDLIB", "BGNSTR", "STRNAME", "ENDSTR", "BOUNDARY", "PATH", "SREF", "AREF", "TEXT", "LAYER",
    "DATATYPE", "WIDTH", "XY", "ENDEL", "SNAME", "COLROW", "TEXTNODE", "NODE", "TEXTTYPE", "PRESENTATION", "SPACING", "STRING", "STRANS", "MAG",
    "ANGLE", "UINTEGER", "USTRING", "REFLIBS", "FONTS", "PATHTYPE", "GENERATIONS", "ATTRTABLE", "STYPTABLE", "STRTYPE", "ELFLAGS", "ELKEY",
    "LINKTYPE", "LINKKEYS", "NODETYPE", "PROPATTR", "PROPVALUE", "BOX", "BOXTYPE", "PLEX", "BGNEXTN", "ENDEXTN", "TAPENUM", "TAPECODE",
    "STRCLASS", "RESERVED", "FORMAT", "MASK", "ENDMASKS", "LIBDIRSIZE", "SRFNAME", "LIBSECUR",
};

struct record
{
    uint16_t length;
    uint8_t recordtype;
    uint8_t datatype;
    uint8_t* data;
};

int _read_record(FILE* file, struct record* record)
{
    uint8_t buf[4];
    size_t read;
    read = fread(buf, 1, 4, file);
    if(read != 4)
    {
        return 0;
    }
    record->length = (buf[0] << 8) + buf[1];
    record->recordtype = buf[2];
    record->datatype = buf[3];

    size_t numbytes = record->length - 4;
    uint8_t* data = malloc(numbytes);
    read = fread(data, 1, numbytes, file);
    if(read != numbytes)
    {
        free(data);
        return 0;
    }
    record->data = data;
    return 1;
}

struct stream
{
    struct record* records;
    size_t numrecords;
};

static struct stream* _read_raw_stream(const char* filename)
{
    FILE* file = fopen(filename, "r");
    if(!file)
    {
        return NULL;
    }
    size_t numrecords = 0;
    size_t capacity = 10;
    struct record* records = calloc(capacity, sizeof(*records));
    while(1)
    {
        if(numrecords + 1 > capacity)
        {
            capacity *= 2;
            struct record* tmp = realloc(records, capacity * sizeof(*tmp));
            records = tmp;
        }
        if(!_read_record(file, &records[numrecords]))
        {
            fprintf(stderr, "%s\n", "gdsparser: stream abort before ENDLIB");
            break;
        }
        ++numrecords;
        if(records[numrecords - 1].recordtype == ENDLIB)
        {
            break;
        }
    }
    fclose(file);
    struct stream* stream = malloc(sizeof(struct stream));
    stream->records = records;
    stream->numrecords = numrecords;
    return stream;
}

static void _destroy_stream(struct stream* stream)
{
    for(unsigned int i = 0; i < stream->numrecords; ++i)
    {
        free(stream->records[i].data);
    }
    free(stream->records);
    free(stream);
}

static int* _parse_bit_array(uint8_t* data)
{
    int* pdata = calloc(16, sizeof(*pdata));
    for(int j = 0; j < 8; ++j)
    {
        pdata[j] = (data[0] & (1 << (8 - j - 1))) >> (8 - j - 1);
    }
    for(int j = 0; j < 8; ++j)
    {
        pdata[j + 8] = (data[1] & (1 << (8 - j - 1))) >> (8 - j - 1);
    }
    return pdata;
}

static int16_t* _parse_two_byte_integer(uint8_t* data, size_t length)
{
    int16_t* pdata = calloc(length / 2, sizeof(*pdata));
    for(size_t i = 0; i < length / 2; ++i)
    {
        pdata[i] = (data[i * 2] << 8) + data[i * 2 + 1];
    }
    return pdata;
}

static int32_t* _parse_four_byte_integer(uint8_t* data, size_t length)
{
    int32_t* pdata = calloc(length / 4, sizeof(*pdata));
    for(size_t i = 0; i < length / 4; ++i)
    {
        pdata[i] = (data[i * 4] << 24) + (data[i * 4 + 1] << 16) + (data[i * 4 + 2] << 8) + data[i * 4 + 3];
    }
    return pdata;
}

static void _parse_single_point(uint8_t* data, point_t* pt)
{
    pt->x = (data[0] << 24) + (data[1] << 16) + (data[2] << 8) + data[3];
    pt->y = (data[4] << 24) + (data[5] << 16) + (data[6] << 8) + data[7];
}

static inline void _parse_single_point_i(uint8_t* data, size_t i, point_t* pt)
{
    pt->x = (data[i * 4] << 24) + (data[i * 4 + 1] << 16) + (data[i * 4 + 2] << 8) + data[i * 4 + 3];
    pt->y = (data[i * 4 + 4] << 24) + (data[i * 4 + 5] << 16) + (data[i * 4 + 6] << 8) + data[i * 4 + 7];
}

static struct vector* _parse_points(uint8_t* data, size_t length)
{
    struct vector* points = vector_create(length / 8);
    for(size_t i = 0; i < length / 4; i += 2)
    {
        point_t* pt = point_create(0, 0);
        _parse_single_point_i(data, i, pt);
        vector_append(points, pt);
    }
    return points;
}

static double* _parse_four_byte_real(uint8_t* data, size_t length)
{
    double* pdata = calloc(length / 4, sizeof(*pdata));
    for(size_t i = 0; i < length / 4; ++i)
    {
        int sign = data[i * 4] & 0x80;
        int8_t exp = data[i * 4] & 0x7f;
        double mantissa = data[i * 4 + 1] / 256.0
            + data[i * 4 + 2] / 256.0 / 256.0
            + data[i * 4 + 3] / 256.0 / 256.0 / 256.0;
        if(sign)
        {
            pdata[i] = -mantissa * pow(16.0, exp - 64);
        }
        else
        {
            pdata[i] = mantissa * pow(16.0, exp - 64);
        }
    }
    return pdata;
}

static double* _parse_eight_byte_real(uint8_t* data, size_t length)
{
    double* pdata = calloc(length / 8, sizeof(*pdata));
    for(size_t i = 0; i < length / 8; ++i)
    {
        int sign = data[i * 8] & 0x80;
        int8_t exp = data[i * 8] & 0x7f;
        double mantissa = data[i * 8 + 1] / 256.0
                        + data[i * 8 + 2] / 256.0 / 256.0
                        + data[i * 8 + 3] / 256.0 / 256.0 / 256.0
                        + data[i * 8 + 4] / 256.0 / 256.0 / 256.0 / 256.0
                        + data[i * 8 + 5] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0
                        + data[i * 8 + 6] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0
                        + data[i * 8 + 7] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0;
        if(sign)
        {
            pdata[i] = -mantissa * pow(16.0, exp - 64);
        }
        else
        {
            pdata[i] = mantissa * pow(16.0, exp - 64);
        }
    }
    return pdata;
}

static char* _parse_string(uint8_t* data, size_t length)
{
    char* string = malloc(length + 1);
    strncpy(string, (const char*) data, length);
    string[length] = 0;
    return string;
}

static int lgdsparser_read_raw_stream(lua_State* L)
{
    const char* filename = lua_tostring(L, 1);
    struct stream* stream = _read_raw_stream(filename);
    if(!stream)
    {
        lua_pushnil(L);
        lua_pushstring(L, "could not read stream");
        return 2;
    }
    lua_newtable(L);
    for(size_t i = 0; i < stream->numrecords; ++i)
    {
        struct record* record = &stream->records[i];
        lua_newtable(L);

        // header
        lua_pushstring(L, "header");
        lua_newtable(L);

        lua_pushstring(L, "length");
        lua_pushinteger(L, record->length);
        lua_rawset(L, -3);

        lua_pushstring(L, "recordtype");
        lua_pushinteger(L, record->recordtype);
        lua_rawset(L, -3);

        lua_pushstring(L, "datatype");
        lua_pushinteger(L, record->datatype);
        lua_rawset(L, -3);

        lua_rawset(L, -3);

        // data
        // FIXME: use existing functions to parse gds data
        switch(record->datatype)
        {
            case BIT_ARRAY:
                lua_pushstring(L, "data");
                lua_newtable(L);
                for(int j = 0; j < 8; ++j)
                {
                    lua_pushinteger(L, (record->data[0] & (1 << j)) >> j);
                    lua_rawseti(L, -2, j + 1);
                }
                for(int j = 0; j < 8; ++j)
                {
                    lua_pushinteger(L, (record->data[1] & (1 << j)) >> j);
                    lua_rawseti(L, -2, j + 8 + 1);
                }
                lua_rawset(L, -3);
                break;
            case TWO_BYTE_INTEGER:
                if((record->length - 4) / 2 > 1)
                {
                    lua_pushstring(L, "data");
                    lua_newtable(L);
                    for(int j = 0; j < (record->length - 4) / 2; ++j)
                    {
                        int16_t num = (record->data[j * 2]     << 8) 
                                    + (record->data[j * 2 + 1] << 0);
                        lua_pushinteger(L, num);
                        lua_rawseti(L, -2, j + 1);
                    }
                    lua_rawset(L, -3);
                }
                else
                {
                    lua_pushstring(L, "data");
                    int16_t num = (record->data[0] << 8) 
                                + (record->data[1] << 0);
                    lua_pushinteger(L, num);
                    lua_rawset(L, -3);
                }
                break;
            case FOUR_BYTE_INTEGER:
                if((record->length - 4) / 4 > 1)
                {
                    lua_pushstring(L, "data");
                    lua_newtable(L);
                    for(int j = 0; j < (record->length - 4) / 4; ++j)
                    {
                        int32_t num = (record->data[j * 4]     << 24) 
                                    + (record->data[j * 4 + 1] << 16) 
                                    + (record->data[j * 4 + 2] <<  8) 
                                    + (record->data[j * 4 + 3] <<  0);
                        lua_pushinteger(L, num);
                        lua_rawseti(L, -2, j + 1);
                    }
                    lua_rawset(L, -3);
                }
                else
                {
                    lua_pushstring(L, "data");
                    int32_t num = (record->data[0] << 24) 
                                + (record->data[1] << 16) 
                                + (record->data[2] <<  8) 
                                + (record->data[3] <<  0);
                    lua_pushinteger(L, num);
                    lua_rawset(L, -3);
                }
                break;
            case FOUR_BYTE_REAL:
                lua_pushstring(L, "data");
                if((record->length - 4) / 4 > 1)
                {
                    lua_newtable(L);
                }
                for(int j = 0; j < (record->length - 4) / 4; ++j)
                {
                    int sign = record->data[j * 4] & 0x80;
                    int8_t exp = record->data[j * 4] & 0x7f;
                    double mantissa = record->data[j * 4 + 1] / 256.0
                                    + record->data[j * 4 + 2] / 256.0 / 256.0
                                    + record->data[j * 4 + 3] / 256.0 / 256.0 / 256.0;
                    if(sign)
                    {
                        lua_pushnumber(L, -mantissa * pow(16.0, exp - 64));
                    }
                    else
                    {
                        lua_pushnumber(L, mantissa * pow(16.0, exp - 64));
                    }
                    if((record->length - 4) / 4 > 1)
                    {
                        lua_rawseti(L, -2, j + 1);
                    }
                }
                lua_rawset(L, -3);
                break;
            case EIGHT_BYTE_REAL:
                lua_pushstring(L, "data");
                if((record->length - 4) / 8 > 1)
                {
                    lua_newtable(L);
                }
                for(int j = 0; j < (record->length - 4) / 8; ++j)
                {
                    int sign = record->data[j * 8] & 0x80;
                    int8_t exp = record->data[j * 8] & 0x7f;
                    double mantissa = record->data[j * 8 + 1] / 256.0
                                    + record->data[j * 8 + 2] / 256.0 / 256.0
                                    + record->data[j * 8 + 3] / 256.0 / 256.0 / 256.0
                                    + record->data[j * 8 + 4] / 256.0 / 256.0 / 256.0 / 256.0
                                    + record->data[j * 8 + 5] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0
                                    + record->data[j * 8 + 6] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0
                                    + record->data[j * 8 + 7] / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0 / 256.0;
                    if(sign)
                    {
                        lua_pushnumber(L, -mantissa * pow(16.0, exp - 64));
                    }
                    else
                    {
                        lua_pushnumber(L, mantissa * pow(16.0, exp - 64));
                    }
                    if((record->length - 4) / 8 > 1)
                    {
                        lua_rawseti(L, -2, j + 1);
                    }
                }
                lua_rawset(L, -3);
                break;
            case ASCII_STRING:
                if(((char*)record->data)[record->length - 4 - 1] == 0)
                {
                    lua_pushstring(L, "data");
                    lua_pushlstring(L, (char*)record->data, record->length - 4 - 1);
                    lua_rawset(L, -3);
                }
                else
                {
                    lua_pushstring(L, "data");
                    lua_pushlstring(L, (char*)record->data, record->length - 4);
                    lua_rawset(L, -3);
                }
                break;
        }

        lua_rawseti(L, -2, i + 1);
    }
    return 1;
}

int gdsparser_show_records(const char* filename, int raw)
{
    struct stream* stream = _read_raw_stream(filename);
    if(!stream)
    {
        return 0;
    }
    unsigned int indent = 0;
    for(size_t i = 0; i < stream->numrecords; ++i)
    {
        struct record* record = &stream->records[i];
        if(record->recordtype == ENDLIB || record->recordtype == ENDSTR || record->recordtype == ENDEL)
        {
            --indent;
        }
        for(size_t i = 0; i < 4 * indent; ++i)
        {
            putchar(' ');
        }
        printf("%s (%d)", recordnames[record->recordtype], record->length);

        // print data
        if(record->length > 4)
        {
            fputs(" -> data: ", stdout);
            // parsed data
            switch(record->datatype)
            {
                case TWO_BYTE_INTEGER:
                {
                    int16_t* pdata = _parse_two_byte_integer(record->data, record->length - 4);
                    for(int i = 0; i < (record->length - 4) / 2; ++i)
                    {
                        int16_t num = pdata[i];
                        printf("%d ", num);
                    }
                    free(pdata);
                    break;
                }
                case FOUR_BYTE_INTEGER:
                {
                    int32_t* pdata = _parse_four_byte_integer(record->data, record->length - 4);
                    for(int i = 0; i < (record->length - 4) / 4; ++i)
                    {
                        int32_t num = pdata[i];
                        printf("%d ", num);
                    }
                    free(pdata);
                    break;
                }
                case FOUR_BYTE_REAL:
                {
                    double* pdata = _parse_four_byte_real(record->data, record->length - 4);
                    for(int i = 0; i < (record->length - 4) / 4; ++i)
                    {
                        double num = pdata[i];
                        printf("%g ", num);
                    }
                    free(pdata);
                    break;
                }
                case EIGHT_BYTE_REAL:
                {
                    double* pdata = _parse_eight_byte_real(record->data, record->length - 4);
                    for(int i = 0; i < (record->length - 4) / 8; ++i)
                    {
                        double num = pdata[i];
                        printf("%g ", num);
                    }
                    free(pdata);
                    break;
                }
                case ASCII_STRING:
                    putchar('"');
                    for(int i = 0; i < record->length - 4; ++i)
                    {
                        char ch = ((char*)record->data)[i];
                        if(ch) // odd-length strings are zero padded, don't print that character
                        {
                            putchar(ch);
                        }
                    }
                    putchar('"');
                    break;
                case BIT_ARRAY:
                {
                    int* pdata = _parse_bit_array(record->data);
                    for(int i = 0; i < 16; ++i)
                    {
                        if(pdata[i])
                        {
                            putchar('1');
                        }
                        else
                        {
                            putchar('0');
                        }
                    }
                    free(pdata);
                    break;
                }
                default:
                    break;
            }
        }
        if(raw)
        {
            putchar(' ');
            putchar('(');
            for(int i = 0; i < record->length - 4; ++i)
            {
                printf("0x%02x", record->data[i]);
                if(i < record->length - 5)
                {
                    putchar(' ');
                }
            }
            putchar(')');
        }
        putchar('\n');

        if(record->recordtype == BGNLIB ||
           record->recordtype == BGNSTR ||
           record->recordtype == BOUNDARY ||
           record->recordtype == PATH ||
           record->recordtype == SREF ||
           record->recordtype == AREF ||
           record->recordtype == TEXT)
        {
            ++indent;
        }
    }
    _destroy_stream(stream);
    return 1;
}

static void _print_int16(FILE* file, int16_t num)
{
    if(num < 0)
    {
        fputc('-', file);
        num *= -1;
    }
    if(num > 9)
    {
        _print_int16(file, num / 10);
    }
    fputc((num % 10) + '0', file);
}

static void _print_int32(FILE* file, int32_t num)
{
    if(num < 0)
    {
        fputc('-', file);
        num *= -1;
    }
    if(num > 9)
    {
        _print_int32(file, num / 10);
    }
    fputc((num % 10) + '0', file);
}

#define MAX2(a, b) ((a) > (b) ? (a) : (b))
#define MIN2(a, b) ((a) > (b) ? (b) : (a))
#define MAX4(a, b, c, d) MAX2(MAX2(a, b), MAX2(c, d))
#define MIN4(a, b, c, d) MIN2(MIN2(a, b), MIN2(c, d))

struct cellref {
    char* name;
    point_t* origin;
    int16_t xrep;
    int16_t yrep;
    int xpitch;
    int ypitch;
    int* transformation;
    double angle;
};

static const point_t* get_point(const struct vector* vector, size_t i )
{
    return vector_get_const(vector, i);
}

int _check_rectangle(const struct vector* points)
{
    return (((get_point(points, 0))->y == (get_point(points, 1))->y)  &&
            ((get_point(points, 1))->x == (get_point(points, 2))->x)  &&
            ((get_point(points, 2))->y == (get_point(points, 3))->y)  &&
            ((get_point(points, 3))->x == (get_point(points, 4))->x)  &&
            ((get_point(points, 0))->x == (get_point(points, 4))->x)  &&
            ((get_point(points, 0))->y == (get_point(points, 4))->y)) ||
           (((get_point(points, 0))->x == (get_point(points, 1))->x)  &&
            ((get_point(points, 1))->y == (get_point(points, 2))->y)  &&
            ((get_point(points, 2))->x == (get_point(points, 3))->x)  &&
            ((get_point(points, 3))->y == (get_point(points, 4))->y)  &&
            ((get_point(points, 0))->x == (get_point(points, 4))->x)  &&
            ((get_point(points, 0))->y == (get_point(points, 4))->y));
}

struct layermapping {
    int16_t layer;
    int16_t purpose;
    char** mappings;
    size_t num;
};

struct vector* gdsparser_create_layermap(const char* filename)
{
    if(!filename)
    {
        return NULL;
    }
    lua_State* L = util_create_minimal_lua_state();
    int ret = luaL_dofile(L, filename);
    if(ret != LUA_OK)
    {
        const char* msg = lua_tostring(L, -1);
        fprintf(stderr, "error while loading gdslayermap:\n  %s\n", msg);
        lua_close(L);
        return NULL;
    }
    struct vector* map = vector_create(1);
    lua_len(L, -1);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    for(size_t i = 1; i <= len; ++i)
    {
        struct layermapping* layermapping = malloc(sizeof(*layermapping));
        lua_rawgeti(L, -1, i); // get entry

        lua_getfield(L, -1, "layer");
        layermapping->layer = lua_tointeger(L, -1);
        lua_pop(L, 1);

        lua_getfield(L, -1, "purpose");
        layermapping->purpose = lua_tointeger(L, -1);
        lua_pop(L, 1);

        lua_getfield(L, -1, "mappings");
        lua_len(L, -1);
        size_t maplen = lua_tointeger(L, -1);
        lua_pop(L, 1);
        layermapping->num = maplen;
        layermapping->mappings = malloc(len * sizeof(*layermapping->mappings));
        for(size_t j = 1; j <= maplen; ++j)
        {
            lua_rawgeti(L, -1, j);
            const char* mapping = lua_tostring(L, -1);
            layermapping->mappings[j - 1] = strdup(mapping);
            lua_pop(L, 1);
        }
        lua_pop(L, 1);

        lua_pop(L, 1); // pop entry
        
        vector_append(map, layermapping);
    }
    lua_close(L);
    return map;
}

void gdsparser_destroy_layermap(struct vector* layermap)
{
    if(layermap)
    {
        struct vector_iterator* it = vector_iterator_create(layermap);
        while(vector_iterator_is_valid(it))
        {
            struct layermapping* mapping = vector_iterator_get(it);
            for(unsigned int i = 0; i < mapping->num; ++i)
            {
                free(mapping->mappings[i]);
            }
            free(mapping->mappings);
            free(mapping);
            vector_iterator_next(it);
        }
        vector_iterator_destroy(it);
        vector_destroy(layermap, NULL);
    }
}

static void _write_layers(FILE* cellfile, int16_t layer, int16_t purpose, const struct vector* layermap)
{
    fputs("generics.premapped(nil, { ", cellfile);
    fputs("gds = { layer = ", cellfile);
    _print_int16(cellfile, layer);
    fputs(", purpose = ", cellfile);
    _print_int16(cellfile, purpose);
    fputs(" }", cellfile);
    if(layermap)
    {
        struct vector_const_iterator* it = vector_const_iterator_create(layermap);
        while(vector_const_iterator_is_valid(it))
        {
            const struct layermapping* mapping = vector_const_iterator_get(it);
            if(layer == mapping->layer && purpose == mapping->purpose)
            {
                for(unsigned int i = 0; i < mapping->num; ++i)
                {
                    fprintf(cellfile, ", %s", mapping->mappings[i]);
                }
            }
            vector_const_iterator_next(it);
        }
        vector_const_iterator_destroy(it);
    }
    fputs(" })", cellfile);
}

int _check_lpp(int16_t layer, int16_t purpose, const struct vector* ignorelpp)
{
    if(ignorelpp)
    {
        struct vector_const_iterator* it = vector_const_iterator_create(ignorelpp);
        while(vector_const_iterator_is_valid(it))
        {
            const int16_t* lpp = vector_const_iterator_get(it);
            if(layer == lpp[0] && purpose == lpp[1])
            {
                return 0;
            }
            vector_const_iterator_next(it);
        }
        vector_const_iterator_destroy(it);
    }
    return 1;
}

static int _read_TEXT(const struct stream* stream, size_t* i, char** str, int16_t* layer, int16_t* purpose, point_t* origin, double* angle, int** transformation)
{
    ++(*i); // skip TEXT
    while(1)
    {
        struct record* record = &stream->records[*i];
        if(record->recordtype == ELFLAGS)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == PLEX)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == LAYER)
        {
            int16_t* pdata = _parse_two_byte_integer(record->data, 2);
            *layer = *pdata;
            free(pdata);
        }
        else if(record->recordtype == TEXTTYPE)
        {
            int16_t* pdata = _parse_two_byte_integer(record->data, 2);
            *purpose = *pdata;
            free(pdata);
        }
        else if(record->recordtype == PRESENTATION)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == STRANS)
        {
            *transformation = _parse_bit_array(record->data);
        }
        else if(record->recordtype == ANGLE)
        {
            double* pdata = _parse_eight_byte_real(record->data, record->length - 4);
            *angle = *pdata;
            free(pdata);
        }
        else if(record->recordtype == MAG)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == XY)
        {
            _parse_single_point(record->data, origin);
        }
        else if(record->recordtype == STRING)
        {
            *str = _parse_string(record->data, record->length - 4);
        }
        else // wrong record
        {
            return 0;
        }
        ++(*i);
    }
    return 1;
}

static void _destroy_cellref(struct cellref* cellref)
{
    //point_destroy(cellref->origin);
    //if(cellref->transformation)
    //{
    //    free(cellref->transformation);
    //}
    free(cellref);
}

static struct cellref* _read_SREF_AREF(const struct stream* stream, size_t* i, int isAREF)
{
    struct cellref* cellref = malloc(sizeof(*cellref));
    cellref->name = NULL;
    cellref->origin = NULL;
    cellref->xrep = 1;
    cellref->yrep = 1;
    cellref->angle = 0.0;
    cellref->transformation = NULL;
    ++(*i); // skip SREF/AREF
    while(1)
    {
        struct record* record = &stream->records[*i];
        if(record->recordtype == ELFLAGS)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == PLEX)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == SNAME)
        {
            cellref->name = _parse_string(record->data, record->length - 4);
        }
        else if(record->recordtype == STRANS)
        {
            cellref->transformation = _parse_bit_array(record->data);
        }
        else if(record->recordtype == ANGLE)
        {
            double* pdata = _parse_eight_byte_real(record->data, record->length - 4);
            cellref->angle = *pdata;
            free(pdata);
        }
        else if(record->recordtype == MAG)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == COLROW)
        {
            int16_t* pdata = _parse_two_byte_integer(record->data, 4);
            cellref->xrep = pdata[0];
            cellref->yrep = pdata[1];
            free(pdata);
        }
        else if(record->recordtype == XY)
        {
            struct vector* points = _parse_points(record->data, record->length - 4);
            cellref->origin = vector_get(points, 0);
            if(isAREF)
            {
                point_t* pt1 = vector_get(points, 1);
                point_t* pt2 = vector_get(points, 2);
                cellref->xpitch = llabs(pt1->x - cellref->origin->x) / cellref->xrep;
                cellref->ypitch = llabs(pt2->y - cellref->origin->y) / cellref->yrep;
                point_destroy(pt1);
                point_destroy(pt2);
            }
            vector_destroy(points, NULL);
        }
        else if(record->recordtype == ENDEL)
        {
            break;
        }
        else // wrong record
        {
            fprintf(stderr, "malformed SREF/AREF, got unexpected record '%s' (#%zd)\n", recordnames[record->recordtype], *i + 1);
            return NULL;
        }
        ++(*i);
    }
    return cellref;
}
#define _read_SREF(stream, i) _read_SREF_AREF(stream, i, 0)
#define _read_AREF(stream, i) _read_SREF_AREF(stream, i, 1)

static void _write_cellref(FILE* cellfile, const char* importname, const struct cellref* cellref, struct hashmap* references)
{
    if(!hashmap_exists(references, cellref->name))
    {
        fprintf(cellfile, "    ref = pcell.create_layout(\"%s/%s\")\n", importname, cellref->name);
        fprintf(cellfile, "    name = pcell.add_cell_reference(ref, \"%s\")\n", cellref->name);
        hashmap_insert(references, cellref->name, NULL); // use hashmap as set (value == NULL)
    }
    if(cellref->xrep > 1 || cellref->yrep > 1)
    {
        fprintf(cellfile, "    child = cell:add_child_array(name, %d, %d, %d, %d)\n", cellref->xrep, cellref->yrep, cellref->xpitch, cellref->ypitch);
    }
    else
    {
        fputs("    child = cell:add_child(name)\n", cellfile);
    }
    if(cellref->angle == 180)
    {
        if(cellref->transformation && cellref->transformation[0] == 1)
        {
            fputs("    child:mirror_at_xaxis()\n", cellfile);
            fputs("    child:mirror_at_yaxis()\n", cellfile);
        }
        else
        {
            fputs("    child:mirror_at_yaxis()\n", cellfile);
        }
    }
    else if(cellref->angle == 90)
    {
        fputs("    child:rotate_90_left()\n", cellfile);
    }
    if(cellref->transformation && cellref->transformation[0] == 1)
    {
        fputs("    child:mirror_at_xaxis()\n", cellfile);
    }
    fprintf(cellfile, "    child:translate(%lld, %lld)\n", cellref->origin->x, cellref->origin->y);
    free(cellref->name);
    point_destroy(cellref->origin);
    if(cellref->transformation)
    {
        free(cellref->transformation);
    }
}

static int _read_BOUNDARY(const struct stream* stream, size_t* i, int16_t* layer, int16_t* purpose, struct vector** points)
{
    ++(*i); // skip BOUNDARY
    while(1)
    {
        struct record* record = &stream->records[*i];
        if(record->recordtype == ELFLAGS)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == PLEX)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == LAYER)
        {
            int16_t* pdata = _parse_two_byte_integer(record->data, 2);
            *layer = *pdata;
            free(pdata);
        }
        else if(record->recordtype == DATATYPE)
        {
            int16_t* pdata = _parse_two_byte_integer(record->data, 2);
            *purpose = *pdata;
            free(pdata);
        }
        else if(record->recordtype == XY)
        {
            *points = _parse_points(record->data, record->length - 4);
        }
        else if(record->recordtype == PROPATTR)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == PROPVALUE)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == ENDEL)
        {
            break;
        }
        else // wrong record
        {
            fprintf(stderr, "malformed BOUNDARY, got unexpected record '%s' (#%zd)\n", recordnames[record->recordtype], *i + 1);
            return 0;
        }
        ++(*i);
    }
    return 1;
}

static void _write_BOUNDARY(FILE* cellfile, int16_t layer, int16_t purpose, const struct vector* points, const struct vector* gdslayermap)
{
    // check for rectangles
    // BOX is not used for rectangles, at least most tool suppliers seem to do it this way
    // therefor, we check if some "polygons" are actually rectangles and fix the shape types
    if(vector_size(points) == 5 && _check_rectangle(points))
    {
        fputs("    geometry.rectanglebltr(cell, ", cellfile);
        _write_layers(cellfile, layer, purpose, gdslayermap);
        // FIXME: the calls to MAX4 and MIN4 are terrible
        fputs(", point.create(", cellfile);
        _print_int32(cellfile, MIN4((get_point(points, 0))->x, (get_point(points, 1))->x, (get_point(points, 2))->x, (get_point(points, 3))->x));
        fputs(", ", cellfile);
        _print_int32(cellfile, MIN4((get_point(points, 0))->y, (get_point(points, 1))->y, (get_point(points, 2))->y, (get_point(points, 3))->y));
        fputs("), point.create(", cellfile);
        _print_int32(cellfile, MAX4((get_point(points, 0))->x, (get_point(points, 1))->x, (get_point(points, 2))->x, (get_point(points, 3))->x));
        fputs(", ", cellfile);
        _print_int32(cellfile, MAX4((get_point(points, 0))->y, (get_point(points, 1))->y, (get_point(points, 2))->y, (get_point(points, 3))->y));
        fputs("))\n", cellfile);
    }
    else
    {
        fputs("geometry.polygon(cell, ", cellfile);
        _write_layers(cellfile, layer, purpose, gdslayermap);
        fputs(", { ", cellfile);
        for(unsigned int i = 0; i < vector_size(points); ++i)
        {
            const point_t* pt = vector_get_const(points, i);
            fputs("point.create(", cellfile);
            _print_int32(cellfile, pt->x);
            fputs(", ", cellfile);
            _print_int32(cellfile, pt->y);
            fputs("), ", cellfile);
        }
        fputs("})\n", cellfile);
    }
}

static int _read_PATH(const struct stream* stream, size_t* i, int16_t* layer, int16_t* purpose, struct vector** points, coordinate_t* width)
{
    ++(*i); // skip PATH
    while(1)
    {
        struct record* record = &stream->records[*i];
        if(record->recordtype == ELFLAGS)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == PLEX)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == LAYER)
        {
            int16_t* pdata = _parse_two_byte_integer(record->data, 2);
            *layer = *pdata;
            free(pdata);
        }
        else if(record->recordtype == DATATYPE)
        {
            int16_t* pdata = _parse_two_byte_integer(record->data, 2);
            *purpose = *pdata;
            free(pdata);
        }
        else if(record->recordtype == PATHTYPE)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == WIDTH)
        {
            int32_t* pdata = _parse_four_byte_integer(record->data, 4);
            *width = *pdata;
            free(pdata);
        }
        else if(record->recordtype == BGNEXTN)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == ENDEXTN)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == XY)
        {
            *points = _parse_points(record->data, record->length - 4);
        }
        else if(record->recordtype == ENDEL)
        {
            break;
        }
        else // wrong record
        {
            fprintf(stderr, "malformed PATH, got unexpected record '%s' (#%zd)\n", recordnames[record->recordtype], *i + 1);
            return 0;
        }
        ++(*i);
    }
    return 1;
}

static void _write_PATH(FILE* cellfile, int16_t layer, int16_t purpose, const struct vector* points, coordinate_t width, const struct vector* gdslayermap)
{
    fputs("    geometry.path(cell, ", cellfile);
    _write_layers(cellfile, layer, purpose, gdslayermap);
    fputs(", { ", cellfile);
    for(unsigned int i = 0; i < vector_size(points); ++i)
    {
        const point_t* pt = vector_get_const(points, i);
        fprintf(cellfile, "point.create(%lld, %lld), ", pt->x, pt->y);
    }
    fprintf(cellfile, "}, %lld)\n", width);
}

static int _read_structure(const char* importname, const struct stream* stream, size_t* i, const struct vector* gdslayermap, const struct vector* ignorelpp, int16_t* ablayer, int16_t* abpurpose)
{
    FILE* cellfile = NULL;
    struct hashmap* references = hashmap_create();
    ++(*i); // skip BGNSTR
    while(1)
    {
        struct record* record = &stream->records[*i];
        if(record->recordtype == STRNAME)
        {
            char* cellname = _parse_string(record->data, record->length - 4);
            size_t len = strlen(importname) + strlen(importname) + strlen(cellname) + 6; // +2: 2 * '/' + ".lua"
            char* path = malloc(len + 1);
            snprintf(path, len + 1, "%s/%s/%s.lua", importname, importname, cellname);
            cellfile = fopen(path, "w");
            fputs("function parameters() end\n", cellfile);
            fputs("function layout(cell)\n", cellfile);
            fputs("    local ref, name, child\n", cellfile);
            free(cellname);
            free(path);
        }
        else if(record->recordtype == STRCLASS)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == ENDSTR)
        {
            break;
        }
        else if(record->recordtype == BOUNDARY)
        {
            int16_t layer, purpose;
            struct vector* points = NULL;
            if(!_read_BOUNDARY(stream, i, &layer, &purpose, &points))
            {
                return 0;
            }
            if(_check_lpp(layer, purpose, ignorelpp))
            {
                _write_BOUNDARY(cellfile, layer, purpose, points, gdslayermap);
            }
            vector_destroy(points, point_destroy);
            // alignment box
            if(ablayer && abpurpose && layer == *ablayer && purpose == *abpurpose)
            {
                coordinate_t abblx = MIN4((get_point(points, 0))->x, (get_point(points, 1))->x, (get_point(points, 2))->x, (get_point(points, 3))->x);
                coordinate_t abbly = MIN4((get_point(points, 0))->y, (get_point(points, 1))->y, (get_point(points, 2))->y, (get_point(points, 3))->y);
                coordinate_t abtrx = MAX4((get_point(points, 0))->x, (get_point(points, 1))->x, (get_point(points, 2))->x, (get_point(points, 3))->x);
                coordinate_t abtry = MAX4((get_point(points, 0))->y, (get_point(points, 1))->y, (get_point(points, 2))->y, (get_point(points, 3))->y);
                fprintf(cellfile, "    cell:set_alignment_box(point.create(%lld, %lld), point.create(%lld, %lld))\n", abblx, abbly, abtrx, abtry);
            }
        }
        else if(record->recordtype == BOX)
        {
            // FIXME: handle record
        }
        else if(record->recordtype == PATH)
        {
            int16_t layer, purpose;
            struct vector* points = NULL;
            coordinate_t width;
            if(!_read_PATH(stream, i, &layer, &purpose, &points, &width))
            {
                return 0;
            }
            if(_check_lpp(layer, purpose, ignorelpp))
            {
                _write_PATH(cellfile, layer, purpose, points, width, gdslayermap);
            }
            vector_destroy(points, point_destroy);
        }
        else if(record->recordtype == TEXT)
        {
            int16_t layer, purpose;
            point_t origin;
            char* str;
            double angle = 0.0;
            int* transformation = NULL;
            _read_TEXT(stream, i, &str, &layer, &purpose, &origin, &angle, &transformation);
            if(_check_lpp(layer, purpose, ignorelpp))
            {
                fprintf(cellfile, "    cell:add_port(\"%s\", ", str);
                _write_layers(cellfile, layer, purpose, gdslayermap);
                fprintf(cellfile, ", point.create(%lld, %lld))\n", origin.x, origin.y);
                free(str);
            }
            (void) transformation; // port transformation is currently not supported
            (void) angle; // port rotation is currently not supported
            if(transformation)
            {
                free(transformation);
            }
        }
        else if(record->recordtype == SREF)
        {
            struct cellref* cellref = _read_SREF(stream, i);
            if(cellref)
            {
                _write_cellref(cellfile, importname, cellref, references);
                _destroy_cellref(cellref);
            }
            else
            {
                return 0;
            }
        }
        else if(record->recordtype == AREF)
        {
            struct cellref* cellref = _read_AREF(stream, i);
            if(cellref)
            {
                _write_cellref(cellfile, importname, cellref, references);
                _destroy_cellref(cellref);
            }
            else
            {
                return 0;
            }
        }
        else if(record->recordtype == PROPVALUE)
        {
            // FIXME: handle record
        }
        else // wrong record
        {
            printf("structure: unexpected record '%s' (#%zd)\n", recordnames[record->recordtype], *i);
            return 0;
        }
        ++(*i);
    }
    hashmap_destroy(references, NULL);
    fputs("end", cellfile); // close layout function
    fclose(cellfile);
    return 1;
}

int gdsparser_read_stream(const char* filename, const char* importname, const struct vector* gdslayermap, const struct vector* ignorelpp, int16_t* ablayer, int16_t* abpurpose)
{
    const char* libname;
    struct stream* stream = _read_raw_stream(filename);
    if(!stream)
    {
        return 0;
    }

    size_t i = 0;
    while(i < stream->numrecords)
    {
        struct record* record = &stream->records[i];
        if(record->recordtype == LIBNAME)
        {
            libname = (const char*)record->data;
            if(!importname)
            {
                importname = libname;
            }
            size_t len = strlen(importname) + strlen(importname) + 1; // +1: '/'
            char* path = malloc(len + 1);
            snprintf(path, len + 1, "%s/%s", importname, importname);
            filesystem_mkdir(path);
            free(path);
        }
        else if(record->recordtype == BGNSTR)
        {
            if(!_read_structure(importname, stream, &i, gdslayermap, ignorelpp, ablayer, abpurpose))
            {
                _destroy_stream(stream);
                return 0;
            }
        }
        ++i;
    }
    _destroy_stream(stream);
    return 1;
}

static int lgdsparser_show_records(lua_State* L)
{
    const char* filename = lua_tostring(L, 1);
    if(!gdsparser_show_records(filename, 0))
    {
        lua_pushnil(L);
        lua_pushstring(L, "could not read stream");
        return 2;
    }
    lua_pushboolean(L, 1);
    return 1;
}

int open_gdsparser_lib(lua_State* L)
{
    static const luaL_Reg modfuncs[] =
    {
        { "read_raw_stream", lgdsparser_read_raw_stream },
        { "show_records",    lgdsparser_show_records    },
        { NULL,              NULL                       }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "gdsparser");
    return 0;
}
