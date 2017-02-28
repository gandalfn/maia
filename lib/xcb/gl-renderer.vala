/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * gl-renderer.vala
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

internal class Maia.Xcb.GLRenderer : Maia.Graphic.GLRenderer
{
    public delegate GLX.Context glXCreateContextAttribsARB (global::X.Display dpy, global::Xcb.Glx.Fbconfig config, GLX.Context? share_context, bool direct, [CCode (array_length = false)] int[] attrib_list);

    // static methods
    static uint32 attribute_to_glx (Graphic.GLRenderer.Attribute inAttribute)
    {
        switch (inAttribute)
        {
            case Attribute.BUFFER_SIZE:
                return (uint32)GLX.BUFFER_SIZE;
            case Attribute.DOUBLEBUFFER:
                return (uint32)GLX.DOUBLEBUFFER;
            case Attribute.STEREO:
                return (uint32)GLX.STEREO;
            case Attribute.AUX_BUFFERS:
                return (uint32)GLX.AUX_BUFFERS;
            case Attribute.RED_SIZE:
                return (uint32)GLX.RED_SIZE;
            case Attribute.GREEN_SIZE:
                return (uint32)GLX.GREEN_SIZE;
            case Attribute.BLUE_SIZE:
                return (uint32)GLX.BLUE_SIZE;
            case Attribute.ALPHA_SIZE:
                return (uint32)GLX.ALPHA_SIZE;
            case Attribute.DEPTH_SIZE:
                return (uint32)GLX.DEPTH_SIZE;
            case Attribute.STENCIL_SIZE:
                return (uint32)GLX.STENCIL_SIZE;
            case Attribute.ACCUM_RED_SIZE:
                return (uint32)GLX.ACCUM_RED_SIZE;
            case Attribute.ACCUM_GREEN_SIZE:
                return (uint32)GLX.ACCUM_GREEN_SIZE;
            case Attribute.ACCUM_BLUE_SIZE:
                return (uint32)GLX.ACCUM_BLUE_SIZE;
            case Attribute.ACCUM_ALPHA_SIZE:
                return (uint32)GLX.ACCUM_ALPHA_SIZE;
        }

        return 0;
    }
    // properties
    private global::X.Display        m_Display;
    private global::Xcb.Glx.Fbconfig m_FBConfig;
    private Pixmap                   m_Pixmap = null;
    private GLX.Context              m_GLXContext;
    private GLX.Pixmap               m_GLXPixmap = (GLX.Pixmap)global::Xcb.NONE;
    private Graphic.Size             m_Size = Graphic.Size (0, 0);
    private Graphic.Surface?         m_Surface = null;

    // accessors
    public uint32 xid {
        get {
            return m_Pixmap != null ? m_Pixmap.xid : 0;
        }
    }

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

                if (m_Surface != null)
                {
                    create_surface ();
                }
            }
        }
    }

    // methods
    public GLRenderer (Graphic.Size inSize, int inGLMajorVersion, int inGLMinorVersion, uint32[] inAttributes)
        requires ((inAttributes.length % 2) == 0)
    {
        base (inSize, inGLMajorVersion, inGLMinorVersion, inAttributes);
    }

    ~GLRenderer ()
    {
        if (m_GLXPixmap != (GLX.Pixmap)global::Xcb.NONE)
        {
            GLX.destroy_pixmap (m_Display, m_GLXPixmap);
            m_GLXPixmap = (GLX.Pixmap)global::Xcb.NONE;
        }

        GLX.destroy_context (m_Display, m_GLXContext);

        m_Display.sync ();
    }

    private void
    create_surface ()
    {
        m_Surface = null;
        m_Pixmap = null;
        if (m_GLXPixmap != (GLX.Pixmap)global::Xcb.NONE)
        {
            GLX.destroy_pixmap (m_Display, m_GLXPixmap);
            m_GLXPixmap = global::Xcb.NONE;
            m_Display.sync ();
        }

        if (m_Size.width != 0 && m_Size.height != 0)
        {
            int screen_num = Maia.Xcb.application.default_screen;

            GLX.VisualInfo vinfo = GLX.get_visual_from_fbconfig (m_Display, m_FBConfig);

            m_Pixmap = new Pixmap (screen_num, (uint8)vinfo.depth, (int)GLib.Math.ceil (m_Size.width), (int)GLib.Math.ceil (m_Size.height));

            m_Surface = new Graphic.Surface.from_device (m_Pixmap, (int)GLib.Math.ceil (m_Size.width), (int)GLib.Math.ceil (m_Size.height));

            Maia.Xcb.application.sync ();

            m_GLXPixmap = GLX.create_pixmap (m_Display, m_FBConfig, m_Pixmap.xid, null);
        }
    }

    protected override void
    init (int inGLMajorVersion, int inGLMinorVersion, uint32[] inAttributes)
        requires (inGLMajorVersion >= 1)
        requires ((inAttributes.length % 2) == 0)
    {
        uint32[] attribs = {};

        for (int cpt = 0; cpt < inAttributes.length; cpt += 2)
        {
            attribs += attribute_to_glx ((Graphic.GLRenderer.Attribute)inAttributes[cpt]);
            attribs += inAttributes[cpt + 1];
        }

        attribs += GLX.RENDER_TYPE;
        attribs += GLX.RGBA_BIT;

        attribs += GLX.DRAWABLE_TYPE;
        attribs += GLX.PIXMAP_BIT;

        attribs += GLX.X_VISUAL_TYPE;
        attribs += GLX.TRUE_COLOR;

        attribs += 0;


        int screen_num = Maia.Xcb.application.default_screen;
        m_FBConfig = application[screen_num].glx_choose_fb_configs (attribs);

        int[] ctx_attribs = {};
        ctx_attribs += GLX.CONTEXT_MAJOR_VERSION_ARB;
        ctx_attribs += inGLMajorVersion;

        ctx_attribs += GLX.CONTEXT_MINOR_VERSION_ARB;
        ctx_attribs += inGLMinorVersion;

        ctx_attribs += 0;

        unowned glXCreateContextAttribsARB? create_context = (glXCreateContextAttribsARB?)GLX.get_proc_address("glXCreateContextAttribsARB");
        m_GLXContext = create_context (m_Display, m_FBConfig, null, true, ctx_attribs);

        create_surface ();
    }

    internal override void
    delegate_construct ()
    {
        // create a xlib connection for glx
        m_Display = new global::X.Display (application.id == 0 ? null : ((GLib.Quark)application.id).to_string ());
    }

    public override void
    start ()
    {
        if (m_GLXPixmap != (GLX.Pixmap)global::Xcb.NONE)
        {
            GLX.wait_x ();

            GLX.make_current (m_Display, m_GLXPixmap, m_GLXContext);

            base.start ();

            GLX.wait_gl ();
        }
    }

    public override void
    render (uint inFrameNum)
    {
        if (m_GLXPixmap != (GLX.Pixmap)global::Xcb.NONE)
        {
            GLX.wait_x ();

            GLX.make_current (m_Display, m_GLXPixmap, m_GLXContext);

            base.render (inFrameNum);

            GLX.wait_gl ();

            m_Display.sync ();
        }
    }
}
