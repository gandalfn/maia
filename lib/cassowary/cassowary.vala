/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * cassowary.vala
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

namespace Maia.Cassowary
{
    // types
    public errordomain Error
    {
        INTERNAL,
        NON_LINEAR_EXPRESSION,
        REQUIRED_FAILURE,
        CONSTRAINT_NOT_FOUND
    }

    public enum Operator
    {
        GEQ,
        LEQ
    }

    // methods
    public static LinearExpression
    expr_plus_expr (LinearExpression inE1, LinearExpression inE2)
    {
        return inE1.plus (inE2);
    }

    public static LinearExpression
    constant_plus_expr (double inValue, LinearExpression inExpression)
    {
        return (new LinearExpression.from_constant (inValue)).plus (inExpression);
    }

    public static LinearExpression
    var_plus_expr (AbstractVariable inVariable, LinearExpression inExpression)
    {
        return (new LinearExpression (inVariable)).plus (inExpression);
    }

    public static LinearExpression
    expr_plus_var (LinearExpression inExpression, AbstractVariable inVariable)
    {
        return inExpression.plus (new LinearExpression(inVariable));
    }

    public static LinearExpression
    var_plus_constant (AbstractVariable inVariable, double inConstant)
    {
        return (new LinearExpression (inVariable)).plus (new LinearExpression.from_constant (inConstant));
    }

    public static LinearExpression
    constant_plus_variable (double inConstant, AbstractVariable inVariable)
    {
        return (new LinearExpression.from_constant (inConstant)).plus (new LinearExpression (inVariable));
    }

    public static LinearExpression
    var_minus_expr (AbstractVariable inVariable, LinearExpression inExpression)
    {
        return (new LinearExpression (inVariable)).minus (inExpression);
    }

    public static LinearExpression
    expr_minus_expr (LinearExpression inExpression1, LinearExpression inExpression2)
    {
        return inExpression1.minus (inExpression2);
    }

    public LinearExpression
    constant_minus_expr (double inConstant, LinearExpression inExpression)
    {
        return (new LinearExpression.from_constant (inConstant)).minus (inExpression);
    }

    public static LinearExpression
    expr_minus_constant (LinearExpression inExpression, double inConstant)
    {
        return inExpression.minus (new LinearExpression.from_constant (inConstant));
    }

    public static LinearExpression
    var_minus_constant (AbstractVariable inVariable, double inConstant)
    {
        return (new LinearExpression (inVariable)).minus (new LinearExpression.from_constant (inConstant));
    }

    public static LinearExpression
    expr_times_expr (LinearExpression inExpression1, LinearExpression inExpression2) throws Error
    {
        return inExpression1.times (inExpression2);
    }

    public static LinearExpression
    expr_times_var (LinearExpression inExpression, AbstractVariable inVariable) throws Error
    {
        return inExpression.times (new LinearExpression (inVariable));
    }

    public static LinearExpression
    var_times_expr (AbstractVariable inVariable, LinearExpression inExpression) throws Error
    {
        return (new LinearExpression (inVariable)).times (inExpression);
    }

    public static LinearExpression
    expr_times_constant (LinearExpression inExpression, double inConstant) throws Error
    {
        return inExpression.times (new LinearExpression.from_constant (inConstant));
    }

    public static LinearExpression
    constant_times_expr (double inConstant, LinearExpression inExpression) throws Error
    {
        return (new LinearExpression.from_constant (inConstant)).times (inExpression);
    }

    public static LinearExpression
    constant_times_var (double inConstant, AbstractVariable inVariable) throws Error
    {
        return new LinearExpression (inVariable, inConstant);
    }

    public static LinearExpression
    var_times_constant (AbstractVariable inVariable, double inConstant) throws Error
    {
        return new LinearExpression (inVariable, inConstant);
    }

    public static LinearExpression
    var_divide_expr (AbstractVariable inVariable, LinearExpression inExpression) throws Error
    {
        return (new LinearExpression (inVariable)).divide (inExpression);
    }

    public static LinearExpression
    var_divide_value (AbstractVariable inVariable, double inValue) throws Error
    {
        return (new LinearExpression (inVariable)).divide_by_value (inValue);
    }
    
    public static LinearExpression
    expr_divide_expr (LinearExpression inExpression1, LinearExpression inExpression2) throws Error
    {
        return inExpression1.divide (inExpression2);
    }

    public static LinearExpression
    expr_divide_value (LinearExpression inExpression, double inValue) throws Error
    {
        return inExpression.divide_by_value (inValue);
    }

    public static bool
    approx (double inA, double inB)
    {
        double epsilon = 1.0e-8;

        if (inA == 0.0)
        {
          return (GLib.Math.fabs (inB) < epsilon);
        }
        else if (inB == 0.0)
        {
          return (GLib.Math.fabs (inA) < epsilon);
        }
        else
        {
          return (GLib.Math.fabs (inA - inB) < GLib.Math.fabs (inA) * epsilon);
        }
    }

    public static bool
    approx_variable_with_value (Variable inVariable, double inB)
    {
        return approx (inVariable.@value, inB);
    }

    public static bool
    approx_value_with_variable (double inA, Variable inVariable)
    {
        return approx (inA, inVariable.@value);
    }
}
