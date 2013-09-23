/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * shortcut.vala
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

public class Maia.Gtk.Shortcut : Maia.Shortcut
{
    // properties
    private global::Gtk.Button m_Button;
    private global::Gtk.Label m_Label;
    private global::Gtk.Image m_Image;

    // accessors
    public string icon_name { get; set; default = null; }
    public double angle { get; set; default = 0; }

    public global::Gtk.Button button {
        get {
            return m_Button;
        }
    }

    // methods
    internal override void
    delegate_construct ()
    {
        // Create button
        m_Button = new global::Gtk.Button ();

        var box = new global::Gtk.VBox (false, 5);
        box.show ();
        m_Button.add (box);

        m_Image = new global::Gtk.Image ();
        m_Image.show ();
        box.pack_start (m_Image, false, false, 0);

        m_Label = new global::Gtk.Label ("");
        m_Label.show ();
        box.pack_start (m_Label, true, true, 0);

        // Connect onto label change
        notify["label"].connect (() => {
            m_Label.set_markup (label ?? "");
        });

        // Connect onto angle change
        notify["angle"].connect (() => {
            m_Label.angle = (angle * 180) / GLib.Math.PI;
        });


        // Connect onto icon_name change
        notify["icon-name"].connect (() => {
            if (icon_name != null)
            {
                m_Image.set_from_icon_name (icon_name, global::Gtk.IconSize.DIALOG);
            }
            else
            {
                m_Image.clear ();
            }
        });

        // Connect onto section change
        notify["section"].connect (on_section_changed);

        // Connect onto button reparent
        m_Button.notify["parent"].connect (on_section_changed);

        // connect onto clicked
        m_Button.clicked.connect (activate);
    }

    private void
    on_section_changed ()
    {
        if (section != null)
        {
            unowned Item item = root.find (GLib.Quark.from_string (section)) as Item;
            if (item != null)
            {
                item.notify["visible"].connect (() => {
                    if (!item.visible)
                        m_Button.hide ();
                    else
                        m_Button.show ();
                });

                if (!item.visible)
                    m_Button.hide ();
                else
                    m_Button.show ();
            }
        }
    }
}
