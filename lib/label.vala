/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * label.vala
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

public class Maia.Label : Item, ItemMovable, ItemPackable, Manifest.Element
{
    // properties
    private Graphic.Glyph m_Glyph;

    // accessors
    internal override string tag {
        get {
            return "Label";
        }
    }

    internal override string characters { get; set; default = null; }

    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal double xalign  { get; set; default = 0.5; }

    internal bool   yexpand { get; set; default = true; }
    internal bool   yfill   { get; set; default = true; }
    internal double yalign  { get; set; default = 0.5; }

    internal double top_padding    { get; set; default = 0; }
    internal double bottom_padding { get; set; default = 0; }
    internal double left_padding   { get; set; default = 0; }
    internal double right_padding  { get; set; default = 0; }

    public string   font_description { get; set; default = ""; }
    public string   text             { get; set; default = ""; }

    // methods
    construct
    {
        // connect onto text changed
        notify["text"].connect (() => {
            m_Glyph = null;
            geometry = null;
        });
    }

    public Label (string inId, string inLabel)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), text: inLabel);
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        if (text.length > 0)
        {
            if (m_Glyph == null)
            {
                m_Glyph = new Graphic.Glyph (font_description);
                m_Glyph.text = text;
            }

            if (m_Glyph != null)
            {
                // Create a fake surface to calculate the size of path
                var fake_surface = new Graphic.Surface (1, 1);

                m_Glyph.update (fake_surface.context);
                size = m_Glyph.size;
            }
        }

        return base.size_request (inSize);
    }

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        if (m_Glyph != null && stroke_color != null)
        {
            inContext.save ();
            {
                inContext.pattern = stroke_color;
                inContext.translate (Graphic.Point (geometry.extents.size.width / 2, geometry.extents.size.height / 2));
                inContext.translate (Graphic.Point (-m_Glyph.size.width / 2, -m_Glyph.size.height / 2));
                inContext.render (m_Glyph);
            }
            inContext.restore ();
        }
    }
}
