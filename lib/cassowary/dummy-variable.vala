/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * dummy-variable.vala
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

internal class Maia.Cassowary.DummyVariable : AbstractVariable
{
    // accessors
    internal override bool is_external {
        get {
            return false;
        }
    }

    internal override bool is_pivotable {
        get {
            return false;
        }
    }

    internal override bool is_restricted {
        get {
            return true;
        }
    }

    // methods
    public DummyVariable ()
    {
        base ();
    }

    public DummyVariable.with_name (string inName)
    {
        base.with_name (inName);
    }

    public DummyVariable.with_prefix (long inNumber, string inPrefix)
    {
        base.with_prefix (inNumber, inPrefix);
    }

    internal override string
    to_string ()
    {
        return "[" + name + ":dummy]";
    }
}
