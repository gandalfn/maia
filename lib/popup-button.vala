/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * popup-button.vala
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

public class Maia.PopupButton : ToggleButton
{
    // properties
    private Popup m_Popup;

    // accessors
    internal override string tag {
        get {
            return "PopupButton";
        }
    }

    public Item? content {
        get {
            return m_Popup.content;
        }
        set {
            // Clear popup
            if (m_Popup.content != null)
            {
                m_Popup.content.parent = null;
            }

            // Add item to popup
            if (value != null)
            {
                m_Popup.add (value);
            }
        }
    }

    // methods
    construct
    {
        // Create popup
        m_Popup = new Popup (@"$name-popup");
        m_Popup.visible = false;
        m_Popup.shadow_width = 15;
        m_Popup.round_corner = 5;
        m_Popup.close_button = true;
        m_Popup.placement = PopupPlacement.ABSOLUTE;
        m_Popup.parent = this;

        // connect onto visible changed
        m_Popup.notify["visible"].connect (on_popup_visible_changed);

        // connect onto active changed
        notify["active"].connect (on_active_changed);

        // connect onto characters change
        notify["characters"].connect (on_characters_changed);
        on_characters_changed ();

        // Connect onto background pattern change
        notify["background-pattern"].connect (on_background_pattern_changed);
        on_background_pattern_changed ();

        // Connect onto stroke pattern change
        notify["stroke-pattern"].connect (on_stroke_pattern_changed);
        on_stroke_pattern_changed ();
    }

    public PopupButton (string inId, string inLabel)
    {
        base (inId, inLabel);
    }

    private void
    on_background_pattern_changed ()
    {
        m_Popup.background_pattern = background_pattern;
    }

    private void
    on_stroke_pattern_changed ()
    {
        m_Popup.stroke_pattern = stroke_pattern;
    }

    private void
    on_popup_visible_changed ()
    {
        notify["active"].disconnect (on_active_changed);
        active = m_Popup.visible;
        notify["active"].connect (on_active_changed);
    }

    private void
    on_active_changed ()
    {
        m_Popup.notify["visible"].disconnect (on_popup_visible_changed);
        m_Popup.visible = active;
        m_Popup.notify["visible"].connect (on_popup_visible_changed);
    }

    private void
    on_characters_changed ()
    {
        content = create_popup_content ();
    }

    private Item?
    create_popup_content ()
    {
        // parse template
        try
        {
            Manifest.Document? document = null;

            if (characters != null && characters.length > 0)
            {
                document = new Manifest.Document.from_buffer (characters, characters.length);
                document.path = manifest_path;
                document.theme = manifest_theme;
            }

            if (document != null)
            {
                return document.get (null) as Item;
            }
        }
        catch (Core.ParseError err)
        {
            Log.critical (GLib.Log.METHOD, Log.Category.MANIFEST_PARSING,
                          "Error on parsing cell %s: %s", name, err.message);
        }

        return null;
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return base.can_append_child (inObject) || inObject is Popup;
    }

    internal override void
    update (Graphic.Context inContext, Graphic.Region inAllocation) throws Graphic.Error
    {
        if (visible && (geometry == null || !geometry.equal (inAllocation)))
        {
            Log.debug (GLib.Log.METHOD, Log.Category.CANVAS_GEOMETRY, "");

            base.update (inContext, inAllocation);

            var toplevel_window = toplevel;

            if (toplevel_window != null && m_Popup.content != null)
            {
                var window_size = toplevel_window.geometry.extents.size;
                var pos = toplevel_window.convert_to_root_space (Graphic.Point ((window_size.width - m_Popup.content.size.width) / 2,
                                                                                (window_size.height - m_Popup.content.size.height) / 2));

                m_Popup.position = convert_to_item_space (pos);

                // Set popup geometry
                var popup_area = Graphic.Rectangle (m_Popup.position.x, m_Popup.position.y,
                                                    m_Popup.content.size.width, m_Popup.content.size.height);

                m_Popup.update (inContext, new Graphic.Region (popup_area));
            }
        }
    }
}
