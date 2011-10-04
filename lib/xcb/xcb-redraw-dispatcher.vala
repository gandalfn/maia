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
    private Region            m_DamagedArea = null;
    private Set<uint32>       m_DamagedWindow = null;

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

        // Create damaged window queue
        m_DamagedWindow = new Set<uint32> ();

        // Create redraw timeline
        m_RefreshTicTac = new TicTac (60);
        m_RefreshTicTac.bell.watch (on_refresh);
        m_RefreshTicTac.end_bell.watch (on_end_refresh);
    }

    private bool
    on_refresh ()
    {
        if (m_DamagedArea != null)
        {
            audit (GLib.Log.METHOD, "refresh %s", m_DamagedArea.to_string ());

            m_DamagedWindow.iterator ().foreach ((id) => {
                unowned Window? window = (Window)m_Workspace[id];
                if (window != null)
                {
                    ((XcbWindow)window.proxy).swap_buffer (m_DamagedArea);
                }
                else
                {
                    m_Workspace.iterator ().foreach ((child) => {
                        window = (Window)child[id];
                        if (window != null)
                        {
                            ((XcbWindow)window.proxy).swap_buffer (m_DamagedArea);
                            return false;
                        }
                        return true;
                    });
                }
                return true;
            });
        }
        m_DamagedWindow.clear ();
        m_DamagedArea = null;

        return true;
    }

    private void
    on_end_refresh ()
    {
        if (m_DamagedArea == null)
            m_RefreshTicTac.sleep ();
    }

    private void
    on_queue_draw (QueueDrawEventArgs inArgs)
    {
        audit (GLib.Log.METHOD, "");
        if (inArgs.window != null)
            m_DamagedWindow.insert (inArgs.window.id);

        if (m_DamagedArea == null)
        {
            m_DamagedArea = inArgs.area;
        }
        else
        {
            m_DamagedArea.union (inArgs.area);
        }

        on_refresh ();
        if (false && m_RefreshTicTac.state == Task.State.SLEEPING)
        {
            m_RefreshTicTac.wakeup ();
        }
    }
}