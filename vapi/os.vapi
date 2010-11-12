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
    int clock_gettime (int inClockId, TimeSpec inTimerSpec);

    [CCode (cname = "struct itimerspec")]
    public struct ITimerSpec
    {
        public TimeSpec it_interval;
        public TimeSpec it_value;
    }

    [CCode (cname = "struct timespec")]
    public struct TimeSpec
    {
        time_t tv_sec;
        long tv_nsec;
    }

    [CCode (cname = "int", cprefix = "timerfd_")]
    public struct TimerFd : int
    {
        [CCode (cname = "timerfd_create")]
        public TimerFd (int inClockId, int inFlags);
        public int settime (int inFlags, ITimerSpec inNewValue, out ITimerSpec? outOldValue);
        public int gettime (out ITimerSpec outCurrentValue);
    }

    public const int32 CLOCK_MONOTONIC;
    public const int32 TFD_CLOEXEC;

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
        public int32 fd;
        public uint32 u32;
        public uint64 u64;
    }

    [CCode (cname = "struct epoll_event")]
    public struct EPollEvent
    {
        public uint32 events;
        public EPollData data;
    }

    public const int32 EPOLL_CLOEXEC;
    public const int32 EPOLL_CTL_ADD;
    public const int32 EPOLL_CTL_MOD;
    public const int32 EPOLL_CTL_DEL;
    public const int32 EPOLLIN;
    public const int32 EPOLLOUT;
}