#include "lshape.h"

#include "lua/lauxlib.h"

#define LSHAPEMODULE "shape"

int lshape_create_rectangle_bltr(lua_State* L)
{
    lua_newtable(L);
    // set lpp
    lua_pushstring(L, "lpp");
    lua_pushvalue(L, 1); 
    lua_rawset(L, -3);
    // set type
    lua_pushstring(L, "typ");
    lua_pushstring(L, "rectangle"); 
    lua_rawset(L, -3);

    // set points
    lua_pushstring(L, "points");
    lua_newtable(L);
    // bl
    lua_pushstring(L, "bl");
    lua_pushvalue(L, 2);
    lua_rawset(L, -3);
    // tr
    lua_pushstring(L, "tr");
    lua_pushvalue(L, 3);
    lua_rawset(L, -3);
    // store
    lua_rawset(L, -3);

    // setmetatable
    luaL_setmetatable(L, LSHAPEMODULE);

    return 1;
}

int lshape_create_polygon(lua_State* L)
{
    if(lua_gettop(L) < 2)
    {
        lua_newtable(L);
    }
    lua_newtable(L);
    // set lpp
    lua_pushstring(L, "lpp");
    lua_pushvalue(L, 1); 
    lua_rawset(L, -3);
    // set type
    lua_pushstring(L, "typ");
    lua_pushstring(L, "polygon"); 
    lua_rawset(L, -3);
    // set points
    lua_pushstring(L, "points");
    lua_pushvalue(L, 2);
    lua_rawset(L, -3);
    // setmetatable
    luaL_setmetatable(L, LSHAPEMODULE);
    return 1;
}

int lshape_create_path(lua_State* L)
{
    lua_newtable(L);
    // set lpp
    lua_pushstring(L, "lpp");
    lua_pushvalue(L, 1); 
    lua_rawset(L, -3);
    // set type
    lua_pushstring(L, "typ");
    lua_pushstring(L, "path"); 
    lua_rawset(L, -3);
    // set points
    lua_pushstring(L, "points");
    lua_pushvalue(L, 2);
    lua_rawset(L, -3);
    // set width
    lua_pushstring(L, "width");
    lua_pushvalue(L, 3);
    lua_rawset(L, -3);
    // set ending
    if(lua_gettop(L) > (3 + 1)) // ending type is present (table was pushed on the stack, therefor + 1)
    {
        /*
        if(lua_type(L, 4) == LUA_TSTRING)
        {
        }
        else // LUA_TTABLE, variable start and end extensions
        {
        }
        */
        lua_pushstring(L, "extension");
        lua_pushvalue(L, 4);
        lua_rawset(L, -3);
    }
    // setmetatable
    luaL_setmetatable(L, LSHAPEMODULE);
    return 1;
}

int open_lshape_lib(lua_State* L)
{
    // create metatable for shapes
    luaL_newmetatable(L, LSHAPEMODULE);
    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);

    static const luaL_Reg modfuncs[] =
    {
        { "create_rectangle_bltr", lshape_create_rectangle_bltr },
        { "create_polygon",        lshape_create_polygon        },
        { "create_path",           lshape_create_path           },
        { NULL,                    NULL                         }
    };
    luaL_setfuncs(L, modfuncs, 0);

    lua_setglobal(L, LSHAPEMODULE);

    return 0;
}
