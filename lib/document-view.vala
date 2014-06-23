/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * document-view.vala
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

public class Maia.DocumentView : Group
{
    // static properties
    private static GLib.Quark s_QuarkShortcut;
    
    // properties
    private unowned Document m_Document;
    private ScrollView       m_Content;
    private ToggleGroup      m_ShortcutsGroup;
    private Model            m_Shortcuts;
    private View             m_ShortcutsToolbar;
    
    // accessors
    internal override string tag {
        get {
            return "DocumentView";
        }
    }

    public bool fit_width  { get; set; default = false; }
    public bool fit_height { get; set; default = false; }

    // static methods
    static construct
    {
        s_QuarkShortcut = GLib.Quark.from_string ("MaiaDocumentViewShortcut");
    }
    
    // methods
    construct
    {
        // Create document scroll view
        m_Content = new ScrollView (@"$(name)-content");
        m_Content.parent = this;

        // Create shortcut model
        m_Shortcuts = new Model (@"$(name)-model", "shortcut", typeof (Shortcut));
        
        // Create toolbar grid
        m_ShortcutsToolbar = new View (@"$(name)-shortcuts-toolbar");
        m_ShortcutsToolbar.column = 1;
        m_ShortcutsToolbar.xexpand = false;
        m_ShortcutsToolbar.characters = @"ToggleButton.$(name)-shortcut-button {\n"+
                                         "   top_padding: 5;\n" +
                                         "   left_padding: 5;\n" +
                                         "   right_padding: 5;\n" +
                                         "   yexpand: false;\n" +
                                         "   label: @shortcut;\n" +
                                         "}";
        m_ShortcutsToolbar.set_property_func (on_shortcut_property_func);
        m_ShortcutsToolbar.model = m_Shortcuts;
        m_ShortcutsToolbar.parent = this;

        // Create  shortcuts group
        m_ShortcutsGroup = new ToggleGroup (@"$(name)-shortcuts-group");
    }

    public DocumentView (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    on_shortcut_button_toggled (Core.EventArgs? inArgs)
    {
        var arg = inArgs as Toggle.ToggledEventArgs;
        if (arg != null && arg.active)
        {
            // Get shortcut associated with button
            var id_shortcut = GLib.Quark.from_string (arg.button_name);
            for (int cpt = 0; cpt < m_Shortcuts.nb_rows; ++cpt)
            {
                Shortcut? shortcut = (Shortcut?)m_Shortcuts["shortcut"][cpt];
                if (shortcut.id == id_shortcut)
                {
                    if (shortcut.section != null)
                    {
                        unowned Item item = m_Document.find (GLib.Quark.from_string (shortcut.section)) as Item;
                        if (item != null)
                        {
                            item.scroll_to (item);
                        }
                    }
                    break;
                }
            }
        }
    }

    private void
    on_shortcut_section_changed (GLib.Object inObject)
    {
        if (m_Document != null)
        {
            unowned Shortcut shortcut = inObject as Shortcut;
            unowned ToggleButton button = shortcut.get_qdata<unowned ToggleButton> (s_QuarkShortcut);

            if (shortcut.section != null)
            {
                unowned Item item = m_Document.find (GLib.Quark.from_string (shortcut.section)) as Item;
                if (item != null)
                {
                    item.bind_property ("visible", button, "visible", GLib.BindingFlags.SYNC_CREATE);
                }
            }
        }
    }

    private bool
    on_shortcut_property_func (GLib.Object inObject, string inProperty, string inColumnName, uint inRow)
    {
        bool ret = false;
        switch (inColumnName)
        {
            case "shortcut":
                // get shortcut associated
                Shortcut? shortcut = (Shortcut?)m_Shortcuts["shortcut"][inRow];
                if (shortcut != null)
                {
                    // Get button in view
                    unowned ToggleButton? button = inObject as ToggleButton;
                    if (button != null)
                    {
                        // check if button is already connected
                        unowned Shortcut? data = button.get_qdata<unowned Shortcut> (s_QuarkShortcut);
                        if (data == null)
                        {
                            shortcut.bind_property ("label", button, "label", GLib.BindingFlags.SYNC_CREATE);
                            shortcut.notify["section"].connect ((o, p) => { on_shortcut_section_changed (o); });
                            
                            button.id = shortcut.id;

                            m_ShortcutsGroup.add_button (button);

                            button.set_qdata (s_QuarkShortcut, shortcut);
                            shortcut.set_qdata (s_QuarkShortcut, button);
                            
                            button.toggled.subscribe (on_shortcut_button_toggled);
                        }
                    }
                }

                ret = true;
                break;
        }

        return ret;
    }

    internal override bool
    can_append_child (Core.Object inChild)
    {
        return inChild is ScrollView || inChild is Grid || inChild is Shortcut;
    }

    internal override void
    insert_child (Core.Object inObject)
    {
        if (!(inObject is Document))
        {
            base.insert_child (inObject);

            if (inObject is Shortcut)
            {
                // Add shortcut in model
                uint row;
                if (m_Shortcuts.append_row (out row))
                {
                    m_Shortcuts["shortcut"][row] = inObject as Shortcut;
                }
            }
        }
        else if (m_Document == null)
        {
            // Add document to scroll view
            m_Document = inObject as Document;
            m_Document.parent = m_Content;

            for (int cpt = 0; cpt < m_Shortcuts.nb_rows; ++cpt)
            {
                Shortcut? shortcut = (Shortcut?)m_Shortcuts["shortcut"][cpt];
                if (shortcut != null)
                {
                    on_shortcut_section_changed (shortcut);
                }
            }
        }
    }

    internal override void
    remove_child (Core.Object inObject)
    {
        if (inObject == m_Document)
        {
            m_Document.parent = null;
            m_Document = null;
        }
        else
        {
            if (inObject is Shortcut && m_Shortcuts != null)
            {
                // Search shortcut in model
                for (int cpt = 0; cpt < m_Shortcuts.nb_rows; ++cpt)
                {
                    Shortcut? shortcut = (Shortcut?)m_Shortcuts["shortcut"][cpt];
                    if (shortcut == inObject)
                    {
                        // Remove button from group
                        var button = m_ShortcutsToolbar.get_item (cpt) as Toggle;
                        if (button != null)
                        {
                            m_ShortcutsGroup.remove_button (button);
                        }

                        // remove shortcut from model
                        m_Shortcuts.remove_row (cpt);

                        break;
                    }
                }
            }

            base.remove_child (inObject);
        }
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "");

            geometry = inAllocation;

            // Get shortcuts toolbar size
            var toolbar_size = m_ShortcutsToolbar.size;

            // Calculate content allocation            
            var content_allocation = Graphic.Rectangle (0, 0, geometry.extents.size.width - toolbar_size.width, geometry.extents.size.height);

            // Manage fit properties
            if (fit_width || fit_height)
            {
                double scale_x = 1, scale_y = 1;
                
                var content_size = m_Document.size;

                if (fit_width)
                {
                    scale_x = content_allocation.size.width / (content_size.width - 5);
                }
                if (fit_height)
                {
                    scale_y = content_allocation.size.height / (content_size.height - 5);
                }

                m_Document.transform = new Graphic.Transform.init_scale (scale_x == 1 ? scale_y : scale_x, scale_y == 1 ? scale_x : scale_y);
                content_size = m_Content.size;
            }

            // Set content allocation
            m_Content.update (inContext, new Graphic.Region (content_allocation));

            // Set toolbar  allocation
            var toolbar_allocation = Graphic.Rectangle (geometry.extents.size.width - toolbar_size.width, 0, toolbar_size.width, geometry.extents.size.height);
            m_ShortcutsToolbar.update (inContext, new Graphic.Region (toolbar_allocation));

            damage_area ();
        }
    }
}
