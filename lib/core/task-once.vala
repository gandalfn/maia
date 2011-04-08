/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * task-once.vala
 * Copyright (C) Nicolas Bruguier 2010-2011 <gandalfn@club-internet.fr>
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

public class Maia.TaskOnce : Task
{
    // types
    public delegate void Callback ();

    // properties
    private Callback m_Callback;

    // methods
    public TaskOnce (Callback inCallback, Task.Priority inPriority = Priority.NORMAL, bool inThread = false)
    {
        base (inPriority, inThread);
        m_Callback = inCallback;
    }

    internal override void*
    main ()
    {
        void* ret = base.main ();

        m_Callback ();

        finish ();

        return ret;
    }
}