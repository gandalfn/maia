/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * mouse-event-args.vala
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

public class Maia.MouseEventArgs : Maia.Core.EventArgs
{
    // type
    [Flags]
    public enum EventFlags
    {
        BUTTON_PRESS    = 1 << 0,
        BUTTON_RELEASE  = 1 << 1,
        MOTION          = 1 << 2
    }

    // properties
    private uint8         m_EventFlags;
    private uint8         m_Button;
    private Graphic.Point m_Position;

    // accessors
    public override GLib.Variant serialize {
        owned get {
            return new GLib.Variant ("(yydd)", m_EventFlags, m_Button, m_Position.x, m_Position.y);
        }
        set {
            if (value != null)
            {
                double x, y;
                value.get ("(yydd)", out m_EventFlags, out m_Button, out x, out y);
                m_Position = Graphic.Point (x, y);
            }
            else
            {
                m_EventFlags = 0;
                m_Button = 0;
                m_Position = Graphic.Point (0, 0);
            }
        }
    }

    public uint8 flags {
        get {
            return m_EventFlags;
        }
    }

    public uint8 button {
        get {
            return m_Button;
        }
    }

    public Graphic.Point position {
        get {
            return m_Position;
        }
    }

    // methods
    public MouseEventArgs (uint8 inEventFlags, uint8 inButton, double inX, double inY)
    {
        base ();

        m_EventFlags = inEventFlags;
        m_Button = inButton;
        m_Position = Graphic.Point (inX, inY);
    }
}
