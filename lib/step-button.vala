/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * step-button.vala
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

public class Maia.StepButton : Item, ItemMovable, ItemPackable
{
    /**
     * Event args provided by step button on changed event
     */
    public class ChangedEventArgs : Core.EventArgs
    {
        // accessors
        /**
         * Active state of step button
         */
        public uint active {
            get {
                return (uint)this["active", 0];
            }
        }

        // static methods
        static construct
        {
            Core.EventArgs.register_protocol (typeof (ChangedEventArgs).name (),
                                              "Changed",
                                              "message Changed {"    +
                                              "     uint32 active;"  +
                                              "}");
        }

        // methods
        internal ChangedEventArgs (uint inActive)
        {
            this["active", 0] = (uint32)inActive;
        }
    }

    // properties
    private uint                   m_Active = 0;
    private Core.Animator          m_Animator = null;
    private uint                   m_Transition = 0;
    private double                 m_Progress = 0.0;
    private Label                  m_Label;
    private View                   m_View;
    private Graphic.Region[]       m_Areas;
    private int                    m_AreaClicked = -1;
    private bool                   m_Button1Pressed = false;
    private Graphic.Point          m_Button1Origin = Graphic.Point (0, 0);
    private Graphic.Surface        m_ViewSurface;
    private Graphic.LinearGradient m_ViewMask;

    // accessors
    internal override string tag {
        get {
            return "StepButton";
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

    internal override bool can_focus  {
        get {
            return parent is DrawingArea;
        }
        set {
            base.can_focus = value;
        }
    }

    /**
     * The default font description of button label
     */
    public string font_description { get;  set; default = ""; }

    /**
     * Alignment of button label ``left``, ``center`` or ``right``, default was ``center``
     */
    public Graphic.Glyph.Alignment alignment { get; set; default = Graphic.Glyph.Alignment.CENTER; }

    /**
     * The label of button
     */
    public string label { get; set; default = ""; }

    /**
     * The border around labels
     */
    public double border { get; set; default = 5; }

    /**
     * Space between each label
     */
    public double spacing { get; set; default = 5; }

    /**
     * Indicate if the button is sensitive
     */
    public bool sensitive { get; set; default = true; }

    /**
     * Display separator
     */
    public bool separator { get; set; default = true; }

    /**
     * Model
     */
    [CCode (notify = false)]
    public Model model {
        get {
            return m_View.model;
        }
        set {
            m_View.model = value;
        }
    }

    /**
     * Active row number
     */
    [CCode (notify = false)]
    public uint active {
        get {
            return m_Active;
        }
        set {
            if (m_Active != value)
            {
                m_Active = uint.min (value, m_View.model != null ? m_View.model.nb_rows : 0);

                launch_active_progess ((int)m_Active);

                changed.publish (new ChangedEventArgs (m_Active));

                GLib.Signal.emit_by_name (this, "notify::active");
            }
        }
    }

    [CCode (notify = false)]
    internal double progress
    {
        get {
            return m_Progress;
        }
        set {
            if (m_Progress != value)
            {
                m_Progress = value;
                damage.post ();
            }
        }
    }

    // events
    /**
     * Event emmitted when button was clicked
     */
    public Core.Event clicked { get; private set; }

    /**
     * Event emmitted when step of button was changed
     */
    public Core.Event changed { get; private set; }

    // static methods
    static construct
    {
        // Ref Mpdel class to register model transform
        typeof (Model).class_ref ();
    }

    // methods
    construct
    {
        // Create events
        clicked = new Core.Event ("clicked", this);
        changed = new Core.Event ("changed", this);

        // Set default properties
        stroke_pattern[State.NORMAL] = new Graphic.Color (0, 0, 0);

        // Create areas
        m_Areas = new Graphic.Region[4];

        // Create label
        m_Label = new Label (@"$name-label", "");
        m_Label.visible = true;

        // Create view
        m_View = new View (@"$name-view");
        m_View.layout = Grid.Layout.HOMOGENEOUS;
        m_View.orientation = Orientation.HORIZONTAL;
        m_View.visible = true;

        // Plug properties
        plug_property ("label",            m_Label, "text");
        plug_property ("stroke-pattern",   m_Label, "stroke-pattern");
        plug_property ("font-description", m_Label, "font-description");
        plug_property ("alignment",        m_Label, "alignment");
        plug_property ("spacing",          m_View,  "column-spacing");
        plug_property ("characters",       m_View,  "characters");

        // Create animator
        m_Animator = new Core.Animator (60, 120);
    }

    /**
     * Create a new step button
     *
     * @param inId id of item
     */
    public StepButton (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    inc_dec_active (bool inInc)
    {
        int val = (int)m_Active + (inInc ? 1 : -1);
        if (val < 0)
        {
            m_Active = (uint)((int)m_View.model.nb_rows + val) % (int)m_View.model.nb_rows;
        }
        else
        {
            m_Active = (uint)(val % (int)m_View.model.nb_rows);
        }

        launch_active_progess (val);

        changed.publish (new ChangedEventArgs (m_Active));

        GLib.Signal.emit_by_name (this, "notify::active");
    }

    private void
    launch_active_progess (int inActive)
    {
        m_Animator.stop ();

        if (m_Transition > 0)
        {
            m_Animator.remove_transition (m_Transition);
        }
        m_Transition = m_Animator.add_transition (0, 1, Core.Animator.ProgressType.EXPONENTIAL);
        uint nb = m_View.model != null ? m_View.model.nb_rows : 0;
        if (m_Progress < 0)
        {
            m_Progress = nb + m_Progress;
        }
        else if (m_Progress >= nb)
        {
            m_Progress = m_Progress - nb;
        }

        GLib.Value from = m_Progress;
        GLib.Value to = (double)inActive;
        m_Animator.add_transition_property (m_Transition, this, "progress", from, to);
        m_Animator.start ();
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        Graphic.Region area = new Graphic.Region ();

        var label_size = m_Label.size;
        Graphic.Rectangle label_area = Graphic.Rectangle (border, border, label_size.width + border, label_size.height + border);
        area.union_with_rect (label_area);

        if (model != null && model.nb_rows > 0)
        {
            // get view size
            var view_size = m_View.size;

            // Remove spacing between each column
            view_size.width -= spacing * (model.nb_rows - 1);

            // Calculate item size
            view_size.width /= model.nb_rows;

            // Three item has been visible
            view_size.width *= 3;
            view_size.width += spacing * 2.0;

            var view_area = Graphic.Rectangle (border, border + label_size.height + spacing, view_size.width + border, view_size.height + border);
            area.union_with_rect (view_area);
        }

        // get area size
        var ret = area.extents.size;

        return ret;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        base.update (inContext, inAllocation);

        if (model != null && model.nb_rows > 0)
        {
            var item_size = area.extents.size;
            item_size.resize (-border * 2.0, -border * 2.0);

            Graphic.Point start = Graphic.Point (0, 0);
            Graphic.Point end = Graphic.Point (item_size.width, 0);

            // Set label size allocation
            var label_size = m_Label.size;
            var label_area = Graphic.Rectangle (border, border, item_size.width, label_size.height);
            m_Label.update (inContext, new Graphic.Region (label_area));

            // Calculate size of one item
            item_size.width -= spacing * 2;
            item_size.width /= 3;

            // Calculate sensitive areas
            m_Areas[0] = new Graphic.Region (Graphic.Rectangle (border, border + label_size.height + spacing, item_size.width, item_size.height - label_size.height - spacing));
            m_Areas[1] = new Graphic.Region (Graphic.Rectangle (border + item_size.width + spacing, border + label_size.height + spacing, item_size.width, item_size.height - label_size.height - spacing));
            m_Areas[2] = new Graphic.Region (Graphic.Rectangle (border + ((item_size.width + spacing) * 2.0), border + label_size.height + spacing, item_size.width, item_size.height - label_size.height - spacing));
            m_Areas[3] = new Graphic.Region (label_area);

            // Calculate size of view
            item_size.width *= model.nb_rows;
            item_size.width += spacing * (model.nb_rows - 1);

            // Set view size allocation
            var view_size = m_View.size;
            var view_area = Graphic.Rectangle (0, 0, item_size.width, view_size.height);
            m_View.update (inContext, new Graphic.Region (view_area));

            // Create view surface
            m_ViewSurface = new Graphic.Surface.similar (inContext.surface, (uint)GLib.Math.ceil (item_size.width), (uint)GLib.Math.ceil (view_size.height));
            m_ViewSurface.clear ();

            // Create mask pattern
            var color = new Graphic.Color (0, 0, 0, 0);
            var color_half = new Graphic.Color (0, 0, 0, 0.5);
            var color_full = new Graphic.Color (0, 0, 0, 1.0);

            m_ViewMask = new Graphic.LinearGradient (start, end);
            m_ViewMask.add (new Graphic.Gradient.ColorStop (0, color));
            m_ViewMask.add (new Graphic.Gradient.ColorStop (m_Areas[1].extents.origin.x / end.x, color_half));
            m_ViewMask.add (new Graphic.Gradient.ColorStop (m_Areas[1].extents.origin.x / end.x, color_full));
            m_ViewMask.add (new Graphic.Gradient.ColorStop ((m_Areas[1].extents.origin.x + m_Areas[1].extents.size.width) / end.x, color_full));
            m_ViewMask.add (new Graphic.Gradient.ColorStop ((m_Areas[1].extents.origin.x + m_Areas[1].extents.size.width) / end.x, color_half));
            m_ViewMask.add (new Graphic.Gradient.ColorStop (1, color));
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        inContext.save ();
        {
            if (m_AreaClicked < 0 || fill_pattern == null)
            {
                paint_background (inContext);
            }
            else
            {
                inContext.save ();
                {
                    unowned Graphic.Image? image = fill_pattern[state] as Graphic.Image;
                    if (image != null)
                    {
                        var item_area = area;
                        Graphic.Size image_size = image.size;
                        double scale = double.max (image_size.width / item_area.extents.size.width,
                                                   image_size.height / item_area.extents.size.height);
                        var transform = new Graphic.Transform.identity ();
                        transform.scale (scale, scale);
                        inContext.translate (Graphic.Point ((item_area.extents.size.width - (image_size.width / scale)) / 2,
                                                            (item_area.extents.size.height - (image_size.height / scale)) / 2));
                        image.transform = transform;
                        inContext.pattern = fill_pattern[state];
                    }
                    else
                    {
                        inContext.pattern = fill_pattern[state];
                    }

                    inContext.paint ();
                }
                inContext.restore ();
            }

            // if we have any item in view
            if (m_View.model != null && m_View.model.nb_rows > 0)
            {
                var item_size = area.extents.size;
                item_size.resize (-border * 2.0, -border * 2.0);
                var label_area = m_Label.geometry.extents;

                // Draw label
                m_Label.damage_area ();
                m_Label.draw (inContext);

                // Calculate the view area
                double view_ypos = label_area.origin.y + label_area.size.height + spacing;
                double view_height = item_size.height - label_area.size.height - spacing;
                view_ypos += (view_height - m_View.geometry.extents.size.height) / 2.0;
                Graphic.Rectangle view_area = Graphic.Rectangle (border, view_ypos, item_size.width, view_height);

                // Calculate size of one item
                item_size.width -= spacing * 2;
                item_size.width /= 3;

                // Draw view on view surface
                m_ViewSurface.clear ();
                var ctx = m_ViewSurface.context;
                ctx.save ();
                {
                    ctx.translate (Graphic.Point (item_size.width + spacing - ((item_size.width + spacing) * m_Progress), 0));
                    m_View.damage_area ();
                    m_View.draw (ctx);
                }
                ctx.restore ();

                uint nb = m_View.model.nb_rows;

                if (m_Progress < 1)
                {
                    var view_size = m_View.geometry.extents.size;
                    double diff = 1.0 - m_Progress;

                    ctx.save ();
                    {
                        ctx.translate (Graphic.Point (-view_size.width + ((item_size.width + spacing) * diff), 0));

                        m_View.damage_area ();
                        m_View.draw (ctx);
                    }
                    ctx.restore ();
                    if (stroke_pattern[State.NORMAL] != null && separator)
                    {
                        ctx.save ();
                        {
                            var line = new Graphic.Path ();
                            line.move_to (((item_size.width + spacing) * diff), 0);
                            line.line_to (((item_size.width + spacing) * diff), view_size.height);
                            ctx.pattern = stroke_pattern[State.NORMAL];
                            ctx.stroke (line);
                        }
                        ctx.restore ();
                    }
                }
                else if (m_Progress > nb - 2)
                {
                    var view_size = m_View.geometry.extents.size;
                    double diff = nb - 1.0 - m_Progress;

                    ctx.save ();
                    {
                        ctx.translate (Graphic.Point (((item_size.width + spacing) * 2) + (item_size.width * diff), 0));

                        m_View.damage_area ();
                        m_View.draw (ctx);
                    }
                    ctx.restore ();
                    if (stroke_pattern[State.NORMAL] != null && separator)
                    {
                        ctx.save ();
                        {
                            var line = new Graphic.Path ();
                            line.move_to (((item_size.width + spacing) * 2) + ((item_size.width + (spacing / 2.0)) * diff), 0);
                            line.line_to (((item_size.width + spacing) * 2) + ((item_size.width + (spacing / 2.0)) * diff), view_size.height);
                            ctx.pattern = stroke_pattern[State.NORMAL];
                            ctx.stroke (line);
                        }
                        ctx.restore ();
                    }
                }

                // Paint view under button
                inContext.clip (new Graphic.Path.from_rectangle (view_area));
                inContext.translate (view_area.origin);
                inContext.pattern = m_ViewSurface;
                inContext.mask (m_ViewMask);
            }
        }
        inContext.restore ();
    }

    internal override bool
    on_button_press_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_press_event (inButton, inPoint);

        if (sensitive && ret && m_View.model != null)
        {
            m_AreaClicked = -1;
            if (inButton == 1)
            {
                if (!m_Areas[0].is_empty () && inPoint in m_Areas[0])
                {
                    m_AreaClicked = 0;
                }
                else if (!m_Areas[1].is_empty () && inPoint in m_Areas[1])
                {
                    m_AreaClicked = 1;
                }
                else if (!m_Areas[2].is_empty () && inPoint in m_Areas[2])
                {
                    m_AreaClicked = 2;
                }
                else if (!m_Areas[3].is_empty () && inPoint in m_Areas[3])
                {
                    m_AreaClicked = 3;
                }

                m_Button1Pressed = true;
                m_Button1Origin = inPoint;
            }
            else if (inButton == 4 && active >= 1)
            {
                m_AreaClicked = 0;
            }
            else if (inButton == 5)
            {
                m_AreaClicked = 2;
            }

            if (m_AreaClicked >= 0)
            {
                state = State.ACTIVE;

                grab_pointer (this);
            }
        }

        return ret;
    }

    internal override bool
    on_button_release_event (uint inButton, Graphic.Point inPoint)
    {
        bool ret = base.on_button_release_event (inButton, inPoint);

        if (m_AreaClicked >= 0)
        {
            if (inButton == 1)
            {
                if (m_AreaClicked == 0 && !m_Areas[0].is_empty () && inPoint in m_Areas[0])
                {
                    inc_dec_active (false);
                }
                else if ((m_AreaClicked == 1 && !m_Areas[1].is_empty () && inPoint in m_Areas[1]) || (m_AreaClicked == 3 && !m_Areas[3].is_empty () && inPoint in m_Areas[3]))
                {
                    clicked.publish ();
                }
                else if (m_AreaClicked == 2  && !m_Areas[2].is_empty () && inPoint in m_Areas[2])
                {
                    inc_dec_active (true);
                }
            }
            else if (inButton == 4 && ret)
            {
                inc_dec_active (false);
            }
            else if (inButton == 5 && ret)
            {
                inc_dec_active (true);
            }

            m_AreaClicked = -1;

            state = State.NORMAL;

            ungrab_pointer (this);
        }

        if (inButton == 1) m_Button1Pressed = false;

        return ret;
    }

    internal override bool
    on_motion_event (Graphic.Point inPoint)
    {
        bool ret = base.on_motion_event (inPoint);

        if (ret && m_Button1Pressed)
        {
            double diff = inPoint.x - m_Button1Origin.x;
            if (diff > 0 && diff > m_Areas[1].extents.size.width)
            {
                inc_dec_active (false);

                m_AreaClicked = -1;

                state = State.NORMAL;

                ungrab_pointer (this);

                m_Button1Origin = inPoint;
            }
            else if (diff < 0 && diff < -m_Areas[1].extents.size.width)
            {
                inc_dec_active (true);

                m_AreaClicked = -1;

                state = State.NORMAL;

                ungrab_pointer (this);

                m_Button1Origin = inPoint;
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
