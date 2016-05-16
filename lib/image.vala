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

public class Maia.Image : Item, ItemPackable, ItemMovable, ItemResizable, ItemFocusable
{
    // properties
    private Graphic.Image m_Image;
    private FocusGroup    m_FocusGroup = null;

    // accessors
    internal override string tag {
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
    internal bool   xshrink { get; set; default = false; }
    internal bool   xlimp   { get; set; default = false; }
    internal double xalign  { get; set; default = 0.5; }

    internal bool   yexpand { get; set; default = true; }
    internal bool   yfill   { get; set; default = true; }
    internal bool   yshrink { get; set; default = false; }
    internal bool   ylimp   { get; set; default = false; }
    internal double yalign  { get; set; default = 0.5; }

    internal double top_padding    { get; set; default = 0; }
    internal double bottom_padding { get; set; default = 0; }
    internal double left_padding   { get; set; default = 0; }
    internal double right_padding  { get; set; default = 0; }

    internal Graphic.Pattern backcell_pattern { get; set; default = null; }

    internal bool can_focus {
        get {
            return parent is DrawingArea;
        }
        set {
        }
    }
    internal bool have_focus  { get; set; default = false; }
    internal int  focus_order { get; set; default = -1; }
    internal FocusGroup focus_group {
        get {
            return m_FocusGroup;
        }
        set {
            if (m_FocusGroup != null)
            {
                m_FocusGroup.remove (this);
            }

            m_FocusGroup = value;

            if (m_FocusGroup != null)
            {
                m_FocusGroup.add (this);
            }
        }
        default = null;
    }


    public string? filename { get; set; default = null; }

    // static methods
    static construct
    {
        // Ref FocusGroup class to register focus group transform
        typeof (FocusGroup).class_ref ();
    }

    // methods
    construct
    {
        notify["filename"].connect  (on_filename_characters_changed);
        notify["characters"].connect  (on_filename_characters_changed);
        notify["size"].connect (on_size_changed);
    }

    public Image (string inId, string? inFilename)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), filename: inFilename);
    }

    private void
    on_size_changed ()
    {
        // Add property in manifest dump if size is not empty
        if (!size.is_empty ())
        {
            not_dumpable_attributes.remove ("size");
        }
        else
        {
            not_dumpable_attributes.insert ("size");
        }
    }

    private void
    on_filename_characters_changed ()
    {
        m_Image = null;
        need_update = true;
        geometry = null;
    }

    protected virtual Graphic.Image?
    create_image (Graphic.Size inSize)
    {
        if (filename != null)
        {
            return Graphic.Image.create (filename, inSize);
        }
        else if (characters != null)
        {
            return new Graphic.ImageSvg.from_data (characters, inSize);
        }

        return null;
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return false;
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        if (m_Image == null || !m_Image.size.equal (inSize))
        {
            m_Image = create_image (inSize);
        }

        if (m_Image != null)
        {
            notify["size"].disconnect (on_size_changed);
            size = m_Image.size;
            notify["size"].connect (on_size_changed);
        }

        return base.size_request (inSize);
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        if (m_Image != null)
        {
            inContext.save ();
            {
                inContext.pattern = m_Image;
                inContext.paint ();
            }
            inContext.restore ();
        }
    }
}
