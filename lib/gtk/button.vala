/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * button.vala
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

internal class Maia.Gtk.Button : Maia.Button
{
    // properties
    private string m_IconName;

    // accessors
    public string? icon_name {
        get {
            return m_IconName;
        }
        set {
            if (m_IconName != value)
            {
                m_IconName = value;
                if (m_IconName != null)
                {
                    var icon_theme = global::Gtk.IconTheme.get_default ();
                    var info = icon_theme.lookup_icon (m_IconName, -1, global::Gtk.IconLookupFlags.FORCE_SVG);
                    icon_filename = info.get_filename ();
                    not_dumpable_attributes.insert ("icon-filename");
                }
                else
                {
                    icon_filename = null;
                    not_dumpable_attributes.remove ("icon-filename");
                }
            }
        }
        default = null;
    }

    // methods
    public Button (string inId, string? inLabel = null)
    {
        base (inId, inLabel);
    }
}
