/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * delete-event-args.vala
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

public class Maia.Xcb.DeleteEventArgs : Maia.DeleteEventArgs
{
    // properties
    private unowned global::Xcb.Window m_Window;

    // accessors
    public override GLib.Variant serialize {
        owned get {
            return new GLib.Variant ("(vu)", base.serialize, m_Window);
        }
        set {
            if (value != null)
            {
                GLib.Variant val;
                value.get ("(vu)", out val, out m_Window);
                base.serialize = val;
            }
            else
            {
                cancel = false;
            }
        }
    }

    public global::Xcb.Window window {
        get {
            return m_Window;
        }
    }

    // methods
    public DeleteEventArgs (global::Xcb.Window inWindow)
    {
        base ();
        m_Window = inWindow;
    }

    public override void
    accumulate (Core.EventArgs inArgs)
    {
        if (m_Window == ((DeleteEventArgs)inArgs).m_Window)
        {
            base.accumulate (inArgs);
        }
    }
}
