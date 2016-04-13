/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * notebook-page.vala
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

public class Maia.NotebookPage : Group, ItemPackable
{
    // properties
    private unowned Item?   m_Content = null;
    private Toggle?         m_Toggle  = null;

    // accessors
    internal override string tag {
        get {
            return "NotebookPage";
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

    /**
     * Toggle button of page
     */
    [CCode (notify = false)]
    public unowned Toggle? toggle {
        get {
            if (m_Toggle == null)
            {
                m_Toggle = create_toggle ();
            }
            return m_Toggle;
        }
        set {
            if (m_Toggle != value)
            {
                not_dumpable_characters = false;
                m_Toggle = value;
                GLib.Signal.emit_by_name (this, "notify::toggle");
            }
        }
    }

    /**
     * The default font description of button label
     */
    public string font_description { get;  set; default = ""; }

    /**
     * Alignment of label ``left``, ``center`` or ``right``, default was ``center``
     */
    public Graphic.Glyph.Alignment alignment { get; set; default = Graphic.Glyph.Alignment.CENTER; }

    /**
     * The label of button
     */
    public string label { get; set; default = ""; }

    // static methods
    static construct
    {
        Manifest.Attribute.register_transform_func (typeof (Toggle), attribute_to_toggle);

        GLib.Value.register_transform_func (typeof (Toggle), typeof (string), toggle_value_to_string);
    }

    static void
    attribute_to_toggle (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        unowned Toggle? toggle = null;
        unowned Core.Object object = inAttribute.owner as Core.Object;

        if (object != null)
        {
            GLib.Quark id  = GLib.Quark.from_string (inAttribute.get ());
            for (unowned Core.Object item = object.parent; item != null; item = item.parent)
            {
                unowned View? view = item.parent as View;

                // If view is in view search toggle in cell first
                if (view != null)
                {
                    toggle = item.find (id, false) as Toggle;
                    if (toggle != null) break;
                }
                // We not found toggle in view parents search in root
                else if (item.parent == null)
                {
                    toggle = item.find (id) as Toggle;
                }
            }
        }

        outValue = toggle;
    }

    static void
    toggle_value_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Toggle)))
    {
        unowned Toggle val = (Toggle)inSrc;

        outDest = val.name;
    }

    // methods
    construct
    {
        not_dumpable_characters = true;

        stroke_pattern[State.NORMAL] = new Graphic.Color (0, 0, 0);

        characters = @"ButtonTab.$(name)_toggle {\n" +
                     @"    fill-pattern: @fill-pattern;\n" +
                     @"    stroke-pattern: @stroke-pattern;\n" +
                     @"    font-description: @font-description;\n" +
                     @"    alignment: @alignment;\n" +
                     @"    label: @label;\n" +
                     @"}";

        notify["characters"].connect (on_characters_changed);
    }

    public NotebookPage (string inId)
    {
        base (inId);
    }

    private void
    on_template_attribute_bind (Core.Notification inNotification)
    {
        unowned Manifest.Document.AttributeBindAddedNotification? notification = inNotification as Manifest.Document.AttributeBindAddedNotification;
        if (notification != null)
        {
            // plug property to binded property
            plug_property (notification.attribute.get (), notification.attribute.owner as Core.Object, notification.property);
        }
    }

    private void
    on_characters_changed ()
    {
        toggle = null;
    }

    private Toggle?
    create_toggle ()
    {
        if (characters != null && characters.length > 0)
        {
            // parse template
            try
            {
                var document = new Manifest.Document.from_buffer (characters, characters.length);
                document.path = manifest_path;
                document.theme = manifest_theme;
                document.notifications["attribute-bind-added"].add_object_observer (on_template_attribute_bind);
                return document.get () as Toggle;
            }
            catch (Core.ParseError err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING, "Error on parsing cell %s: %s", name, err.message);
            }
        }

        return null;
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Item && m_Content == null;
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        base.insert_child (inObject);

        if (can_append_child (inObject))
        {
            m_Content = inObject as Item;
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        base.remove_child (inObject);

        if (m_Content == inObject)
        {
            m_Content = null;
        }
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
            geometry = inAllocation;

            if (m_Content != null)
            {
                m_Content.update (inContext, area);
            }

            damage_area ();
        }
    }
}
