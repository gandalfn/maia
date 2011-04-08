/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * reparent-window-event.vala
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

public class Maia.ReparentWindowEventArgs : EventArgs
{
    // accessors
    [CCode (notify = false)]
    public Window parent { get; private set; }
    [CCode (notify = false)]
    public Window window { get; private set; }

    // methods
    public ReparentWindowEventArgs (Window inParent, Window inWindow)
    {
        parent = inParent;
        window = inWindow;
    }
}

public class Maia.ReparentWindowEvent : Event<ReparentWindowEventArgs>
{
    // methods
    public ReparentWindowEvent (uint32 inId, void* inOwner)
    {
        base.with_id (inId, inOwner);
    }
}