/* -*- Mode: C; indent-tabs-mode: null; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * os.h
 * Copyright (C) Nicolas Bruguier 2009 <gandalfn@club-internet.fr>
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

#ifndef __OS_H__
#define __OS_H__

#define os_cpu_relax()                          __asm__ __volatile__("rep; nop" ::: "memory");

#define os_memory_barrier()                     __sync_synchronize()

#define os_atomic_get(P)                        ({ os_memory_barrier(); *(P); })
#define os_atomic_set(P, V)                     ({ *(P) = V; os_memory_barrier(); })
#define os_atomic_fetch_and_add(P, V)           ({ __sync_fetch_and_add((P), (V)); })
#define os_atomic_compare_and_exchange(P, O, N) ({ __sync_bool_compare_and_swap((P), (O), (N)); })
#define os_atomic_inc(P)                        ({ __sync_add_and_fetch((P), 1); })
#define os_atomic_dec(P)                        ({ __sync_add_and_fetch((P), -1); }) 
#define os_atomic_add(P, V)                     ({ __sync_add_and_fetch((P), (V)); })
#define os_atomic_compare(P, V)                 ({ os_atomic_get(P) == (V); })
#define os_atomic_cast_ushort(P)                (volatile gushort*)P
#define os_atomic_cast_short(P)                 (volatile gshort*)P
#define os_atomic_cast_uint(P)                  (volatile guint*)P
#define os_atomic_cast_int(P)                   (volatile gint*)P
#define os_atomic_cast_ulong(P)                 (volatile gulong*)P
#define os_atomic_cast_long(P)                  (volatile glong*)P
#define os_atomic_cast_pointer(P)               (volatile gpointer*)P


static inline void*
os_atomic_exchange_64(void *ptr, void *x)
{
    __asm__ __volatile__("xchgq %0,%1"
                         :"=r" ((unsigned long long) x)
                         :"m" (*(volatile long long *)ptr), "0" ((unsigned long long) x)
                         :"memory");

    return x;
}

static inline unsigned
os_atomic_exchange_32(void *ptr, unsigned x)
{
    __asm__ __volatile__("xchgl %0,%1"
                         :"=r" ((unsigned) x)
                         :"m" (*(volatile unsigned *)ptr), "0" (x)
                         :"memory");

    return x;
}

static inline unsigned short
os_atomic_exchange_16(void *ptr, unsigned short x)
{
    __asm__ __volatile__("xchgw %0,%1"
                         :"=r" ((unsigned short) x)
                         :"m" (*(volatile unsigned short *)ptr), "0" (x)
                         :"memory");

    return x;
}

static inline char
os_atomic_bitsetandtest(void *ptr, int x)
{
    char out;
    __asm__ __volatile__("lock; bts %2,%1\n"
                         "sbb %0,%0\n"
                         :"=r" (out), "=m" (*(volatile long long *)ptr)
                         :"Ir" (x)
                         :"memory");

    return out;
}

#endif /* __OS_H__ */