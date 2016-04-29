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
                m_Damage.create (application.connection, drawable.xid, global::Xcb.Damage.ReportLevel.BOUNDING_BOX);
                m_Damage.subtract (application.connection, global::Xcb.NONE, global::Xcb.NONE);

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
    public CloneRenderer (Graphic.Rectangle inArea, Graphic.Device inDevice)
    {
        base (inArea, inDevice);
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

        if (m_Size.width != 0 && m_Size.height != 0)
        {
            m_Surface = new Graphic.Surface.similar (m_CloneSurface, (int)GLib.Math.ceil (m_Size.width), (int)GLib.Math.ceil (m_Size.height));
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
                    m_CloneSurface.transform = new Graphic.Transform.init_translate (position.x, position.y);
                    ctx.operator = Graphic.Operator.SOURCE;
                    ctx.pattern = m_CloneSurface;
                    ctx.fill (new Graphic.Path.from_rectangle (Graphic.Rectangle (0, 0, m_Size.width, m_Size.height)));
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
