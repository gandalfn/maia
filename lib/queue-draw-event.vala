/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * queue-draw-event.vala
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

public class Maia.QueueDrawEventArgs : EventArgs
{
    // properties
    private Region          m_Area;
    private unowned Window? m_Window;

    // accessors
    public Region area {
        get {
            return m_Area; 
        }
    }

    public unowned Window? window {
        get {
            return m_Window;
        }
    }

    // methods
    public QueueDrawEventArgs (Window? inWindow, Region inArea)
    {
        m_Window = inWindow;
        m_Area = inArea;
    }
}

public class Maia.QueueDrawEvent : Event<QueueDrawEventArgs>
{
    // methods
    public QueueDrawEvent (Workspace inWorkspace)
    {
        base ("queue-draw", inWorkspace);
    }
}