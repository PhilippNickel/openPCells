#include "shape.h"

#include <stdlib.h>

#include "geometry.h"

static shape_t* _create_shape(shapetype type, size_t capacity)
{
    shape_t* shape = malloc(sizeof(*shape));
    shape->type = type;
    shape->points = calloc(capacity, sizeof(*shape->points));
    shape->capacity = capacity;
    shape->size = 0;
    return shape;
}

shape_t* shape_create_rectangle(coordinate_t bl_x, coordinate_t bl_y, coordinate_t tr_x, coordinate_t tr_y)
{
    shape_t* shape = _create_shape(RECTANGLE, 2);
    shape->points[0] = point_create(bl_x, bl_y);
    shape->points[1] = point_create(tr_x, tr_y);
    shape->size = 2;
    return shape;
}

shape_t* shape_create_polygon(size_t capacity)
{
    shape_t* shape = _create_shape(POLYGON, capacity);
    return shape;
}

shape_t* shape_create_path(size_t capacity, ucoordinate_t width, coordinate_t extstart, coordinate_t extend)
{
    shape_t* shape = _create_shape(PATH, capacity);
    path_properties_t* properties = malloc(sizeof(path_properties_t));
    properties->width = width;
    properties->extension[0] = extstart;
    properties->extension[1] = extend;
    shape->properties = properties;
    return shape;
}

shape_t* shape_copy(shape_t* self)
{
    shape_t* new;
    if(self->type == RECTANGLE)
    {
        new = shape_create_rectangle(self->points[0]->x, self->points[0]->y, self->points[1]->x, self->points[1]->y);
    }
    else
    {
        if(self->type == POLYGON)
        {
            new = shape_create_polygon(self->capacity);
        }
        else // PATH
        {
            path_properties_t* properties = self->properties;
            new = shape_create_path(self->capacity, properties->width, properties->extension[0], properties->extension[1]);
        }
        for(unsigned int i = 0; i < self->size; ++i)
        {
            new->points[i] = point_copy(self->points[i]);
        }
        new->size = self->size;
    }
    new->layer = self->layer; // copy only pointer, this is intended
    return new;
}

void shape_destroy(shape_t* shape)
{
    for(unsigned int i = 0; i < shape->size; ++i)
    {
        point_destroy(shape->points[i]);
    }
    free(shape->points);
    if(shape->type == PATH)
    {
        free(shape->properties);
    }
    free(shape);
}

void shape_append(shape_t* shape, coordinate_t x, coordinate_t y)
{
    if(shape->type == RECTANGLE)
    {
        return;
    }
    // don't append points that are equal as the last one
    if(shape->size > 0)
    {
        if((shape->points[shape->size - 1]->x == x) && (shape->points[shape->size - 1]->y == y))
        {
            return;
        }
    }
    if(shape->size == shape->capacity)
    {
        shape->capacity = (shape->capacity * 2) > (shape->size + 1) ? (shape->capacity * 2) : (shape->size + 1);
        point_t** points = realloc(shape->points, shape->capacity * sizeof(*shape->points));
        shape->points = points;
    }
    shape->points[shape->size] = point_create(x, y);
    shape->size += 1;
}

int shape_get_path_width(shape_t* shape, ucoordinate_t* width)
{
    if(shape->type != PATH)
    {
        return 0;
    }
    *width = ((path_properties_t*)shape->properties)->width;
    return 1;
}

int shape_get_path_extension(shape_t* shape, coordinate_t* start, coordinate_t* end)
{
    if(shape->type != PATH)
    {
        return 0;
    }
    *start = ((path_properties_t*)shape->properties)->extension[0];
    *end = ((path_properties_t*)shape->properties)->extension[1];
    return 1;
}

int shape_is_empty(shape_t* shape)
{
    return shape->layer->size == 0;
}

void shape_translate(shape_t* shape, coordinate_t dx, coordinate_t dy)
{
    for(unsigned int i = 0; i < shape->size; ++i)
    {
        point_translate(shape->points[i], dx, dy);
    }
}

void shape_apply_transformation(shape_t* shape, transformationmatrix_t* matrix)
{
    for(unsigned int i = 0; i < shape->size; ++i)
    {
        transformationmatrix_apply_transformation(matrix, shape->points[i]);
    }
    if(shape->type == RECTANGLE)
    {
        // order of points matter, check if bottom left is still bottom left
        if(shape->points[0]->x > shape->points[1]->x)
        {
            coordinate_t tmp = shape->points[0]->x;
            shape->points[0]->x = shape->points[1]->x;
            shape->points[1]->x = tmp;
        }
        if(shape->points[0]->y > shape->points[1]->y)
        {
            coordinate_t tmp = shape->points[0]->y;
            shape->points[0]->y = shape->points[1]->y;
            shape->points[1]->y = tmp;
        }
    }
}

void shape_apply_inverse_transformation(shape_t* shape, transformationmatrix_t* matrix)
{
    for(unsigned int i = 0; i < shape->size; ++i)
    {
        transformationmatrix_apply_inverse_transformation(matrix, shape->points[i]);
    }
    if(shape->type == RECTANGLE)
    {
        // order of points matter, check if bottom left is still bottom left
        if(shape->points[0]->x > shape->points[1]->x)
        {
            coordinate_t tmp = shape->points[0]->x;
            shape->points[0]->x = shape->points[1]->x;
            shape->points[1]->x = tmp;
        }
        if(shape->points[0]->y > shape->points[1]->y)
        {
            coordinate_t tmp = shape->points[0]->y;
            shape->points[0]->y = shape->points[1]->y;
            shape->points[1]->y = tmp;
        }
    }
}

coordinate_t shape_get_width(shape_t* shape)
{
    coordinate_t minx = COORDINATE_MAX;
    coordinate_t maxx = COORDINATE_MIN;
    for(unsigned int i = 0; i < shape->size; ++i)
    {
        if(shape->points[i]->x < minx)
        {
            minx = shape->points[i]->x;
        }
        if(shape->points[i]->x > maxx)
        {
            maxx = shape->points[i]->x;
        }
    }
    return maxx - minx;
}

coordinate_t shape_get_height(shape_t* shape)
{
    coordinate_t miny = COORDINATE_MAX;
    coordinate_t maxy = COORDINATE_MIN;
    for(unsigned int i = 0; i < shape->size; ++i)
    {
        if(shape->points[i]->y < miny)
        {
            miny = shape->points[i]->y;
        }
        if(shape->points[i]->y > maxy)
        {
            maxy = shape->points[i]->y;
        }
    }
    return maxy - miny;
}

int shape_get_center(shape_t* shape, coordinate_t* x, coordinate_t* y)
{
    if(shape->type != RECTANGLE)
    {
        return 0;
    }
    *x = (shape->points[0]->x + shape->points[1]->x) / 2;
    *y = (shape->points[0]->y + shape->points[1]->y) / 2;
    return 1;
}

int shape_resize_lrtb(shape_t* shape, coordinate_t left, coordinate_t right, coordinate_t top, coordinate_t bottom)
{
    if(shape->type != RECTANGLE)
    {
        return 0;
    }
    point_translate(shape->points[0], -left, -bottom);
    point_translate(shape->points[1], right, top);
    return 0;
}

void shape_resolve_path(shape_t* shape)
{
    if(shape->type != PATH)
    {
        return;
    }
    int miterjoin = 1;
    path_properties_t* properties = shape->properties;
    shape_t* new = geometry_path_to_polygon(shape->points, shape->size, properties->width, miterjoin);
    free(shape->properties);
    for(unsigned int i = 0; i < shape->size; ++i)
    {
        point_destroy(shape->points[i]);
    }
    free(shape->points);
    shape->properties = NULL;
    shape->points = new->points;
    shape->size = new->size;
    shape->capacity = new->capacity;
    shape->type = new->type;
    free(new);
}

