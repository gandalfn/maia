/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * shape.vala
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

public abstract class Maia.Shape : Item, ItemMovable, ItemResizable, ItemFocusable
{
    // types
    public enum Caliper
    {
        CROSS,
        TRIANGLE;

        public string
        to_string ()
        {
            switch (this)
            {
                case TRIANGLE:
                    return "triangle";
            }

            return "cross";
        }

        public static Caliper
        from_string (string inValue)
        {
            switch (inValue.down ())
            {
                case "triangle":
                    return TRIANGLE;
            }

            return CROSS;
        }

        public string
        to_path (Graphic.Size inSize)
        {
            switch (this)
            {
                case TRIANGLE:
                    return @"M $(inSize.width / 2.0),0 L $(inSize.width),$(inSize.height) L 0, $(inSize.height) L $(inSize.width / 2.0),0";
            }

            return @"M 0, 0 L $(inSize.width),$(inSize.height) M 0,$(inSize.height) L $(inSize.width),0";
        }
    }

    // properties
    private FocusGroup m_FocusGroup = null;

    // accessors
    internal bool can_focus   { get; set; default = true; }
    internal bool have_focus  { get; set; default = false; }
    internal int  focus_order { get; set; default = -1; }
    internal FocusGroup focus_group {
        get {
            return m_FocusGroup;
        }
        set {
            if (m_FocusGroup != null)
            {
                m_FocusGroup.remove (this);
            }

            m_FocusGroup = value;

            if (m_FocusGroup != null)
            {
                m_FocusGroup.add (this);
            }
        }
        default = null;
    }

    public double border { get; set; default = 8; }

    public Caliper caliper { get; set; default = Caliper.CROSS; }

    public Graphic.Size caliper_size { get; set; default = Graphic.Size (32, 32); }

    public double caliper_line_width { get; set; default = 1.0; }

    // static methods
    static construct
    {
        // Ref FocusGroup class to register focus group transform
        typeof (FocusGroup).class_ref ();
    }

    // methods
    construct
    {
        is_movable = false;
        is_resizable = false;
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }
}
