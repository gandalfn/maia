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
    public bool is_dummy {
        get {
            return false;
        }
    }

    public bool is_external {
        get {
            return true;
        }
    }

    public bool is_pivotable {
        get {
            return false;
        }
    }

    public bool is_restricted {
        get {
            return false;
        }
    }

    public double @value { get; private set; default = 0.0; }

    // methods
    public Variable (string inName, double inValue)
    {
        base.with_name (inName);
        @value = inValue;
    }

    public Variable.with_name (string inName)
    {
        base.with_name (inName);
    }
}
