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

    // methods
    construct
    {
        notifications.add (new Notification ("closed"));
    }

    /**
     * Create a new Socket watcher
     *
     * @param inSocket socket to watch
     * @param inCondition condition to watch
     * @param inContext main context
     * @param inPriority watch priority
     */
    public SocketWatch (GLib.Socket inSocket, Watch.Condition inCondition = Watch.Condition.IN, GLib.MainContext? inContext = GLib.MainContext.get_thread_default (), int inPriority = GLib.Priority.HIGH)
    {
        base (inSocket.fd, inCondition, inContext, inPriority);
        m_Socket = inSocket;
    }

    ~SocketWatch ()
    {
        m_Socket.close ();
    }

    /**
     * {@inheritDoc}
     */
    internal override void
    on_error ()
    {
        notifications["closed"].post ();
    }

    /**
     * {@inheritDoc}
     */
    internal override bool
    check ()
    {
        var status = m_Socket.condition_check (GLib.IOCondition.OUT | GLib.IOCondition.IN | GLib.IOCondition.PRI | GLib.IOCondition.HUP | GLib.IOCondition.ERR | GLib.IOCondition.NVAL);

        if ((GLib.IOCondition.ERR in status) || (GLib.IOCondition.HUP in status) || (GLib.IOCondition.NVAL in status))
        {
            on_error ();

            return false;
        }

        if (condition == Watch.Condition.OUT)
        {
            return GLib.IOCondition.OUT in status;
        }

        return ((GLib.IOCondition.IN in status) || (GLib.IOCondition.PRI in status));
    }

    /**
     * {@inheritDoc}
     */
    internal override bool
    on_process ()
    {
        bool ret = base.on_process ();

        return !m_Socket.is_closed () && ret;
    }
}
