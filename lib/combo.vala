/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * combo.vala
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

public class Maia.Combo : Group, ItemPackable, ItemMovable
{
    // properties
    private bool m_PopupVisible = false;
    private Core.Animator m_PopupAnimator;
    private uint m_PopupTransition = 0;
    private double m_PopupProgress = 1.0;
    private int m_ActiveRow = -1;

    // accessors
    internal override string tag {
        get {
            return "Combo";
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

    public string   font_description { get; set; default = ""; }

    // signals
    public signal void changed ();

    // methods
    construct
    {
        // Add not dumpable attributes
        not_dumpable_attributes.insert ("popup-progress");

        // Create arrow
        string id_arrow = "%s-arrow".printf (name);
        var arrow_item = new Path (id_arrow, "M 0,0 L 50, 0, L 25, 50 Z");
        update_arrow_size (arrow_item);
        add (arrow_item);

        string id_label = "%s-label".printf (name);
        var label_item = new Label (id_label, "");
        add (label_item);

        label_item.text = "TEST 100";

        notify["stroke-pattern"].connect (() => {
            arrow_item.fill_pattern = stroke_pattern;
            label_item.stroke_pattern = stroke_pattern;
        });

        notify["font-description"].connect (() => {
            update_arrow_size (arrow_item);
            label_item.font_description = font_description;
        });

        arrow_item.button_press_event.connect (on_button_press);
        label_item.button_press_event.connect (on_button_press);

        // Connect onto button press
        button_press_event.connect (on_button_press);

        stroke_pattern = new Graphic.Color (0, 0, 0);

        // Create popup animator
        m_PopupAnimator = new Core.Animator (30, 200);
    }

    public Combo (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    update_arrow_size (Path inPath)
    {
        var glyph = new Graphic.Glyph (font_description);
        glyph.text = "00";

        // Create a fake surface to calculate the size of path
        var fake_surface = new Graphic.Surface (1, 1);
        glyph.update (fake_surface.context);
        inPath.path = "M 0,0 L %g,0 L %g,%g Z".printf (glyph.size.width, glyph.size.width / 2, glyph.size.height);
    }

    private bool
    on_button_press (uint inButton, Graphic.Point inPoint)
    {
        grab_focus (this);
        m_PopupVisible = !m_PopupVisible;

        m_PopupAnimator.stop ();
        if (m_PopupTransition > 0)
        {
            m_PopupAnimator.remove_transition (m_PopupTransition);
        }
        m_PopupTransition = m_PopupAnimator.add_transition (0, 1, Core.Animator.ProgressType.EXPONENTIAL, (p) => {
            m_PopupProgress = m_PopupVisible ? 1 - p : p;
            damage ();

            return true;
        });
        m_PopupAnimator.start ();

        damage ();
        return true;
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is View || inObject is Label || inObject is Path;
    }

    internal override Graphic.Size
    childs_size_request ()
    {
        Graphic.Size childs_size = Graphic.Size (0, 0);
        Graphic.Size view_size = Graphic.Size (0, 0);

        // Get size of first view child
        foreach (unowned Core.Object child in this)
        {
            if (child is View)
            {
                view_size = (child as View).size;
                break;
            }
        }

        // Get label size
        string id_label = "%s-label".printf (name);
        Label label_item = find (GLib.Quark.from_string (id_label), false) as Label;
        if (label_item != null)
        {
            var label_size = label_item.size;
            view_size.width = double.max (view_size.width, label_size.width);
            view_size.height = double.max (view_size.height, label_size.height);
        }

        // Get size of arrow
        string id_arrow = "%s-arrow".printf (name);
        Path arrow_item = find (GLib.Quark.from_string (id_arrow), false) as Path;
        if (arrow_item != null)
        {
            var arrow_size = arrow_item.size;
            if (view_size.width > 0)
            {
                childs_size.width = view_size.width + arrow_size.width + ((3 * arrow_size.width) / 2);
            }
            else
            {
                childs_size.width = arrow_size.width * 2;
            }

            if (view_size.height > 0)
            {
                childs_size.height = view_size.height + arrow_size.height;
            }
            else
            {
                childs_size.height = arrow_size.height * 2;
            }
        }

        return childs_size;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (geometry == null)
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "");

            geometry = inAllocation;

            // Update arrow position
            string id_arrow = "%s-arrow".printf (name);
            Path arrow_item = find (GLib.Quark.from_string (id_arrow), false) as Path;
            if (arrow_item != null)
            {
                var arrow_size = arrow_item.size_requested;
                var arrow_area = Graphic.Rectangle (inAllocation.extents.size.width - ((3 * arrow_size.width) / 2),
                                                    arrow_size.height / 2,
                                                    arrow_size.width, arrow_size.height);

                arrow_item.update (inContext, new Graphic.Region (arrow_area));

                // Update label position
                string id_label = "%s-label".printf (name);
                Label label_item = find (GLib.Quark.from_string (id_label), false) as Label;
                if (label_item != null)
                {
                    var label_area = Graphic.Rectangle (arrow_size.width / 2, arrow_size.height / 2,
                                                        inAllocation.extents.size.width - (arrow_size.width * 2),
                                                        label_item.size_requested.height);

                    label_item.update (inContext, new Graphic.Region (label_area));
                }

                // Get size of first view child
                foreach (unowned Core.Object child in this)
                {
                    if (child is View)
                    {
                        unowned View view = (View)child;
                        var view_position = Graphic.Point (arrow_size.width / 2, (arrow_size.height / 2) + label_item.size_requested.height);
                        var view_size = view.size;
                        view.update (inContext, new Graphic.Region (Graphic.Rectangle (view_position.x, view_position.y,
                                                                                       size_requested.width - arrow_size.width, view_size.height)));

                        var root_start = convert_to_root_space (view_position);
                        var view_end = Graphic.Point (view_position.x + view_size.width,
                                                      view_position.y + view_size.height);
                        var root_end = convert_to_root_space (view_end);
                        var root_area = Graphic.Rectangle (root_start.x, root_start.y,
                                                           root_start.x + root_end.x, root_start.y + root_end.y);
                        ((Drawable)root).damage (new Graphic.Region (root_area));
                        break;
                    }
                }
            }

            damage ();
        }
    }

    internal override void
    paint (Graphic.Context inContext) throws Graphic.Error
    {
         // paint background
        if (background_pattern != null)
        {
            inContext.save ();
            unowned Graphic.Image? image = background_pattern as Graphic.Image;
            if (image != null)
            {
                Graphic.Size image_size = image.size;
                double scale = double.max (geometry.extents.size.width / image.size.width, geometry.extents.size.height / image.size.height);
                image_size.width *= scale;
                image_size.height *= scale;
                (background_pattern as Graphic.Image).size = image_size;

                inContext.pattern = background_pattern;
                inContext.translate (Graphic.Point ((geometry.extents.size.width - image_size.width) / 2, (geometry.extents.size.height - image_size.height) / 2));
            }
            else
            {
                inContext.pattern = background_pattern;
            }

            inContext.paint ();
            inContext.restore ();
        }

        // paint childs
        var area = new Graphic.Region ();
        foreach (unowned Core.Object child in this)
        {
            if (child is Label || child is Path)
            {
                area.union_ (((Drawable)child).geometry);
                ((Drawable)child).draw (inContext);
            }
            else if (child is View && (m_PopupVisible || m_PopupAnimator.is_playing))
            {
                inContext.save ();
                {
                    var popup_area = ((Drawable)child).geometry.copy ();
                    var path_clip  = new Graphic.Path.from_region (popup_area);
                    inContext.clip (path_clip);

                    inContext.translate (Graphic.Point (0.0, -(m_PopupProgress * popup_area.extents.size.height)));
                    var path = new Graphic.Path.from_region (popup_area);
                    inContext.pattern = new Graphic.Color.parse ("#C0C0C0");
                    inContext.fill (path);

                    ((Drawable)child).draw (inContext);

                    inContext.pattern = stroke_pattern;
                    inContext.dash = null;
                    inContext.line_width = 1;
                    inContext.stroke (path);
                }
                inContext.restore ();
            }
        }

        if (m_PopupVisible)
        {
            var path = new Graphic.Path.from_region (area);
            inContext.pattern = stroke_pattern;
            inContext.dash = { 1, 1 };
            inContext.line_width = 0.5;
            inContext.stroke (path);
        }
    }
}
