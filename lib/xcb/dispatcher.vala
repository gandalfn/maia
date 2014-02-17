/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * dispatcher.vala
 * Copyright (C) Nicolas Bruguier 2010-2014 <gandalfn@club-internet.fr>
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

internal class Maia.Xcb.Dispatcher : Core.Object
{
    // properties
    private global::Xcb.Connection m_Connection;
    private int                    m_DefaultScreen;
    private Core.Timeline          m_Timeline;
    private ConnectionWatch        m_Watch;

    // accessors
    public global::Xcb.Connection connection {
        get {
            return m_Connection;
        }
    }

    public int default_screen {
        get {
            return m_DefaultScreen;
        }
    }

    // methods
    public Dispatcher (string? inDisplay = null)
    {
        GLib.Object (id: inDisplay != null ? GLib.Quark.from_string (inDisplay) : 0);

        m_Connection = new global::Xcb.Connection (inDisplay, out m_DefaultScreen);
        m_Watch = new ConnectionWatch (m_Connection);
        m_Timeline = new Core.Timeline (60, 60);
        m_Timeline.loop = true;
        m_Timeline.new_frame.connect (on_new_frame);
    }

    private void
    on_new_frame (int inFrameNum)
    {
        Core.List<unowned Window> list = new Core.List<unowned Window> ();
        foreach (unowned Core.Object child in this)
        {
            unowned Window window = child as Window;
            if (window.visible && window.surface != null)
            {
                list.insert (window);
                Graphic.Context ctx = window.surface.context;
                window.update (ctx, new Graphic.Region (Graphic.Rectangle (0, 0, window.size.width, window.size.height)));
            }
        }
        m_Connection.flush ();

        foreach (unowned Window window in list)
        {
            Graphic.Context ctx = window.surface.context;
            window.draw (ctx, new Graphic.Region (Graphic.Rectangle (0, 0, window.size.width, window.size.height)));
        }
    }

    internal override bool
    can_append_child (Core.Object inChild)
    {
        return inChild is Window;
    }
}
