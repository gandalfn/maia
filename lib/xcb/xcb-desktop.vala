/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xcb-desktop.vala
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

internal class Maia.XcbDesktop : DesktopProxy
{
    // properties
    private Xcb.Connection m_Connection       = null;
    private int            m_DefaultScreenNum = 0;

    // accessors
    public Xcb.Connection connection {
        get {
            return m_Connection;
        }
    }

    public override string id {
        get {
            return base.id;
        }
        set {
            if (m_Connection == null)
            {
                // Open connection
                m_Connection = new Xcb.Connection(value, out m_DefaultScreenNum);
                if (m_Connection == null)
                {
                    error ("Error on open display %s", value);
                }

                int nbScreens = m_Connection.get_setup().roots_length();
                if (nbScreens <= 0)
                {
                    error ("Error on create screen list %s", value);
                }

                int cpt = 0;
                for (Xcb.ScreenIterator iter = m_Connection.get_setup().roots_iterator(); 
                     iter.rem != 0; Xcb.ScreenIterator.next(out iter), ++cpt)
                {
                    Workspace workspace = new Workspace (delegator as Desktop);
                    WorkspaceProxy proxy = workspace.delegate_cast<WorkspaceProxy> ();
                    (proxy as XcbWorkspace).num = cpt;
                    (proxy as XcbWorkspace).xcb_screen = iter.data;
                }

                base.id = value;
            }
        }
    }

    public override Workspace default_workspace {
        get {
            return childs.at (m_DefaultScreenNum) as Workspace;
        }
    }

    // methods
}
