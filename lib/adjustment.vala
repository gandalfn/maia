/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * adjustment.vala
 * Copyright (C) Nicolas Bruguier 2010-2014 <gandalfn@club-internet.fr>
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

public class Maia.Adjustment : Object
{
    // properties
    private double m_Value;
    private double m_Lower;
    private double m_Upper;
    private double m_PageSize;

    // signal
    public signal void changed ();

    // accessors
    public double @value {
        get {
            return m_Value;
        }
        set {
            double old = m_Value;
            m_Value = value;
            m_Value.clamp (m_Lower, m_Upper);
            if (old != m_Value) changed ();
        }
        default = 0.0;
    }

    public double lower {
        get {
            return m_Lower;
        }
        set {
            m_Lower = double.min (value, m_Upper);
        }
        default = 0.0;
    }

    public double upper {
        get {
            return m_Upper;
        }
        set {
            m_Upper = double.max (value, m_Lower);
        }
        default = 0.0;
    }
    
    public double page_size {
        get {
            return m_PageSize;
        }
        set {
            m_PageSize = double.min (m_Upper - m_Lower, value);
        }
        default = 0.0;
    }

    // methods
    public Adjustment ()
    {
    }

    public Adjustment.configure (double inLower, double inUpper, double inPageSize)
    {
        GLib.Object (lower: inLower, upper: inUpper, page_size: inPageSize);
    }
}
