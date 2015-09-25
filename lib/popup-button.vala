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
            if (m_Popup.content == null)
            {
                m_Popup.content = create_popup_content ();
            }
            return m_Popup.content;
        }
        set {
            if (m_Popup != null)
            {
                m_Popup.content = value;
            }
        }
        default = null;
    }

    public Graphic.Color  shadow_color  { get; set; default = new Graphic.Color (0, 0, 0); }
    public double         shadow_width  { get; set; default = 15; }
    public Window.Border  shadow_border { get; set; default = Window.Border.ALL; }
    public double         round_corner  { get; set; default = 5.0; }
    public bool           close_button  { get; set; default = true; }
    public double         popup_border  { get; set; default = 0.0; }

    // methods
    construct
    {
        // Create popup
        m_Popup = new Popup (@"$name-popup");
        m_Popup.window_type = Window.Type.TOPLEVEL;
        m_Popup.visible = false;
        m_Popup.placement = PopupPlacement.ABSOLUTE;

        // connect onto visible changed
        m_Popup.notify["visible"].connect (on_popup_visible_changed);

        // connect onto active changed
        notify["active"].connect (on_active_changed);

        // connect onto characters change
        notify["characters"].connect (on_characters_changed);
        on_characters_changed ();

        // plug background pattern property to popup
        plug_property ("background-pattern", m_Popup, "background-pattern");

        // plug stroke pattern property to popup
        plug_property ("stroke-pattern", m_Popup, "stroke-pattern");

        // plug transform property to window
        plug_property ("transform", m_Popup, "transform");

        // plug border property to window
        plug_property ("popup-border", m_Popup, "border");

        // plug shadow border property to window
        plug_property ("shadow-border", m_Popup, "shadow-border");

        // plug shadow width property to window
        plug_property ("shadow-width", m_Popup, "shadow-width");

        // plug shadow color property to window
        plug_property ("shadow-color", m_Popup, "shadow-color");

        // plug round corner property to window
        plug_property ("round-corner", m_Popup, "round-corner");

        // plug close button property to window
        plug_property ("close-button", m_Popup, "close-button");

        m_Popup.parent = this;
    }

    public PopupButton (string inId, string inLabel)
    {
        base (inId, inLabel);
    }

    private void
    on_popup_visible_changed ()
    {
        notify["active"].disconnect (on_active_changed);
        active = m_Popup.visible;
        notify["active"].connect (on_active_changed);

        if (active)
        {
            m_Popup.grab_pointer (m_Popup);
        }
        else
        {
            m_Popup.ungrab_pointer (m_Popup);
        }
    }

    private void
    on_active_changed ()
    {
        m_Popup.notify["visible"].disconnect (on_popup_visible_changed);
        m_Popup.visible = active;
        m_Popup.notify["visible"].connect (on_popup_visible_changed);

        if (active)
        {
            m_Popup.grab_pointer (m_Popup);
        }
        else
        {
            m_Popup.ungrab_pointer (m_Popup);
        }
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

            if (toplevel_window != null && m_Popup.content != null && m_Popup.visible)
            {
                m_Popup.transient_for = toplevel_window;

                // Set popup geometry
                var popup_area = Graphic.Rectangle (m_Popup.position.x, m_Popup.position.y,
                                                    m_Popup.content.size.width, m_Popup.content.size.height);

                m_Popup.update (inContext, new Graphic.Region (popup_area));
            }
        }
    }
}
