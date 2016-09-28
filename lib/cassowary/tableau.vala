/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * tableau.vala
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

public class Maia.Cassowary.Tableau : Core.Object
{
    // properties
    /**
     * m_Columns is a mapping from variables which occur in expressions to the
     * set of basic variables whose expressions contain them
     * i.e., it's a mapping from variables in expressions (a column) to the
     * set of rows that contain them.
     */
    protected Core.Map<AbstractVariable, Core.Set<AbstractVariable>> m_Columns; // From ClAbstractVariable to Core.Set of variables

    /**
     * m_Rows maps basic variables to the expressions for that row in the tableau.
     */
    protected Core.Map<AbstractVariable, LinearExpression> m_Rows;    // From AbstractVariable to LinearExpression

    /**
     * Collection of basic variables that have infeasible rows
     * (used when reoptimizing).
     */
    protected Core.Set<AbstractVariable> m_InfeasibleRows; // Core.Set of ClAbstractVariable-s

    /**
     * Core.Set of rows where the basic variable is external
     * this was added to the Java/C++/C# versions to reduce time in set_external_variables().
     */
    protected Core.Set<AbstractVariable> m_ExternalRows; // Core.Set of ClVariable-s

    /**
     * Core.Set of external variables which are parametric
     * this was added to the Java/C++/C# versions to reduce time in set_external_variables().
     */
    protected Core.Set<AbstractVariable> m_ExternalParametricVars; // Core.Set of ClVariable-s

    // methods
    /**
     * Constructor is protected, since this only supports an ADT for
     * the SimplexSolver class.
     */
    protected Tableau()
    {
        m_Columns                = new Core.Map<AbstractVariable, Core.Set<AbstractVariable>> ();
        m_Rows                   = new Core.Map<AbstractVariable, LinearExpression> ();
        m_InfeasibleRows         = new Core.Set<AbstractVariable> ();
        m_ExternalRows           = new Core.Set<AbstractVariable> ();
        m_ExternalParametricVars = new Core.Set<AbstractVariable> ();
    }

    /**
     * Convenience function to insert a variable into
     * the set of rows stored at m_Columns[inParamVar],
     * creating a new set if needed.
     */
    private inline void
    insert_col_var (AbstractVariable inParamVar, AbstractVariable inRowVar)
    {
        unowned Core.Set<AbstractVariable>? rowset = m_Columns[inParamVar];

        // TODO: two parsing on set creation, need to be simplified
        if (rowset == null)
        {
            var new_rowset = new Core.Set<AbstractVariable> ();
            m_Columns[inParamVar] = new_rowset;
            rowset = new_rowset;
        }

        rowset.insert (inRowVar);
    }

    /**
     * Variable inV has been removed from an expression. If the
     * expression is in a tableau the corresponding basic variable is
     * inSubject (or if subject is nil then it's in the objective function).
     * Update the column cross-indices.
     */
    public inline void
    note_removed_variable (AbstractVariable inV, AbstractVariable inSubject)
    {
        m_Columns[inV].remove (inSubject);
    }

    /**
     * inV has been added to the linear expression for inSubject
     * update column cross indices.
     */
    public inline void
    note_added_variable (AbstractVariable inV, AbstractVariable inSubject)
    {
        insert_col_var (inV, inSubject);
    }

    /**
     * Returns information about the tableau's internals.
     *
     * Originally from Michael Noth <noth@cs.washington.edu>
     *
     * @return String containing the information.
     */
    public virtual string
    get_internal_info ()
    {
        string s = "Tableau Information:\n";
        s += "Rows: %u (= %u constraints)".printf (m_Rows.length, m_Rows.length - 1);
        s += "\nColumns: %u".printf (m_Columns.length);
        s += "\nInfeasible Rows: %u".printf (m_InfeasibleRows.length);
        s += "\nExternal basic variables: %u".printf (m_ExternalRows.length);
        s += "\nExternal parametric variables: %u".printf (m_ExternalParametricVars.length);

        return s;
    }

    internal override string
    to_string ()
    {
        string s = "Tableau:\n";

        s += "\nRows:";
        m_Rows.iterator ().foreach ((pair) => {
            s += "\n%s <==> %s".printf (pair.first.to_string (), pair.second.to_string ());
            return true;
        });

        s += "\nColumns:";
        m_Columns.iterator ().foreach ((pair) => {
            pair.second.iterator ().foreach ((variable) => {
                s += "\n%s".printf (variable.to_string());
                return true;
            });
            return true;
        });

        s += "\nInfeasible rows:";
        m_InfeasibleRows.iterator ().foreach ((variable) => {
            s += "\n%s".printf (variable.to_string());
            return true;
        });

        s += "\nExternal basic variables:";
        m_ExternalRows.iterator ().foreach ((variable) => {
            s += "\n%s".printf (variable.to_string());
            return true;
        });

        s += "\nExternal parametric variables:";
        m_ExternalParametricVars.iterator ().foreach ((variable) => {
            s += "\n%s".printf (variable.to_string());
            return true;
        });
        return s;
    }

    /**
     * Add inVariable=inExpr to the tableau, update column cross indices
     * inVariable becomes a basic variable
     * inExpr is now owned by Tableau class,
     * and Tableau is responsible for deleting it
     * (also, inExpr better be allocated on the heap!).
     */
    protected inline void
    add_row (AbstractVariable inVariable, LinearExpression inExpr)
    {
        // for each variable in inExpr, add inVariable to the set of rows which
        // have that variable in their expression
        m_Rows[inVariable] = inExpr;

        inExpr.terms.iterator ().foreach ((pair) => {
            insert_col_var (pair.first, inVariable);

            if (pair.first.is_external)
            {
                m_ExternalParametricVars.insert (pair.first);
            }

            return true;
        });

        if (inVariable.is_external)
        {
            m_ExternalRows.insert (inVariable);
        }
    }

    /**
     * Remove inVariable from the tableau -- remove the column cross indices for inVariable
     * and remove inVariable from every expression in rows in which inVariable occurs
     */
    protected inline void
    remove_column (AbstractVariable inVariable)
    {
        // remove the rows with the variables in varset
        unowned Core.Set<AbstractVariable> rows = m_Columns[inVariable];
        if (rows != null)
        {
            rows.iterator ().foreach ((variable) => {
                LinearExpression expr = m_Rows[variable];
                expr.terms.unset (inVariable);
                return true;
            });
        }
        m_Columns.unset (inVariable);

        if (inVariable.is_external)
        {
            m_ExternalRows.remove (inVariable);
            m_ExternalParametricVars.remove (inVariable);
        }
    }

    /**
     * Remove the basic variable inVariable from the tableau row inVariable=inExpr
     * Then update column cross indices.
     */
    protected inline LinearExpression
    remove_row (AbstractVariable inVariable)
    {
        unowned LinearExpression? expr = m_Rows[inVariable];
        GLib.return_val_if_fail (expr != null, null);

        // Keep a ref on expression for is detructed on remove
        LinearExpression ret = expr.ref () as LinearExpression;

        // For each variable in this expression, update
        // the column mapping and remove the variable from the list
        // of rows it is known to be in.
        expr.terms.iterator ().foreach ((pair) => {
            unowned Core.Set<AbstractVariable>? varset = m_Columns[pair.first];

            if (varset != null)
            {
                varset.remove (inVariable);
            }

            return true;
        });

        m_InfeasibleRows.remove (inVariable);

        if (inVariable.is_external)
        {
            m_ExternalRows.remove (inVariable);
        }

        m_Rows.unset (inVariable);

        return ret;
    }

    /**
     * Replace all occurrences of inOldVar with inExpr, and update column cross indices
     * inOldVar should now be a basic variable.
     */
    protected inline void
    substitute_out (AbstractVariable inOldVar, LinearExpression inExpr)
    {
        unowned Core.Set<AbstractVariable>? varset = m_Columns[inOldVar];

        varset.iterator ().foreach((variable) => {
            unowned LinearExpression row = m_Rows[variable];
            row.substitute_out (inOldVar, inExpr, variable, this);
            if (variable.is_restricted && row.constant.@value < 0.0)
            {
                m_InfeasibleRows.insert (variable);
            }
            return true;
        });

        if (inOldVar.is_external)
        {
            m_ExternalRows.insert (inOldVar);
            m_ExternalParametricVars.insert (inOldVar);
        }

        m_Columns.unset (inOldVar);
    }

    /**
     * Return true if and only if the variable inSubject is in the columns keys
     */
    protected inline bool
    columns_has_key (AbstractVariable inSubject)
    {
        return inSubject in m_Columns;
    }

    protected inline unowned LinearExpression?
    row_expression (AbstractVariable inVariable)
    {
        return m_Rows[inVariable];
    }
}
