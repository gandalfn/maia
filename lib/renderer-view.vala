/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * renderer-view.vala
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

public class Maia.RendererView : Group, ItemPackable, ItemMovable
{
    // types
    private class Task : Core.Task
    {
        // properties
        private unowned RendererView   m_View;
        private Core.Task.EventWatch[] m_Damaged = {};

        // methods
        public Task (RendererView inView)
        {
            base ("task-renderer-view");
            m_View = inView;
        }

        private void
        on_new_frame (int inFrameNum)
        {
            m_View.m_Lock.lock ();
            m_View.renderer.render (inFrameNum);
            m_View.m_Lock.unlock ();

            lock (m_Damaged)
            {
                foreach (unowned Core.Task.EventWatch? f in m_Damaged)
                {
                    f.@signal ();
                }
            }
        }

        internal override void
        finish ()
        {
            m_Damaged = {};
            m_View.m_Looper.finish ();

            base.finish ();

            // Signal has task is finished
            m_View.m_Mutex.lock ();
            m_View.m_Cond.signal ();
            m_View.m_Mutex.unlock ();
        }

        internal override void
        main (GLib.MainContext? inContext)
        {
            m_View.m_Lock.lock ();
            m_View.renderer.start ();
            m_View.m_Lock.unlock ();

            m_View.m_Looper.prepare (on_new_frame);

            // Signal has task is running
            m_View.m_Mutex.lock ();
            m_View.m_Cond.signal ();
            m_View.m_Mutex.unlock ();
        }

        internal void
        add_damage_observer (Core.Task.Callback inCallback, GLib.MainContext? inContext = null)
        {
            lock (m_Damaged)
            {
                var f = new Core.Task.EventWatch (this, (Core.Task.EventWatch.DestroyNotifyFunc)unref);
                f.set_object_observer (inCallback);
                f.attach (inContext ?? GLib.MainContext.@default ());
                m_Damaged += f;
                ref ();
            }
        }
    }

    // properties
    private Graphic.Renderer.Looper m_Looper = null;
    private bool                    m_RendererDamaged = false;
    private Graphic.Renderer        m_Renderer;
    private Graphic.Surface         m_Front;
    private Graphic.Region          m_FrontDamaged;
    private Core.TaskPool           m_Pool;
    private Task                    m_Task;
    private bool                    m_Pause;
    private GLib.Mutex              m_Mutex = GLib.Mutex ();
    private GLib.Cond               m_Cond  = GLib.Cond ();
    private GLib.Mutex              m_Lock = GLib.Mutex ();

    // accessors
    internal override string tag {
        get {
            return "RendererView";
        }
    }

    internal override bool can_focus { get; set; default = true; }

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
     * Renderer looper
     */
    public Graphic.Renderer.Looper looper {
        get {
            return m_Looper;
        }
        set {
            if (m_Looper != value)
            {
                m_Looper = value;

                if (m_Task != null && m_Looper != null)
                {
                    cancel_task ();
                    create_task ();
                }
            }
        }
    }

    /**
     * Renderer
     */
    public Graphic.Renderer renderer {
        get {
            return m_Renderer;
        }
        set {
            m_Renderer = value;

            if (m_Task != null)
            {
                cancel_task ();
                create_task ();
            }
        }
    }

    /**
     * Pause task
     */
    public bool pause {
        get {
            return m_Pause;
        }
        set {
            if (m_Pause != value)
            {
                m_Pause = value;

                if (m_Pause && m_Task != null)
                {
                    cancel_task ();
                    m_Task = null;
                }
                else if (!m_Pause && m_Task == null)
                {
                    create_task ();
                }
            }
        }
    }


    // static methods
    static construct
    {
        Manifest.Function.register_transform_func (typeof (Graphic.Renderer.Looper), "timeline",  attribute_to_timeline);
    }

    static void
    attribute_to_timeline (Manifest.Function inFunction, ref GLib.Value outDest) throws Manifest.Error
    {
        outDest = new Graphic.Renderer.TimelineLooper.from_function (inFunction);
    }

    // methods
    construct
    {
        m_Pool = new Core.TaskPool ("task-pool-renderer-view");

        notify["visible"].connect (on_visible_changed);
        notify["window"].connect (on_visible_changed);
    }

    /**
     * Create a new renderer view item
     *
     * @param inId id of renderer view
     * @param inRenderer renderer
     */
    public RendererView (string inId, Graphic.Renderer inRenderer)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), renderer: inRenderer);
    }

    ~RendererView ()
    {
        cancel_task ();
    }

    private void
    cancel_task ()
    {
        if (m_Task != null && !m_Task.is_cancelled)
        {
            m_Mutex.lock ();
            {
                m_Task.cancel ();
                m_Cond.wait (m_Mutex);
                m_Task = null;
            }
            m_Mutex.unlock ();
        }
    }

    private void
    create_task ()
    {
        if (m_Task == null && m_Looper != null && !m_Pause)
        {
            m_Task = new Task (this);
            m_Task.add_damage_observer (on_renderer_damaged);

            m_Mutex.lock ();
            {
                m_Pool.push (m_Task);
                m_Cond.wait (m_Mutex);
            }
            m_Mutex.unlock ();
        }
    }

    private void
    on_visible_changed ()
    {
        if (window != null && visible && m_Task == null && m_Renderer != null)
        {
            create_task ();
        }
        else if ((window == null || !visible) && m_Task != null)
        {
            cancel_task ();
        }
    }

    private void
    add_front_damage (Graphic.Region? inArea)
    {
        if (inArea != null)
        {
            var damaged_area = area;
            damaged_area.intersect (inArea);

            if (!damaged_area.is_empty ())
            {
                if (m_FrontDamaged == null)
                {
                    m_FrontDamaged = damaged_area;
                }
                else if (m_FrontDamaged.contains_rectangle (damaged_area.extents) !=  Graphic.Region.Overlap.IN)
                {
                    m_FrontDamaged.union_ (damaged_area);
                }
            }
        }
        else
        {
            m_FrontDamaged = area;
        }
    }

    private bool
    on_renderer_damaged (Core.Task inTask)
    {
        m_RendererDamaged = true;
        damage.post ();
        m_RendererDamaged = false;

        return true;
    }

    internal override void
    on_damage_area (Graphic.Region inArea)
    {
        if (!m_RendererDamaged)
        {
            add_front_damage (inArea);
        }
    }

    internal override void
    on_child_damaged (Drawable inChild, Graphic.Region? inArea)
    {
        base.on_child_damaged (inChild, inArea);

        if (inChild.geometry != null)
        {
            Graphic.Region child_damaged_area;

            if (inArea == null)
            {
                child_damaged_area = inChild.geometry.copy ();
            }
            else
            {
                child_damaged_area = inChild.area_to_parent_item_space (inArea);
            }

            add_front_damage (child_damaged_area);
        }
    }

    internal override void
    on_damage (Graphic.Region? inArea)
    {
        if (!m_RendererDamaged)
        {
            base.on_damage (inArea);
            add_front_damage (inArea);
        }
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (!inAllocation.extents.is_empty () && (geometry == null || !geometry.equal (inAllocation)))
        {
            geometry = inAllocation;

            var item_area = area;
            if (m_Front == null || !m_Front.size.equal (item_area.extents.size))
            {
                m_Front = new Graphic.Surface.similar (inContext.surface, (int)item_area.extents.size.width, (int)item_area.extents.size.height);
            }

            if (m_Renderer != null)
            {
                if (!m_Renderer.size.equal (item_area.extents.size))
                {
                    cancel_task ();
                    m_Renderer.size = item_area.extents.size;
                    create_task ();
                }
                else if (m_Task == null)
                {
                    create_task ();
                }
            }

            foreach (unowned Core.Object child in this)
            {
                if (child is Item)
                {
                    unowned Item item = (Item)child;

                    // Get child position and size
                    var item_position = item.position;
                    var item_size     = item.size;

                    // Set child size allocation
                    var item_area_size = item_area.extents.size;
                    var child_allocation = Graphic.Rectangle (item_position.x, item_position.y,
                                                              item_position.x + item_size.width < item_area_size.width ? item_area_size.width : item_size.width,
                                                              item_position.y + item_size.height < item_area_size.height ? item_area_size.height : item_size.height);

                    // Update child allocation
                    item.update (inContext, new Graphic.Region (child_allocation));
                }
            }

            damage_area ();

            add_front_damage (null);
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        // paint background
        paint_background (inContext);

        // swap renderer content on view
        if (m_Renderer != null)
        {
            m_Lock.lock ();
            {
                inContext.operator = Graphic.Operator.OVER;
                inContext.pattern = m_Renderer.surface;
                inContext.paint ();
            }
            m_Lock.unlock ();
        }

        // paint childs
        if (m_FrontDamaged != null && !m_FrontDamaged.is_empty ())
        {
            var ctx = m_Front.context;
            foreach (unowned Core.Object child in this)
            {
                if (child is Drawable)
                {
                    unowned Drawable drawable = (Drawable)child;

                    if (drawable.damaged != null && !drawable.damaged.is_empty ())
                    {
                        var area = area_to_child_item_space (drawable, m_FrontDamaged);

                        ctx.save ();
                            ctx.clip (new Graphic.Path.from_region (m_FrontDamaged));
                            ctx.operator = Graphic.Operator.CLEAR;
                            ctx.paint ();

                            ctx.operator = Graphic.Operator.OVER;
                            drawable.draw (ctx, area);
                        ctx.restore ();
                    }
                }
            }

            m_FrontDamaged = null;
        }

        inContext.operator = Graphic.Operator.OVER;
        inContext.pattern = m_Front;
        inContext.paint ();
    }
}
