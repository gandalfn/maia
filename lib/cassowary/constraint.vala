/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * constraint.vala
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

public abstract class Maia.Cassowary.Constraint : Object
{
    // properties
    private Strength m_Strength;
    private double m_Weight;

    // accessors
    public abstract LinearExpression expression { get; }

    public virtual bool is_required {
        get {
            return m_Strength.is_required;
        }
    }

    public Strength strength {
        get {
            return m_Strength;
        }
        set {
            m_Strength = value;
        }
    }

    public double weight {
        get {
            return m_Weight;
        }
        set {
            m_Weight = value;
        }
    }

    // methods
    public Constraint (Strength inStrength = Strength.required, double inWeight = 1.0)
    {
        m_Strength = inStrength;
        m_Weight = inWeight;
    }

    internal override string
    to_string ()
    {
        // two curly brackets escape the format, so use three to surround
        // a format expression in brackets!
        //
        // example output: weak:[0,0,1] {1} (23 + -1*[update.height:23]
        return "%s {%f} (%s".printf (m_Strength.to_string (), m_Weight, expression.to_string ());
    }
}
