/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * glyph.vala
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

internal class Maia.Cairo.Glyph : Graphic.Glyph
{
    // type
    public class Line : Graphic.Glyph.Line
    {
        // properties
        private unowned Pango.LayoutLine m_Layout;

        // accessors
        public override Graphic.Size size {
            get {
                if (m_Layout != null)
                {
                    Pango.Rectangle ink, logical;
                    m_Layout.get_pixel_extents (out ink, out logical);
                    return Graphic.Size (logical.x + logical.width, logical.y + logical.height);
                }
                return Graphic.Size (0, 0);
            }
        }

        // methods
        public Line (uint32 inCount, Pango.LayoutLine inLayoutLine)
        {
            id = inCount;
            m_Layout = inLayoutLine;
        }
    }

    // properties
    private Pango.Layout m_Layout;
    private Graphic.Size m_Size = Graphic.Size (0, 0);

    // accessors
    public Pango.Layout layout {
        get {
            return m_Layout;
        }
    }

    inline static Pango.Alignment
    pango_alignment (Graphic.Glyph.Alignment inAlign)
    {
        if (inAlign == Graphic.Glyph.Alignment.LEFT)
        {
            return Pango.Alignment.LEFT;
        }
        else if (inAlign == Graphic.Glyph.Alignment.RIGHT)
        {
            return Pango.Alignment.RIGHT;
        }

        return Pango.Alignment.CENTER;
    }

    inline static Pango.WrapMode
    pango_wrap_mode (Graphic.Glyph.WrapMode inType)
    {
        if (inType == Graphic.Glyph.WrapMode.CHAR)
        {
            return Pango.WrapMode.CHAR;
        }

        return Pango.WrapMode.WORD;
    }

    inline static Pango.EllipsizeMode
    pango_ellipsize_mode (Graphic.Glyph.EllipsizeMode inMode)
    {
        switch (inMode)
        {
            case Graphic.Glyph.EllipsizeMode.START:
                return Pango.EllipsizeMode.START;

            case Graphic.Glyph.EllipsizeMode.MIDDLE:
                return Pango.EllipsizeMode.MIDDLE;

            case Graphic.Glyph.EllipsizeMode.END:
                return Pango.EllipsizeMode.END;
        }

        return Pango.EllipsizeMode.NONE;
    }

    public override Graphic.Size size {
        get {
            if (m_Layout != null)
            {
                Pango.Rectangle ink, logical;
                m_Layout.get_pixel_extents (out ink, out logical);
                return Graphic.Size (logical.x + logical.width, logical.y + logical.height);
            }
            return m_Size;
        }

        set {
            m_Size = value;

            if (m_Layout != null)
            {
                m_Layout.set_width ((int)(m_Size.width > 0 ? m_Size.width * Pango.SCALE : -1));
                m_Layout.set_height ((int)(m_Size.height > 0 ? m_Size.height * Pango.SCALE : -1));
            }
        }
    }

    // methods
    public Glyph (string inFontDescription)
    {
        base (inFontDescription);
    }

    private int
    skip_pango_markup (string inText, int inPos)
    {
        string tag = inText.substring (inPos, -1);

        if (tag.has_prefix ("<b>") ||
            tag.has_prefix ("<i>") ||
            tag.has_prefix ("<s>") ||
            tag.has_prefix ("<u>"))
            return 3;

        if (tag.has_prefix ("</b>") ||
            tag.has_prefix ("</i>") ||
            tag.has_prefix ("</s>") ||
            tag.has_prefix ("</u>") ||
            tag.has_prefix ("<tt>"))
            return 4;

        if (tag.has_prefix ("<big>") ||
            tag.has_prefix ("<sub>") ||
            tag.has_prefix ("<sup>") ||
            tag.has_prefix ("</tt>"))
            return 5;

        if (tag.has_prefix ("<span>"))
            return 6;

        if (tag.has_prefix ("<small>") ||
            tag.has_prefix ("</span>"))
            return 7;

        if (tag.has_prefix ("</small>"))
            return 8;

        if (tag.has_prefix ("<span"))
        {
            int ret = 1;
            for (int cpt = inPos; cpt < inText.length; ++cpt, ++ret)
            {
                if (inText[cpt] == '>') break;
            }
            return ret;
        }

        return 0;
    }

    // TODO: Very very slow runtime
    private string
    escape_text (string inText)
    {
        GLib.StringBuilder ret = new GLib.StringBuilder ();
        int index = 0;
        unichar c;
        while (inText.get_next_char (ref index, out c))
        {
            int nb = skip_pango_markup (inText, index - 1);
            if (nb > 0)
            {
                ret.append (inText.substring (index - 1, nb));
                index += nb - 1;
            }
            else if (index <= inText.length)
            {
                if (c == '&')
                {
                    ret.append ("&amp;");
                }
                else if (c == '"')
                {
                    ret.append ("&quot;");
                }
                else if (c == '\'')
                {
                    ret.append ("&apos;");
                }
                else if (c == '<')
                {
                    ret.append ("&lt;");
                }
                else if (c == '>')
                {
                    ret.append ("&gt;");
                }
                else
                {
                    ret.append_unichar (c);
                }
            }
        }

        return ret.str;
    }

    private void
    update_layout (Context inContext)
    {
        // Clear childs
        while (first () != null)
        {
            first ().parent = null;
        }

        // create layout
        m_Layout = new Pango.Layout (inContext.pango_context);

        // set layout properties
        Pango.FontDescription desc = Pango.FontDescription.from_string (font_description);
        m_Layout.set_font_description (desc);
        if (use_markup)
            m_Layout.set_markup (escape_text (text ?? ""), -1);
        else
            m_Layout.set_text (text ?? "", -1);
        m_Layout.set_width ((int)(m_Size.width > 0 ? m_Size.width * Pango.SCALE : -1));
        m_Layout.set_height ((int)(m_Size.height > 0 ? m_Size.height * Pango.SCALE : -1));
        m_Layout.set_alignment (pango_alignment (alignment));
        m_Layout.set_wrap (pango_wrap_mode (wrap));
        m_Layout.set_ellipsize (pango_ellipsize_mode (ellipsize));

        // update pango layout
        Pango.cairo_update_layout (inContext.context, m_Layout);

        // add glyph lines
        for (int cpt = 0; cpt < m_Layout.get_line_count(); ++cpt)
        {
            var line = new Line (cpt, m_Layout.get_line (cpt));
            add (line);
        }
    }

    public override Graphic.Rectangle
    get_cursor_position (int inIndex)
    {
        Graphic.Rectangle rect = Graphic.Rectangle (0, 0, 0, 0);

        if (m_Layout != null && text != null)
        {
            Pango.Rectangle strong_pos, weak_pos;
            m_Layout.get_cursor_pos (inIndex, out strong_pos, out weak_pos);
            rect = Graphic.Rectangle (strong_pos.x / Pango.SCALE, strong_pos.y / Pango.SCALE,
                                      strong_pos.width / Pango.SCALE, strong_pos.height / Pango.SCALE);
        }

        return rect;
    }

    public override void
    update (Graphic.Context inContext)
        requires (inContext is Context)
    {
        update_layout ((Context)inContext);
    }
}
