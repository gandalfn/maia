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
        [CCode (notify = false)]
        public Graphic.Size size { get; set; default = Graphic.Size (0, 0); }

        public InitializeNotification (string inName)
        {
            base (inName);
        }

        public new void
        post (Graphic.Size inSize)
        {
            size = inSize;
            base.post ();
        }
    }

    public class NewFrameNotification : Core.Notification
    {
        [CCode (notify = false)]
        public uint num_frame { get; set; default = 0; }

        public NewFrameNotification (string inName)
        {
            base (inName);
        }

        public new void
        post (uint inNumFrame)
        {
            num_frame = inNumFrame;
            base.post ();
        }
    }

    public delegate void RenderFunc(int inFrameNum);

    public abstract class Looper : Core.Object
    {
        public abstract void prepare (RenderFunc inFunc);
        public abstract void finish ();
    }

    public class TimelineLooper : Looper
    {
        private Core.Timeline      m_Timeline;
        private unowned RenderFunc m_Func;

        public TimelineLooper (int inFps, int inNbFrames)
        {
            m_Timeline = new Core.Timeline (inNbFrames, inFps);
            m_Timeline.loop = true;
            m_Timeline.new_frame.add_object_observer (on_new_frame);
        }

        internal TimelineLooper.from_function (Manifest.Function inFunction) throws Manifest.Error
        {
            int cpt = 0;
            int framerate = 0;
            int nb_frames = 0;
            foreach (unowned Core.Object child in inFunction)
            {
                unowned Manifest.Attribute arg = (Manifest.Attribute)child;
                switch (cpt)
                {
                    case 0:
                        framerate = (int)arg.transform (typeof (int));
                        break;
                    case 1:
                        nb_frames = (int)arg.transform (typeof (int));
                    break;
                    default:
                        throw new Manifest.Error.TOO_MANY_FUNCTION_ARGUMENT ("Too many arguments in %s function", inFunction.to_string ());
                }
                cpt++;
            }
            if (cpt >= 2)
            {
                this (framerate, nb_frames);
            }
            else
            {
                throw new Manifest.Error.MISSING_FUNCTION_ARGUMENT ("Missing argument in %s function", inFunction.to_string ());
            }
        }

        private void
        on_new_frame (Core.Notification inNotification)
        {
            if (m_Func != null)
            {
                Core.Timeline.NewFrameNotification notification = (Core.Timeline.NewFrameNotification)inNotification;

                m_Func ((int)notification.num_frame);
            }
        }

        internal override void
        prepare (RenderFunc inFunc)
        {
            m_Func = inFunc;
            m_Timeline.start ();
        }

        internal override void
        finish ()
        {
            m_Timeline.stop ();
            m_Func = null;
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
        initialize.post (size);
    }

    private void
    on_new_frame (uint inFrameNum)
    {
        new_frame.post (inFrameNum);
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
