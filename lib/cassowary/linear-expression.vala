/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * linear-expression.vala
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

public class Maia.Cassowary.LinearExpression : Core.Object
{
    // properties
    internal Double                            constant;
    private Core.Map<AbstractVariable, Double> m_Terms;

    // accessors
    internal Core.Map<AbstractVariable, Double> terms {
        get {
            return m_Terms;
        }
    }

    public bool is_constant {
        get {
            return m_Terms.length == 0;
        }
    }

    // methods
    public LinearExpression (AbstractVariable? inVariable, double inValue = 1.0, double inConstant = 0.0)
    {
        constant = new Double(inConstant);
        m_Terms = new Core.Map<AbstractVariable, Double> ();

        if (inVariable != null)
            m_Terms[inVariable] = new Double(inValue);
    }

    public LinearExpression.from_constant (double inNum = 0)
    {
        this (null, 0, inNum);
    }

    internal LinearExpression.cloned (Double inConstant, Core.Map<AbstractVariable, Double> inTerms)
    {
        constant = (Double) inConstant.clone();
        m_Terms = new Core.Map<AbstractVariable, Double> ();

        inTerms.iterator ().foreach ((pair) => {
            m_Terms[pair.first] = pair.second.clone();
            return true;
        });
    }

    public LinearExpression
    clone()
    {
        return new LinearExpression.cloned (constant, m_Terms);
    }

    public LinearExpression
    multiply_me (double inX)
    {
        constant.@value = constant.@value * inX;

        m_Terms.iterator ().foreach ((pair) => {
            pair.second.@value = pair.second.@value * inX;
            return true;
        });

        return this;
    }

    public LinearExpression
    times_with_value (double inX)
    {
        return clone ().multiply_me (inX);
    }

    public LinearExpression
    times (LinearExpression inExpr) throws Error
    {
        if (is_constant)
        {
            return inExpr.times_with_value (constant.@value);
        }
        else if (!inExpr.is_constant)
        {
            throw new Error.NON_LINEAR_EXPRESSION ("Non linear expression");
        }

        return times_with_value (inExpr.constant.@value);
    }

    public LinearExpression
    plus (LinearExpression inExpr)
    {
        return clone ().add_expression (inExpr, 1.0);
    }

    public LinearExpression
    plus_variable (Variable inVariable) throws Error
    {
        return clone ().add_variable (inVariable, 1.0);
    }

    public LinearExpression
    minus (LinearExpression inExpr)
    {
        return clone ().add_expression (inExpr, -1.0);
    }

    public LinearExpression
    minus_variable (Variable inVariable) throws Error
    {
        return clone ().add_variable (inVariable, -1.0);
    }

    public LinearExpression
    divide_by_value (double inX) throws Error
    {
        if (approx (inX, 0.0))
        {
            throw new Error.NON_LINEAR_EXPRESSION ("Non linear expression");
        }

        return times_with_value (1.0 / inX);
    }

    public LinearExpression
    divide (LinearExpression inExpr) throws Error
    {
        if (!inExpr.is_constant)
        {
            throw new Error.NON_LINEAR_EXPRESSION ("Non linear expression");
        }

        return divide_by_value (inExpr.constant.@value);
    }

    public LinearExpression
    div_from (LinearExpression inExpr) throws Error
    {
        if (!is_constant || approx (constant.@value, 0.0))
        {
            throw new Error.NON_LINEAR_EXPRESSION ("Non linear expression");
        }

        return inExpr.divide_by_value (constant.@value);
    }

    public LinearExpression
    subtract_from (LinearExpression inExpr)
    {
        return inExpr.minus (this);
    }

    /**
     * Add n*expr to this expression from another expression expr.
     * Notify the solver if a variable is added or deleted from this
     * expression.
     */
    public LinearExpression
    add_expression (LinearExpression inExpr, double inN = 1.0, AbstractVariable? inSubject = null, Tableau? inSolver = null)
    {
        increment_constant (inN * inExpr.constant.@value);

        inExpr.m_Terms.iterator ().foreach ((pair) => {
            double coeff = pair.second.@value;
            add_variable (pair.first, coeff * inN, inSubject, inSolver);
            return true;
        });

        return this;
    }

    /**
     * Add a term c*v to this expression.  If the expression already
     * contains a term involving v, add c to the existing coefficient.
     * If the new coefficient is approximately 0, delete v.  Notify the
     * solver if v appears or disappears from this expression.
     */
    public LinearExpression
    add_variable (AbstractVariable inVariable, double inC = 1.0, AbstractVariable? inSubject = null, Tableau? inSolver = null)
    {
        unowned Double? coeff = m_Terms[inVariable];

        if (coeff != null)
        {
            double new_coefficient = coeff.@value + inC;

            if (approx (new_coefficient, 0.0))
            {
                if (inSolver != null)
                    inSolver.note_removed_variable (inVariable, inSubject);
                m_Terms.unset (inVariable);
            }
            else
            {
                coeff.@value = new_coefficient;
            }
        }
        else
        {
            if (!approx (inC, 0.0))
            {
                m_Terms[inVariable] = new Double(inC);
                if (inSolver != null)
                    inSolver.note_added_variable (inVariable, inSubject);
            }
        }

        return this;
    }

    public LinearExpression
    set_variable (AbstractVariable inVariable, double inC)
        requires (inC != 0.0)
    {
        unowned Double? coeff = m_Terms[inVariable];

        if (coeff != null)
            coeff.@value = inC;
        else
            m_Terms[inVariable] = new Double(inC);

        return this;
    }

    /**
     * Return a pivotable variable in this expression.  (It is an error
     * if this expression is constant -- signal ExCLInternalError in
     * that case).  Return null if no pivotable variables
     */
    public AbstractVariable?
    any_pivotable_variable () throws Error
    {
        if (is_constant)
        {
            throw new Error.INTERNAL ("any_pivotable_variable called on a constant");
        }

        AbstractVariable? ret = null;

        m_Terms.iterator ().foreach ((pair) => {
            if (pair.first.is_pivotable)
            {
                ret = pair.first;
                return false;
            }
            return true;
        });

        // No pivotable variables, so just return null, and let the caller
        // error if needed
        return ret;
    }

    /**
     * Replace var with a symbolic expression expr that is equal to it.
     * If a variable has been added to this expression that wasn't there
     * before, or if a variable has been dropped from this expression
     * because it now has a coefficient of 0, inform the solver.
     * PRECONDITIONS:
     * var occurs with a non-zero coefficient in this expression.
     */
    public void
    substitute_out (AbstractVariable inVariable, LinearExpression inExpr, AbstractVariable inSubject, Tableau inSolver)
    {
        double multiplier = m_Terms[inVariable].@value;
        m_Terms.unset (inVariable);
        increment_constant (multiplier * inExpr.constant.@value);

        inExpr.m_Terms.iterator ().foreach ((pair) => {
            double coeff = pair.second.@value;
            unowned Double? d_old_coeff = m_Terms[pair.first];

            if (d_old_coeff != null)
            {
                double old_coeff = d_old_coeff.@value;
                double newCoeff = old_coeff + multiplier * coeff;

                if (approx (newCoeff, 0.0))
                {
                    inSolver.note_removed_variable (pair.first, inSubject);
                    m_Terms.unset (pair.first);
                }
                else
                {
                    d_old_coeff.@value = newCoeff;
                }
            }
            else
            {
                // did not have that variable already
                m_Terms[pair.first] = new Double(multiplier * coeff);
                inSolver.note_added_variable (pair.first, inSubject);
            }
            return true;
        });
    }

    /**
     * This linear expression currently represents the equation
     * oldSubject=self.  Destructively modify it so that it represents
     * the equation newSubject=self.
     *
     * Precondition: newSubject currently has a nonzero coefficient in
     * this expression.
     *
     * NOTES
     * Suppose this expression is c + a*newSubject + a1*v1 + ... + an*vn.
     *
     * Then the current equation is
     * oldSubject = c + a*newSubject + a1*v1 + ... + an*vn.
     * The new equation will be
     * newSubject = -c/a + oldSubject/a - (a1/a)*v1 - ... - (an/a)*vn.
     * Note that the term involving newSubject has been dropped.
     */
    public void
    change_subject (AbstractVariable inOldSubject, AbstractVariable inNewSubject)
    {
        unowned Double? d = m_Terms[inOldSubject];

        if (d != null)
            d.@value  = new_subject (inNewSubject);
        else
            m_Terms[inOldSubject] = new Double(new_subject (inNewSubject));
    }

    /**
     * This linear expression currently represents the equation self=0.  Destructively modify it so
     * that subject=self represents an equivalent equation.
     *
     * Precondition: subject must be one of the variables in this expression.
     * NOTES
     * Suppose this expression is
     * c + a*subject + a1*v1 + ... + an*vn
     * representing
     * c + a*subject + a1*v1 + ... + an*vn = 0
     * The modified expression will be
     * subject = -c/a - (a1/a)*v1 - ... - (an/a)*vn
     * representing
     * subject = -c/a - (a1/a)*v1 - ... - (an/a)*vn
     *
     * Note that the term involving subject has been dropped.
     * Returns the reciprocal, so changeSubject can use it, too
     */
    public double
    new_subject (AbstractVariable inSubject)
        requires (m_Terms.contains (inSubject))
    {
        double coeff = m_Terms[inSubject].@value;
        m_Terms.unset (inSubject);

        double reciprocal = 1.0 / coeff;
        multiply_me (-reciprocal);

        return reciprocal;
    }

    /**
     * Return the coefficient corresponding to variable var, i.e.,
     * the 'ci' corresponding to the 'vi' that var is:
     * v1*c1 + v2*c2 + .. + vn*cn + c
     */
    public double
    coefficient_for (AbstractVariable inVariable)
    {
        unowned Double? coeff = m_Terms[inVariable];

        if (coeff != null)
            return coeff.@value;
        else
            return 0.0;
    }

    public void
    increment_constant(double inC)
    {
        constant.@value = constant.@value + inC;
    }

    internal override string
    to_string ()
    {
        string s = "";
        bool is_first = true;

        if (!approx (constant.@value, 0.0))
        {
            s += constant.to_string ();
            is_first = false;
        }

        m_Terms.iterator ().foreach ((pair) => {
            if (is_first)
                s += "%s*%s".printf (pair.first.to_string (), pair.second.to_string ());
            else
                s += " + %s*%s".printf (pair.first.to_string (), pair.second.to_string ());
            is_first = false;
            return true;
        });

        return s;
    }
}
