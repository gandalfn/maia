/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * socket-bus-service.vala
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

public class Maia.Core.SocketBusService : BusService
{
    // properties
    private GLib.SocketService m_Socket;
    private ulong              m_ClientCount = 0;

    // methods
    public SocketBusService (string inName, BusAddress inAddress)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Create socket bus service %s", inName);

        base (inName, inAddress);

        m_Socket = new GLib.SocketService ();

        try
        {
            switch (inAddress.address_type)
            {
                case BusAddress.Type.UNIX:
                    m_Socket.add_address (new GLib.UnixSocketAddress.as_abstract (inAddress.hier, -1),
                                          GLib.SocketType.STREAM, GLib.SocketProtocol.DEFAULT, null, null);
                    break;

                case BusAddress.Type.SOCKET:
                    if (inAddress.port == 0)
                    {
                        inAddress.port = m_Socket.add_any_inet_port (null);
                    }
                    else
                    {
                        m_Socket.add_inet_port ((uint16)inAddress.port, null);
                    }
                    break;
            }
        }
        catch (GLib.Error err)
        {
        }

        m_Socket.incoming.connect (on_client_connect);

        m_Socket.start ();
    }

    ~SocketBusService ()
    {
        string filename = "%s/maia-bus-socket.%x".printf (GLib.Environment.get_tmp_dir (), id);

        GLib.FileUtils.unlink (filename);
    }

    private bool
    on_client_connect (GLib.SocketConnection inConnection, GLib.Object? inSource)
    {
        Log.audit (GLib.Log.METHOD, Log.Category.MAIN_BUS, "Client connected");
        var client = new SocketBusConnection.client (@"$address-connection-$(++m_ClientCount)", address, inConnection);
        add (client);

        return false;
    }

    internal override bool
    can_append_child (Object inChild)
    {
        return inChild is SocketBusConnection && base.can_append_child (inChild);
    }

    internal override size_t
    write (uint8[] inData) throws BusError
    {
        return 0;
    }

    internal override async size_t
    write_async (uint8[] inData, GLib.Cancellable? inCancellable) throws BusError
    {
        return 0;
    }

    internal override size_t
    read (uint8[] inData) throws BusError
    {
        return 0;
    }

    internal override async size_t
    read_async (uint8[] inData, GLib.Cancellable? inCancellable) throws BusError
    {
        return 0;
    }
}
