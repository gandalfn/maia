/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * visibility-event-args.vala
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

public class Maia.VisibilityEventArgs : Maia.Core.EventArgs
{
    // properties
    private bool m_Visible;

    // accessors
    public override GLib.Variant serialize {
        owned get {
            return new GLib.Variant ("(b)", m_Visible);
        }
        set {
            if (value != null)
            {
                value.get ("(b)", out m_Visible);
            }
            else
            {
                m_Visible = false;
            }
        }
    }

    public bool visible {
        get {
            return m_Visible;
        }
    }

    // methods
    public VisibilityEventArgs (bool inVisible)
    {
        base ();

        m_Visible = inVisible;
    }

    public override void
    accumulate (Core.EventArgs inArgs)
    {
        m_Visible |= ((VisibilityEventArgs)inArgs).m_Visible;
    }
}
