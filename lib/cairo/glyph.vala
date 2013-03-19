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

internal class Maia.Graphic.Cairo.Glyph : Graphic.Glyph
{
    // properties
    private Cairo.Context m_Context;
    private Pango.Layout  m_Layout;

    // accessors
    internal Pango.Layout layout {
        get {
            return m_Layout;
        }
    }

    public override Size size {
        get {
            if (m_Context != null && m_Layout != null)
            {
                int width, height;
                m_Layout.get_pixel_size (out width, out height);
                return Size (width, height);
            }
            return Size (0, 0);
        }
    }

    // methods
    public Glyph (string inFontDescription)
    {
        base (inFontDescription);
    }

    public override void
    update (Graphic.Context inContext)
    {
        m_Context = (Cairo.Context)inContext;
        m_Layout = Pango.cairo_create_layout (((Cairo.Context)inContext).context);
        Pango.FontDescription desc = Pango.FontDescription.from_string (font_description);
        m_Layout.set_font_description (desc);
        m_Layout.set_text (text, text.length);
        Pango.cairo_update_layout (((Cairo.Context)inContext).context, m_Layout);
    }
}
