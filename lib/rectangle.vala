/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * rectangle.vala
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

public class Maia.Rectangle : Item, ItemMovable, ItemResizable, ItemFocusable
{
    // properties
    private FocusGroup m_FocusGroup = null;

    // accessors
    internal override string tag {
        get {
            return "Rectangle";
        }
    }

    internal bool can_focus  {
        get {
            return parent is DrawingArea;
        }
        set {
        }
    }
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

    // static methods
    static construct
    {
        // Ref FocusGroup class to register focus group transform
        typeof (FocusGroup).class_ref ();
    }

    // methods
    public Rectangle (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        var path = new Graphic.Path.from_region (area);

        inContext.line_width = line_width;

        if (fill_pattern[state] != null)
        {
            inContext.pattern = fill_pattern[state];
            inContext.fill (path);
        }

        if (stroke_pattern[state] != null)
        {
            inContext.pattern = stroke_pattern[state];
            inContext.stroke (path);
        }
    }
}
