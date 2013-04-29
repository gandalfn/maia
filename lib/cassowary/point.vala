/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * point.vala
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

public class Maia.Cassowary.Point : Object
{
    // properties
    private Variable m_X;
    private Variable m_Y;

    // accessors
    public Variable x {
        get {
            return m_X;
        }
        set {
            m_X = value;
        }
    }

    public double x_value {
        get {
            return m_X.@value;
        }
        set {
            x.@value = value;
        }
    }

    public Variable y {
        get {
            return m_Y;
        }
        set {
            m_Y = value;
        }
    }

    public double y_value {
        get {
            return m_Y.@value;
        }
        set {
            m_Y.@value = value;
        }
    }

    // methods
    public Point (double inX, double inY)
    {
        m_X = new Variable (inX);
        m_Y = new Variable (inY);
    }

    public Point.with_index (double inX, double inY, int inA)
    {
        m_X = new Variable.with_name_and_value ("x" + inA.to_string (), inX);
        m_Y = new Variable.with_name_and_value ("y" + inA.to_string (), inY);
    }

    public Point.with_variable (Variable inX, Variable inY)
    {
        m_X = inX;
        m_Y = inY;
    }

    public void
    set_xy (double inX, double inY)
    {
        m_X.@value = inX;
        m_Y.@value = inY;
    }

    public void
    set_xy_variable (Variable inX, Variable inY)
    {
        m_X = inX;
        m_Y = inY;
    }

    internal override string
    to_string ()
    {
        return "(" + m_X.to_string () + ", " + m_Y.to_string () + ")";
    }
}
