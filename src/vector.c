#include "vector.h"

#include <stdlib.h>
#include <string.h>

struct vector {
    void** elements;
    size_t size;
    size_t capacity;
};

static void _resize_data(struct vector* vector, size_t capacity)
{
    vector->capacity = capacity;
    void* e = realloc(vector->elements, sizeof(void*) * vector->capacity);
    vector->elements = e;
}

struct vector* vector_create(size_t capacity)
{
    struct vector* vector = malloc(sizeof(*vector));
    vector->elements = NULL;
    vector->size = 0;
    vector->capacity = capacity;
    if(capacity > 0)
    {
        _resize_data(vector, capacity);
    }
    return vector;
}

void vector_destroy(struct vector* vector, void (*destructor)(void*))
{
    if(destructor)
    {
        for(size_t i = 0; i < vector->size; ++i)
        {
            destructor(vector->elements[i]);
        }
    }
    // non-owned data, only destroy vector structure
    free(vector->elements);
    free(vector);
}

struct vector* vector_copy(struct vector* vector, void* (*copy)(void*))
{
    struct vector* new = vector_create(vector->capacity);
    for(size_t i = 0; i < vector->size; ++i)
    {
        new->elements[i] = copy(vector->elements[i]);
    }
    new->size = vector->size;
    return new;
}

void vector_reserve(struct vector* vector, size_t additional_capacity)
{
    if((vector->capacity - vector->size) < additional_capacity)
    {
        _resize_data(vector, vector->capacity + (additional_capacity - (vector->capacity - vector->size)));
    }
}

size_t vector_size(const struct vector* vector)
{
    return vector->size;
}

size_t vector_capacity(const struct vector* vector)
{
    return vector->capacity;
}

int vector_empty(const struct vector* vector)
{
    return vector->size == 0;
}

void* vector_get(struct vector* vector, size_t i)
{
    return vector->elements[i];
}

void* vector_get_reference(struct vector* vector, size_t i)
{
    return &vector->elements[i];
}

void* vector_content(struct vector* vector)
{
    return vector->elements;
}

void* vector_disown_content(struct vector* vector)
{
    void* content = vector->elements;
    free(vector);
    return content;
}

void vector_set(struct vector* vector, size_t i, void* element)
{
    vector->elements[i] = element;
}

void vector_append(struct vector* vector, void* element)
{
    while(vector->size + 1 > vector->capacity)
    {
        _resize_data(vector, vector->capacity ? vector->capacity * 2 : 1);
    }
    vector->elements[vector->size] = element;
    vector->size += 1;
}

void vector_prepend(struct vector* vector, void* element)
{
    while(vector->size + 1 > vector->capacity)
    {
        _resize_data(vector, vector->capacity ? vector->capacity * 2 : 1);
    }
    memmove(vector->elements + 1, vector->elements, sizeof(void*) * vector->size);
    vector->elements[0] = element;
    vector->size += 1;
}

void vector_remove(struct vector* vector, size_t index, void (*destructor)(void*))
{
    if(destructor)
    {
        destructor(vector->elements[index]);
    }
    for(size_t i = index + 1; i < vector->size; ++i)
    {
        vector->elements[i - 1] = vector->elements[i];
    }
    --vector->size;
}

struct vector_iterator
{
    struct vector* vector;
    size_t index;
};

struct vector_iterator* vector_iterator_create(struct vector* vector)
{
    struct vector_iterator* it = malloc(sizeof(*it));
    it->vector = vector;
    it->index = 0;
    return it;
}

int vector_iterator_is_valid(struct vector_iterator* iterator)
{
    return iterator->index < iterator->vector->size;
}

void* vector_iterator_get(struct vector_iterator* iterator)
{
    return vector_get(iterator->vector, iterator->index);
}

void vector_iterator_next(struct vector_iterator* iterator)
{
    iterator->index += 1;
}

void vector_iterator_destroy(struct vector_iterator* iterator)
{
    free(iterator);
}

void vector_sort(struct vector* vector, int (*cmp_func)(const void* left, const void* right))
{
    qsort(vector->elements, vector->size, sizeof(void*), cmp_func);
}

struct const_vector {
    const void** elements;
    size_t size;
    size_t capacity;
};

static void _const_resize_data(struct const_vector* const_vector, size_t capacity)
{
    const_vector->capacity = capacity;
    void* e = realloc(const_vector->elements, sizeof(void*) * const_vector->capacity);
    const_vector->elements = e;
}

struct const_vector* const_vector_create(size_t capacity)
{
    struct const_vector* const_vector = malloc(sizeof(*const_vector));
    const_vector->elements = NULL;
    const_vector->size = 0;
    _const_resize_data(const_vector, capacity);
    return const_vector;
}

void const_vector_destroy(struct const_vector* const_vector)
{
    free(const_vector->elements);
    free(const_vector);
}

size_t const_vector_size(struct const_vector* const_vector)
{
    return const_vector->size;
}

const void* const_vector_get(struct const_vector* const_vector, size_t i)
{
    return const_vector->elements[i];
}

void const_vector_set(struct const_vector* const_vector, size_t i, const void* element)
{
    const_vector->elements[i] = element;
}

void const_vector_append(struct const_vector* const_vector, const void* element)
{
    while(const_vector->size + 1 > const_vector->capacity)
    {
        _const_resize_data(const_vector, const_vector->capacity ? const_vector->capacity * 2 : 1);
    }
    const_vector->elements[const_vector->size] = element;
    const_vector->size += 1;
}

void const_vector_prepend(struct const_vector* const_vector, const void* element)
{
    while(const_vector->size + 1 > const_vector->capacity)
    {
        _const_resize_data(const_vector, const_vector->capacity ? const_vector->capacity * 2 : 1);
    }
    memmove(const_vector->elements + 1, const_vector->elements, sizeof(void*) * const_vector->size);
    const_vector->elements[0] = element;
    const_vector->size += 1;
}

void const_vector_remove(struct const_vector* const_vector, size_t index)
{
    for(size_t i = index + 1; i < const_vector->size; ++i)
    {
        const_vector->elements[i - 1] = const_vector->elements[i];
    }
    --const_vector->size;
}
