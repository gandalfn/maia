/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * renderer.vala
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

public class Maia.Graphic.Renderer : Core.Object
{
    // types
    public class InitializeNotification : Core.Notification
    {
        public Graphic.Size size { get; set; default = Graphic.Size (0, 0); }

        public InitializeNotification (string inName)
        {
            base (inName);
        }
    }

    public class NewFrameNotification : Core.Notification
    {
        public uint num_frame { get; set; default = 0; }

        public NewFrameNotification (string inName)
        {
            base (inName);
        }
    }

    // accessors
    public virtual Surface? surface {
        get {
            return null;
        }
    }

    [CCode (notify = false)]
    public virtual Size size { get; construct set; default = Size (0, 0); }

    // notifications
    public unowned InitializeNotification? initialize {
        get {
            return notifications["initialize"] as InitializeNotification;
        }
    }

    public unowned NewFrameNotification? new_frame {
        get {
            return notifications["new-frame"] as NewFrameNotification;
        }
    }

    // methods
    construct
    {
        notifications.add (new InitializeNotification ("initialize"));
        notifications.add (new NewFrameNotification ("new-frame"));
    }

    public Renderer (Graphic.Size inSize)
    {
        GLib.Object (size: inSize);
    }

    private void
    on_initialize ()
    {
        initialize.size = size;
        initialize.post ();
    }

    private void
    on_new_frame (uint inFrameNum)
    {
        new_frame.num_frame = inFrameNum;
        new_frame.post ();
    }

    public virtual void
    start ()
    {
        on_initialize ();
    }

    public virtual void
    render (uint inFrameNum)
    {
        on_new_frame (inFrameNum);
    }
}
