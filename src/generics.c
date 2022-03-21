#include "generics.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

struct hashmapentry
{
    uint32_t key;
    generics_t* layer;
    int destroy;
};

struct hashmap // FIXME: pseudo hashmap, but it will probably be good enough as there are not many elements
{
    struct hashmapentry** entries;
    size_t size;
    size_t capacity;
};

// FIXME: don't use a global variable, put this in the registry for usage in lua
struct hashmap* generics_layer_map;

generics_t* generics_create_empty_layer(void)
{
    generics_t* layer = malloc(sizeof(*layer));
    memset(layer, 0, sizeof(*layer));
    return layer;
}

generics_t* generics_create_premapped_layer(size_t size)
{
    generics_t* layer = malloc(sizeof(*layer));
    layer->data = calloc(size, sizeof(*layer->data));
    layer->exportnames = calloc(size, sizeof(*layer->exportnames));
    layer->size = size;
    layer->is_pre = 1;
    return layer;
}

generics_t* generics_get_layer(uint32_t key)
{
    for(unsigned int i = 0; i < generics_layer_map->size; ++i)
    {
        if(generics_layer_map->entries[i]->key == key)
        {
            return generics_layer_map->entries[i]->layer;
        }
    }
    return NULL;
}

void generics_insert_layer(uint32_t key, generics_t* layer)
{
    if(generics_layer_map->capacity == generics_layer_map->size)
    {
        generics_layer_map->capacity += 1;
        struct hashmapentry** entries = realloc(generics_layer_map->entries, sizeof(*entries) * generics_layer_map->capacity);
        generics_layer_map->entries = entries;
    }
    generics_layer_map->entries[generics_layer_map->size] = malloc(sizeof(struct hashmapentry));
    generics_layer_map->entries[generics_layer_map->size]->key = key;
    generics_layer_map->entries[generics_layer_map->size]->layer = layer;
    generics_layer_map->entries[generics_layer_map->size]->destroy = 0;
    generics_layer_map->size += 1;
}

void generics_insert_extra_layer(uint32_t key, generics_t* layer)
{
    generics_insert_layer(key, layer);
    generics_layer_map->entries[generics_layer_map->size - 1]->destroy = 1;
}

void generics_destroy_layer(generics_t* layer)
{
    for(unsigned int i = 0; i < layer->size; ++i)
    {
        free(layer->exportnames[i]);
        keyvaluearray_destroy(layer->data[i]);
    }
    free(layer->exportnames);
    free(layer->data);
    free(layer);
}

void generics_initialize_layer_map(void)
{
    generics_layer_map = malloc(sizeof(*generics_layer_map));
    generics_layer_map->entries = NULL;
    generics_layer_map->capacity = 0;
    generics_layer_map->size = 0;
}

void generics_destroy_layer_map(void)
{
    for(unsigned int i = 0; i < generics_layer_map->size; ++i)
    {
        // only explicitely premapped layers in cells need to be destroyed, 
        // all other layers are built and destroyed by the technology module
        if(generics_layer_map->entries[i]->destroy)
        {
            generics_destroy_layer(generics_layer_map->entries[i]->layer);
        }
        free(generics_layer_map->entries[i]);
    }
    free(generics_layer_map->entries);
    free(generics_layer_map);
}

size_t generics_get_layer_map_size(void)
{
    return generics_layer_map->size;
}

generics_t* generics_get_indexed_layer(size_t idx)
{
    return generics_layer_map->entries[idx]->layer;
}

int generics_resolve_premapped_layers(const char* name)
{
    int found = 0;
    for(unsigned int i = 0; i < generics_layer_map->size; ++i)
    {
        generics_t* layer = generics_layer_map->entries[i]->layer;
        if(layer->is_pre)
        {
            unsigned int idx = 0;
            for(unsigned int k = 0; k < layer->size; ++k)
            {
                if(strcmp(name, layer->exportnames[k]) == 0)
                {
                    found = 1;
                    idx = k;
                }
            }
            if(!found)
            {
                return 0;
            }

            // swap entries and mark as mapped
            // for mapped entries, only data[0] is used, but it is easier to keep the data here
            // and let _destroy_generics free all data, regardless if a layer is premapped or mapped

            // swap data
            struct keyvaluearray* tmp = layer->data[0];
            layer->data[0] = layer->data[idx];
            layer->data[idx] = tmp;

            // swap export names
            char* str = layer->exportnames[0];
            layer->exportnames[0] = layer->exportnames[idx];
            layer->exportnames[idx] = str;
            layer->is_pre = 0;
        }
    }
    return 1;
}
