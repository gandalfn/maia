/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * simplex-solver.vala
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

public class Maia.Cassowary.SimplexSolver : Tableau
{
    // properties
    /**
     * The array of negative error vars for the stay constraints
     * (need both positive and negative since they have only non-negative
     * values).
     */
    private Core.Array<AbstractVariable> m_StayMinusErrorVars;

    /**
     * The array of positive error vars for the stay constraints
     * (need both positive and negative since they have only non-negative
     * values).
     */
    private Core.Array<AbstractVariable> m_StayPlusErrorVars;

    /**
     * Give error variables for a non-required constraints,
     * maps to SlackVariable.
     *
     * Core.Map Constraint to Set (of Variable).
     */
    private Core.Map<Constraint, Core.Set<AbstractVariable>> m_ErrorVars;

    /**
     * Return a lookup table giving the marker variable for
     * each constraints (used when deleting a constraint).
     *
     * Core.Map Constraint to Variable.
     */
    private Core.Map<Constraint, AbstractVariable> m_MarkerVars;

    private ObjectiveVariable m_Objective;

    /**
     * Core.Map edit variables to EditInfo.
     *
     * EditInfo instances contain all the information for an
     * edit constraints (the edit plus/minus vars, the index [for old-style
     * resolve(ArrayList...)] interface), and the previous value.
     * (EditInfo replaces the parallel vectors from the Smalltalk impl.)
     */
    private Core.Map<Variable, EditInfo> m_EditVarMap;

    private long m_SlackCounter;
    private long m_ArtificialCounter;
    private long m_DummyCounter;

    private Core.Pair<Double, Double> m_ResolvePair;

    private double m_Epsilon;

    private bool m_OptimizeAutomatically;
    private bool m_NeedsSolving;

    private Core.Stack<int> m_StkCedcns;

    // accessors
    /**
     * Controls wether optimization and setting of external variables is done
     * automatically or not.
     *
     * By default it is done automatically and <see cref="Solve"/> never needs
     * to be explicitly called by client code. If <see cref="AutoSolve"/> is
     * put to false, then <see cref="Solve"/> needs to be invoked explicitly
     * before using variables' values.
     * (Turning off @ref auto_solve while addings lots and lots
     * of constraints [ala the AddDel test in ClTests] saved about 20 % in
     * runtime, from 60sec to 54sec for 900 constraints, with 126 failed adds).
     */
    public bool auto_solve {
        get {
            return m_OptimizeAutomatically;
        }
        set {
            m_OptimizeAutomatically = value;
        }
    }

    public Core.Map<Constraint, AbstractVariable> constraint_map {
        get {
            return m_MarkerVars;
        }
    }

    // methods
    /**
     * Constructor initializes the fields, and creaties the objective row.
     */
    public SimplexSolver ()
    {
        m_StayMinusErrorVars = new Core.Array<AbstractVariable> ();
        m_StayPlusErrorVars  = new Core.Array<AbstractVariable> ();
        m_ErrorVars          = new Core.Map<Constraint, Core.Set<AbstractVariable>> ();
        m_MarkerVars         = new Core.Map<Constraint, AbstractVariable> ();

        m_ResolvePair        = new Core.Pair<Double, Double> (new Double (0), new Double (0));

        m_Objective          = new ObjectiveVariable.with_name ("Z");

        m_EditVarMap         = new Core.Map<Variable, EditInfo> ();

        m_SlackCounter = 0;
        m_ArtificialCounter = 0;
        m_DummyCounter = 0;
        m_Epsilon = 1e-8;

        m_OptimizeAutomatically = true;
        m_NeedsSolving = false;

        LinearExpression e = new LinearExpression.from_constant ();
        m_Rows[m_Objective] = e;
        m_StkCedcns = new Core.Stack<int> ();
        m_StkCedcns.push (0);
    }

    /**
     * Add the constraint expr=0 to the inequality tableau using an
     * artificial variable.
     *
     * To do this, create an artificial variable av and add av=expr
     * to the inequality tableau, then make av be 0 (raise an exception
     * if we can't attain av=0).
     */
    protected void
    add_with_artificial_variable (LinearExpression inExpr) throws Error
    {
        SlackVariable av = new SlackVariable.with_prefix (++m_ArtificialCounter, "a");
        ObjectiveVariable az = new ObjectiveVariable.with_name ("az");
        LinearExpression azRow = inExpr.clone();

        add_row (az, azRow);
        add_row (av, inExpr);

        optimize (az);

        unowned LinearExpression? azTableauRow = row_expression (az);

        if (!approx (azTableauRow.constant, 0.0))
        {
            remove_row (az);
            remove_column (av);
            throw new Error.REQUIRED_FAILURE ("");
        }

        // see if av is a basic variable
        unowned LinearExpression? e = row_expression (av);

        if (e != null)
        {
            // find another variable in this row and pivot,
            // so that av becomes parametric
            if (e.is_constant)
            {
                // if there isn't another variable in the row
                // then the tableau contains the equation av=0 --
                // just delete av's row
                remove_row (av);
                remove_row (az);
                return;
            }
            AbstractVariable entryVar = e.any_pivotable_variable ();
            pivot (entryVar, av);
        }
        remove_column (av);
        remove_row (az);
    }

    /**
     * Try to add expr directly to the tableau without creating an
     * artificial variable.
     *
     * We are trying to add the constraint expr=0 to the appropriate
     * tableau.
     *
     * @return True if successful and false if not.
     */
    protected bool
    try_adding_directly (LinearExpression inExpr) throws Error
    {
        unowned AbstractVariable subject = choose_subject (inExpr);
        if (subject == null)
        {
            return false;
        }
        inExpr.new_subject (subject);
        if (columns_has_key (subject))
        {
            substitute_out (subject, inExpr);
        }
        add_row (subject, inExpr);

        return true; // succesfully added directly
    }

    /**
     * Try to choose a subject (a variable to become basic) from
     * among the current variables in expr.
     *
     * We are trying to add the constraint expr=0 to the tableaux.
     * If expr constains any unrestricted variables, then we must choose
     * an unrestricted variable as the subject. Also if the subject is
     * new to the solver, we won't have to do any substitutions, so we
     * prefer new variables to ones that are currently noted as parametric.
     * If expr contains only restricted variables, if there is a restricted
     * variable with a negative coefficient that is new to the solver we can
     * make that the subject. Otherwise we can't find a subject, so return nil.
     * (In this last case we have to add an artificial variable and use that
     * variable as the subject -- this is done outside this method though.)
     */
    protected unowned AbstractVariable?
    choose_subject (LinearExpression inExpr) throws Error
    {
        unowned AbstractVariable? subject = null; // the current best subject, if any

        bool foundUnrestricted = false;
        bool foundNewRestricted = false;

        unowned Core.Map<AbstractVariable, Double> terms = inExpr.terms;

        foreach (unowned Core.Pair<AbstractVariable, Double> pair in terms)
        {
            double c = pair.second.@value;

            if (foundUnrestricted)
            {
                if (!pair.first.is_restricted)
                {
                    if (!columns_has_key (pair.first))
                        return pair.first;
                }
            }
            else
            {
                // we haven't found an restricted variable yet
                if (pair.first.is_restricted)
                {
                    if (!foundNewRestricted && !(pair.first is DummyVariable) && c < 0.0)
                    {
                        unowned Core.Set<AbstractVariable> col = m_Columns[pair.first];

                        if (col == null || (col.length == 1 && columns_has_key (m_Objective)))
                        {
                            subject = pair.first;
                            foundNewRestricted = true;
                        }
                    }
                }
                else
                {
                    subject = pair.first;
                    foundUnrestricted = true;
                }
            }
        }

        if (subject != null)
            return subject;

        double coeff = 0.0;

        foreach (unowned Core.Pair<AbstractVariable, Double> pair in terms)
        {
            double c = pair.second.@value;

            if (!(pair.first is DummyVariable))
                return null; // nope, no luck
            if (!columns_has_key (pair.first))
            {
                subject = pair.first;
                coeff = c;
            }
        }

        if (!approx(inExpr.constant, 0.0))
        {
            throw new Error.REQUIRED_FAILURE ("");
        }
        if (coeff > 0.0)
        {
            inExpr.multiply_me (-1);
        }

        return subject;
    }

    internal LinearExpression
    new_expression (Constraint inConstraint, Core.Pair<SlackVariable, SlackVariable> inEPlusEMinus, Double inPrevEConstant)
    {
        LinearExpression cnExpr = inConstraint.expression;
        LinearExpression expr = new LinearExpression.from_constant (cnExpr.constant);
        SlackVariable slackVar = new SlackVariable ();
        DummyVariable dummyVar = new DummyVariable ();
        SlackVariable eminus = new SlackVariable ();
        SlackVariable eplus = new SlackVariable ();

        foreach (unowned Core.Pair<AbstractVariable, Double> pair in cnExpr.terms)
        {
            double c = pair.second.@value;
            unowned LinearExpression? e = row_expression (pair.first);
            if (e == null)
                expr.add_variable (pair.first, c);
            else
                expr.add_expression (e, c);
        }

        if (inConstraint is LinearInequality)
        {
            ++m_SlackCounter;
            slackVar = new SlackVariable.with_prefix (m_SlackCounter, "s");
            expr.set_variable (slackVar, -1);
            m_MarkerVars[inConstraint] = slackVar;
            if (!inConstraint.is_required)
            {
                ++m_SlackCounter;
                eminus = new SlackVariable.with_prefix (m_SlackCounter, "em");
                expr.set_variable (eminus, 1.0);
                unowned LinearExpression? zRow = row_expression (m_Objective);
                SymbolicWeight sw = inConstraint.strength.symbolic_weight.times (inConstraint.weight);
                zRow.set_variable (eminus, sw.to_double ());
                insert_error_var (inConstraint, eminus);
                note_added_variable (eminus, m_Objective);
            }
        }
        else
        {
            // cn is an equality
            if (inConstraint.is_required)
            {
                ++m_DummyCounter;
                dummyVar = new DummyVariable.with_prefix (m_DummyCounter, "d");
                expr.set_variable (dummyVar, 1.0);
                m_MarkerVars[inConstraint] = dummyVar;
            }
            else
            {
                ++m_SlackCounter;
                eplus = new SlackVariable.with_prefix (m_SlackCounter, "ep");
                eminus = new SlackVariable.with_prefix (m_SlackCounter, "em");

                expr.set_variable (eplus, -1.0);
                expr.set_variable (eminus, 1.0);
                m_MarkerVars[inConstraint] = eplus;
                unowned LinearExpression? zRow = row_expression (m_Objective);
                SymbolicWeight sw = inConstraint.strength.symbolic_weight.times (inConstraint.weight);
                double swCoeff = sw.to_double ();
                zRow.set_variable (eplus, swCoeff);
                note_added_variable (eplus, m_Objective);
                zRow.set_variable (eminus, swCoeff);
                note_added_variable (eminus, m_Objective);
                insert_error_var (inConstraint, eminus);
                insert_error_var (inConstraint, eplus);
                if (inConstraint is StayConstraint)
                {
                    m_StayPlusErrorVars.insert (eplus);
                    m_StayMinusErrorVars.insert (eminus);
                }
                else if (inConstraint is EditConstraint)
                {
                    inEPlusEMinus.first = eplus;
                    inEPlusEMinus.second = eminus;
                    inPrevEConstant.@value = cnExpr.constant;
                }
            }
        }

        if (expr.constant < 0)
            expr.multiply_me (-1);

        return expr;
    }

    /**
     * Minimize the value of the objective.
     *
     * The tableau should already be feasible.
     */
    internal void
    optimize (ObjectiveVariable inVariable) throws Error
    {
        unowned LinearExpression? zRow = row_expression (inVariable);
        GLib.return_if_fail(zRow != null);

        unowned AbstractVariable? entryVar = null;
        unowned AbstractVariable? exitVar = null;

        while (true)
        {
            double objectiveCoeff = 0;
            foreach (unowned Core.Pair<AbstractVariable, Double> pair in zRow.terms)
            {
                double c = pair.second.@value;
                if (pair.first.is_pivotable && c < objectiveCoeff)
                {
                    objectiveCoeff = c;
                    entryVar = pair.first;
                    break;
                }
            }
            if (objectiveCoeff >= -m_Epsilon || entryVar == null)
                return;

            double minRatio = double.MAX;
            double r = 0.0;
            foreach (unowned AbstractVariable variable in m_Columns[entryVar])
            {
                if (variable.is_pivotable)
                {
                    unowned LinearExpression? expr = row_expression (variable);
                    double coeff = expr.coefficient_for (entryVar);
                    if (coeff < 0.0)
                    {
                        r = - expr.constant / coeff;
                        if (r < minRatio)
                        {
                            minRatio = r;
                            exitVar = variable;
                        }
                    }
                }
            }
            if (minRatio == double.MAX)
            {
                throw new Error.INTERNAL ("Objective function is unbounded in Optimize");
            }
            pivot (entryVar, exitVar);
        }
    }

    /**
     * Fix the constants in the equations representing the edit constraints.
     *
     * Each of the non-required edits will be represented by an equation
     * of the form:
     * v = c + eplus - eminus
     * where v is the variable with the edit, c is the previous edit value,
     * and eplus and eminus are slack variables that hold the error in
     * satisfying the edit constraint. We are about to change something,
     * and we want to fix the constants in the equations representing
     * the edit constraints. If one of eplus and eminus is basic, the other
     * must occur only in the expression for that basic error variable.
     * (They can't both be basic.) Fix the constant in this expression.
     * Otherwise they are both non-basic. Find all of the expressions
     * in which they occur, and fix the constants in those. See the
     * UIST paper for details.
     * (This comment was for ResetEditConstants(), but that is now
     * gone since it was part of the screwey vector-based interface
     * to resolveing. --02/16/99 gjb)
     */
    protected void
    delta_edit_constant (double inDelta, AbstractVariable inPlusErrorVar, AbstractVariable inMinusErrorVar)
    {
        unowned LinearExpression? exprPlus = row_expression (inPlusErrorVar);
        if (exprPlus != null)
        {
            exprPlus.increment_constant (inDelta);

            if (exprPlus.constant < 0.0)
            {
                m_InfeasibleRows.insert (inPlusErrorVar);
            }
            return;
        }

        unowned LinearExpression? exprMinus = row_expression (inMinusErrorVar);
        if (exprMinus != null)
        {
            exprMinus.increment_constant (-inDelta);
            if (exprMinus.constant < 0.0)
            {
                m_InfeasibleRows.insert (inMinusErrorVar);
            }
            return;
        }

        unowned Core.Set<AbstractVariable> columnVars = m_Columns[inMinusErrorVar];

        foreach (AbstractVariable basicVar in columnVars)
        {
            unowned LinearExpression? expr = row_expression (basicVar);
            double c = expr.coefficient_for (inMinusErrorVar);
            expr.increment_constant (c * inDelta);
            if (basicVar.is_restricted && expr.constant < 0.0)
            {
                m_InfeasibleRows.insert (basicVar);
            }
        }
    }

    /**
     * Re-optimize using the dual simplex algorithm.
     *
     * We have set new values for the constants in the edit constraints.
     */
    protected void
    dual_optimize () throws Error
    {
        unowned LinearExpression? zRow = row_expression (m_Objective);
        while (m_InfeasibleRows.length != 0)
        {
            Core.Iterator<AbstractVariable> iter = m_InfeasibleRows.iterator ();
            iter.next ();
            AbstractVariable exitVar = iter.get ();

            m_InfeasibleRows.remove (exitVar);
            unowned AbstractVariable? entryVar = null;
            unowned LinearExpression? expr = row_expression (exitVar);
            if (expr != null)
            {
                if (expr.constant < 0.0)
                {
                    double ratio = double.MAX;
                    double r;
                    unowned Core.Map<AbstractVariable, Double> terms = expr.terms;
                    foreach (unowned Core.Pair<AbstractVariable, Double> pair in terms)
                    {
                        double c = pair.second.@value;
                        if (c > 0.0 && pair.first.is_pivotable)
                        {
                            double zc = zRow.coefficient_for (pair.first);
                            r = zc / c; // FIXME: zc / c or zero, as ClSymbolicWeigth-s
                            if (r < ratio)
                            {
                                entryVar = pair.first;
                                ratio = r;
                            }
                        }
                    }
                    if (ratio == double.MAX)
                    {
                        throw new Error.INTERNAL ("ratio == nil (Double.MaxValue) in DualOptimize");
                    }
                    pivot(entryVar, exitVar);
                }
            }
        }
    }

    /**
     * Do a pivot. Move entryVar into the basis and move exitVar
     * out of the basis.
     *
     * We could for example make entryVar a basic variable and
     * make exitVar a parametric variable.
     */
    protected void
    pivot (AbstractVariable inEntryVar, AbstractVariable inExitVar) throws Error
    {
        // the entryVar might be non-pivotable if we're doing a
        // RemoveConstraint -- otherwise it should be a pivotable
        // variable -- enforced at call sites, hopefully
        inExitVar.ref ();
        LinearExpression pexpr = remove_row (inExitVar);

        pexpr.change_subject (inExitVar, inEntryVar);
        substitute_out (inEntryVar, pexpr);
        add_row (inEntryVar, pexpr);
        inExitVar.unref ();
    }

    /**
     * Fix the constants in the equations representing the stays.
     *
     * Each of the non-required stays will be represented by an equation
     * of the form
     * v = c + eplus - eminus
     * where v is the variable with the stay, c is the previous value
     * of v, and eplus and eminus are slack variables that hold the error
     * in satisfying the stay constraint. We are about to change something,
     * and we want to fix the constants in the equations representing the
     * stays. If both eplus and eminus are nonbasic they have value 0
     * in the current solution, meaning the previous stay was exactly
     * satisfied. In this case nothing needs to be changed. Otherwise one
     * of them is basic, and the other must occur only in the expression
     * for that basic error variable. Reset the constant of this
     * expression to 0.
     */
    protected void
    reset_stay_constants ()
    {
        for (int cpt = 0; cpt < m_StayPlusErrorVars.length; ++cpt)
        {
            unowned LinearExpression? expr = row_expression (m_StayPlusErrorVars[cpt]);
            if (expr == null)
                expr = row_expression (m_StayMinusErrorVars[cpt]);
            if (expr != null)
                expr.constant = 0.0;
        }
    }

    /**
     * Set the external variables known to this solver to their appropriate values.
     *
     * Set each external basic variable to its value, and set each external parametric
     * variable to 0. (It isn't clear that we will ever have external parametric
     * variables -- every external variable should either have a stay on it, or have an
     * equation that defines it in terms of other external variables that do have stays.
     * For the moment I'll put this in though.) Variables that are internal to the solver
     * don't actually store values -- their values are just implicit in the tableau -- so
     * we don't need to set them.
     */
    protected void
    set_external_variables ()
    {
        foreach (unowned AbstractVariable variable in m_ExternalParametricVars)
        {
            if (row_expression (variable) != null)
                continue;

            ((Variable)variable).@value = 0.0;
        }

        foreach (unowned AbstractVariable variable in m_ExternalRows)
        {
            unowned LinearExpression? expr = row_expression (variable);
            ((Variable)variable).@value = expr.constant;
        }

        m_NeedsSolving = false;
    }

    /**
     * Protected convenience function to insert an error variable
     * into the _errorVars set, creating the mapping with Add as necessary.
     */
    protected void
    insert_error_var (Constraint inConstraint, AbstractVariable inVariable)
    {
        unowned Core.Set<AbstractVariable>? cnset = m_ErrorVars[inConstraint];
        if (cnset == null)
        {
            Core.Set<AbstractVariable> newSet = new Core.Set<AbstractVariable> ();
            m_ErrorVars[inConstraint] = newSet;
            cnset = newSet;
        }
        cnset.insert (inVariable);
    }

    /**
     * Add a constraint to the solver.
     *
     * @param inConstraint The constraint to be added.
     */
    public SimplexSolver
    add_constraint (Constraint inConstraint) throws Error
    {
        Core.Pair<SlackVariable, SlackVariable> eplus_eminus = new Core.Pair<SlackVariable, SlackVariable>.empty ();
        Double prevEConstant = new Double ();
        LinearExpression expr = new_expression (inConstraint, eplus_eminus, prevEConstant);

        bool cAddedOkDirectly = false;

        try
        {
            cAddedOkDirectly = try_adding_directly (expr);
            if (!cAddedOkDirectly)
            {
                // could not add directly
                add_with_artificial_variable (expr);
            }
        }
        catch (Error rf)
        {
            throw rf;
        }

        m_NeedsSolving = true;

        if (inConstraint is EditConstraint)
        {
            m_EditVarMap[((EditConstraint)inConstraint).variable] = new EditInfo(inConstraint, eplus_eminus.first, eplus_eminus.second,
                                                                                 prevEConstant.@value, m_EditVarMap.length);
        }

        if (m_OptimizeAutomatically)
        {
            optimize(m_Objective);
            set_external_variables();
        }

        return this;
    }

    /**
     * Same as AddConstraint, throws no exceptions.
     *
     * @return ``false`` if the constraint resulted in an unsolvable system, otherwise ``true``.
     */
    public bool
    add_constraint_no_exception (Constraint inConstraint)
    {
        try
        {
            add_constraint (inConstraint);
            return true;
        }
        catch (Error err)
        {
            return false;
        }
    }

    /**
     * Add an edit constraint for a variable with a given strength.
     *
     * @param inVariable Variable to add an edit constraint to.
     * @param inStrength Strength of the edit constraint.
     */
    public SimplexSolver
    add_edit_var (Variable inVariable, Strength inStrength = Strength.strong) throws Error
    {
        try
        {
            EditConstraint cnEdit = new EditConstraint (inVariable, inStrength);
            return add_constraint (cnEdit);
        }
        catch (Error err)
        {
            // should not get this
            throw new Error.INTERNAL ("Required failure when adding an edit variable");
        }
    }

    /**
     * Remove the edit constraint previously added.
     *
     * @param inVariable Variable to which the edit constraint was added before.
     */
    public SimplexSolver
    remove_edit_var (Variable inVariable) throws Error
    {
        EditInfo cei = m_EditVarMap[inVariable];
        Constraint cn = cei.constraint;
        remove_constraint (cn);

        return this;
    }

    /**
     * Marks the start of an edit session.
     *
     * begin_edit should be called before sending resolve ()
     * messages, after adding the appropriate edit variables.
     */
    public SimplexSolver
    begin_edit () throws Error
        requires (m_EditVarMap.length > 0)
    {
        // may later want to do more in here
        m_InfeasibleRows.clear ();
        reset_stay_constants ();
        m_StkCedcns.push (m_EditVarMap.length);

        return this;
    }

    /**
     * Marks the end of an edit session.
     *
     * end_edit should be called after editing has finished for now, it
     * just removes all edit variables.
     */
    public SimplexSolver
    end_edit () throws Error
        requires (m_EditVarMap.length > 0)
    {
        resolve ();
        m_StkCedcns.pop ();
        int n = m_StkCedcns.peek ();
        remove_edit_vars_to (n);
        // may later want to do more in hore

        return this;
    }

    /**
     * Eliminates all the edit constraints that were added.
     */
    public SimplexSolver
    remove_all_edit_vars () throws Error
    {
        return remove_edit_vars_to (0);
    }

    /**
     * Remove the last added edit vars to leave only
     * a specific number left.
     *
     * @param inNumber Number of edit variables to keep.
     */
    public SimplexSolver
    remove_edit_vars_to (int inNumber) throws Error
    {
        Core.Map<Variable, EditInfo> editVarMapCopy = new Core.Map<Variable, EditInfo> ();

        foreach (unowned Core.Pair<Variable, EditInfo> pair in m_EditVarMap)
        {
            editVarMapCopy[pair.first] = pair.second;
        }

        try
        {
            foreach (unowned Core.Pair<Variable, EditInfo> pair in m_EditVarMap)
            {
                if (pair.second.index >= inNumber)
                {
                    remove_edit_var (pair.first);
                }
            }

            return this;
        }
        catch (Error err)
        {
            // should not get this
            throw new Error.INTERNAL ("Constraint not found in remove_edit_vars_to");
        }
    }

    public SimplexSolver
    add_point_stay_variable_weight (Variable inVx, Variable inVy, double inWeight) throws Error
    {
        add_stay (inVx, Strength.@weak, inWeight);
        add_stay (inVy, Strength.@weak, inWeight);

        return this;
    }

    public SimplexSolver
    add_point_stay_variable (Variable inVx, Variable inVy) throws Error
    {
        add_point_stay_variable_weight (inVx, inVy, 1.0);

        return this;
    }

    /**
     * Add a stay of the given strength (default to Strength#weak)
     * of a variable to the tableau..
     *
     * @param inVariable Variable to add the stay constraint to.
     */
    public SimplexSolver
    add_stay (Variable inVariable, Strength inStrength = Strength.weak, double inWeight = 1.0) throws Error
    {
        StayConstraint cn = new StayConstraint (inVariable, inStrength, inWeight);

        return add_constraint (cn);
    }

    /**
     * Remove a constraint from the tableau.
     * Also remove any error variable associated with it.
     */
    public SimplexSolver
    remove_constraint (Constraint inConstraint) throws Error
    {
        m_NeedsSolving = true;

        reset_stay_constants ();

        unowned LinearExpression? zRow = row_expression (m_Objective);

        unowned Core.Set<AbstractVariable> eVars = m_ErrorVars[inConstraint];

        if (eVars != null)
        {
            foreach (unowned AbstractVariable variable in eVars)
            {
                unowned LinearExpression? expr = row_expression (variable);
                if (expr == null)
                {
                    zRow.add_variable (variable,
                                       -inConstraint.weight * inConstraint.strength.symbolic_weight.to_double (),
                                       m_Objective, this);
                }
                else // the error variable was in the basis
                {
                    zRow.add_expression (expr,
                                         -inConstraint.weight * inConstraint.strength.symbolic_weight.to_double (),
                                         m_Objective, this);
                }
            }
        }

        if (!(inConstraint in m_MarkerVars))
        {
            throw new Error.CONSTRAINT_NOT_FOUND ("");
        }

        AbstractVariable marker = m_MarkerVars[inConstraint].ref () as AbstractVariable;
        m_MarkerVars.unset (inConstraint);

        if (row_expression (marker) == null)
        {
            // not in the basis, so need to do some more work
            unowned Core.Set<AbstractVariable> col = m_Columns[marker];

            unowned AbstractVariable? exitVar = null;
            double minRatio = 0.0;
            foreach (unowned AbstractVariable variable in col)
            {
                if (variable.is_restricted)
                {
                    unowned LinearExpression? expr = row_expression (variable);
                    double coeff = expr.coefficient_for (marker);

                    if (coeff < 0.0)
                    {
                        double r = -expr.constant / coeff;
                        if (exitVar == null || r < minRatio)
                        {
                            minRatio = r;
                            exitVar = variable;
                        }
                    }
                }
            }

            if (exitVar == null)
            {
                foreach (unowned AbstractVariable variable in col)
                {
                    if (variable.is_restricted)
                    {
                        unowned LinearExpression? expr = row_expression (variable);
                        double coeff = expr.coefficient_for (marker);
                        double r = expr.constant / coeff;
                        if (exitVar == null || r < minRatio)
                        {
                            minRatio = r;
                            exitVar = variable;
                        }
                    }
                }
            }

            if (exitVar == null)
            {
                // exitVar is still null
                if (col.length == 0)
                {
                    remove_column (marker);
                }
                else
                {
                    // put first element in exitVar
                    Core.Iterator<AbstractVariable> iter = col.iterator ();
                    iter.next ();
                    exitVar = iter.get ();
                }
            }

            if (exitVar != null)
            {
                pivot (marker, exitVar);
            }
        }

        if (row_expression (marker) != null)
        {
            remove_row (marker);
        }

        if (eVars != null)
        {
            foreach (unowned AbstractVariable variable in eVars)
            {
                // FIXME: decide wether to use equals or !=
                if (variable.compare (marker) != 0)
                {
                    remove_column (variable);
                }
            }
        }

        if (inConstraint is StayConstraint)
        {
            if (eVars != null)
            {
                for (int cpt = 0; cpt < m_StayPlusErrorVars.length; ++cpt)
                {
                    eVars.remove (m_StayPlusErrorVars[cpt]);
                    eVars.remove (m_StayMinusErrorVars[cpt]);
                }
            }
        }
        else if (inConstraint is EditConstraint)
        {
            EditConstraint cnEdit = (EditConstraint)inConstraint;
            Variable clv = cnEdit.variable;
            EditInfo cei = m_EditVarMap[clv];
            SlackVariable clvEditMinus = cei.edit_minus;
            remove_column (clvEditMinus);
            m_EditVarMap.unset (clv);
        }

        // FIXME: do the remove at top
        if (eVars != null)
        {
            m_ErrorVars.unset (inConstraint);
        }
        marker = null;

        if (m_OptimizeAutomatically)
        {
            optimize (m_Objective);
            set_external_variables ();
        }

        return this;
    }

    /**
     * Re-initialize this solver from the original constraints, thus
     * getting rid of any accumulated numerical problems
     *
     * Actually, we haven't definitely observed any such problems yet.
     */
    public void
    reset () throws Error
    {
        throw new Error.INTERNAL ("Reset not implemented");
    }

    /**
     * Re-solve the current collection of constraints for new values
     * for the constants of the edit variables.
     *
     * Deprecated. Use suggest_value(...) then resolve(). If you must
     * use this, be sure to not use it if you
     * remove an edit variable (or edit constraints) from the middle
     * of a list of edits, and then try to resolve with this function
     * (you'll get the wrong answer, because the indices will be wrong
     * in the EditInfo objects).
     */
    internal void
    resolve_pair (Core.Pair<Double, Double> m_NewEditConstants) throws Error
    {
        foreach (unowned Core.Pair<Variable, EditInfo> pair in m_EditVarMap)
        {
            int i = pair.second.index;
            try
            {
                if (i < 2)
                {
                    suggest_value (pair.first, i == 0 ? m_NewEditConstants.first.@value : m_NewEditConstants.second.@value);
                }
            }
            catch (Error err)
            {
                throw new Error.INTERNAL ("Error during resolve");
            }
        }
        resolve();
    }

    /**
     * Convenience function for resolve-s of two variables.
     */
    public void
    resolve_values (double inX, double inY) throws Error
    {
        m_ResolvePair.first.@value = inX;
        m_ResolvePair.second.@value = inY;

        resolve_pair (m_ResolvePair);
    }

    /**
     * Re-solve the current collection of constraints, given the new
     * values for the edit variables that have already been
     * suggested
     */
    public void
    resolve () throws Error
    {
        dual_optimize ();
        set_external_variables ();
        m_InfeasibleRows.clear ();
        reset_stay_constants ();
    }

    /**
     * Suggest a new value for an edit variable.
     *
     * The variable needs to be added as an edit variable and
     * begin_edit() needs to be called before this is called.
     * The tableau will not be solved completely until after resolve()
     * has been called.
     */
    public SimplexSolver
    suggest_value (Variable inVariable, double inX) throws Error
    {
        unowned EditInfo cei = m_EditVarMap[inVariable];
        if (cei == null)
        {
            throw new Error.INTERNAL ("SuggestValue for variable " + inVariable.to_string () + ", but var is not an edit variable\n");
        }
        SlackVariable clvEditPlus = cei.edit_plus;
        SlackVariable clvEditMinus = cei.edit_minus;
        double delta = inX - cei.prev_edit_constant;
        cei.prev_edit_constant = inX;
        delta_edit_constant (delta, clvEditPlus, clvEditMinus);

        return this;
    }

    public SimplexSolver
    solve () throws Error
    {
        if (m_NeedsSolving)
        {
            optimize (m_Objective);
            set_external_variables ();
        }

        return this;
    }

    public SimplexSolver
    set_edited_value (Variable inVariable, double inN) throws Error
    {
        if (!contains_variable (inVariable))
        {
            inVariable.@value = inN;
            return this;
        }

        if (!approx (inN, inVariable.@value))
        {
            add_edit_var (inVariable);
            begin_edit ();
            try
            {
                suggest_value (inVariable, inN);
            }
            catch(Error err)
            {
                // just added it above, so we shouldn't get an error
                throw new Error.INTERNAL ("Error in SetEditedValue");
            }
            end_edit ();
        }

        return this;
    }

    public bool
    contains_variable (Variable inVariable) throws Error
    {
        return columns_has_key (inVariable) || (row_expression (inVariable) != null);
    }

    public SimplexSolver
    add_var (Variable inVariable) throws Error
    {
        if (!contains_variable (inVariable))
        {
            try
            {
                add_stay (inVariable);
            }
            catch (Error err)
            {
                // cannot have a required failure, since we add w/ weak
                throw new Error.INTERNAL ("Error in AddVar -- required failure is impossible");
            }
        }

        return this;
    }

    /**
     * Returns information about the solver's internals.
     *
     * Originally from Michael Noth <noth@cs.washington.edu>
     *
     * @return String containing the information.
     */
    internal override string
    get_internal_info ()
    {
        string result = base.get_internal_info ();

        result += "\nSolver info:\n";
        result += "Stay Error Variables: ";
        result += m_StayPlusErrorVars.length.to_string () + m_StayMinusErrorVars.length.to_string ();
        result += " (" + m_StayPlusErrorVars.length.to_string () + " +, ";
        result += m_StayMinusErrorVars.length.to_string () + " -)\n";
        result += "Edit Variables: " + m_EditVarMap.length.to_string ();
        result += "\n";

        return result;
    }

    public string
    get_debug_info ()
    {
        string result = to_string ();
        result += get_internal_info ();
        result += "\n";

        return result;
    }

    internal override string
    to_string ()
    {
        string result = base.to_string ();

        result += "\nm_StayPlusErrorVars: ";
        foreach (unowned AbstractVariable variable in m_StayPlusErrorVars)
        {
            result += "\n" + variable.to_string ();
        }
        result += "\nm_StayMinusErrorVars: ";
        foreach (unowned AbstractVariable variable in m_StayMinusErrorVars)
        {
            result += "\n" + variable.to_string ();
        }
        result += "\n";

        return result;
    }
}
