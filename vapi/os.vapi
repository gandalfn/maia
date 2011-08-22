/* -*- Mode: C; indent-tabs-mode: null; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * os.vapi
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

[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "sys/epoll.h,sys/timerfd.h,unistd.h")]
namespace Os
{
    public int dup (int fd);
    public int pipe ([CCode (array_length = false, null_terminated = false)] int[] pipefd);
    public ssize_t read (int fd, void* buf, size_t count);
    public ssize_t write (int fd, void* buf, size_t count);
    public int close (int fd);
    public uint usleep (uint useconds);

    public int clock_gettime (int inClockId, out TimeSpec inTimerSpec);

    [CCode (cname = "struct itimerspec")]
    public struct ITimerSpec
    {
        public TimeSpec it_interval;
        public TimeSpec it_value;
    }

    [CCode (cname = "struct timespec")]
    public struct TimeSpec
    {
        public time_t tv_sec;
        public long tv_nsec;
    }

    [CCode (cname = "int", cprefix = "timerfd_")]
    public struct TimerFd : int
    {
        [CCode (cname = "timerfd_create")]
        public TimerFd (int inClockId, int inFlags);
        public int settime (int inFlags, ITimerSpec inNewValue, out ITimerSpec? outOldValue);
        public int gettime (out ITimerSpec outCurrentValue);
    }

    public const int CLOCK_MONOTONIC;
    public const int TFD_CLOEXEC;

    [CCode (cname = "int", cprefix = "epoll_")]
    public struct EPoll : int
    {
        [CCode (cname = "epoll_create1")]
        public EPoll (int inFlags);

        public int wait (EPollEvent[] inEvents, int inTimeOut);
        public int ctl (int inOperation, int inFileDescriptor, EPollEvent? inoutEvent);
    }

    [CCode (cname = "epoll_data_t")]
    public struct EPollData
    {
        public void* ptr;
        public int fd;
        public uint32 u32;
        public uint64 u64;
    }

    [CCode (cname = "struct epoll_event")]
    public struct EPollEvent
    {
        public uint32 events;
        public EPollData data;
    }

    public const int EPOLL_CLOEXEC;
    public const int EPOLL_CTL_ADD;
    public const int EPOLL_CTL_MOD;
    public const int EPOLL_CTL_DEL;
    public const int EPOLLIN;
    public const int EPOLLOUT;
    public const int EPOLLERR;
    public const int EPOLLHUP;

    public delegate void* ThreadFunc ();

    [SimpleType]
    [CCode (cname = "pthread_t", cprefix = "pthread_", cheader_filename = "pthread.h")]
    public struct Thread
    {
        public static int create (out Thread outThread, ThreadAttr? inAttr, ThreadFunc inFunc);
        public static int exit (void* inRet);

        public int detach ();
        public int join (out void* outRetval);
    }

    [CCode (cname = "pthread_attr_t", cheader_filename = "pthread.h")]
    public struct ThreadAttr
    {
    }

    [CCode (cname = "pthread_spinlock_t", cprefix = "pthread_spin_", cheader_filename = "pthread.h")]
    public struct ThreadSpin
    {
        [CCode (cname = "pthread_spin_init")]
        public ThreadSpin (bool inPShared = false);

        public int lock ();
        public int trylock ();
        public int unlock ();
    }

    [CCode (cheader_filename = "os.h")]
    namespace Memory
    {
        [CCode (cname = "os_memory_barrier")]
        public static void barrier ();
    }

    [CCode (cheader_filename = "os.h")]
    namespace Cpu
    {
        [CCode (cname = "os_cpu_relax")]
        public static void relax ();
    }

    [CCode (cheader_filename = "os.h")]
    namespace Atomic
    {
        [CCode (cname = "os_atomic_fetch_and_add")]
        public static ushort ushort_fetch_and_add (ref ushort P, ushort val);
        [CCode (cname = "os_atomic_fetch_and_add")]
        public static int int_fetch_and_add (ref int P, int val);

        [CCode (cname = "os_atomic_inc")]
        public static ushort ushort_inc (ref ushort P);
        [CCode (cname = "os_atomic_inc")]
        public static int int_inc (ref int P);
        [CCode (cname = "os_atomic_dec")]
        public static ushort ushort_dec (ref ushort P);
        [CCode (cname = "os_atomic_dec")]
        public static int int_dec (ref int P);

        [CCode (cname = "os_atomic_compare_and_exchange")]
        public static bool uint_compare_and_exchange (uint* P, uint old, uint val);
        [CCode (cname = "os_atomic_compare_and_exchange")]
        public static bool int_compare_and_exchange (int* P, int old, int val);
        [CCode (cname = "os_atomic_compare_and_exchange")]
        public static bool pointer_compare_and_exchange (void** P, void* old, void* val);

        [CCode (cname = "os_atomic_compare")]
        public static bool ushort_compare (ushort a, ushort b);
        [CCode (cname = "os_atomic_compare")]
        public static bool int_compare (int a, int b);
        [CCode (cname = "os_atomic_compare")]
        public static bool pointer_compare (void* a, void* b);

        [CCode (cname = "os_atomic_exchange_32")]
        public static uint32 exchange_32 (ref uint32 P, uint32 val);
    }
}