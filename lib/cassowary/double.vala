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

public class Maia.Cassowary.Double : Object
{
    // properties
    private double m_Value;

    // accessors
    public int int_value {
        get {
            return (int) m_Value;
        }
    }

    public long long_value {
        get {
            return (long) m_Value;
        }
    }

    public float float_value {
        get {
            return (float) m_Value;
        }
    }

    public uint8 byte_value {
        get {
            return (uint8) m_Value;
        }
    }

    public short short_value {
        get {
            return (short) m_Value;
        }
    }

    public double @value {
        get {
            return m_Value;
        }
        set {
            m_Value = value;
        }
    }

    // methods
    public Double (double inVal = 0.0)
    {
        m_Value = inVal;
    }

    public Double
    clone ()
    {
        return new Double (m_Value);
    }

    internal override string
    to_string ()
    {
        return m_Value.to_string ();
    }

    internal override int
    compare (Object inObject)
        requires (inObject is Double)
    {
        return (int)(m_Value - (inObject as Double).m_Value);
    }
}
