/* -*- Mode: C; indent-tabs-mode: null; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * machine.h
 * Copyright (C) Nicolas Bruguier 2011 <gandalfn@club-internet.fr>
 *
 * maia is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * maia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdbool.h>

#ifndef __MACHINE_H__
#define __MACHINE_H__

static inline void machine_cpu_pause ()
{
    __asm__ __volatile__("pause" ::: "memory");
    return;
}

#define MACHINE_MEMORY_FENCE(T, I)                  \
    inline static void                              \
    machine_memory_fence_strict_##T(void)           \
    {                                               \
        __asm__ __volatile__(I ::: "memory");       \
    }                                               \
    inline static void                              \
    machine_memory_fence_##T(void)                  \
    {                                               \
        __asm__ __volatile__("" ::: "memory");      \
    }

MACHINE_MEMORY_FENCE(load,          "lfence")
MACHINE_MEMORY_FENCE(load_depends,  "")
MACHINE_MEMORY_FENCE(store,         "sfence")
MACHINE_MEMORY_FENCE(memory,        "mfence")

#undef MACHINE_MEMORY_FENCE

#define MACHINE_MEMORY_ATOMIC_FAS(S, M, T, C, I)            \
    inline static T                                         \
    machine_memory_atomic_fas_##S(volatile M *target, T v)  \
    {                                                       \
        __asm__ __volatile__(I " %0, %1"                    \
                    : "+m" (*(C *)target),                  \
                      "+q" (v)                              \
                    :                                       \
                    : "memory");                            \
        return v;                                           \
    }

MACHINE_MEMORY_ATOMIC_FAS(ptr, void, void *, char, "xchgl")

#define MACHINE_MEMORY_ATOMIC_FAS_S(S, T, I) MACHINE_MEMORY_ATOMIC_FAS(S, T, T, T, I)

MACHINE_MEMORY_ATOMIC_FAS_S(double, double,       "xchgq")
MACHINE_MEMORY_ATOMIC_FAS_S(char,   char,         "xchgb")
MACHINE_MEMORY_ATOMIC_FAS_S(uint,   unsigned int, "xchgl")
MACHINE_MEMORY_ATOMIC_FAS_S(int,    int,          "xchgl")
MACHINE_MEMORY_ATOMIC_FAS_S(64,     guint64,      "xchgq")
MACHINE_MEMORY_ATOMIC_FAS_S(32,     guint32,      "xchgl")
MACHINE_MEMORY_ATOMIC_FAS_S(16,     guint16,      "xchgw")
MACHINE_MEMORY_ATOMIC_FAS_S(8,      guint8,       "xchgb")

#undef MACHINE_MEMORY_ATOMIC_FAS_S
#undef MACHINE_MEMORY_ATOMIC_FAS

#define MACHINE_MEMORY_ATOMIC_LOAD(S, M, T, C, I)       \
    inline static T                                     \
    machine_memory_atomic_load_##S(volatile M *target)  \
    {                                                   \
        T r;                                            \
        __asm__ __volatile__(I " %1, %0"                \
                    : "=q" (r)                          \
                    : "m"  (*(C *)target)               \
                    : "memory");                        \
        return (r);                                     \
    }

MACHINE_MEMORY_ATOMIC_LOAD(ptr, void, void *, char, "movq")

#define MACHINE_MEMORY_ATOMIC_LOAD_S(S, T, I) MACHINE_MEMORY_ATOMIC_LOAD(S, T, T, T, I)

MACHINE_MEMORY_ATOMIC_LOAD_S(char,   char,         "movb")
MACHINE_MEMORY_ATOMIC_LOAD_S(uint,   unsigned int, "movl")
MACHINE_MEMORY_ATOMIC_LOAD_S(int,    int,          "movl")
MACHINE_MEMORY_ATOMIC_LOAD_S(double, double,       "movq")
MACHINE_MEMORY_ATOMIC_LOAD_S(64,     guint64,      "movq")
MACHINE_MEMORY_ATOMIC_LOAD_S(32,     guint32,      "movl")
MACHINE_MEMORY_ATOMIC_LOAD_S(16,     guint16,      "movw")
MACHINE_MEMORY_ATOMIC_LOAD_S(8,      guint8,       "movb")

#undef MACHINE_MEMORY_ATOMIC_LOAD_S
#undef MACHINE_MEMORY_ATOMIC_LOAD

#define MACHINE_MEMORY_ATOMIC_STORE(S, M, T, C, I)          \
    inline static void                                      \
    machine_memory_atomic_store_##S(volatile M *target, T v)\
    {                                                       \
        __asm__ __volatile__(I " %1, %0"                    \
                    : "=m" (*(C *)target)                   \
                    : "i" "q" (v)                           \
                    : "memory");                            \
        return;                                             \
    }

MACHINE_MEMORY_ATOMIC_STORE(ptr, void, void *, char, "movq")

#define MACHINE_MEMORY_ATOMIC_STORE_S(S, T, I) MACHINE_MEMORY_ATOMIC_STORE(S, T, T, T, I)

MACHINE_MEMORY_ATOMIC_STORE_S(char,   char,         "movb")
MACHINE_MEMORY_ATOMIC_STORE_S(uint,   unsigned int, "movl")
MACHINE_MEMORY_ATOMIC_STORE_S(int,    int,          "movl")
MACHINE_MEMORY_ATOMIC_STORE_S(double, double,       "movq")
MACHINE_MEMORY_ATOMIC_STORE_S(64,     guint64,      "movq")
MACHINE_MEMORY_ATOMIC_STORE_S(32,     guint32,      "movl")
MACHINE_MEMORY_ATOMIC_STORE_S(16,     guint16,      "movw")
MACHINE_MEMORY_ATOMIC_STORE_S(8,      guint8,       "movb")

#undef MACHINE_MEMORY_ATOMIC_STORE_S
#undef MACHINE_MEMORY_ATOMIC_STORE

#define MACHINE_MEMORY_ATOMIC_FAA(S, M, T, C, I)            \
    inline static T                                         \
    machine_memory_atomic_faa_##S(volatile M *target, T d)  \
    {                                                       \
        __asm__ __volatile__("lock " I " %1, %0"            \
                    : "+m" (*(C *)target),                  \
                      "+q" (d)                              \
                    :                                       \
                    : "memory", "cc");                      \
        return (d);                                         \
    }

MACHINE_MEMORY_ATOMIC_FAA(ptr, void, unsigned int *, char, "xaddq")

#define MACHINE_MEMORY_ATOMIC_FAA_S(S, T, I) MACHINE_MEMORY_ATOMIC_FAA(S, T, T, T, I)

MACHINE_MEMORY_ATOMIC_FAA_S(char,     char,         "xaddb")
MACHINE_MEMORY_ATOMIC_FAA_S(uint,     unsigned int, "xaddl")
MACHINE_MEMORY_ATOMIC_FAA_S(int,      int,          "xaddl")
MACHINE_MEMORY_ATOMIC_FAA_S(64,       guint64,      "xaddq")
MACHINE_MEMORY_ATOMIC_FAA_S(32,       guint32,      "xaddl")
MACHINE_MEMORY_ATOMIC_FAA_S(16,       guint16,      "xaddw")
MACHINE_MEMORY_ATOMIC_FAA_S(8,        guint8,       "xaddb")

#undef MACHINE_MEMORY_ATOMIC_FAA_S
#undef MACHINE_MEMORY_ATOMIC_FAA

#define MACHINE_MEMORY_ATOMIC_UNARY(K, S, T, C, I)              \
    MACHINE_MEMORY_ATOMIC_UNARY_R(K, S, T, C, I)                \
    MACHINE_MEMORY_ATOMIC_UNARY_V(K, S, T, C, I)

#define MACHINE_MEMORY_ATOMIC_UNARY_R(K, S, T, C, I)            \
    inline static void                                          \
    machine_memory_atomic_##K##_##S(volatile T *target)         \
    {                                                           \
        __asm__ __volatile__("lock " I " %0"                    \
                    : "+m" (*(C *)target)                       \
                    :                                           \
                    : "memory", "cc");                          \
        return;                                                 \
    }

#define MACHINE_MEMORY_ATOMIC_UNARY_V(K, S, T, C, I)                    \
    inline static void                                                  \
    machine_memory_atomic_##K##_##S##_zero(volatile T *target, bool *r) \
    {                                                                   \
        __asm__ __volatile__("lock " I " %0; setz %1"                   \
                    : "+m" (*(C *)target),                              \
                      "=m" (*r)                                         \
                    :                                                   \
                    : "memory", "cc");                                  \
        return;                                                         \
    }


#define MACHINE_MEMORY_ATOMIC_UNARY_S(K, S, T, I) MACHINE_MEMORY_ATOMIC_UNARY(K, S, T, T, I)

#define MACHINE_MEMORY_ATOMIC_GENERATE(K)                        \
    MACHINE_MEMORY_ATOMIC_UNARY  (K, ptr,  void, char,   #K "q") \
    MACHINE_MEMORY_ATOMIC_UNARY_S(K, char, char,         #K "b") \
    MACHINE_MEMORY_ATOMIC_UNARY_S(K, int,  int,          #K "l") \
    MACHINE_MEMORY_ATOMIC_UNARY_S(K, uint, unsigned int, #K "l") \
    MACHINE_MEMORY_ATOMIC_UNARY_S(K, 64,   guint64,      #K "q") \
    MACHINE_MEMORY_ATOMIC_UNARY_S(K, 32,   guint32,      #K "l") \
    MACHINE_MEMORY_ATOMIC_UNARY_S(K, 16,   guint16,      #K "w") \
    MACHINE_MEMORY_ATOMIC_UNARY_S(K, 8,    guint8,       #K "b")

MACHINE_MEMORY_ATOMIC_GENERATE(inc)
MACHINE_MEMORY_ATOMIC_GENERATE(dec)
MACHINE_MEMORY_ATOMIC_GENERATE(neg)

#undef MACHINE_MEMORY_ATOMIC_UNARY_V
#define MACHINE_MEMORY_ATOMIC_UNARY_V(a, b, c, d, e)
MACHINE_MEMORY_ATOMIC_GENERATE(not)

#undef MACHINE_MEMORY_ATOMIC_GENERATE
#undef MACHINE_MEMORY_ATOMIC_UNARY_S
#undef MACHINE_MEMORY_ATOMIC_UNARY_V
#undef MACHINE_MEMORY_ATOMIC_UNARY_R
#undef MACHINE_MEMORY_ATOMIC_UNARY

#define MACHINE_MEMORY_ATOMIC_CAS(S, M, T, C, I)                        \
    inline static bool                                                  \
    machine_memory_atomic_cas_##S(volatile M *target, T compare, T set) \
    {                                                                   \
        bool z;                                                         \
        __asm__ __volatile__("lock " I " %2, %0; setz %1"               \
                    : "+m"  (*(C *)target),                             \
                      "=a"  (z)                                         \
                    : "q"   (set),                                      \
                      "a"   (compare)                                   \
                    : "memory", "cc");                                  \
        return z;                                                       \
    }

MACHINE_MEMORY_ATOMIC_CAS(ptr, void, void *, char, "cmpxchgq")

#define MACHINE_MEMORY_ATOMIC_CAS_S(S, T, I) MACHINE_MEMORY_ATOMIC_CAS(S, T, T, T, I)

MACHINE_MEMORY_ATOMIC_CAS_S(char,   char,           "cmpxchgb")
MACHINE_MEMORY_ATOMIC_CAS_S(int,    int,            "cmpxchgl")
MACHINE_MEMORY_ATOMIC_CAS_S(uint,   unsigned int,   "cmpxchgl")
MACHINE_MEMORY_ATOMIC_CAS_S(double, double,         "cmpxchgq")
MACHINE_MEMORY_ATOMIC_CAS_S(64,     guint64,        "cmpxchgq")
MACHINE_MEMORY_ATOMIC_CAS_S(32,     guint32,        "cmpxchgl")
MACHINE_MEMORY_ATOMIC_CAS_S(16,     guint16,        "cmpxchgw")
MACHINE_MEMORY_ATOMIC_CAS_S(8,      guint8,         "cmpxchgb")

#undef MACHINE_MEMORY_ATOMIC_CAS_S
#undef MACHINE_MEMORY_ATOMIC_CAS

#define MACHINE_MEMORY_ATOMIC_CAS_O(S, M, T, C, I, R)                                \
    inline static bool                                                               \
    machine_memory_atomic_cas_##S##_value(volatile M *target, T compare, T set, M *v)\
    {                                                                                \
        bool z;                                                                      \
        __asm__ __volatile__("lock " "cmpxchg" I " %3, %0;"                          \
                     "mov %% " R ", %2;"                                             \
                     "setz %1;"                                                      \
                    : "+m"  (*(C *)target),                                          \
                      "=a"  (z),                                                     \
                      "=m"  (*(C *)v)                                                \
                    : "q"   (set),                                                   \
                      "a"   (compare)                                                \
                    : "memory", "cc");                                               \
        return z;                                                                    \
    }

MACHINE_MEMORY_ATOMIC_CAS_O(ptr, void, void *, char, "q", "rax")

#define MACHINE_MEMORY_ATOMIC_CAS_O_S(S, T, I, R)                           \
    MACHINE_MEMORY_ATOMIC_CAS_O(S, T, T, T, I, R)

MACHINE_MEMORY_ATOMIC_CAS_O_S(char,   char,         "b", "al")
MACHINE_MEMORY_ATOMIC_CAS_O_S(int,    int,          "l", "eax")
MACHINE_MEMORY_ATOMIC_CAS_O_S(uint,   unsigned int, "l", "eax")
MACHINE_MEMORY_ATOMIC_CAS_O_S(double, double,       "q", "rax")
MACHINE_MEMORY_ATOMIC_CAS_O_S(64,     guint64,      "q", "rax")
MACHINE_MEMORY_ATOMIC_CAS_O_S(32,     guint32,      "l", "eax")
MACHINE_MEMORY_ATOMIC_CAS_O_S(16,     guint16,      "w", "ax")
MACHINE_MEMORY_ATOMIC_CAS_O_S(8,      guint8,       "b", "al")

#undef MACHINE_MEMORY_ATOMIC_CAS_O_S
#undef MACHINE_MEMORY_ATOMIC_CAS_O

#define MACHINE_MEMORY_ATOMIC_CAST(S, T)                                    \
    inline static volatile T *                                              \
    machine_memory_atomic_cast_##S(void *v)                                 \
    {                                                                       \
        return (T *)v;                                                      \
    }

MACHINE_MEMORY_ATOMIC_CAST(ptr,    void)
MACHINE_MEMORY_ATOMIC_CAST(char,   char)
MACHINE_MEMORY_ATOMIC_CAST(int,    int)
MACHINE_MEMORY_ATOMIC_CAST(uint,   unsigned int)
MACHINE_MEMORY_ATOMIC_CAST(double, double)
MACHINE_MEMORY_ATOMIC_CAST(64,     guint64)
MACHINE_MEMORY_ATOMIC_CAST(32,     guint32)
MACHINE_MEMORY_ATOMIC_CAST(16,     guint16)
MACHINE_MEMORY_ATOMIC_CAST(8,      guint8)

#undef MACHINE_MEMORY_ATOMIC_CAST

#define MACHINE_MEMORY_ATOMIC_SET(S, M, T)                                  \
    inline static void                                                      \
    machine_memory_atomic_set_##S(volatile M *v, T val)                     \
    {                                                                       \
        machine_memory_fence_strict_store ();                               \
        *v = val;                                                           \
    }

MACHINE_MEMORY_ATOMIC_SET(ptr,    void*,        void*)
MACHINE_MEMORY_ATOMIC_SET(char,   char,         char)
MACHINE_MEMORY_ATOMIC_SET(int,    int,          int)
MACHINE_MEMORY_ATOMIC_SET(uint,   unsigned int, unsigned int)
MACHINE_MEMORY_ATOMIC_SET(double, double,       double)
MACHINE_MEMORY_ATOMIC_SET(64,     guint64,      guint64)
MACHINE_MEMORY_ATOMIC_SET(32,     guint32,      guint32)
MACHINE_MEMORY_ATOMIC_SET(16,     guint16,      guint16)
MACHINE_MEMORY_ATOMIC_SET(8,      guint8,       guint8)

#undef MACHINE_MEMORY_ATOMIC_SET

#define MACHINE_MEMORY_ATOMIC_GET(S, M, T)                                  \
    inline static T                                                         \
    machine_memory_atomic_get_##S(volatile M *v)                            \
    {                                                                       \
        machine_memory_fence_strict_load ();                                \
        return (T)*v;                                                       \
    }

MACHINE_MEMORY_ATOMIC_GET(ptr,    void*,        void*)
MACHINE_MEMORY_ATOMIC_GET(char,   char,         char)
MACHINE_MEMORY_ATOMIC_GET(int,    int,          int)
MACHINE_MEMORY_ATOMIC_GET(uint,   unsigned int, unsigned int)
MACHINE_MEMORY_ATOMIC_GET(double, double,       double)
MACHINE_MEMORY_ATOMIC_GET(64,     guint64,      guint64)
MACHINE_MEMORY_ATOMIC_GET(32,     guint32,      guint32)
MACHINE_MEMORY_ATOMIC_GET(16,     guint16,      guint16)
MACHINE_MEMORY_ATOMIC_GET(8,      guint8,       guint8)

#undef MACHINE_MEMORY_ATOMIC_GET

#endif /* __MACHINE_H__ */
