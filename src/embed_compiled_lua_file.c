#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lua/lua.h"
#include "lua/lauxlib.h"

struct buffer
{
    char* data;
    size_t capacity;
    size_t length;
};

static void _resize_buffer(struct buffer* buffer, size_t capacity)
{
    buffer->capacity = capacity;
    char* d = realloc(buffer->data, buffer->capacity);
    buffer->data = d;
}

static struct buffer* _create_buffer(void)
{
    struct buffer* buffer = malloc(sizeof(*buffer));
    buffer->data = NULL;
    buffer->length = 0;
    _resize_buffer(buffer, 1024);
    return buffer;
}

static void _append_to_buffer(struct buffer* buffer, char ch)
{
    while(buffer->length + 1 > buffer->capacity)
    {
        _resize_buffer(buffer, buffer->capacity * 2);
    }
    buffer->data[buffer->length] = ch;
    buffer->length += 1;
}

int _writer(lua_State* L, const void* p, size_t sz, void* ud)
{
    (void)L;
    struct buffer* buffer = ud;
    for(unsigned int i = 0; i < sz; ++i)
    {
        _append_to_buffer(buffer, ((char*)p)[i]);
    }
    return 0;
}

int main(int argc, char** argv)
{
    if(argc != 6)
    {
        puts("embed_compiled_lua_file: 5 arguments expected: mode, lua filename, prefix, base and target filename");
        return 1;
    }
    const char* mode = argv[1];
    const char* filename = argv[2];
    const char* prefix = argv[3];
    const char* base = argv[4];
    const char* target = argv[5];

    // compile lua script and load into buffer
    lua_State* L = luaL_newstate();
    int ret = luaL_loadfile(L, filename);
    if(ret != LUA_OK)
    {
        const char* msg = lua_tostring(L, -1);
        fprintf(stderr, "could not compile lua module '%s':\n    %s\n", filename, msg);
        lua_close(L);
        return 1;
    }
    struct buffer* buffer = _create_buffer();
    lua_dump(L, _writer, buffer, 0);
    lua_close(L);

    // export to C representation
    FILE* cfile = fopen(target, "a");
    fprintf(cfile, "unsigned char %s_data[] = {", base);
    for(size_t i = 0; i < buffer->length; ++i)
    {
        if(i % 16 == 0)
        {
            fputs("\n    ", cfile);
        }
        fprintf(cfile, "0x%02hhx", buffer->data[i]);
        if(i != buffer->length - 1)
        {
            fputc(',', cfile);
            fputc(' ', cfile);
        }
    }
    fputs("\n};\n", cfile);
    fprintf(cfile, "size_t %s_data_len = %ld;\n", base, buffer->length);
	fprintf(cfile, "int %s_%s(lua_State* L)", prefix, base);
	fputs("\n{\n", cfile);
    if(strcmp(mode, "--module") == 0)
    {
	    fprintf(cfile, "    return main_load_module(L, %s_data, %s_data_len, \"%s\", \"@%s\");", base, base, base, base);
    }
    else
    {
	    fprintf(cfile, "    return main_call_lua_program_from_buffer(L, %s_data, %s_data_len, \"@%s\");", base, base, base);
    }
	fputs("\n}\n", cfile);
    fclose(cfile);

    return 0;
}

