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

    internal string         characters     { get; set; default = null; }
    internal string         style          { get; set; default = null; }
    internal string         manifest_path  { get; set; default = null; }
    internal Manifest.Theme manifest_theme { get; set; default = null; }

    /**
     * The section to scroll to on shortcut activation
     */
    public string section { get; set; default = null; }

    /**
     * The shortcut label
     */
    public string label   { get; set; default = null; }
}
