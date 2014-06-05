/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * strength.vala
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

public class Maia.Cassowary.Strength : Core.Object
{
    // static properties
    private static Strength s_Required;
    private static Strength s_Strong;
    private static Strength s_Medium;
    private static Strength s_Weak;

    // static accessors
    public static Strength required {
        get {
            if (s_Required == null)
                s_Required = new Strength.with_values ("<Required>", 1000, 1000, 1000);
            return s_Required;
        }
    }

    public static Strength strong {
        get {
            if (s_Strong == null)
                s_Strong = new Strength.with_values ("strong", 1.0, 0.0, 0.0);
            return s_Strong;
        }
    }

    public static Strength medium {
        get {
            if (s_Medium == null)
                s_Medium = new Strength.with_values ("medium", 0.0, 1.0, 0.0);
            return s_Medium;
        }
    }

    public static Strength @weak {
        get {
            if (s_Weak == null)
                s_Weak = new Strength.with_values ("weak", 0.0, 0.0, 1.0);
            return s_Weak;
        }
    }

    // accessors
    public string name {
        get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    public SymbolicWeight symbolic_weight { get; construct; }

    public bool is_required {
        get {
            return this == s_Required;
        }
    }

    // methods
    public Strength (string inName, SymbolicWeight inSymbolicWeight)
    {
        GLib.Object (name: inName, symbolic_weight: inSymbolicWeight);
    }

    public Strength.with_values (string inName, double inW1, double inW2, double inW3)
    {
        GLib.Object (id: GLib.Quark.from_string (inName), symbolic_weight: new SymbolicWeight.with_weights (inW1, inW2, inW3));
    }

    internal override string
    to_string()
    {
        if (!is_required)
            return "%s:%s".printf (name, symbolic_weight.to_string ());
        else
            return name;
    }
}
