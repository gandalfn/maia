/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * notebook.vala
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

public class Maia.Notebook : Grid
{
    // type
    public enum Transition
    {
        NONE,
        OPACITY,
        SLIDE,
        ZOOM;

        public string
        to_string ()
        {
            switch (this)
            {
                case OPACITY:
                    return "opacity";

                case SLIDE:
                    return "slide";

                case ZOOM:
                    return "zoom";
            }

            return "none";
        }

        public static Transition
        from_string (string inValue)
        {
            switch (inValue.down ())
            {
                case "opacity":
                    return OPACITY;

                case "slide":
                    return SLIDE;

                case "zoom":
                    return ZOOM;
            }

            return NONE;
        }
    }

    // static properties
    private static GLib.Quark s_QuarkNotebookPageNum;

    // properties
    private uint               m_Page = 0;
    private uint               m_NbPages = 0;
    private ToggleGroup        m_TabGroup;
    private Core.EventListener m_TabGroupChangedListener;
    private unowned Grid       m_Tab = null;
    private Placement          m_Placement = Placement.TOP;
    private Graphic.Surface    m_CurrentPage = null;
    private Graphic.Surface    m_PrevPage = null;
    private Core.Animator      m_SwitchAnimator = null;
    private uint               m_SwitchTransition = 0;
    private double             m_SwitchProgress = 1.0;
    private bool               m_SwitchDirectionUp = false;

    // accessors
    internal override string tag {
        get {
            return "Notebook";
        }
    }

    [CCode (notify = false)]
    internal double switch_progress {
        get {
            return m_SwitchProgress;
        }
        set {
            m_SwitchProgress = value;
            damage.post ();
        }
    }

    /**
     * Active page number of notebook
     */
    [CCode (notify = false)]
    public uint page {
        get {
            return m_Page;
        }
        set {
            if (m_Page != value)
            {
                switch_page (value);
                GLib.Signal.emit_by_name (this, "notify::page");
            }
        }
    }

    /**
     * Number of pages in notebook
     */
    public uint n_pages {
        get {
            return m_NbPages;
        }
    }

    /**
     * Show tab
     */
    public bool show_tabs { get; set; default = true; }

    /**
     * Expand the child's tab.
     */
    public bool expand_tabs { get; set; default = false; }

    /**
     * Tab position
     */
    public Placement tab_placement {
        get {
            return m_Placement;
        }
        set {
            if (m_Placement != value)
            {
                m_Placement = value;

                foreach (unowned Toggle? toggle in m_TabGroup.toggles)
                {
                    if (toggle.parent == m_Tab)
                    {
                        uint pos = toggle.get_qdata<uint> (s_QuarkNotebookPageNum);

                        if (m_Placement == Placement.TOP || m_Placement == Placement.BOTTOM)
                        {
                            if (toggle.parent == m_Tab)
                            {
                                toggle.row = 0;
                                toggle.column = pos;
                            }
                            if (toggle is ButtonTab)
                            {
                                (toggle as ButtonTab).indicator_placement = m_Placement == Placement.TOP ? Placement.BOTTOM : Placement.TOP;
                            }
                        }
                        else
                        {
                            if (toggle.parent == m_Tab)
                            {
                                toggle.column = 0;
                                toggle.row = pos;
                            }
                            if (toggle is ButtonTab)
                            {
                                (toggle as ButtonTab).indicator_placement = m_Placement == Placement.LEFT ? Placement.RIGHT : Placement.LEFT;
                            }
                        }
                    }
                }

                unplug_property ("expand-tabs", m_Tab, "xfill");
                unplug_property ("expand-tabs", m_Tab, "xexpand");
                unplug_property ("expand-tabs", m_Tab, "yfill");
                unplug_property ("expand-tabs", m_Tab, "yexpand");
                if (m_Placement == Placement.TOP || m_Placement == Placement.BOTTOM)
                {
                    plug_property ("expand-tabs", m_Tab, "xfill");
                    plug_property ("expand-tabs", m_Tab, "xexpand");
                    m_Tab.yfill = false;
                    m_Tab.yexpand = false;
                    m_Tab.row = tab_placement == Placement.TOP ? 0 : 1;
                    m_Tab.column = 0;
                    foreach (unowned Core.Object child in this)
                    {
                        unowned NotebookPage page = child as NotebookPage;
                        if (page != null)
                        {
                            page.row = tab_placement == Placement.BOTTOM ? 0 : 1;
                            page.column = 0;
                        }
                    }
                }
                else
                {
                    m_Tab.xfill = false;
                    m_Tab.xexpand = false;
                    plug_property ("expand-tabs", m_Tab, "yfill");
                    plug_property ("expand-tabs", m_Tab, "yexpand");
                    m_Tab.column = tab_placement == Placement.LEFT ? 0 : 1;
                    m_Tab.row = 0;
                    foreach (unowned Core.Object child in this)
                    {
                        unowned NotebookPage page = child as NotebookPage;
                        if (page != null)
                        {
                            page.column = tab_placement == Placement.RIGHT ? 0 : 1;
                            page.row = 0;
                        }
                    }
                }
            }
        }
        default = Placement.TOP;
    }

    /**
     * Transition animation
     */
    [CCode (notify = false)]
    public Transition transition { get; set; default = Transition.NONE; }

    /**
     * Notebook toggle group
     */
    public ToggleGroup toggle_group {
        get {
            return m_TabGroup;
        }
    }

    // static methods
    static construct
    {
        s_QuarkNotebookPageNum = GLib.Quark.from_string ("MaiaNotebookPageNum");

        Manifest.Attribute.register_transform_func (typeof (Placement), attribute_to_tab_placement);
        Manifest.Attribute.register_transform_func (typeof (Transition), attribute_to_transition);

        GLib.Value.register_transform_func (typeof (Placement), typeof (string), tab_placement_to_value_string);
        GLib.Value.register_transform_func (typeof (Transition), typeof (string), transition_to_value_string);
    }

    static void
    attribute_to_tab_placement (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = Placement.from_string (inAttribute.get ());
    }

    static void
    tab_placement_to_value_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Placement)))
    {
        Placement val = (Placement)inSrc;

        outDest = val.to_string ();
    }

    static void
    attribute_to_transition (Manifest.Attribute inAttribute, ref GLib.Value outValue)
    {
        outValue = Transition.from_string (inAttribute.get ());
    }

    static void
    transition_to_value_string (GLib.Value inSrc, out GLib.Value outDest)
        requires (inSrc.holds (typeof (Transition)))
    {
        Transition val = (Transition)inSrc;

        outDest = val.to_string ();
    }

    // methods
    construct
    {
        // create switch animator
        m_SwitchAnimator = new Core.Animator (60, 120);

        // Create tab toggle group
        m_TabGroup = new ToggleGroup (@"$(name)-group");
        m_TabGroup.exclusive = true;
        m_TabGroupChangedListener = m_TabGroup.changed.object_subscribe (on_toggle_changed);

        // Create tab
        var tab = new Grid (@"$(name)-tabs");
        m_Tab = tab;
        m_Tab.yfill = false;
        m_Tab.yexpand = false;
        m_Tab.ylimp = true;
        m_Tab.xlimp = true;
        m_Tab.visible = true;
        m_Tab.parent = this;
        plug_property ("expand-tabs", m_Tab, "xfill");
        plug_property ("expand-tabs", m_Tab, "xexpand");
        plug_property("show-tabs", m_Tab, "visible");
        plug_property ("fill-pattern", m_Tab, "background-pattern");
    }

    public Notebook (string inId)
    {
        base (inId);
    }

    private void
    switch_page (uint inPage)
        requires (inPage < n_pages)
    {
        if (m_Page != inPage)
        {
            // Get old page
            if (m_Page >= 0 && m_Page < m_NbPages)
            {
                unowned NotebookPage? prev = get_nth_page (m_Page);
                prev.visible = false;
            }

            m_SwitchDirectionUp = inPage > m_Page;

            m_Page = inPage;

            // Get current page
            unowned NotebookPage? current = get_nth_page (m_Page);
            if (current != null)
            {
                current.visible = true;
                if (current.toggle != null)
                {
                    m_TabGroup.active = current.toggle.name;
                    current.toggle.active = true;
                }

                // prepare animation
                if (m_CurrentPage != null && transition != Transition.NONE)
                {
                    m_PrevPage = m_CurrentPage;

                    m_SwitchAnimator.stop ();

                    if (m_SwitchTransition > 0)
                    {
                        m_SwitchAnimator.remove_transition (m_SwitchTransition);
                    }

                    m_SwitchTransition = m_SwitchAnimator.add_transition (0, 1, Core.Animator.ProgressType.EXPONENTIAL, null, on_transition_finished);
                    m_SwitchProgress = 1.0 - m_SwitchProgress;
                    GLib.Value from = m_SwitchProgress;
                    GLib.Value to = 1.0;
                    m_SwitchAnimator.add_transition_property (m_SwitchTransition, this, "switch-progress", from, to);
                    m_SwitchAnimator.start ();
                }
            }
        }
    }

    private void
    on_transition_finished ()
    {
        m_PrevPage = null;
        m_SwitchProgress = 1.0;
        m_SwitchTransition = 0;
    }

    private void
    on_toggle_page_changed ()
    {
        int cpt = 0;
        foreach (unowned Core.Object child in this)
        {
            unowned NotebookPage page = child as NotebookPage;
            if (page != null)
            {
                unowned Toggle? found = null;
                foreach (unowned Toggle? toggle in m_TabGroup.toggles)
                {
                    if (toggle != null && toggle.get_qdata<uint> (s_QuarkNotebookPageNum) == cpt)
                    {
                        found = toggle;
                        break;
                    }
                }

                if (found != page.toggle)
                {
                    m_TabGroup.remove_button (found);
                    page.toggle.toggle_group = m_TabGroup;
                    page.toggle.set_qdata<uint> (s_QuarkNotebookPageNum, cpt);
                    page.toggle.active = found.active;

                    if (found.parent == m_Tab)
                    {
                        found.parent = null;
                    }

                    if (page.toggle.parent == null)
                    {
                        if (tab_placement == Placement.TOP || tab_placement == Placement.BOTTOM)
                        {
                            page.toggle.column = cpt;
                        }
                        else
                        {
                            page.toggle.row = cpt;
                        }
                        page.toggle.parent = m_Tab;
                    }

                    break;
                }

                cpt++;
            }
        }
    }

    private void
    on_toggle_changed (Core.EventArgs? inArgs)
    {
        unowned ToggleGroup.ChangedEventArgs? args = inArgs as ToggleGroup.ChangedEventArgs;
        if (args != null)
        {
            foreach (unowned Toggle? toggle in m_TabGroup.toggles)
            {
                if (toggle.name == args.active)
                {
                    switch_page (toggle.get_qdata<uint> (s_QuarkNotebookPageNum));
                    break;
                }
            }
        }
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return ((inObject is NotebookPage) || inObject == m_Tab);
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        base.insert_child (inObject);

        unowned NotebookPage? page = inObject as NotebookPage;
        if (page != null)
        {
            if (tab_placement == Placement.TOP || tab_placement == Placement.BOTTOM)
            {
                page.row = tab_placement == Placement.TOP ? 1 : 0;
                page.column = 0;
            }
            else
            {
                page.column = tab_placement == Placement.LEFT ? 1 : 0;
                page.row = 0;
            }
            page.visible = (m_Page == m_NbPages);
            page.notify["toggle"].connect (on_toggle_page_changed);
            if (page.toggle != null)
            {
                page.toggle.set_qdata<uint> (s_QuarkNotebookPageNum, m_NbPages);
                page.toggle.toggle_group = m_TabGroup;
                if (m_Page == m_NbPages)
                {
                    m_TabGroup.active = page.toggle.name;
                    page.toggle.active = true;
                }
                if (page.toggle.parent == null)
                {
                    if (tab_placement == Placement.TOP || tab_placement == Placement.BOTTOM)
                    {
                        page.toggle.column = m_NbPages;
                        if (page.toggle is ButtonTab)
                        {
                            (page.toggle as ButtonTab).indicator_placement = m_Placement == Placement.TOP ? Placement.BOTTOM : Placement.TOP;
                        }
                    }
                    else
                    {
                        page.toggle.row = m_NbPages;
                        if (page.toggle is ButtonTab)
                        {
                            (page.toggle as ButtonTab).indicator_placement = m_Placement == Placement.LEFT ? Placement.RIGHT : Placement.LEFT;
                        }
                    }
                    page.toggle.parent = m_Tab;
                }
            }
            m_NbPages++;
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        base.remove_child (inObject);

        unowned NotebookPage? page = inObject as NotebookPage;
        if (page != null)
        {
            page.notify["toggle"].disconnect (on_toggle_page_changed);
            if (page.toggle != null)
            {
                if (page.toggle.parent == m_Tab)
                {
                    page.toggle.parent = null;
                }
                m_TabGroup.remove_button (page.toggle);
            }
            m_NbPages--;
            if (m_NbPages == m_Page && m_Page > 0)
            {
                switch_page (m_Page - 1);
            }
        }
    }

    internal override Graphic.Size
    size_request (Graphic.Size inSize)
    {
        unowned NotebookPage? page_visible = null;

        foreach (unowned Core.Object child in this)
        {
            unowned NotebookPage? page = child as NotebookPage;
            if (page != null)
            {
                if (page.visible) page_visible = page;
                page.visible = true;
            }
        }

        Graphic.Size ret = base.size_request (inSize);

        foreach (unowned Core.Object child in this)
        {
            unowned NotebookPage? page = child as NotebookPage;
            if (page != null)
            {
                if (page != page_visible)
                {
                    page.visible = false;
                }
            }
        }

        return ret;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        base.update (inContext, inAllocation);

        var item_size = Graphic.Size (0, 0);
        foreach (unowned Core.Object child in this)
        {
            unowned NotebookPage? page = child as NotebookPage;
            if (page != null && page.visible)
            {
                var page_size = page.geometry != null ? page.geometry.extents.size : page.size;
                item_size.width = double.max (item_size.width, page_size.width);
                item_size.height = double.max (item_size.height, page_size.height);
            }
        }

        if (!item_size.is_empty ())
        {
            m_CurrentPage = new Graphic.Surface.similar (inContext.surface, (uint)GLib.Math.ceil (item_size.width), (uint)GLib.Math.ceil (item_size.height));
            m_CurrentPage.clear ();
        }
        else
        {
            m_CurrentPage = null;
        }
    }

    internal override void
    paint (Graphic.Context inContext, Graphic.Region inArea) throws Graphic.Error
    {
        if (m_CurrentPage != null)
        {
            m_CurrentPage.clear ();
            var ctx = m_CurrentPage.context;
            var page_origin = Graphic.Point (0, 0);

            ctx.save ();
            {
                // paint childs
                foreach (unowned Core.Object child in this)
                {
                    unowned NotebookPage? page = child as NotebookPage;
                    if (page != null && page.visible)
                    {
                        page_origin = page.geometry.extents.origin;
                        ctx.translate (page_origin.invert ());
                        page.draw (ctx, area_to_child_item_space (page, inArea));
                        break;
                    }
                }
            }
            ctx.restore ();

            inContext.save ();
            {
                // Draw tab
                m_Tab.draw (inContext, area_to_child_item_space (m_Tab, inArea));

                // Paint page
                inContext.translate (page_origin);
                switch (transition)
                {
                    case Transition.OPACITY:
                        if (m_PrevPage != null && m_SwitchProgress < 1.0)
                        {
                            inContext.pattern = m_PrevPage;
                            inContext.paint_with_alpha (1 - m_SwitchProgress);
                        }
                        inContext.pattern = m_CurrentPage;
                        inContext.paint_with_alpha (m_SwitchProgress);
                        break;

                    case Transition.ZOOM:
                        if (m_SwitchDirectionUp)
                        {
                            if (m_PrevPage != null && m_SwitchProgress < 1.0)
                            {
                                double scale = 0.5 + ((1.0 - m_SwitchProgress) / 2.0);
                                var surface_size = m_PrevPage.size;
                                inContext.save ();
                                {
                                    inContext.translate (Graphic.Point ((surface_size.width - (surface_size.width * scale)) / 2.0,
                                                                        (surface_size.height - (surface_size.height * scale)) / 2.0));
                                    inContext.transform = new Graphic.Transform.init_scale (scale, scale);
                                    inContext.pattern = m_PrevPage;
                                    inContext.paint_with_alpha (1 - m_SwitchProgress);
                                }
                                inContext.restore ();
                            }
                            inContext.pattern = m_CurrentPage;
                            inContext.paint_with_alpha (m_SwitchProgress);
                        }
                        else
                        {
                            if (m_PrevPage != null && m_SwitchProgress < 1.0)
                            {
                                inContext.pattern = m_PrevPage;
                                inContext.paint_with_alpha (1 - m_SwitchProgress);
                            }

                            if (m_SwitchProgress > 0)
                            {
                                double scale = 0.5 + (m_SwitchProgress / 2.0);
                                var surface_size = m_CurrentPage.size;
                                inContext.save ();
                                {
                                    inContext.translate (Graphic.Point ((surface_size.width - (surface_size.width * scale)) / 2.0,
                                                                        (surface_size.height - (surface_size.height * scale)) / 2.0));
                                    inContext.transform = new Graphic.Transform.init_scale (scale, scale);
                                    inContext.pattern = m_CurrentPage;
                                    inContext.paint_with_alpha (m_SwitchProgress);
                                }
                                inContext.restore ();
                            }
                        }
                        break;

                    default:
                        inContext.pattern = m_CurrentPage;
                        inContext.paint ();
                        break;
                }
            }
            inContext.restore ();
        }
    }

    public unowned NotebookPage?
    get_nth_page (uint inPage)
        requires (inPage < n_pages)
    {
        int cpt = 0;

        foreach (unowned Core.Object child in this)
        {
            unowned NotebookPage page = child as NotebookPage;
            if (page != null)
            {
                if (cpt == inPage) return page;
                cpt++;
            }
        }

        return null;
    }
}
