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
    // types
    private enum RequestQueue
    {
        QUERY,
        COMMIT,
        N
    }

    // properties
    private Xcb.Connection    m_Connection       = null;
    private int               m_DefaultScreenNum = 0;

    private XcbAtoms          m_Atoms            = null;

    private Queue<unowned XcbRequest?> m_Requests[2];

    // accessors
    public Xcb.Connection connection {
        get {
            return m_Connection;
        }
    }

    public override Workspace default_workspace {
        get {
            return (Workspace)get_child_at (m_DefaultScreenNum);
        }
    }

    public XcbAtoms atoms {
        get {
            return m_Atoms;
        }
    }

    // methods
    construct
    {
        // Create request queue
        for (int cpt = 0; cpt < RequestQueue.N; ++cpt)
        {
            m_Requests[cpt] = new Queue<unowned XcbRequest?> (); 
        }

        // Get name
        string? name = Atom.to_string (id);

        // Open connection
        m_Connection = new Xcb.Connection(name, out m_DefaultScreenNum);
        if (m_Connection == null)
        {
            error ("Error on open display %s", name);
        }
        m_Connection.prefetch_maximum_request_length ();

        // Get atoms
        m_Atoms = new XcbAtoms (this);

        // Create screen collection
        int nbScreens = m_Connection.get_setup().roots_length();
        if (nbScreens <= 0)
        {
            error ("Error on create screen list %s", name);
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
    }

    public override string
    to_string ()
    {
        string ret = "";

        foreach (Object child in this)
        {
            ret += child.to_string ();
        }

        return ret;
    }

    public void
    add_request (XcbRequest inRequest)
    {
        Token token = Token.get_for_class (m_Requests);
        switch (inRequest.state)
        {
            case XcbRequest.State.QUERYING:
                m_Requests[RequestQueue.QUERY].push (inRequest);
                break;

            case XcbRequest.State.COMMITING:
                m_Requests[RequestQueue.COMMIT].push (inRequest);
                break;
        }
        token.release ();
    }

    public void
    remove_request (XcbRequest inRequest)
    {
        Token token = Token.get_for_class (m_Requests);
        for (int cpt = 0; cpt < RequestQueue.N; ++cpt)
        {
            m_Requests[cpt].remove (inRequest);
        }
        token.release ();
    }

    public void
    flush ()
    {
        unowned XcbRequest? request = null;

        Token token_requests = Token.get_for_class (m_Requests);
        while ((request = m_Requests[RequestQueue.COMMIT].pop ()) != null)
        {
            Token token = Token.get_for_object (request);
            request.process ();
            token.release ();
        }

        m_Connection.flush ();

        while ((request = m_Requests[RequestQueue.QUERY].pop ()) != null)
        {
            Token token = Token.get_for_object (request);
            if (request.state == XcbRequest.State.QUERYING)
                request.process ();
            token.release ();
        }
        token_requests.release ();
    }
}
