/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-cassowary.vala
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

public class Maia.TestCassowary : Maia.TestCase
{
    const int N_CONSTRAINTS = 900;
    const int N_VARIABLES = 900;
    const int N_RESOLVES = 10000;

    public TestCassowary ()
    {
        base ("cassowary");

        add_test ("simple", test_simple);
        add_test ("just-stay", test_just_stay);
        add_test ("add-delete1", test_add_delete1);
        add_test ("add-delete2", test_add_delete2);
        add_test ("casso1", test_casso1);
        add_test ("inconsistent1", test_inconsistent1);
        add_test ("inconsistent2", test_inconsistent2);
        add_test ("inconsistent3", test_inconsistent3);
        add_test ("multi-edit", test_multi_edit);
        if (Test.perf())
        {
            add_test ("add-del-bench", test_add_del_bench);
        }
    }

    public void
    test_simple ()
    {
        try
        {
            Cassowary.Variable x = new Cassowary.Variable (167);
            Cassowary.Variable y = new Cassowary.Variable (2);
            Cassowary.SimplexSolver solver = new Cassowary.SimplexSolver ();

            Cassowary.LinearEquation eq = new Cassowary.LinearEquation.with_variable (x, new Cassowary.LinearExpression (y));
            solver.add_constraint (eq);

            Test.message ("x == %f".printf (x.@value));
            Test.message ("y == %f".printf (y.@value));

            assert (x.@value == y.@value);

            Test.message ("x == %f".printf (x.@value));
            Test.message ("y == %f".printf (y.@value));
        }
        catch (GLib.Error err)
        {
            Test.message (err.message);
            assert (false);
        }
    }

    public void
    test_just_stay ()
    {
        try
        {
            Cassowary.Variable x = new Cassowary.Variable (5);
            Cassowary.Variable y = new Cassowary.Variable (10);
            Cassowary.SimplexSolver solver = new Cassowary.SimplexSolver ();

            solver.add_stay (x);
            solver.add_stay (y);

            assert (Cassowary.approx_variable_with_value (x, 5));
            assert (Cassowary.approx_variable_with_value (y, 10));

            Test.message ("x == %f".printf (x.@value));
            Test.message ("y == %f".printf (y.@value));
        }
        catch (GLib.Error err)
        {
            Test.message (err.message);
            assert (false);
        }
    }

    public void
    test_add_delete1 ()
    {
        try
        {
            Cassowary.Variable x = new Cassowary.Variable.with_name ("x");
            Cassowary.SimplexSolver solver = new Cassowary.SimplexSolver ();

            solver.add_constraint (new Cassowary.LinearEquation.with_variable_value (x, 100, Cassowary.Strength.@weak));

            Cassowary.LinearInequality c10 = new Cassowary.LinearInequality.with_variable_value (x, Cassowary.Operator.LEQ, 10.0);
            Cassowary.LinearInequality c20 = new Cassowary.LinearInequality.with_variable_value (x, Cassowary.Operator.LEQ, 20.0);

            solver.add_constraint (c10);
            solver.add_constraint (c20);

            assert (Cassowary.approx_variable_with_value (x, 10));
            Test.message ("x == %f".printf (x.@value));

            solver.remove_constraint (c10);
            assert (Cassowary.approx_variable_with_value (x, 20));
            Test.message ("x == %f".printf (x.@value));

            solver.remove_constraint (c20);
            assert (Cassowary.approx_variable_with_value (x, 100));
            Test.message ("x == %f".printf (x.@value));

            Cassowary.LinearInequality c10again = new Cassowary.LinearInequality.with_variable_value (x, Cassowary.Operator.LEQ, 10.0);

            solver.add_constraint (c10);
            solver.add_constraint (c10again);

            assert (Cassowary.approx_variable_with_value (x, 10));
            Test.message ("x == %f".printf (x.@value));

            solver.remove_constraint (c10);
            assert (Cassowary.approx_variable_with_value (x, 10));
            Test.message ("x == %f".printf (x.@value));

            solver.remove_constraint (c10again);
            assert (Cassowary.approx_variable_with_value (x, 100));
            Test.message ("x == %f".printf (x.@value));
        }
        catch (GLib.Error err)
        {
            Test.message (err.message);
            assert (false);
        }
    }

    public void
    test_add_delete2 ()
    {
        try
        {
            Cassowary.Variable x = new Cassowary.Variable.with_name ("x");
            Cassowary.Variable y = new Cassowary.Variable.with_name ("y");
            Cassowary.SimplexSolver solver = new Cassowary.SimplexSolver ();

            solver.add_constraint (new Cassowary.LinearEquation.with_variable_value (x, 100.0, Cassowary.Strength.@weak));
            solver.add_constraint (new Cassowary.LinearEquation.with_variable_value (y, 120.0, Cassowary.Strength.@strong));

            Cassowary.LinearInequality c10 = new Cassowary.LinearInequality.with_variable_value (x, Cassowary.Operator.LEQ, 10.0);
            Cassowary.LinearInequality c20 = new Cassowary.LinearInequality.with_variable_value (x, Cassowary.Operator.LEQ, 20.0);

            solver.add_constraint (c10);
            solver.add_constraint (c20);

            assert (Cassowary.approx_variable_with_value (x, 10.0) && Cassowary.approx_variable_with_value (y, 120.0));
            Test.message ("x == %f, y == %f", x.@value, y.@value);

            solver.remove_constraint (c10);
            assert (Cassowary.approx_variable_with_value (x, 20.0) && Cassowary.approx_variable_with_value (y, 120.0));
            Test.message ("x == %f, y == %f", x.@value, y.@value);

            Cassowary.LinearEquation cxy = new Cassowary.LinearEquation.with_expression_variable (Cassowary.constant_times_var (2.0, x), y);
            solver.add_constraint (cxy);
            assert (Cassowary.approx_variable_with_value (x, 20.0) && Cassowary.approx_variable_with_value (y, 40.0));
            Test.message ("x == %f, y == %f", x.@value, y.@value);

            solver.remove_constraint (c20);
            assert (Cassowary.approx_variable_with_value (x, 60.0) && Cassowary.approx_variable_with_value (y, 120.0));
            Test.message ("x == %f, y == %f", x.@value, y.@value);

            solver.remove_constraint (cxy);
            assert (Cassowary.approx_variable_with_value (x, 100.0) && Cassowary.approx_variable_with_value (y, 120.0));
            Test.message ("x == %f, y == %f", x.@value, y.@value);
        }
        catch (GLib.Error err)
        {
            Test.message (err.message);
            assert (false);
        }
    }

    public void
    test_casso1 ()
    {
        try
        {
            Cassowary.Variable x = new Cassowary.Variable.with_name ("x");
            Cassowary.Variable y = new Cassowary.Variable.with_name ("y");
            Cassowary.SimplexSolver solver = new Cassowary.SimplexSolver ();

            solver.add_constraint (new Cassowary.LinearInequality.with_variables (x, Cassowary.Operator.LEQ, y));
            solver.add_constraint (new Cassowary.LinearEquation.with_variable (y, Cassowary.var_plus_constant (x, 3.0)));
            solver.add_constraint (new Cassowary.LinearEquation.with_variable_value (x, 10.0, Cassowary.Strength.@weak));
            solver.add_constraint (new Cassowary.LinearEquation.with_variable_value (y, 10.0, Cassowary.Strength.@weak));

            assert ((Cassowary.approx_variable_with_value (x, 10.0) && Cassowary.approx_variable_with_value (y, 13.0)) ||
                    (Cassowary.approx_variable_with_value (x, 7.0) && Cassowary.approx_variable_with_value (y, 10.0)));
            Test.message ("x == %f, y == %f", x.@value, y.@value);
        }
        catch (GLib.Error err)
        {
            Test.message (err.message);
            assert (false);
        }
    }

    public void
    test_inconsistent1 ()
    {
        try
        {
            Cassowary.Variable x = new Cassowary.Variable.with_name ("x");
            Cassowary.SimplexSolver solver = new Cassowary.SimplexSolver ();

            solver.add_constraint (new Cassowary.LinearEquation.with_variable_value (x, 10.0));
            solver.add_constraint (new Cassowary.LinearEquation.with_variable_value (x, 5.0));

            assert (false);
        }
        catch (GLib.Error err)
        {
            Test.message ("got the exception");
        }
    }

    public void
    test_inconsistent2 ()
    {
        try
        {
            Cassowary.Variable x = new Cassowary.Variable.with_name ("x");
            Cassowary.SimplexSolver solver = new Cassowary.SimplexSolver ();

            solver.add_constraint (new Cassowary.LinearInequality.with_variable_value (x, Cassowary.Operator.GEQ, 10.0));
            solver.add_constraint (new Cassowary.LinearInequality.with_variable_value (x, Cassowary.Operator.LEQ, 5.0));

            assert (false);
        }
        catch (GLib.Error err)
        {
            Test.message ("got the exception");
        }
    }

    public void
    test_inconsistent3 ()
    {
        try
        {
            Cassowary.Variable w = new Cassowary.Variable.with_name ("w");
            Cassowary.Variable x = new Cassowary.Variable.with_name ("x");
            Cassowary.Variable y = new Cassowary.Variable.with_name ("y");
            Cassowary.Variable z = new Cassowary.Variable.with_name ("z");
            Cassowary.SimplexSolver solver = new Cassowary.SimplexSolver ();

            solver.add_constraint (new Cassowary.LinearInequality.with_variable_value (w, Cassowary.Operator.GEQ, 10.0));
            solver.add_constraint (new Cassowary.LinearInequality.with_variables (x, Cassowary.Operator.GEQ, w));
            solver.add_constraint (new Cassowary.LinearInequality.with_variables (y, Cassowary.Operator.GEQ, x));
            solver.add_constraint (new Cassowary.LinearInequality.with_variables (z, Cassowary.Operator.GEQ, y));
            solver.add_constraint (new Cassowary.LinearInequality.with_variable_value (z, Cassowary.Operator.GEQ, 8.0));
            solver.add_constraint (new Cassowary.LinearInequality.with_variable_value (z, Cassowary.Operator.LEQ, 4.0));

            assert (false);
        }
        catch (GLib.Error err)
        {
            Test.message ("got the exception");
        }
    }

    public void
    test_multi_edit ()
    {
        try
        {
            Cassowary.Variable x = new Cassowary.Variable.with_name ("x");
            Cassowary.Variable y = new Cassowary.Variable.with_name ("y");
            Cassowary.Variable w = new Cassowary.Variable.with_name ("w");
            Cassowary.Variable h = new Cassowary.Variable.with_name ("h");
            Cassowary.SimplexSolver solver = new Cassowary.SimplexSolver ();

            solver.add_stay (x);
            solver.add_stay (y);
            solver.add_stay (w);
            solver.add_stay (h);

            solver.add_edit_var (x);
            solver.add_edit_var (y);
            solver.begin_edit ();

            solver.suggest_value (x, 10);
            solver.suggest_value (y, 20);
            solver.resolve ();

            assert (Cassowary.approx_variable_with_value (x, 10) && Cassowary.approx_variable_with_value (y, 20) &&
                    Cassowary.approx_variable_with_value (w, 0) && Cassowary.approx_variable_with_value (h, 0));

            Test.message ("x == %f, y == %f", x.@value, y.@value);
            Test.message ("w == %f, h == %f", w.@value, h.@value);

            solver.add_edit_var (w);
            solver.add_edit_var (h);
            solver.begin_edit ();

            solver.suggest_value (w, 30);
            solver.suggest_value (h, 40);
            solver.end_edit ();

            assert (Cassowary.approx_variable_with_value (x, 10) && Cassowary.approx_variable_with_value (y, 20) &&
                    Cassowary.approx_variable_with_value (w, 30) && Cassowary.approx_variable_with_value (h, 40));

            Test.message ("x == %f, y == %f", x.@value, y.@value);
            Test.message ("w == %f, h == %f", w.@value, h.@value);

            solver.suggest_value (x, 50);
            solver.suggest_value (y, 60);
            solver.end_edit ();

            assert (Cassowary.approx_variable_with_value (x, 50) && Cassowary.approx_variable_with_value (y, 60) &&
                    Cassowary.approx_variable_with_value (w, 30) && Cassowary.approx_variable_with_value (h, 40));

            Test.message ("x == %f, y == %f", x.@value, y.@value);
            Test.message ("w == %f, h == %f", w.@value, h.@value);
        }
        catch (GLib.Error err)
        {
            Test.message (err.message);
            assert (false);
        }
    }

    public void
    test_add_del_bench ()
    {
        try
        {
            double ineqProb = 0.12;
            int maxVars = 3;

            Test.message ("starting timing test. nCns = %i , nVars = %i, nResolves = %i", N_CONSTRAINTS, N_VARIABLES, N_RESOLVES);

            Test.timer_start ();
            Cassowary.SimplexSolver solver = new Cassowary.SimplexSolver ();

            Cassowary.Variable[] rgpclv = new Cassowary.Variable[N_VARIABLES];
            for (int i = 0; i < N_VARIABLES; i++)
            {
                rgpclv[i] = new Cassowary.Variable.with_prefix (i, "x");
                solver.add_stay (rgpclv[i]);
            }

            Cassowary.Constraint[] rgpcns = new Cassowary.Constraint[N_CONSTRAINTS];
            int nvs = 0;
            int k;
            int j;
            double coeff;
            for (j = 0; j < N_CONSTRAINTS; j++)
            {
                // number of variables in this constraint
                nvs = Test.rand_int_range (1, maxVars);
                Cassowary.LinearExpression expr = new Cassowary.LinearExpression.from_constant (Test.rand_double () * 20.0 - 10.0);
                for (k = 0; k < nvs; k++)
                {
                    coeff = Test.rand_double () * 10 - 5;
                    int iclv = (int) (Test.rand_double () * N_VARIABLES);
                    expr.add_expression (Cassowary.var_times_constant (rgpclv[iclv], coeff));
                }
                if (Test.rand_double () < ineqProb)
                {
                    rgpcns[j] = new Cassowary.LinearInequality (expr);
                }
                else
                {
                    rgpcns[j] = new Cassowary.LinearEquation (expr);
                }
            }

            Test.message ("done building data structures");
            Test.message ("time = %f", Test.timer_elapsed ());

            Test.timer_start ();
            int cExceptions = 0;
            for (j = 0; j < N_CONSTRAINTS; j++)
            {
                // add the constraint -- if it's incompatible, just ignore it
                try
                {
                    solver.add_constraint (rgpcns[j]);
                }
                catch (GLib.Error err)
                {
                    cExceptions++;
                    rgpcns[j] = null;
                }
            }

            Test.message ("done adding constraints [%i exceptions]", cExceptions);
            Test.message ("time = %f", Test.timer_elapsed ());

            Test.timer_start ();
            int e1Index = (int)(Test.rand_double () * N_VARIABLES);
            int e2Index = (int)(Test.rand_double () * N_VARIABLES);

            Test.message("indices %i,%i", e1Index, e2Index);

            Cassowary.EditConstraint edit1 = new Cassowary.EditConstraint (rgpclv[e1Index], Cassowary.Strength.strong);
            Cassowary.EditConstraint edit2 = new Cassowary.EditConstraint (rgpclv[e2Index], Cassowary.Strength.strong);

            solver.add_constraint (edit1);
            solver.add_constraint (edit2);

            Test.message ("done creating edit constraints -- about to start resolves");
            Test.message ("time = %f", Test.timer_elapsed ());

            Test.timer_start ();
            for (int m = 0; m < N_RESOLVES; m++)
            {
                solver.resolve_values (rgpclv[e1Index].@value * 1.001, rgpclv[e2Index].@value * 1.001);
            }

            Test.message ("done resolves -- now removing constraints");
            Test.message ("time = %f", Test.timer_elapsed ());

            solver.remove_constraint (edit1);
            solver.remove_constraint (edit2);

            Test.timer_start ();
            for (j = 0; j < N_CONSTRAINTS; j++)
            {
                if (rgpcns[j] != null)
                {
                    solver.remove_constraint (rgpcns[j]);
                }
            }

            Test.message ("done removing constraints and AddDel timing test");
            Test.message ("time = %f", Test.timer_elapsed ());
        }
        catch (GLib.Error err)
        {
            Test.message (err.message);
            assert (false);
        }
    }
}
