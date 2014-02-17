/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * window.vala
 * Copyright (C) Nicolas Bruguier 2010-2013 <gandalfn@club-internet.fr>
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

public class Maia.Window : Group
{
    // properties
    private Core.Event m_MouseEvent;
    private Core.Event m_KeyboardEvent;

    // accessors
    public override string tag {
        get {
            return "Window";
        }
    }

    public virtual Graphic.Surface? surface {
        get {
            return null;
        }
    }

    public Core.Event mouse_event {
        get {
            return m_MouseEvent;
        }
    }

    public Core.Event keyboard_event {
        get {
            return m_KeyboardEvent;
        }
    }

    // methods
    construct
    {
        m_MouseEvent    = new Core.Event ("mouse",    ((int)id).to_pointer ());
        m_KeyboardEvent = new Core.Event ("keyboard", ((int)id).to_pointer ());
    }

    /**
     * Create a new window
     */
    public Window (string inName, int inWidth, int inHeight)
    {
        GLib.Object (id: GLib.Quark.from_string (inName), size: Graphic.Size (inWidth, inHeight));
    }
}
