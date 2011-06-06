/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * desktop.vala
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

public class Maia.Desktop : Object
{
    // types
    [Compact]
    public class Iterator
    {
        internal Desktop m_Desktop;
        internal int m_Index;

        internal Iterator (Desktop inDesktop)
        {
            m_Desktop = inDesktop;
            m_Index = -1;
        }

        public bool
        next ()
        {
            bool ret = false;
            int nb_items = m_Desktop.nb_childs;

            if (m_Index == -1 && nb_items > 0)
            {
                m_Index = 0;
                ret = true;
            }
            else if (m_Index < nb_items)
            {
                m_Index++;
                ret = m_Index < nb_items;
            }

            return ret;
        }

        public unowned Workspace?
        get ()
        {
            return (Workspace)m_Desktop.get_child_at (m_Index);
        }
    }

    // properties
    private unowned DesktopProxy m_Proxy;

    // accessors
    public unowned DesktopProxy proxy {
        get {
            return m_Proxy;
        }
    }

    public int nb_workspaces {
        get {
            return nb_childs;
        }
    }

    public unowned Workspace? default_workspace {
        get {
            return m_Proxy.default_workspace;
        }
    }

    // methods
    construct
    {
        m_Proxy = delegate_cast<DesktopProxy> ();
    }

    internal override bool 
    can_append_child (Object inChild)
    {
        return inChild is Workspace;
    }

    internal override string
    to_string ()
    {
        return m_Proxy.to_string ();
    }

    public new unowned Workspace?
    @get (int inNumWorkspace)
    {
        return (Workspace)get_child_at (inNumWorkspace);
    }

    public new Iterator
    iterator ()
    {
        return new Iterator (this);
    }
}