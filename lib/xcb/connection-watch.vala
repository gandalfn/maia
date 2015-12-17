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
    private global::Xcb.Util.KeySymbols    m_Symbols;
    private global::Xcb.GenericEvent?      m_LastEvent = null;

    // methods
    public ConnectionWatch (global::Xcb.Connection inConnection)
    {
        base (inConnection.file_descriptor, Core.Watch.Condition.IN, null, GLib.Priority.DEFAULT);

        m_Connection = inConnection;

        // Get keyboard mapping
        m_Symbols = new global::Xcb.Util.KeySymbols (m_Connection);
    }

    private void
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

    private void
    send_keyboard_event (global::Xcb.Window inWindow, bool inPress, global::Xcb.KeyButMask inMask, global::Xcb.Keycode inCode)
    {
        Maia.Modifier modifier = Maia.Modifier.NONE;

        int col = 0;

        // Shift key
        if ((inMask & global::Xcb.KeyButMask.SHIFT) == global::Xcb.KeyButMask.SHIFT)
        {
            modifier |= Maia.Modifier.SHIFT;
            col++;
        }

        // Control key
        if ((inMask & global::Xcb.KeyButMask.CONTROL) == global::Xcb.KeyButMask.CONTROL)
        {
            modifier |= Maia.Modifier.CONTROL;
        }

        // Super key
        if ((inMask & global::Xcb.KeyButMask.MOD_1) == global::Xcb.KeyButMask.MOD_1)
        {
            modifier |= Maia.Modifier.ALT;
        }

        // Super key
        if ((inMask & global::Xcb.KeyButMask.MOD_4) == global::Xcb.KeyButMask.MOD_4)
        {
            modifier |= Maia.Modifier.SUPER;
        }

        // Cap lock
        if ((inMask & global::Xcb.KeyButMask.LOCK) == global::Xcb.KeyButMask.LOCK)
        {
            col += 2;
        }

        // Altgr
        if ((inMask & global::Xcb.KeyButMask.MOD_5) == global::Xcb.KeyButMask.MOD_5)
        {
            col += 4;
        }
        // Verr num
        if (global::Xcb.Util.is_keypad_key (m_Symbols[inCode, 0]) &&
            (inMask & global::Xcb.KeyButMask.MOD_2) == global::Xcb.KeyButMask.MOD_2)
            col++;

        // Get the keysym code with the modifier
        global::Xcb.Keysym keysym = m_Symbols[inCode, col];
        // convert keysym to maia key
        Maia.Key key = convert_xcb_keysym_to_key (keysym);
        // convert keysym to unichar
        unichar car = keysym_to_unicode (keysym);

        // send keyboard event
        Core.EventBus.default.publish ("keyboard", ((int)inWindow).to_pointer (),
                                                   new KeyboardEventArgs (inPress ? KeyboardEventArgs.State.PRESS : KeyboardEventArgs.State.RELEASE,
                                                                          modifier, key, car));
    }

    internal override void
    on_error ()
    {
        // TODO
    }

    internal override bool
    check ()
    {
        return (m_LastEvent != null || (m_LastEvent = m_Connection.poll_for_event ()) != null);
    }

    internal override bool
    on_process ()
    {
        Core.Map<int, MouseEventArgs> motions = new Core.Map<int, MouseEventArgs> ();
        Core.Map<int, GeometryEventArgs> configures = new Core.Map<int, GeometryEventArgs> ();

        while (m_LastEvent != null || (m_LastEvent = m_Connection.poll_for_event ()) != null)
        {
            int response_type = m_LastEvent.response_type & 0x7f;
            bool send_event = (m_LastEvent.response_type & 0x80) != 0;

            print(@"response_type: $((global::Xcb.EventType)response_type) send_event: $send_event\n");
            switch (response_type)
            {
                // Expose event
                case global::Xcb.EventType.EXPOSE:
                    unowned global::Xcb.ExposeEvent? evt_expose = (global::Xcb.ExposeEvent?)m_LastEvent;

                    // send event damage
                    Core.EventBus.default.publish ("damage", ((int)evt_expose.window).to_pointer (),
                                                   new DamageEventArgs (evt_expose.x, evt_expose.y,
                                                                        evt_expose.width, evt_expose.height));
                    break;

                // configure notify event
                case global::Xcb.EventType.CONFIGURE_NOTIFY:
                    if (send_event)
                    {
                        unowned global::Xcb.ConfigureNotifyEvent? evt_configure = (global::Xcb.ConfigureNotifyEvent?)m_LastEvent;

                        // send event geometry
                        configures[(int)evt_configure.window] = new GeometryEventArgs (evt_configure.x, evt_configure.y,
                                                                                       evt_configure.width + (evt_configure.border_width * 2),
                                                                                       evt_configure.height + (evt_configure.border_width * 2));
                    }
                    break;

                // map notify event
                case global::Xcb.EventType.MAP_NOTIFY:
                    unowned global::Xcb.MapNotifyEvent? evt_map_notify = (global::Xcb.MapNotifyEvent?)m_LastEvent;

                    // send event geometry
                    Core.EventBus.default.publish ("visibility", ((int)evt_map_notify.window).to_pointer (),
                                                   new VisibilityEventArgs (true));
                    break;

                // unmap notify event
                case global::Xcb.EventType.UNMAP_NOTIFY:
                    unowned global::Xcb.UnmapNotifyEvent? evt_unmap_notify = (global::Xcb.UnmapNotifyEvent?)m_LastEvent;

                    // send event geometry
                    Core.EventBus.default.publish ("visibility", ((int)evt_unmap_notify.window).to_pointer (),
                                                   new VisibilityEventArgs (false));
                    break;

                // button press event
                case global::Xcb.EventType.BUTTON_PRESS:
                    unowned global::Xcb.ButtonPressEvent? evt_button_press = (global::Xcb.ButtonPressEvent?)m_LastEvent;

                    // send event mouse
                    Core.EventBus.default.publish ("mouse", ((int)evt_button_press.event).to_pointer (),
                                                   new MouseEventArgs (MouseEventArgs.EventFlags.BUTTON_PRESS,
                                                                       evt_button_press.detail,
                                                                       evt_button_press.event_x,
                                                                       evt_button_press.event_y));
                    break;

                // button release event
                case global::Xcb.EventType.BUTTON_RELEASE:
                    unowned global::Xcb.ButtonReleaseEvent? evt_button_release = (global::Xcb.ButtonReleaseEvent?)m_LastEvent;

                    // send event mouse
                    Core.EventBus.default.publish ("mouse", ((int)evt_button_release.event).to_pointer (),
                                                   new MouseEventArgs (MouseEventArgs.EventFlags.BUTTON_RELEASE,
                                                                       evt_button_release.detail,
                                                                       evt_button_release.event_x,
                                                                       evt_button_release.event_y));
                    break;

                // motion notify event
                case global::Xcb.EventType.MOTION_NOTIFY:
                    unowned global::Xcb.MotionNotifyEvent? evt_motion_notify = (global::Xcb.MotionNotifyEvent?)m_LastEvent;

                    if (evt_motion_notify.detail == global::Xcb.Motion.HINT)
                    {
                        var reply = evt_motion_notify.event.query_pointer (m_Connection).reply (m_Connection);
                        if (reply != null)
                        {
                            motions[(int)evt_motion_notify.event] = new MouseEventArgs (MouseEventArgs.EventFlags.MOTION,
                                                                                        0,
                                                                                        reply.win_x,
                                                                                        reply.win_y);
                        }
                    }
                    else
                    {
                        // Add motion event in compressed map events
                        motions[(int)evt_motion_notify.event] = new MouseEventArgs (MouseEventArgs.EventFlags.MOTION,
                                                                                    0,
                                                                                    evt_motion_notify.event_x,
                                                                                    evt_motion_notify.event_y);
                    }
                    break;

                // client message event
                case global::Xcb.EventType.CLIENT_MESSAGE:
                    unowned global::Xcb.ClientMessageEvent? evt_client_message = (global::Xcb.ClientMessageEvent?)m_LastEvent;

                    // check client message type
                    if (evt_client_message.type           == Xcb.application.atoms[AtomType.WM_PROTOCOLS] &&
                        evt_client_message.data.data32[0] == Xcb.application.atoms[AtomType.WM_DELETE_WINDOW])
                    {
                        Core.EventBus.default.object_publish_with_reply ("delete", ((int)evt_client_message.window).to_pointer (),
                                                                         new DeleteEventArgs (evt_client_message.window),
                                                                         on_delete_event_reply);
                    }
                    break;

                // destroy notify event
                case global::Xcb.EventType.DESTROY_NOTIFY:
                    unowned global::Xcb.DestroyNotifyEvent? evt_destroy_notify = (global::Xcb.DestroyNotifyEvent?)m_LastEvent;

                    // send event geometry
                    Core.EventBus.default.publish ("destroy", ((int)evt_destroy_notify.window).to_pointer (), null);
                    break;

                // key press event
                case global::Xcb.EventType.KEY_PRESS:
                    unowned global::Xcb.KeyPressEvent? evt_key_press = (global::Xcb.KeyPressEvent?)m_LastEvent;

                    send_keyboard_event (evt_key_press.event, true, evt_key_press.state, evt_key_press.detail);
                    break;

                // key press event
                case global::Xcb.EventType.KEY_RELEASE:
                    unowned global::Xcb.KeyReleaseEvent? evt_key_release = (global::Xcb.KeyReleaseEvent?)m_LastEvent;

                    send_keyboard_event (evt_key_release.event, false, evt_key_release.state, evt_key_release.detail);
                    break;

                // mapping notify event
                case global::Xcb.EventType.MAPPING_NOTIFY:
                    unowned global::Xcb.MappingNotifyEvent? evt_mapping_notify = (global::Xcb.MappingNotifyEvent?)m_LastEvent;

                    // refresh keybaord mapping
                    m_Symbols.refresh_keyboard_mapping (evt_mapping_notify);
                    break;
            }

            m_LastEvent = null;
        }

        // send compressed configure
        foreach (var configure in configures)
        {
            Core.EventBus.default.publish ("geometry", configure.first.to_pointer (), configure.second);
        }

        // send compressed motion
        foreach (var motion in motions)
        {
            Core.EventBus.default.publish ("mouse", motion.first.to_pointer (), motion.second);
        }

        return true;
    }
}
