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

public class Maia.Shortcut : Core.Object, Manifest.Element
{
    // accessors
    internal string tag {
        get {
            return "Shortcut";
        }
    }

    internal string characters { get; set; default = null; }
    internal string manifest_path { get; set; default = null; }
    internal Core.Set<Manifest.Style> manifest_styles { get; set; default = null; }


    public string section { get; set; default = null; }
    public string label { get; set; default = null; }

    // methods
    public void
    activate ()
    {
        if (section != null)
        {
            unowned Item item = root.find (GLib.Quark.from_string (section)) as Item;
            if (item != null)
            {
                item.scroll_to (item);
            }
        }
    }
}
