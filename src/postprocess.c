#include "postprocess.h"

#include <string.h>

#include "vector.h"
#include "union.h"

static void _merge_shapes(struct object* object, struct technology_state* techstate)
{
    struct layer_iterator* it = layer_iterator_create(techstate);
    while(layer_iterator_is_valid(it))
    {
        const struct generics* layer = layer_iterator_get(it);
        struct vector* rectangles = vector_create(32, NULL);
        for(int j = object_get_shapes_size(object) - 1; j >= 0; --j)
        {
            struct shape* S = object_get_shape(object, j);
            if(shape_is_rectangle(S) && shape_get_layer(S) == layer)
            {
                vector_append(rectangles, S);
                object_disown_shape(object, j);
            }
        }
        if(vector_size(rectangles) > 1)
        {
            union_rectangle_all(rectangles);
        }
        for(unsigned int i = 0; i < vector_size(rectangles); ++i)
        {
            object_add_raw_shape(object, vector_get(rectangles, i));
        }
        vector_destroy(rectangles);
        layer_iterator_next(it);
    }
    layer_iterator_destroy(it);
}

void postprocess_merge_shapes(struct object* object, struct technology_state* techstate)
{
    _merge_shapes(object, techstate);
}

void postprocess_filter_exclude(struct object* object, const char** layernames)
{
    for(int i = object_get_shapes_size(object) - 1; i >= 0; --i)
    {
        struct shape* S = object_get_shape(object, i);
        const char** layername = layernames;
        while(*layername)
        {
            if(generics_is_layer_name(shape_get_layer(S), *layername))
            {
                object_remove_shape(object, i);
            }
            ++layername;
        }
    }
}

void postprocess_filter_include(struct object* object, const char** layernames)
{
    for(int i = object_get_shapes_size(object) - 1; i >= 0; --i)
    {
        struct shape* S = object_get_shape(object, i);
        int keep = 0;
        const char** layername = layernames;
        while(*layername)
        {
            if(generics_is_layer_name(shape_get_layer(S), *layername))
            {
                keep = 1;
            }
            ++layername;
        }
        if(!keep)
        {
            object_remove_shape(object, i);
        }
    }
}

