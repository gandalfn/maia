/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * image.vala
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

internal class Maia.Gtk.Image : Maia.Image
{
    // properties
    private string     m_IconName;
    private Gdk.Pixbuf m_Pixbuf;

    // accessors
    public string icon_name {
        get {
            return m_IconName;
        }
        set {
            if (m_IconName != value)
            {
                m_IconName = value;
                var icon_theme = global::Gtk.IconTheme.get_default ();
                var info = icon_theme.lookup_icon (m_IconName, -1, global::Gtk.IconLookupFlags.FORCE_SVG);
                filename = info.get_filename ();

                if (m_IconName != null)
                {
                    not_dumpable_attributes.insert ("filename");
                }
                else
                {
                    not_dumpable_attributes.remove ("filename");
                }
                damage ();
            }
        }
        default = null;
    }

    public Gdk.Pixbuf pixbuf {
        get {
            return m_Pixbuf;
        }
        set {
            if (m_Pixbuf != value)
            {
                m_Pixbuf = value;
                if (m_Pixbuf != null)
                {
                    not_dumpable_attributes.insert ("filename");
                    not_dumpable_attributes.insert ("icon-name");
                }
                else
                {
                    not_dumpable_attributes.remove ("filename");
                    not_dumpable_attributes.remove ("icon-name");
                }
                damage ();
            }
        }
    }

    // methods
    construct
    {
        not_dumpable_attributes.insert ("pixbuf");
    }

    public Image (string inId, string inIconName)
    {
        var icon_theme = global::Gtk.IconTheme.get_default ();
        var info = icon_theme.lookup_icon (m_IconName, -1, global::Gtk.IconLookupFlags.FORCE_SVG);
        base (inId, info.get_filename ());
    }

    internal override Graphic.Image?
    create_image (Graphic.Size inSize)
    {
        if (m_Pixbuf != null)
        {
            return new GdkPixbuf.ImagePixbuf (m_Pixbuf, inSize);
        }

        return base.create_image (inSize);
    }
}
