/* -*- Mode: C; indent-tabs-mode: null; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * valgrind.vapi
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

[CCode (cprefix = "VALGRIND_", lower_case_cprefix = "VALGRIND_")]
namespace Valgrind
{
    [CCode (cprefix = "VALGRIND_HG_", lower_case_cprefix = "VALGRIND_HG_", cheader_filename="valgrind/helgrind.h")]
    namespace Helgrind
    {
        [CCode (cname="VALGRIND_HG_MUTEX_INIT_POST")]
        public static void mutex_init_post (void* _mutex, long _mbRec);
        [CCode (cname="VALGRIND_HG_MUTEX_LOCK_PRE")]
        public static void mutex_lock_pre (void* _mutex, long _isTryLock);
        [CCode (cname="VALGRIND_HG_MUTEX_LOCK_POST")]
        public static void mutex_lock_post (void* _mutex);
        [CCode (cname="VALGRIND_HG_MUTEX_UNLOCK_PRE")]
        public static void mutex_unlock_pre (void* _mutex);
        [CCode (cname="VALGRIND_HG_MUTEX_UNLOCK_POST")]
        public static void mutex_unlock_post (void* _mutex);
        [CCode (cname="VALGRIND_HG_MUTEX_DESTROY_PRE")]
        public static void mutex_destroy_pre (void* _mutex);

        [CCode (cname="ANNOTATE_RWLOCK_CREATE")]
        public static void rwlock_create (void* _lock);
        [CCode (cname="ANNOTATE_RWLOCK_DESTROY")]
        public static void rwlock_destroy (void* _lock);
        [CCode (cname="ANNOTATE_RWLOCK_ACQUIRED")]
        public static void rwlock_acquired (void* _lock, ulong is_w);
        [CCode (cname="ANNOTATE_RWLOCK_RELEASED")]
        public static void rwlock_released (void* _lock, ulong is_w);
    }
}
