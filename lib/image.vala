/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * image.vala
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

public class Maia.Image : Item, ItemPackable
{
    // properties
    private Graphic.Image m_Image;

    // accessors
    public override string tag {
        get {
            return "Image";
        }
    }

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

    public string? filename { get; set; default = ""; }

    // methods
    public Image (string inId, string inFilename)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), filename: inFilename);
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        if (filename != "")
        {
            if (m_Image == null)
            {
                m_Image = Graphic.Image.create (filename, inSize);
            }

            if (m_Image != null)
            {
                size = m_Image.size;
            }
        }
        else if (characters != null)
        {
            if (m_Image == null)
            {
                m_Image = new Graphic.ImageSvg.from_data (characters, inSize);
            }

            if (m_Image != null)
            {
                size = m_Image.size;
            }
        }

        return base.size_request (inSize);
    }

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
        if (m_Image != null && m_Image.surface != null)
        {
            inContext.pattern = m_Image.surface;
            inContext.paint ();
        }
    }
}
