#include "cmdoptions.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "util.h"

struct cmdoptions* cmdoptions_create(void)
{
    struct cmdoptions* options = malloc(sizeof(options));
    options->options = vector_create();
    return options;
}

void _destroy_option(void* ptr)
{
    struct option* option = ptr;
    if(option->argument)
    {
        if(option->flags & MULTIPLE)
        {
            char** p = option->argument;
            while(*p)
            {
                free(*p);
                ++p;
            }
        }
        free(option->argument);
    }
    free(ptr);
}

void cmdoptions_destroy(struct cmdoptions* options)
{
    vector_destroy(options->options, _destroy_option);
    free(options);
}

void cmdoptions_exit(struct cmdoptions* options, int exitcode)
{
    cmdoptions_destroy(options);
    exit(exitcode);
}

void cmdoptions_add_long_option(struct cmdoptions* options, char short_identifier, const char* long_identifier, int argument_required, int flags)
{
    struct option* option = malloc(sizeof(*option));
    option->short_identifier = short_identifier;
    option->long_identifier = long_identifier;
    option->flags = flags;
    option->argument_required = argument_required;
    option->argument = NULL;
    option->was_provided = 0;
    vector_append(options->options, option);
}

struct option* cmdoptions_get_option_long(struct cmdoptions* options, const char* long_identifier)
{
    for(unsigned int i = 0; i < vector_size(options->options); ++i)
    {
        struct option* option = vector_get(options->options, i);
        if(strcmp(option->long_identifier, long_identifier) == 0)
        {
            return option;
        }
    }
    return NULL;
}

int cmdoptions_was_provided_long(struct cmdoptions* options, const char* opt)
{
    for(unsigned int i = 0; i < vector_size(options->options); ++i)
    {
        struct option* option = vector_get(options->options, i);
        if(strcmp(option->long_identifier, opt) == 0)
        {
            return option->was_provided;
        }
    }
    return 0;
}

int cmdoptions_parse(struct cmdoptions* options, int argc, const char* const * argv)
{
    int endofoptions = 0;
    for(int i = 1; i < argc; ++i)
    {
        const char* arg = argv[i];
        if(!endofoptions && arg[0] == '-' && arg[1] == 0); // single dash (-)
        else if(!endofoptions && arg[0] == '-' && arg[1] == '-' && arg[2] == 0) // end of options (--)
        {
            endofoptions = 1;
        }
        else if(!endofoptions && arg[0] == '-') // option
        {
            if(arg[1] == '-') // long option
            {
                const char* longopt = arg + 2;
                struct option* option = cmdoptions_get_option_long(options, longopt);
                if(!option)
                {
                    //printf("unknown command line option: '--%s'\n", longopt);
                    //return 0;
                }
                else
                {
                    if(option->was_provided && !(option->flags & MULTIPLE))
                    {
                        printf("option '%s' is only allowed once\n", longopt);
                    }
                    option->was_provided = 1;
                    if(option->argument_required)
                    {
                        if(i < argc - 1)
                        {
                            if(option->flags & MULTIPLE)
                            {
                                if(!option->argument)
                                {
                                    char** argument = calloc(2, sizeof(char*));
                                    argument[0] = util_copy_string(argv[i + 1]);
                                    option->argument = argument;
                                }
                                else
                                {
                                    char** ptr = option->argument;
                                    while(*ptr) { ++ptr; }
                                    int len = ptr - (char**)option->argument;
                                    char** argument = calloc(len + 2, sizeof(char*));
                                    for(int i = 0; i < len; ++i)
                                    {
                                        argument[i] = ((char**)option->argument)[i];
                                    }
                                    argument[len] = util_copy_string(argv[i + 1]);
                                    free(option->argument);
                                    option->argument = argument;
                                }
                            }
                            else
                            {
                                option->argument = util_copy_string(argv[i + 1]);
                            }
                        }
                        else
                        {
                            //printf("expected argument for option '%s'\n", longopt);
                            //return 0;
                        }
                        ++i;
                    }
                }
            }
            else // short option
            {
                const char* ch = arg + 1;
                while(*ch)
                {
                    char shortopt = *ch;
                    ++ch;
                }
            }
        }
        else // positional parameter
        {
            const char* pospar = arg;
        }
    }
    return 1;
}

const char* cmdoptions_get_argument_long(struct cmdoptions* options, const char* long_identifier)
{
    for(unsigned int i = 0; i < vector_size(options->options); ++i)
    {
        struct option* option = vector_get(options->options, i);
        if(strcmp(option->long_identifier, long_identifier) == 0)
        {
            return option->argument;
        }
    }
    return NULL;
}

