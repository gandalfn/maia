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

/**
 * An object representing an adjustable bounded value
 */
public class Maia.Adjustment : Object
{
    // properties
    private double m_Value;
    private double m_Lower;
    private double m_Upper;
    private double m_PageSize;

    // accessors
    /**
     * The current value of the adjustment.
     */
    [CCode (notify = false)]
    public double @value {
        get {
            return m_Value;
        }
        set {
            if (value.clamp (m_Lower, m_Upper - m_PageSize) != m_Value)
            {
                m_Value = value.clamp (m_Lower, m_Upper - m_PageSize);
                GLib.Signal.emit_by_name (this, "notify::value");
            }
        }
        default = 0.0;
    }

    /**
     * The current minimum value of the adjustment.
     */
    [CCode (notify = false)]
    public double lower {
        get {
            return m_Lower;
        }
        set {
            if (m_Lower != double.min (value, m_Upper))
            {
                double delta = (m_Upper - m_Lower) != 0 ? m_Value / (m_Upper - m_Lower) : 0;
                m_Lower = double.min (value, m_Upper);
                m_Value = delta * (m_Upper - m_Lower);
                GLib.Signal.emit_by_name (this, "notify::lower");
            }
        }
        default = 0.0;
    }

    /**
     * The current maximum value of the adjustment.
     */
    [CCode (notify = false)]
    public double upper {
        get {
            return m_Upper;
        }
        set {
            if (m_Upper != double.max (value, m_Lower))
            {
                double delta = (m_Upper - m_Lower) != 0 ? m_Value / (m_Upper - m_Lower) : 0;
                m_Upper = double.max (value, m_Lower);
                m_Value = delta * (m_Upper - m_Lower);
                GLib.Signal.emit_by_name (this, "notify::upper");
            }
        }
        default = 0.0;
    }

    /**
     * The current page size of the adjustment.
     */
    [CCode (notify = false)]
    public double page_size {
        get {
            return m_PageSize;
        }
        set {
            if (m_PageSize != double.min (m_Upper - m_Lower, value))
            {
                m_PageSize = double.min (m_Upper - m_Lower, value);
                GLib.Signal.emit_by_name (this, "notify::page-size");
            }
        }
        default = 0.0;
    }

    // methods
    /**
     * Create a new adjustment object
     */
    public Adjustment ()
    {
    }

    /**
     * Create a new adjustement object with default properties
     *
     * @param inLower the minimum value of adjustment
     * @param inUpper the maximum value of adjustment
     * @param inPageSize the page size of adjustment
     */
    public Adjustment.with_properties (double inLower, double inUpper, double inPageSize)
    {
        GLib.Object (lower: inLower, upper: inUpper, page_size: inPageSize);
    }

    /**
     * Configure adjustment
     *
     * @param inLower the minimum value of adjustment
     * @param inUpper the maximum value of adjustment
     * @param inPageSize the page size of adjustment
     */
    public void
    configure (double inLower, double inUpper, double inPageSize)
    {
        double delta = (m_Upper - m_Lower) != 0 ? m_Value / (m_Upper - m_Lower) : 0;

        m_Lower = double.min (inLower, m_Upper);
        m_Upper = double.max (inUpper, m_Lower);
        m_Value = delta * (m_Upper - m_Lower);
        m_PageSize = double.min (m_Upper - m_Lower, inPageSize);
    }
}
