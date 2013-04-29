/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * linear-equation.vala
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

public class Maia.Cassowary.LinearEquation : LinearConstraint
{
    // methods
    public LinearEquation (LinearExpression inExpression, Strength inStrength = Strength.required, double inWeight = 1.0)
    {
        base (inExpression, inStrength, inWeight);
    }

    public LinearEquation.with_variable (AbstractVariable inVariable, LinearExpression inExpression,
                                         Strength inStrength = Strength.required, double inWeight = 1.0)
    {
        base (inExpression, inStrength, inWeight);
        m_Expression.add_variable (inVariable, -1.0);
    }

    public LinearEquation.with_variable_value (AbstractVariable inVariable, double inVal,
                                               Strength inStrength = Strength.required, double inWeight = 1.0)
    {
        base (new LinearExpression.from_constant (inVal), inStrength, inWeight);
        m_Expression.add_variable (inVariable, -1.0);
    }

    public LinearEquation.with_expression_variable (LinearExpression inExpression, AbstractVariable inVariable,
                                                    Strength inStrength = Strength.required, double inWeight = 1.0)
    {
        base(inExpression.clone(), inStrength, inWeight);
        m_Expression.add_variable (inVariable, -1.0);
    }

    public LinearEquation.with_expressions (LinearExpression inExpression1, LinearExpression inExpression2,
                                            Strength inStrength = Strength.required, double inWeight = 1.0)
    {
        base(inExpression1.clone(), inStrength, inWeight);
        m_Expression.add_expression (inExpression2, -1.0);
    }

    internal override string
    to_string()
    {
      return base.to_string () + " = 0)";
    }
}
