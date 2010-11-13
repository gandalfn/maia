/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-observer.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
 * 
 * libmaia is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * maiawm is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public class Maia.Observer
{
    // types
    [CCode (has_target = false)]
    public delegate void ActionFunc (void* inTarget, Notification inNotification, Args inArgs);

    public abstract class Args
    {
    }

    // Properties
    internal ActionFunc   m_Func;
    internal void*        m_pTarget;

    // Methods
    public Observer (ActionFunc inFunc, void* inTarget)
    {
        m_Func = inFunc;
        m_pTarget = inTarget;
    }

    internal void
    notify (Notification inNotification, Args? inArgs = null)
    {
        m_Func (m_pTarget, inNotification, inArgs);
    }

    internal bool
    equals (Observer inOther)
    {
        return m_Func == inOther.m_Func && m_pTarget == inOther.m_pTarget;
    }
}