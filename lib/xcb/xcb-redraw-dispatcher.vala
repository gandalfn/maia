/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-redraw-dispatcher.vala
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

internal class Maia.XcbRedrawDispatcher : Object
{
    // properties
    private unowned Workspace m_Workspace = null;
    private TicTac            m_RefreshTicTac = null;
    private bool              m_NeedRedraw = true;

    // accessors
    public override Object parent {
        get {
            return base.parent;
        }
        construct set {
            base.parent = value;
            if (m_RefreshTicTac != null)
                m_RefreshTicTac.parent = value;

            if (m_Workspace != null)
                m_Workspace.queue_draw_event.listen (on_queue_draw, ((Dispatcher)value));
        }
    }

    // methods
    public XcbRedrawDispatcher (Workspace inWorkspace)
    {
        // Get workspace
        m_Workspace = inWorkspace;

        // Create redraw timeline
        m_RefreshTicTac = new TicTac (60);
        m_RefreshTicTac.bell.watch (on_refresh);
        m_RefreshTicTac.end_bell.watch (on_end_refresh);
    }

    private bool
    on_refresh ()
    {
        audit (GLib.Log.METHOD, "refresh");

        m_NeedRedraw = false;

        return true;
    }

    private void
    on_end_refresh ()
    {
        if (!m_NeedRedraw)
            m_RefreshTicTac.sleep ();
    }

    private void
    on_queue_draw (QueueDrawEventArgs inArgs)
    {
        if (!m_NeedRedraw)
        {
            m_NeedRedraw = true;
            m_RefreshTicTac.wakeup ();
        }
    }
}