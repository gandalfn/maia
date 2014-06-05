/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * variable.vala
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

public class Maia.Cassowary.Variable : AbstractVariable
{
    // accessors
    internal override bool is_external {
        get {
            return true;
        }
    }

    internal override bool is_pivotable {
        get {
            return false;
        }
    }

    internal override bool is_restricted {
        get {
            return false;
        }
    }

    public double @value { get; set; default = 0.0; }

    // methods
    public Variable (double inValue)
    {
        base ();
        @value = inValue;
    }

    public Variable.with_name (string inName)
    {
        base.with_name (inName);
    }

    public Variable.with_name_and_value (string inName, double inValue)
    {
        base.with_name (inName);
        @value = inValue;
    }

    public Variable.with_prefix (long inNumber, string inPrefix)
    {
        base.with_prefix (inNumber, inPrefix);
    }

    public Variable.with_prefix_and_value (long inNumber, string inPrefix, double inValue)
    {
        base.with_prefix (inNumber, inPrefix);
        @value = inValue;
    }

    internal override string
    to_string ()
    {
        return name;
    }
}
