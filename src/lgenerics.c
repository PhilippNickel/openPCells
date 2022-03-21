#include "lgenerics.h"

#include "lua/lauxlib.h"

#include <stdlib.h>
#include <string.h>

#include "generics.h"
#include "util.h"
#include "technology.h"

#define METAL_IDENTIFIER          1
#define METALPORT_IDENTIFIER      2
#define VIA_IDENTIFIER            3
#define CONTACT_IDENTIFIER        4
#define OXIDE_IDENTIFIER          5
#define IMPLANT_IDENTIFIER        6
#define VTHTYPE_IDENTIFIER        7
#define OTHER_IDENTIFIER          8
#define SPECIAL_IDENTIFIER        9

uint32_t _hash(const uint8_t* data, size_t size)
{
    uint32_t a = 1;
    uint32_t b = 0;
    const uint32_t MODADLER = 65521;
 
    for(unsigned int i = 0; i < size; ++i)
    {
        a = (a + data[i]) % MODADLER;
        b = (b + a) % MODADLER;
        i++;
    }
    return (b << 16) | a;
}

static int lgenerics_create_metal(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    if(num < 0)
    {
        lua_getglobal(L, "technology");
        lua_pushstring(L, "get_config_value");
        lua_rawget(L, -2);
        lua_pushstring(L, "metals");
        lua_call(L, 1, 1);
        unsigned int nummetals = lua_tointeger(L, -1);
        lua_pop(L, 1);
        num = nummetals + num + 1;
    }

    uint32_t key = (METAL_IDENTIFIER << 24) | (num & 0x00ffffff);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        size_t len = 1 + util_num_digits(num);
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "M%d", num);
        layer = technology_get_layer(layername);
        free(layername);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_metalport(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    if(num < 0)
    {
        lua_getglobal(L, "technology");
        lua_pushstring(L, "get_config_value");
        lua_rawget(L, -2);
        lua_pushstring(L, "metals");
        lua_call(L, 1, 1);
        unsigned int nummetals = lua_tointeger(L, -1);
        lua_pop(L, 1);
        num = nummetals + num + 1;
    }

    uint32_t key = (METALPORT_IDENTIFIER << 24) | (num & 0x00ffffff);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        size_t len = 1 + util_num_digits(num) + 4; // M + %d + port
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "M%dport", num);
        layer = technology_get_layer(layername);
        free(layername);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_viacut(lua_State* L)
{
    int metal1 = luaL_checkinteger(L, 1);
    int metal2 = luaL_checkinteger(L, 2);
    if(metal1 < 0 || metal2 < 0)
    {
        lua_getglobal(L, "technology");
        lua_pushstring(L, "get_config_value");
        lua_rawget(L, -2);
        lua_pushstring(L, "metals");
        lua_call(L, 1, 1);
        unsigned int nummetals = lua_tointeger(L, -1);
        lua_pop(L, 1);
        if(metal1 < 0)
        {
            metal1 = nummetals + metal1 + 1;
        }
        if(metal2 < 0)
        {
            metal2 = nummetals + metal2 + 1;
        }
    }
    if(metal1 > metal2)
    {
        int tmp = metal2;
        metal2 = metal1;
        metal1 = tmp;
    }
    uint32_t key = (VIA_IDENTIFIER << 24) | ((metal1 & 0x00000fff) << 12) | (metal2 & 0x00000fff);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        size_t len = 6 + 1 + util_num_digits(metal1) + 1 + util_num_digits(metal2); // viacut + M + %d + M + %d
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "viacutM%dM%d", metal1, metal2);
        layer = technology_get_layer(layername);
        free(layername);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_contact(lua_State* L)
{
    size_t len;
    const char* region = luaL_checklstring(L, 1, &len);
    uint8_t data[len + 1];
    data[0] = CONTACT_IDENTIFIER;
    memcpy(data + 1, region, len);

    uint32_t key = _hash(data, len + 1);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        size_t len = 7 + strlen(region); // contact + %s
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "contact%s", region);
        layer = technology_get_layer(layername);
        free(layername);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_oxide(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);

    uint32_t key = (OXIDE_IDENTIFIER << 24) | (num & 0x00ffffff);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        size_t len = 5 + util_num_digits(num); // oxide + %d
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "oxide%d", num);
        layer = technology_get_layer(layername);
        free(layername);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_implant(lua_State* L)
{
    const char* str = luaL_checkstring(L, 1);
    uint32_t key = (IMPLANT_IDENTIFIER << 24) | (str[0] & 0x00ffffff); // the '& 0x00ffffff' is unnecessary here, but kept for completeness
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        size_t len = 8; // [np]implant
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "%cimplant", str[0]);
        layer = technology_get_layer(layername);
        free(layername);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_vthtype(lua_State* L)
{
    const char* channeltype = luaL_checkstring(L, 1);
    int vthtype = luaL_checkinteger(L, 2);
    uint32_t key = (VTHTYPE_IDENTIFIER << 24) | ((channeltype[0] & 0x000000ff) << 16) | (vthtype & 0x0000ffff);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        size_t len = 7 + 1 + util_num_digits(vthtype); // vthtype + %c + %d
        char* layername = malloc(len + 1);
        snprintf(layername, len + 1, "vthtype%c%d", channeltype[0], vthtype);
        layer = technology_get_layer(layername);
        free(layername);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_other(lua_State* L)
{
    size_t len;
    const char* str = luaL_checklstring(L, 1, &len);
    uint8_t data[len + 1];
    data[0] = OTHER_IDENTIFIER;
    memcpy(data + 1, str, len);

    uint32_t key = _hash(data, len + 1);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        layer = technology_get_layer(str);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_special(lua_State* L)
{
    uint32_t key = (SPECIAL_IDENTIFIER << 24);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        layer = technology_get_layer("special");
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_premapped(lua_State* L)
{
    uint32_t key = 0xffffffff; // this key is arbitrary (it is not used), but it must not collide with any other possible key
    generics_t* layer = technology_make_layer(L);
    generics_insert_extra_layer(key, layer);
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_resolve_premapped_layers(lua_State* L)
{
    const char* exportname = luaL_checkstring(L, 1);
    int ret = generics_resolve_premapped_layers(exportname);
    lua_pushboolean(L, ret);
    return 1;
}

int open_lgenerics_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "metal",                    lgenerics_create_metal             },
        { "metalport",                lgenerics_create_metalport         },
        { "viacut",                   lgenerics_create_viacut            },
        { "contact",                  lgenerics_create_contact           },
        { "oxide",                    lgenerics_create_oxide             },
        { "implant",                  lgenerics_create_implant           },
        { "vthtype",                  lgenerics_create_vthtype           },
        { "other",                    lgenerics_create_other             },
        { "special",                  lgenerics_create_special           },
        { "premapped",                lgenerics_create_premapped         },
        //{ "mapped",                   lgenerics_create_mapped            },
        { "resolve_premapped_layers", lgenerics_resolve_premapped_layers },
        { NULL,                       NULL                               }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LGENERICSMODULE);

    return 0;
}
