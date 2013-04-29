/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * edit-or-stay-constraint.vala
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

public class Maia.Cassowary.EditOrStayConstraint : Constraint
{
    // properties
    private LinearExpression m_Expression;
    protected Variable m_Variable;

    // accessoirs
    public Variable variable {
        get {
            return m_Variable;
        }
    }

    internal override LinearExpression expression {
        get {
            return m_Expression;
        }
    }

    // methods
    public EditOrStayConstraint (Variable inVariable, Strength inStrength = Strength.required, double inWeight = 1.0)
    {
        base (inStrength, inWeight);
        m_Variable = inVariable;
        m_Expression = new LinearExpression (m_Variable, -1.0, m_Variable.@value);
    }

    internal override string
    to_string ()
    {
        return base.to_string () + ")";
    }
}
