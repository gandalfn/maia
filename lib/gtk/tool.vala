/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * tool.vala
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

internal class Maia.Gtk.Tool : Maia.Tool
{
    // accessors
    public string? icon_name {
        get {
            unowned Image? icon_item = find (GLib.Quark.from_string ("%s-icon".printf (name)), false) as Image;
            if (icon_item != null)
            {
                return icon_item.icon_name;
            }

            return null;
        }
        set {
            unowned Image? icon_item = find (GLib.Quark.from_string ("%s-icon".printf (name)), false) as Image;
            if (icon_item != null)
            {
                icon_item.icon_name = value;
                if (value != null)
                {
                    not_dumpable_attributes.insert ("icon_filename");
                }
                else
                {
                    not_dumpable_attributes.remove ("icon_filename");
                }
            }
        }
        default = null;
    }

    // methods
    public Tool (string inId, string? inLabel = null)
    {
        base (inId, inLabel);
    }
}
