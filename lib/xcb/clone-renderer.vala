/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * clone-renderer.vala
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

public class Maia.Xcb.CloneRenderer : Maia.Graphic.CloneRenderer
{
    // types
    public class Looper : Graphic.CloneRenderer.Looper
    {
        // properties
        private global::Xcb.Damage.Damage           m_Damage;
        private Core.Event                          m_DamageEvent;
        private unowned Graphic.Renderer.RenderFunc m_Func;

        // methods
        public Looper (Graphic.Device inDevice)
        {
            GLib.Object (device: inDevice);
        }

        private void
        on_damage_event (Core.EventArgs? inArgs)
        {
            if (m_Func != null)
            {
                m_Func (0);
            }

            m_Damage.subtract (application.connection, global::Xcb.NONE, global::Xcb.NONE);
        }

        internal override void
        prepare (Graphic.Renderer.RenderFunc inFunc)
        {
            if (device != null && device is Drawable)
            {
                unowned Drawable? drawable = (Drawable)device;

                m_Damage = global::Xcb.Damage.Damage (application.connection);
                m_Damage.create (application.connection, drawable.xid, global::Xcb.Damage.ReportLevel.NON_EMPTY);

                m_DamageEvent = new Core.Event ("damage", ((int)m_Damage).to_pointer ());
                m_DamageEvent.subscribe (on_damage_event);

                m_Func = inFunc;
            }
        }

        internal override void
        finish ()
        {
            m_Damage.destroy (application.connection);
            m_Damage = 0;
        }
    }

    // properties
    private Pixmap                   m_Pixmap = null;
    private Graphic.Size             m_Size = Graphic.Size (0, 0);
    private Graphic.Surface?         m_Surface = null;
    private Drawable?                m_CloneDevice = null;
    private Graphic.Surface?         m_CloneSurface = null;

    // accessors
    public override Graphic.Surface? surface {
        get {
            return m_Surface;
        }
    }

    [CCode (notify = false)]
    public override Graphic.Size size {
        get {
            return m_Size;
        }
        construct set {
            if (!m_Size.equal (value))
            {
                m_Size = value;

                create_surface ();
            }
        }
    }

    // methods
    public CloneRenderer (Graphic.Size inSize, Graphic.Device inDevice)
    {
        base (inSize, inDevice);
    }

    public override void
    init (Graphic.Device inDevice)
    {
        if (inDevice is Drawable)
        {
            m_CloneDevice = inDevice as Drawable;

            m_CloneSurface = new Graphic.Surface.from_device (m_CloneDevice, (int)GLib.Math.ceil (m_CloneDevice.size.width), (int)GLib.Math.ceil (m_CloneDevice.size.height));
        }
    }

    private void
    create_surface ()
    {
        m_Surface = null;
        m_Pixmap = null;

        if (m_Size.width != 0 && m_Size.height != 0)
        {
            int screen_num = Maia.Xcb.application.default_screen;

            m_Pixmap = new Pixmap (screen_num, (uint8)32, (int)GLib.Math.ceil (m_Size.width), (int)GLib.Math.ceil (m_Size.height));

            m_Surface = new Graphic.Surface.from_device (m_Pixmap, (int)GLib.Math.ceil (m_Size.width), (int)GLib.Math.ceil (m_Size.height));
        }
    }

    public override void
    render (uint inFrameNum)
    {
        if (m_CloneSurface != null)
        {
            try
            {
                var ctx = m_Surface.context;
                ctx.save ();
                    Graphic.Size clone_size = m_CloneSurface.size;
                    Graphic.Size surface_size = m_Surface.size;

                    double scale = double.max (surface_size.width / clone_size.width,
                                               surface_size.height / clone_size.height);
                    var transform = new Graphic.Transform.identity ();
                    transform.scale (scale, scale);

                    ctx.translate (Graphic.Point ((surface_size.width - (clone_size.width / scale)) / 2,
                                                  (surface_size.height - (clone_size.height / scale)) / 2));
                    ctx.transform = transform;
                    ctx.pattern = m_CloneSurface;
                    ctx.paint ();
                ctx.restore ();
            }
            catch (Graphic.Error err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.GRAPHIC_DRAW, @"Error on clone device: $(err.message)");
            }

            base.render (inFrameNum);
        }
    }
}
