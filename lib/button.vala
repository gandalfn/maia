/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * button.vala
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

/**
 * An item that emits an event when clicked on
 *
 * =Manifest description:=
 *
 * {{{
 *      Button.<id> {
 *          font_description: 'Liberation Sans 12';
 *          icon_filename: '/path/filename';
 *          button_color: '#C0C0C0';
 *      }
 * }}}
 *
 */
public class Maia.Button : Item, ItemPackable, ItemMovable
{
    // types
    public enum Relief
    {
        NORMAL,
        NONE;

        public string
        to_string ()
        {
            switch (this)
            {
                case NORMAL:
                    return "normal";

                case NONE:
                    return "none";
            }

            return "none";
        }

        public static Relief
        from_string (string inValue)
        {
            switch (inValue.down ())
            {
                case "normal":
                    return NORMAL;

                case "none":
                    return NONE;
            }

            return NONE;
        }
    }

    // properties
    private bool          m_Clicked = false;
    private unowned Item? m_Content = null;

    // accessors
    internal override string tag {
        get {
            return "Button";
        }
    }

    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal bool   xshrink { get; set; default = true; }
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

    internal override bool can_focus  { get; set; default = true; }

    /**
     * The default font description of button label
     */
    public string font_description { get;  set; default = ""; }

    /**
     * Alignment of label ``left``, ``center`` or ``right``, default was ``center``
     */
    public Graphic.Glyph.Alignment alignment { get; set; default = Graphic.Glyph.Alignment.CENTER; }

    /**
     * Shade color of label
     */
    public Graphic.Color shade_color { get; set; default = null; }

    /**
     * The label of button
     */
    public string label { get; set; default = ""; }

    /**
     * The border around button content
     */
    public double border { get; set; default = 5.0; }

    /**
     * The spacing between button component
     */
    public double spacing { get; set; default = 5.0; }

    /**
     * Indicate if the button is sensitive
     */
    public bool sensitive { get; set; default = true; }

    /**
     * The icon filename no icon if ``null``
     */
    public string icon_filename { get; set; default = null; }

    /**
     * The icon size
     */
    public Graphic.Size icon_size { get; set; default = Graphic.Size (0, 0); }

    /**
     * Sets the relief style of the edges of the button
     */
    public Relief relief { get; set; default = Relief.NORMAL; }

    // events
    /**
     * Event emmitted when button was clicked
     */
    public Core.Event clicked { get; private set; }

    // static methods
    static construct
    {
        Manifest.Attribute.register_transform_func (typeof (Relief), attribute_to_relief_value);

        GLib.Value.register_transform_func (typeof (Relief), typeof (string), relief_value_to_string);
    }

    static void
    attribute_to_relief_value (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = Relief.from_string (inAttribute.get ());
    }

    static void
    relief_value_to_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Relief)))
    {
        Relief val = (Relief)inSrc;

        outDest = val.to_string ();
    }

    // methods
    construct
    {
        // Create clicked event
        clicked = new Core.Event ("clicked", this);

        // Set default property
        fill_pattern   = new Item.StatePatterns (Item.State.NORMAL, new Graphic.Color (0.7, 0.7, 0.7));
        stroke_pattern = new Item.StatePatterns (Item.State.NORMAL, new Graphic.Color (0, 0, 0));

        // Set default content
        characters = @"Grid.$(name)_content { " +
                     @"    column-spacing: @spacing;" +
                     @"    Image.$(name)_image { "    +
                     @"        yfill: false;" +
                     @"        yexpand: true;" +
                     @"        xexpand: false;" +
                     @"        xfill: false;" +
                     @"        xlimp: true;" +
                     @"        filename: @icon-filename;" +
                     @"        size: @icon-size;" +
                     @"    }" +
                     @"    Label.$(name)_label { "    +
                     @"        column: 1; "    +
                     @"        yfill: false;" +
                     @"        yexpand: true;" +
                     @"        xexpand: true;" +
                     @"        xfill: true;" +
                     @"        xlimp: true;" +
                     @"        alignment: @alignment;" +
                     @"        shade-color: @shade-color;" +
                     @"        font-description: @font-description;" +
                     @"        stroke-pattern: @stroke-pattern;" +
                     @"        text: @label;" +
                     @"    }" +
                     @"}";
    }

    /**
     * Create a new button
     *
     * @param inId id of item
     * @param inLabel the label of button ``null`` if none
     */
    public Button (string inId, string? inLabel = null)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), label: inLabel);
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

    private Item?
    create_content ()
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
                return document.get () as Item;
            }
            catch (Core.ParseError err)
            {
                Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING, "Error on parsing cell %s: %s", name, err.message);
            }
        }

        return null;
    }

    private Graphic.Pattern
    get_button_pattern () throws Graphic.Error
    {
        // Paint Background
        var button_size = geometry.extents.size;
        button_size.resize (-border * 2, -border * 2);

        double vb = 1, ve = 1.1, vd = 0.95, vd2 = 0.85;

        if (m_Clicked && sensitive)
        {
            vb = 1.1;
            ve = 1;
            vd = 1.05;
            vd2 = 1.15;
        }
        var button_color = fill_pattern[Item.State.NORMAL] as Graphic.Color;
        var button_inactive_color = fill_pattern[Item.State.INSENSITIVE] as Graphic.Color;
        var beginColor = new Graphic.Color.shade (sensitive ? button_color : button_inactive_color ?? button_color, vb);
        var endColor = new Graphic.Color.shade (sensitive ? button_color : button_inactive_color ?? button_color, ve);

        if (shade_color == null || shade_color.compare (beginColor) != 0)
        {
            shade_color = beginColor;
        }

        if (relief == Relief.NORMAL)
        {
            var pattern = new Graphic.MeshGradient ();
            var topleft = new Graphic.MeshGradient.ArcPatch (Graphic.Point (border, border),
                                                             -GLib.Math.PI, -GLib.Math.PI / 2, border,
                                                             { beginColor, endColor, endColor, beginColor });

            var color1 = endColor;
            var color2 =  new Graphic.Color.shade (color1, vd);
            var top =  new Graphic.MeshGradient.LinePatch (Graphic.Rectangle (border, 0,
                                                                              button_size.width,
                                                                              border),
                                                           { color1, color2, beginColor, beginColor });

            var topright = new Graphic.MeshGradient.ArcPatch (Graphic.Point (button_size.width + border, border),
                                                              -GLib.Math.PI / 2, 0, border,
                                                              { beginColor, color2, color2, beginColor });

            var color3 = color2;
            var color4 =  new Graphic.Color.shade (color3, vd2);
            var right =  new Graphic.MeshGradient.LinePatch (Graphic.Rectangle (button_size.width + border, border,
                                                                                border, button_size.height),
                                                             { beginColor, color3, color4, beginColor });

            var bottomright = new Graphic.MeshGradient.ArcPatch (Graphic.Point (button_size.width + border,
                                                                                button_size.height + border),
                                                                 0, GLib.Math.PI / 2, border,
                                                                 { beginColor, color4, color4, beginColor });

            var bottom =  new Graphic.MeshGradient.LinePatch (Graphic.Rectangle (border, button_size.height + border,
                                                                                 button_size.width, border),
                                                             { beginColor, beginColor, color4, color2 });

            var bottomleft = new Graphic.MeshGradient.ArcPatch (Graphic.Point (border, button_size.height + border),
                                                                GLib.Math.PI / 2, GLib.Math.PI, border,
                                                                { beginColor, color2, color2, beginColor });

            var left =  new Graphic.MeshGradient.LinePatch (Graphic.Rectangle (0, border,
                                                                               border, button_size.height),
                                                           { color1, beginColor, beginColor, color2 });

            var main =  new Graphic.MeshGradient.LinePatch (Graphic.Rectangle (border, border,
                                                                               button_size.width, button_size.height),
                                                           { beginColor, beginColor, beginColor, beginColor });

            pattern.add (topleft);
            pattern.add (top);
            pattern.add (topright);
            pattern.add (right);
            pattern.add (bottomright);
            pattern.add (bottom);
            pattern.add (bottomleft);
            pattern.add (left);
            pattern.add (main);
            return pattern;
        }

        return beginColor;
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return m_Content == null;
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        Graphic.Size ret = Graphic.Size (border * 2.0, border * 2.0);
        if (m_Content == null && characters != null)
        {
            var content = create_content ();
            add (content);
            m_Content = content;
        }

        if (m_Content != null)
        {
            var area = Graphic.Rectangle (0, 0, border * 2.0, border * 2.0);
            var content_size = m_Content.size;
            area.union_ (Graphic.Rectangle (border, border, content_size.width, content_size.height));

            ret = area.size;
            ret.resize (border, border);
        }

        return ret;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
            geometry = inAllocation;

            if (m_Content != null)
            {
                var item_size = area.extents.size;
                item_size.resize (-border * 2.0, -border * 2.0);
                var content_size = m_Content.size;
                m_Content.update (inContext, new Graphic.Region (Graphic.Rectangle (border, border + ((item_size.height - content_size.height) / 2.0 ), item_size.width, content_size.height)));
            }

            damage_area ();
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        inContext.save ();
        {
            // Paint button background
            if (fill_pattern[Item.State.NORMAL] != null && fill_pattern[Item.State.NORMAL] is Graphic.Color)
            {
                inContext.pattern = get_button_pattern ();
                inContext.paint ();
            }

            if (m_Content != null)
            {
                var child_area = area_to_child_item_space (m_Content, inArea);
                m_Content.draw (inContext, child_area);
            }
        }
        inContext.restore ();
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_press_event (inButton, inPoint);

        if (sensitive && ret && inButton == 1)
        {
            m_Clicked = true;

            grab_pointer (this);

            damage.post ();
        }

        return ret;
    }

    internal override bool
    on_button_release_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_release_event (inButton, inPoint);

        if (inButton == 1 && m_Clicked)
        {
            m_Clicked = false;

            ungrab_pointer (this);

            damage.post ();

            if (ret)
            {
                clicked.publish ();
            }
        }

        return ret;
    }

    internal override string
    dump_childs (string inPrefix)
    {
        return "";
    }
}
