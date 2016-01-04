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
        private unowned RendererView m_View;
        private Core.Timeline        m_Timeline;
        private Core.Event           m_Damaged;

        // events
        public Core.Event damaged {
            get {
                return m_Damaged;
            }
        }

        // methods
        public Task (RendererView inView)
        {
            base ("task-renderer-view");
            m_View = inView;
            m_Damaged = new Core.Event ("damaged", this);
        }

        private void
        on_new_frame (int inFrameNum)
        {
            m_View.m_Lock.lock ();
            m_View.renderer.render (inFrameNum);
            m_View.m_Lock.unlock ();

            damaged.publish ();
        }

        internal override void
        finish ()
        {
            base.finish ();

            // Signal has task is finished
            m_View.m_Mutex.lock ();
            m_View.m_Cond.signal ();
            m_View.m_Mutex.unlock ();
        }

        internal override void
        main (GLib.MainContext? inContext)
        {
            m_Timeline = new Core.Timeline (m_View.nb_frames, m_View.frame_rate);
            m_Timeline.loop = true;
            m_Timeline.new_frame.connect (on_new_frame);

            m_View.m_Lock.lock ();
            m_View.renderer.start ();
            m_View.m_Lock.unlock ();

            // Signal has task is running
            m_View.m_Mutex.lock ();
            m_View.m_Cond.signal ();
            m_View.m_Mutex.unlock ();

            // start timeline
            m_Timeline.start ();
        }
    }

    // properties
    private uint             m_FrameRate = 60;
    private uint             m_NbFrames = 60;
    private Graphic.Renderer m_Renderer;
    private Core.TaskPool    m_Pool;
    private Task             m_Task;
    private GLib.Mutex       m_Mutex = GLib.Mutex ();
    private GLib.Cond        m_Cond  = GLib.Cond ();
    private GLib.Mutex       m_Lock = GLib.Mutex ();

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
     * Refresh frame rate
     */
    public uint frame_rate {
        get {
            return m_FrameRate;
        }
        set {
            if (m_FrameRate != value)
            {
                m_FrameRate = value;

                if (m_Task != null)
                {
                    cancel_task ();
                    create_task ();
                }
            }
        }
    }

    /**
     * Nb frames
     */
    public uint nb_frames {
        get {
            return m_NbFrames;
        }
        set {
            if (m_NbFrames != value)
            {
                m_NbFrames = value;

                if (m_Task != null)
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
        if (m_Task == null)
        {
            m_Task = new Task (this);
            m_Task.damaged.object_subscribe (on_renderer_damaged);

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
    on_renderer_damaged (Core.EventArgs? inArgs)
    {
        damage ();
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (!inAllocation.extents.is_empty () && (geometry == null || !geometry.equal (inAllocation)))
        {
            geometry = inAllocation;

            if (m_Renderer != null)
            {
                if (!m_Renderer.size.equal (area.extents.size))
                {
                    cancel_task ();
                    create_task ();
                    m_Renderer.size = area.extents.size;
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
                    var area_size = area.extents.size;
                    var child_allocation = Graphic.Rectangle (item_position.x, item_position.y,
                                                              item_position.x + item_size.width < area_size.width ? area_size.width : item_size.width,
                                                              item_position.y + item_size.height < area_size.height ? area_size.height : item_size.height);

                    // Update child allocation
                    item.update (inContext, new Graphic.Region (child_allocation));
                }
            }

            damage_area ();
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
        foreach (unowned Core.Object child in this)
        {
            if (child is Drawable)
            {
                unowned Drawable drawable = (Drawable)child;

                var area = area_to_child_item_space (drawable, inArea);
                drawable.draw (inContext, area);
            }
        }
    }
}
