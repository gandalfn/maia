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

    private XcbAtoms       m_Atoms            = null;
    private TaskOnce       m_FlushTask        = null;

    // accessors
    public Xcb.Connection connection {
        get {
            return m_Connection;
        }
    }

    [CCode (notify = false)]
    public override string name {
        get {
            return base.name;
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

                // Get atoms
                m_Atoms = new XcbAtoms (this);

                // Create screen collection
                int nbScreens = m_Connection.get_setup().roots_length();
                if (nbScreens <= 0)
                {
                    error ("Error on create screen list %s", value);
                }

                int cpt = 0;
                for (Xcb.ScreenIterator iter = m_Connection.get_setup().roots_iterator(); 
                     cpt < nbScreens; ++cpt, Xcb.ScreenIterator.next(ref iter))
                {
                    debug (GLib.Log.METHOD, "create xcb workspace %i", cpt);
                    Workspace workspace = new Workspace (delegator as Desktop);
                    XcbWorkspace proxy = workspace.delegate_cast<XcbWorkspace> ();
                    proxy.init (iter.data, cpt);
                }

                base.name = value;
            }
        }
    }

    public override Workspace default_workspace {
        get {
            return childs.at (m_DefaultScreenNum) as Workspace;
        }
    }

    public XcbAtoms atoms {
        get {
            return m_Atoms;
        }
    }

    // methods
    public void
    flush (bool inSync = false)
    {
        if (!inSync && m_FlushTask == null)
        {
            m_FlushTask = new TaskOnce (() => {
                m_Connection.flush ();
            });
            m_FlushTask.finished.connect (() => {
                m_FlushTask = null;
            });
            m_FlushTask.parent = Application.self;
        }
        else if (inSync)
        {
            m_Connection.flush ();
        }
    }
}
