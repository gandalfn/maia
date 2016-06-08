/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * gesture.vala
 * Copyright (C) Nicolas Bruguier 2010-2016 <gandalfn@club-internet.fr>
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

public class Maia.Gesture : Core.Object
{
    // constants
    private const int MAX_BUTTONS = 255;

    // type
    public enum Type
    {
        NONE,
        PRESS,
        RELEASE,
        HSCROLL,
        VSCROLL;

        public string
        to_string ()
        {
            switch (this)
            {
                case PRESS:
                    return "press";

                case RELEASE:
                    return "release";

                case HSCROLL:
                    return "hscroll";

                case VSCROLL:
                    return "vscroll";
            }

            return "";
        }
    }

    private struct ButtonStatus
    {
        bool          m_Pressed;
        Graphic.Point m_Origin;
        Graphic.Point m_Position;
        Graphic.Point m_Movement;
    }

    public class Notification : Core.Notification
    {
        public uint          button       { get; private set; default = 0; }
        public Type          gesture_type { get; private set; default = Type.NONE; }
        public Graphic.Point position     { get; private set; default = Graphic.Point (0, 0); }
        public bool          proceed      { get; set; default = false; }

        internal Notification (string inName)
        {
            base (inName);
        }

        public new void
        post (uint inButton, Type inGestureType, Graphic.Point inPosition)
        {
            button       = inButton;
            gesture_type = inGestureType;
            position     = inPosition;
            proceed      = false;

            base.post ();
        }
    }

    // properties
    private unowned Item?  m_Item;
    private Core.Set<uint> m_ButtonMask;
    private ButtonStatus[] m_ButtonsStatus;

    public unowned Notification notification {
        get {
            return notifications["gesture"] as Notification;
        }
    }

    // methods
    construct
    {
        m_ButtonMask = new Core.Set<uint> ();
        m_ButtonsStatus = new ButtonStatus[MAX_BUTTONS];

        notifications.add (new Notification ("gesture"));
    }

    internal Gesture (Item inItem)
    {
        m_Item = inItem;

        m_Item.button_press_event.connect (on_button_press_event);
        m_Item.button_release_event.connect (on_button_release_event);
        m_Item.motion_event.connect (on_motion_event);
    }

    private bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = false;
        if (inButton < MAX_BUTTONS)
        {
            m_ButtonMask.insert (inButton);

            m_ButtonsStatus[inButton].m_Pressed = true;
            m_ButtonsStatus[inButton].m_Origin = inPoint;
            m_ButtonsStatus[inButton].m_Position = inPoint;
            m_ButtonsStatus[inButton].m_Movement = Graphic.Point (0, 0);

            notification.post (inButton, Type.PRESS, inPoint);

            ret = notification.proceed;
        }

        return ret;
    }

    private bool
    on_button_release_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = false;
        if (inButton < MAX_BUTTONS)
        {
            m_ButtonMask.remove (inButton);

            m_ButtonsStatus[inButton].m_Pressed = false;
            m_ButtonsStatus[inButton].m_Origin = Graphic.Point (0, 0);
            m_ButtonsStatus[inButton].m_Position = inPoint;
            m_ButtonsStatus[inButton].m_Movement = Graphic.Point (0, 0);

            notification.post (inButton, Type.RELEASE, inPoint);

            ret = notification.proceed;
        }

        return ret;
    }

    private bool
    on_motion_event (Graphic.Point inPoint)
    {
        bool ret = false;
        foreach (uint button in m_ButtonMask)
        {
            if (m_ButtonsStatus[button].m_Pressed)
            {
                double diffx = inPoint.x - m_ButtonsStatus[1].m_Origin.x;
                double diffy = inPoint.y - m_ButtonsStatus[1].m_Origin.y;

                if (GLib.Math.fabs (diffx) > GLib.Math.fabs (diffy))
                {
                    notification.post (button, Type.HSCROLL, Graphic.Point (diffx, 0));

                    ret |= notification.proceed;
                    if (notification.proceed)
                    {
                        m_ButtonsStatus[button].m_Movement.x = 0;
                        m_ButtonsStatus[button].m_Origin = inPoint;
                    }
                    else
                    {
                        m_ButtonsStatus[button].m_Movement.x = diffx;
                    }

                    m_ButtonsStatus[button].m_Movement.y = 0;
                }
                else if (GLib.Math.fabs (diffx) < GLib.Math.fabs (diffy))
                {
                    notification.post (button, Type.VSCROLL, Graphic.Point (0, diffy));

                    ret |= notification.proceed;
                    if (notification.proceed)
                    {
                        m_ButtonsStatus[button].m_Movement.y = 0;
                        m_ButtonsStatus[button].m_Origin = inPoint;
                    }
                    else
                    {
                        m_ButtonsStatus[button].m_Movement.y = diffy;
                    }

                    m_ButtonsStatus[button].m_Movement.x = 0;
                }

                m_ButtonsStatus[button].m_Position = inPoint;
            }
        }

        return ret;
    }
}
