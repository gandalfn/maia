/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * abstract-variable.vala
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

public abstract class Maia.Cassowary.AbstractVariable : Object
{
    // static properties
    private static long s_Number = 0;

    // accessors
    public string name {
        get {
            return ((GLib.Quark)id).to_string ();
        }
        set {
            id = GLib.Quark.from_string (value);
            s_Number++;
        }
    }

    public abstract bool is_external { get; }
    public abstract bool is_pivotable { get; }
    public abstract bool is_restricted { get; }

    // methods
    public AbstractVariable ()
    {
        GLib.Object (name: "v%li".printf (s_Number));
    }

    public AbstractVariable.with_name (string inName)
    {
        GLib.Object (name: inName);
    }

    public AbstractVariable.with_prefix (long inVarNumber, string inPrefix)
    {
        GLib.Object (name: "%s%li".printf (inPrefix, inVarNumber));
    }
}
