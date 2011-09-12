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

    // emulate gettid(2) for which no glib wrapper exists via syscall
    public GLib.Pid gettid() {
        return (GLib.Pid) syscall( SysCall.gettid );
    }

    // syscall(2)
    [CCode (cprefix = "SYS_", has_type_id = false, cname = "int")]
    public enum SysCall {
        gettid
    }

    [CCode (cname = "syscall", cheader_filename = "unistd.h,sys/syscall.h")]
    public int syscall (int number, ...);

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
        [CCode (cname = "volatile gushort")]
        public struct UShort
        {
            [CCode (cname = "os_atomic_get")]
            public ushort get ();
            [CCode (cname = "os_atomic_set")]
            public void set (ushort inVal);
            [CCode (cname = "os_atomic_fetch_and_add")]
            public ushort fetch_and_add (ushort val);
            [CCode (cname = "os_atomic_inc")]
            public ushort inc ();
            [CCode (cname = "os_atomic_dec")]
            public ushort dec ();
            [CCode (cname = "os_atomic_compare")]
            public bool compare (ushort inVal);
            [CCode (cname = "os_atomic_compare_and_exchange")]
            public bool compare_and_exchange (ushort inOld, ushort inVal);
            [CCode (cname = "os_atomic_cast_ushort")]
            public static unowned UShort? cast (void* inpVal);
        }

        [CCode (cname = "volatile gshort")]
        public struct Short
        {
            [CCode (cname = "os_atomic_get")]
            public short get ();
            [CCode (cname = "os_atomic_set")]
            public void set (short inVal);
            [CCode (cname = "os_atomic_fetch_and_add")]
            public short fetch_and_add (short val);
            [CCode (cname = "os_atomic_inc")]
            public short inc ();
            [CCode (cname = "os_atomic_dec")]
            public short dec ();
            [CCode (cname = "os_atomic_compare")]
            public bool compare (short inVal);
            [CCode (cname = "os_atomic_compare_and_exchange")]
            public bool compare_and_exchange (short inOld, short inVal);
            [CCode (cname = "os_atomic_cast_short")]
            public static unowned Short? cast (void* inpVal);
        }

        [CCode (cname = "volatile guint")]
        public struct UInt
        {
            [CCode (cname = "os_atomic_get")]
            public uint get ();
            [CCode (cname = "os_atomic_set")]
            public void set (uint inVal);
            [CCode (cname = "os_atomic_fetch_and_add")]
            public uint fetch_and_add (uint val);
            [CCode (cname = "os_atomic_inc")]
            public uint inc ();
            [CCode (cname = "os_atomic_dec")]
            public uint dec ();
            [CCode (cname = "os_atomic_compare")]
            public bool compare (uint inVal);
            [CCode (cname = "os_atomic_compare_and_exchange")]
            public bool compare_and_exchange (uint inOld, uint inVal);
            [CCode (cname = "os_atomic_cast_uint")]
            public static unowned UInt? cast (void* inpVal);
        }

        [CCode (cname = "volatile gint")]
        public struct Int
        {
            [CCode (cname = "os_atomic_get")]
            public int get ();
            [CCode (cname = "os_atomic_set")]
            public void set (int inVal);
            [CCode (cname = "os_atomic_fetch_and_add")]
            public int fetch_and_add (int val);
            [CCode (cname = "os_atomic_inc")]
            public int inc ();
            [CCode (cname = "os_atomic_dec")]
            public int dec ();
            [CCode (cname = "os_atomic_compare")]
            public bool compare (int inVal);
            [CCode (cname = "os_atomic_compare_and_exchange")]
            public bool compare_and_exchange (int inOld, int inVal);
            [CCode (cname = "os_atomic_cast_int")]
            public static unowned Int? cast (void* inpVal);
        }

        [CCode (cname = "volatile gulong")]
        public struct ULong
        {
            [CCode (cname = "os_atomic_get")]
            public ulong get ();
            [CCode (cname = "os_atomic_set")]
            public void set (ulong inVal);
            [CCode (cname = "os_atomic_fetch_and_add")]
            public ulong fetch_and_add (ulong val);
            [CCode (cname = "os_atomic_inc")]
            public ulong inc ();
            [CCode (cname = "os_atomic_dec")]
            public ulong dec ();
            [CCode (cname = "os_atomic_compare")]
            public bool compare (ulong inVal);
            [CCode (cname = "os_atomic_compare_and_exchange")]
            public bool compare_and_exchange (ulong inOld, ulong inVal);
            [CCode (cname = "os_atomic_cast_ulong")]
            public static unowned ULong? cast (void* inpVal);
        }

        [CCode (cname = "volatile glong")]
        public struct Long
        {
            [CCode (cname = "os_atomic_get")]
            public long get ();
            [CCode (cname = "os_atomic_set")]
            public void set (long inVal);
            [CCode (cname = "os_atomic_fetch_and_add")]
            public long fetch_and_add (long val);
            [CCode (cname = "os_atomic_inc")]
            public long inc ();
            [CCode (cname = "os_atomic_dec")]
            public long dec ();
            [CCode (cname = "os_atomic_compare")]
            public bool compare (long inVal);
            [CCode (cname = "os_atomic_compare_and_exchange")]
            public bool compare_and_exchange (long inOld, long inVal);
            [CCode (cname = "os_atomic_cast_long")]
            public static unowned Long? cast (void* inpVal);
        }

        [CCode (cname = "volatile gpointer")]
        public struct Pointer
        {
            [CCode (cname = "os_atomic_get")]
            public void* get ();
            [CCode (cname = "os_atomic_set")]
            public void set (void* inVal);
            [CCode (cname = "os_atomic_fetch_and_add")]
            public void* fetch_and_add (void* val);
            [CCode (cname = "os_atomic_inc")]
            public void* inc ();
            [CCode (cname = "os_atomic_dec")]
            public void* dec ();
            [CCode (cname = "os_atomic_compare")]
            public bool compare (void* inVal);
            [CCode (cname = "os_atomic_compare_and_exchange")]
            public bool compare_and_exchange (void* inOld, void* inVal);
            [CCode (cname = "os_atomic_cast_pointer")]
            public static unowned Pointer? cast (void* inpVal);
        }
    }
}