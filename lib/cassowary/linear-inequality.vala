/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * linear-inequality.vala
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

public class Maia.Cassowary.LinearInequality : LinearConstraint
{
    // methods
    public LinearInequality (LinearExpression inExpression, Strength inStrength = Strength.required, double inWeight = 1.0)
    {
        base (inExpression, inStrength, inWeight);
    }

    public LinearInequality.with_variables (AbstractVariable inVariable1, Operator inOperator, Variable inVariable2,
                                            Strength inStrength = Strength.required, double inWeight = 1.0) throws Error
    {
        base (new LinearExpression (inVariable2), inStrength, inWeight);

        switch (inOperator)
        {
            case Operator.GEQ:
                m_Expression.multiply_me (-1.0);
                m_Expression.add_variable (inVariable1);
                break;

            case Operator.LEQ:
                m_Expression.add_variable (inVariable1, -1.0);
                break;

            default:
                throw new Error.INTERNAL ("Invalid operator in LinearInequality constructor");
        }
    }

    public LinearInequality.with_variable_value (AbstractVariable inVariable, Operator inOperator, double inVal,
                                                 Strength inStrength = Strength.required, double inWeight = 1.0) throws Error
    {
        base (new LinearExpression.from_constant (inVal), inStrength, inWeight);

        switch (inOperator)
        {
            case Operator.GEQ:
                m_Expression.multiply_me (-1.0);
                m_Expression.add_variable (inVariable);
                break;

            case Operator.LEQ:
                m_Expression.add_variable (inVariable, -1.0);
                break;

            default:
                throw new Error.INTERNAL ("Invalid operator in LinearInequality constructor");
        }
    }

    public LinearInequality.with_expressions (LinearExpression inExpression1, Operator inOperator, LinearExpression inExpression2,
                                              Strength inStrength = Strength.required, double inWeight = 1.0) throws Error
    {
        base (inExpression2.clone (), inStrength, inWeight);

        switch (inOperator)
        {
            case Operator.GEQ:
                m_Expression.multiply_me (-1.0);
                m_Expression.add_expression (inExpression1);
                break;

            case Operator.LEQ:
                m_Expression.add_expression (inExpression1, -1.0);
                break;

            default:
                throw new Error.INTERNAL ("Invalid operator in LinearInequality constructor");
        }
    }

    public LinearInequality.with_variable_expression (AbstractVariable inVariable, Operator inOperator, LinearExpression inExpression,
                                                      Strength inStrength = Strength.required, double inWeight = 1.0) throws Error
    {
        base (inExpression.clone(), inStrength, inWeight);

        switch (inOperator)
        {
            case Operator.GEQ:
                m_Expression.multiply_me (-1.0);
                m_Expression.add_variable (inVariable);
                break;

            case Operator.LEQ:
                m_Expression.add_variable (inVariable, -1.0);
                break;

            default:
                throw new Error.INTERNAL ("Invalid operator in LinearInequality constructor");
        }
    }

    public LinearInequality.with_expression_variable (LinearExpression inExpression, Operator inOperator, AbstractVariable inVariable,
                                                      Strength inStrength = Strength.required, double inWeight = 1.0) throws Error
    {
        base (inExpression.clone(), inStrength, inWeight);

        switch (inOperator)
        {
            case Operator.GEQ:
                m_Expression.multiply_me (-1.0);
                m_Expression.add_variable (inVariable);
                break;

            case Operator.LEQ:
                m_Expression.add_variable (inVariable, -1.0);
                break;

            default:
                throw new Error.INTERNAL ("Invalid operator in LinearInequality constructor");
        }
    }

    internal override string
    to_string()
    {
      return base.to_string() + " >= 0)";
    }
}
