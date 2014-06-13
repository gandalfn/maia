/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * double.vala
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

internal class Maia.Cassowary.Double : Core.Object
{
    // accessors
    public int int_value {
        get {
            return (int) @value;
        }
    }

    public long long_value {
        get {
            return (long) @value;
        }
    }

    public float float_value {
        get {
            return (float) @value;
        }
    }

    public uint8 byte_value {
        get {
            return (uint8) @value;
        }
    }

    public short short_value {
        get {
            return (short) @value;
        }
    }

    public double @value { get; set; }

    // methods
    public Double (double inVal = 0.0)
    {
        @value = inVal;
    }

    public Double
    clone ()
    {
        return new Double (@value);
    }

    internal override string
    to_string ()
    {
        return @value.to_string ();
    }

    internal override int
    compare (Core.Object inObject)
    {
        return Core.double_compare (@value, ((Double)inObject).@value);
    }
}
