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
            m_Index = 0;
        }

        public bool
        next ()
        {
            m_Index++;
            return m_Index < m_Desktop.childs.nb_items;
        }

        public unowned Workspace?
        get ()
        {
            return m_Desktop.childs.at (m_Index) as Workspace;
        }
    }

    // accessors
    public override GLib.Type object_type {
        get {
            return typeof (Desktop);
        }
    }

    public int nb_workspaces {
        get {
            return childs.nb_items;
        }
    }

    public Workspace default_workspace {
        get {
            return  delegate_cast<DesktopProxy> ().default_workspace;
        }
    }

    // methods
    public Desktop ()
    {
    }

    public override bool 
    can_append_child (Object inChild)
    {
        return inChild is Workspace; 
    }

    public new Workspace?
    @get (int inNumWorkspace)
    {
        return childs.at (inNumWorkspace) as Workspace;
    }

    public Iterator
    iterator ()
    {
        return new Iterator (this);
    }
}