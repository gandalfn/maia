/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * socket-watch.vala
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

public class Maia.Core.SocketWatch : Watch
{
    // properties
    private GLib.Socket m_Socket;

    // signals
    public signal void ready ();
    public signal void closed ();

    // methods
    /**
     * Create a new Socket watcher
     *
     * @param inSocket socket to watch
     * @param inPriority watch priority
     */
    public SocketWatch (GLib.Socket inSocket, GLib.MainContext? inContext = null, int inPriority = GLib.Priority.HIGH)
    {
        base (inSocket.fd, inContext, inPriority);
        m_Socket = inSocket;
    }

    /**
     * Create a new Socket watcher
     *
     * @param inSocket socket to watch
     * @param inPriority watch priority
     */
    public SocketWatch.out (GLib.Socket inSocket, GLib.MainContext? inContext = null, int inPriority = GLib.Priority.HIGH)
    {
        base.out (inSocket.fd, inContext, inPriority);
        m_Socket = inSocket;
    }

    ~SocketWatch ()
    {
        m_Socket.close ();
    }

    /**
     * Called when an error occur on fd
     */
    protected override void
    on_error ()
    {
        closed ();
    }

    /**
     * Called when a data has been available on fd
     */
    protected override bool
    on_process ()
    {
        ready ();

        return !m_Socket.is_closed ();
    }
}
