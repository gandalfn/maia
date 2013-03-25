/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * application.vala
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

namespace Maia
{
    [CCode (cname = "maia_xcb_create_application")]
    internal extern Maia.Application xcb_create_application (string[] inArgs);
}

public class Maia.Application : Object
{
    // static properties
    static Application s_Default;

    // properties
    private Dispatcher m_Dispatcher;

    // accessors
    /**
     * The default application object
     */
    public static unowned Application? default {
        get {
            return s_Default;
        }
    }

    /**
     * Main dispatcher associated to application
     */
    public Dispatcher dispatcher {
        get {
            return m_Dispatcher;
        }
    }

    /**
     * The default workspace
     */
    public virtual unowned Workspace? default_workspace {
        get {
            return null;
        }
    }

    // static methods
    static construct
    {
        s_Default = null;
    }

    /**
     * Create the application
     *
     * @param inArgs command line arguments
     */
    public static void
    init (string[] inArgs)
    {
        if (s_Default == null)
        {
            s_Default = xcb_create_application (inArgs);

            Maia.Manifest.Element.register ("Label", typeof (Maia.Label));
        }
    }

    /**
     * Run application
     */
    public static void
    run ()
    {
        s_Default.m_Dispatcher.run ();
    }

    /**
     * Quit application
     */
    public static void
    quit ()
    {
        s_Default.m_Dispatcher.stop ();
    }

    // methods
    construct
    {
        m_Dispatcher = new Dispatcher ();
        m_Dispatcher.finished.connect (on_dispatcher_finished);
    }

    private void
    on_dispatcher_finished ()
    {
        if (this == s_Default)
            s_Default = null;
    }

    internal override bool
    can_append_child (Object inChild)
    {
        return inChild is Workspace;
    }

    /**
     * Get the inNumWorkspace workspace
     *
     * @param inNumWorkspace workspace number
     *
     * @return the workspace corresponding to inNumWorkspace
     */
    public new unowned Workspace?
    @get (int inNumWorkspace)
    {
        int cpt = 0;

        foreach (unowned Object child in this)
        {
            if (cpt == inNumWorkspace)
            {
                return child as Workspace;
            }
            cpt++;
        }
        return null;
    }
}
