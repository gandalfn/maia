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

public class Maia.DeleteEventArgs : Maia.Core.EventArgs
{
    // properties
    private bool m_Cancel = false;

    // accessors
    public override GLib.Variant serialize {
        owned get {
            return new GLib.Variant ("(b)", m_Cancel);
        }
        set {
            if (value != null)
            {
                value.get ("(b)", out m_Cancel);
            }
            else
            {
                m_Cancel = false;
            }
        }
    }

    public bool cancel {
        get {
            return m_Cancel;
        }
        set {
            m_Cancel = value;
        }
    }

    // methods
    public DeleteEventArgs ()
    {
        base ();
    }

    public override void
    accumulate (Core.EventArgs inArgs)
    {
        m_Cancel |= ((DeleteEventArgs)inArgs).m_Cancel;
    }
}
