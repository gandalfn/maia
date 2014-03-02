/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * connection-watch.vala
 * Copyright (C) Nicolas Bruguier 2010-2014 <gandalfn@club-internet.fr>
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

internal class Maia.Xcb.ConnectionWatch : Core.Watch
{
    // properties
    private unowned global::Xcb.Connection m_Connection;

    // methods
    public ConnectionWatch (global::Xcb.Connection inConnection)
    {
        base (inConnection.file_descriptor);

        m_Connection = inConnection;
    }

    internal override void
    on_error ()
    {
        // TODO
    }

    internal override bool
    on_process ()
    {
        global::Xcb.GenericEvent? evt = null;

        while ((evt = m_Connection.poll_for_event ()) != null)
        {
            int response_type = evt.response_type & ~0x80;
            switch (response_type)
            {
                // Expose event
                case global::Xcb.EventType.EXPOSE:
                    unowned global::Xcb.ExposeEvent evt_expose = (global::Xcb.ExposeEvent)evt;

                    // send event damage
                    Core.EventBus.default.publish ("damage", ((int)evt_expose.window).to_pointer (),
                                                   new DamageEventArgs (evt_expose.x, evt_expose.y,
                                                                        evt_expose.width, evt_expose.height));
                    break;

                // configure notify event
                case global::Xcb.EventType.CONFIGURE_NOTIFY:
                    unowned global::Xcb.ConfigureNotifyEvent evt_configure = (global::Xcb.ConfigureNotifyEvent)evt;

                    // send event geometry
                    Core.EventBus.default.publish ("geometry", ((int)evt_configure.window).to_pointer (),
                                                   new GeometryEventArgs (evt_configure.x, evt_configure.y,
                                                                          evt_configure.width, evt_configure.height));
                    break;

                // map notify event
                case global::Xcb.EventType.MAP_NOTIFY:
                    unowned global::Xcb.MapNotifyEvent evt_map_notify = (global::Xcb.MapNotifyEvent)evt;

                    // send event geometry
                    Core.EventBus.default.publish ("visibility", ((int)evt_map_notify.window).to_pointer (),
                                                   new VisibilityEventArgs (true));
                    break;

                // unmap notify event
                case global::Xcb.EventType.UNMAP_NOTIFY:
                    unowned global::Xcb.UnmapNotifyEvent evt_unmap_notify = (global::Xcb.UnmapNotifyEvent)evt;

                    // send event geometry
                    Core.EventBus.default.publish ("visibility", ((int)evt_unmap_notify.window).to_pointer (),
                                                   new VisibilityEventArgs (false));
                    break;

                // button press event
                case global::Xcb.EventType.BUTTON_PRESS:
                    unowned global::Xcb.ButtonPressEvent evt_button_press = (global::Xcb.ButtonPressEvent)evt;

                    // send event geometry
                    Core.EventBus.default.publish ("mouse", ((int)evt_button_press.event).to_pointer (),
                                                   new MouseEventArgs (MouseEventArgs.EventFlags.BUTTON_PRESS,
                                                                       evt_button_press.detail,
                                                                       evt_button_press.event_x,
                                                                       evt_button_press.event_y));
                    break;

                // button release event
                case global::Xcb.EventType.BUTTON_RELEASE:
                    unowned global::Xcb.ButtonReleaseEvent evt_button_release = (global::Xcb.ButtonReleaseEvent)evt;

                    // send event geometry
                    Core.EventBus.default.publish ("mouse", ((int)evt_button_release.event).to_pointer (),
                                                   new MouseEventArgs (MouseEventArgs.EventFlags.BUTTON_RELEASE,
                                                                       evt_button_release.detail,
                                                                       evt_button_release.event_x,
                                                                       evt_button_release.event_y));
                    break;

                // motion notify event
                case global::Xcb.EventType.MOTION_NOTIFY:
                    unowned global::Xcb.MotionNotifyEvent evt_motion_notify = (global::Xcb.MotionNotifyEvent)evt;

                    // send event geometry
                    Core.EventBus.default.publish ("mouse", ((int)evt_motion_notify.event).to_pointer (),
                                                   new MouseEventArgs (MouseEventArgs.EventFlags.MOTION,
                                                                       evt_motion_notify.detail,
                                                                       evt_motion_notify.event_x,
                                                                       evt_motion_notify.event_y));
                    break;

                // client message event
                case global::Xcb.EventType.CLIENT_MESSAGE:
                    unowned global::Xcb.ClientMessageEvent evt_client_message = (global::Xcb.ClientMessageEvent)evt;

                    // check client message type
                    if (evt_client_message.type           == Xcb.application.atoms[AtomType.WM_PROTOCOLS] &&
                        evt_client_message.data.data32[0] == Xcb.application.atoms[AtomType.WM_DELETE_WINDOW])
                    {
                        Core.EventBus.default.publish_with_reply ("delete", ((int)evt_client_message.window).to_pointer (),
                                                                  new DeleteEventArgs (evt_client_message.window),
                                                                  on_delete_event_reply);
                    }
                    break;

                // destroy notify event
                case global::Xcb.EventType.DESTROY_NOTIFY:
                    unowned global::Xcb.DestroyNotifyEvent evt_destroy_notify = (global::Xcb.DestroyNotifyEvent)evt;

                    // send event geometry
                    Core.EventBus.default.publish ("destroy", ((int)evt_destroy_notify.window).to_pointer (), null);
                    break;
            }
        }

        return true;
    }

    public void
    on_delete_event_reply (Core.EventArgs? inArgs)
    {
        unowned DeleteEventArgs args = inArgs as DeleteEventArgs;

        // delete event is not cancelled destroy window
        if (args != null && !args.cancel)
        {
            args.window.destroy (m_Connection);
            m_Connection.flush ();
        }
    }
}
