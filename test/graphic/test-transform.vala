/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * test-transform.vala
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

public class Maia.TestTransform : Maia.TestCase
{
    private Graphic.Transform m_Transform;

    public TestTransform ()
    {
        base ("transform");

        add_test ("translate", test_transform_translate);
        add_test ("scale", test_transform_scale);
        add_test ("rotate", test_transform_rotate);
        add_test ("invert", test_transform_invert);
        add_test ("push", test_transform_push);
        add_test ("pop", test_transform_pop);
    }

    public override void
    set_up ()
    {
        m_Transform = new Graphic.Transform.identity ();
    }

    public override void
    tear_down ()
    {
        m_Transform = null;
    }

    public void
    test_transform_translate ()
    {
        double x = Test.rand_double_range (double.MIN, double.MAX);
        double y = Test.rand_double_range (double.MIN, double.MAX);
        m_Transform.translate (x, y);

        assert (m_Transform.matrix.xx == 1);
        assert (m_Transform.matrix.yx == 0);
        assert (m_Transform.matrix.xy == 0);
        assert (m_Transform.matrix.yy == 1);
        assert (m_Transform.matrix.x0 == x);
        assert (m_Transform.matrix.y0 == y);
    }

    public void
    test_transform_scale ()
    {
        global::Cairo.Matrix matrix = global::Cairo.Matrix.identity ();

        double x = Test.rand_double_range (-500, 500);
        double y = Test.rand_double_range (-500, 500);
        m_Transform.scale (x, y);

        matrix.scale (x, y);

        assert (m_Transform.matrix.xx == x);
        assert (m_Transform.matrix.yx == 0);
        assert (m_Transform.matrix.xy == 0);
        assert (m_Transform.matrix.yy == y);
        assert (m_Transform.matrix.x0 == 0);
        assert (m_Transform.matrix.y0 == 0);

        x = Test.rand_double_range (-500, 500);
        y = Test.rand_double_range (-500, 500);
        m_Transform.translate (x, y);

        matrix.translate (x, y);

        assert (m_Transform.matrix.xx == matrix.xx);
        assert (m_Transform.matrix.yx == matrix.yx);
        assert (m_Transform.matrix.xy == matrix.xy);
        assert (m_Transform.matrix.yy == matrix.yy);
        assert (m_Transform.matrix.x0 == matrix.x0);
        assert (m_Transform.matrix.y0 == matrix.y0);
    }

    public void
    test_transform_rotate ()
    {
        global::Cairo.Matrix matrix = global::Cairo.Matrix.identity ();

        double x = Test.rand_double_range (-500, 500);
        double y = Test.rand_double_range (-500, 500);
        m_Transform.translate (x, y);

        matrix.translate (x, y);

        assert (m_Transform.matrix.xx == matrix.xx);
        assert (m_Transform.matrix.yx == matrix.yx);
        assert (m_Transform.matrix.xy == matrix.xy);
        assert (m_Transform.matrix.yy == matrix.yy);
        assert (m_Transform.matrix.x0 == matrix.x0);
        assert (m_Transform.matrix.y0 == matrix.y0);

        double rad = Test.rand_double_range (0, 2 * GLib.Math.PI);
        m_Transform.rotate (rad);

        matrix.rotate (rad);

        assert (m_Transform.matrix.xx == matrix.xx);
        assert (m_Transform.matrix.yx == matrix.yx);
        assert (m_Transform.matrix.xy == matrix.xy);
        assert (m_Transform.matrix.yy == matrix.yy);
        assert (m_Transform.matrix.x0 == matrix.x0);
        assert (m_Transform.matrix.y0 == matrix.y0);

        m_Transform.translate (-x, -y);

        matrix.translate (-x, -y);

        assert (m_Transform.matrix.xx == matrix.xx);
        assert (m_Transform.matrix.yx == matrix.yx);
        assert (m_Transform.matrix.xy == matrix.xy);
        assert (m_Transform.matrix.yy == matrix.yy);
        assert (m_Transform.matrix.x0 == matrix.x0);
        assert (m_Transform.matrix.y0 == matrix.y0);
    }

    public void
    test_transform_invert ()
    {
        global::Cairo.Matrix matrix = global::Cairo.Matrix.identity ();

        double x = Test.rand_double_range (-500, 500);
        double y = Test.rand_double_range (-500, 500);
        m_Transform.scale (x, y);

        matrix.scale (x, y);

        assert (m_Transform.matrix.xx == x);
        assert (m_Transform.matrix.yx == 0);
        assert (m_Transform.matrix.xy == 0);
        assert (m_Transform.matrix.yy == y);
        assert (m_Transform.matrix.x0 == 0);
        assert (m_Transform.matrix.y0 == 0);

        x = Test.rand_double_range (-500, 500);
        y = Test.rand_double_range (-500, 500);
        m_Transform.translate (x, y);

        matrix.translate (x, y);

        assert (m_Transform.matrix.xx == matrix.xx);
        assert (m_Transform.matrix.yx == matrix.yx);
        assert (m_Transform.matrix.xy == matrix.xy);
        assert (m_Transform.matrix.yy == matrix.yy);
        assert (m_Transform.matrix.x0 == matrix.x0);
        assert (m_Transform.matrix.y0 == matrix.y0);

        matrix.invert ();
        var m = m_Transform.matrix;
        try
        {
            m.invert ();
        }
        catch (Graphic.Error err)
        {
            Test.message (err.message);
            assert (false);
        }

        assert (m.xx == matrix.xx);
        assert (m.yx == matrix.yx);
        assert (m.xy == matrix.xy);
        assert (m.yy == matrix.yy);
        assert (m.x0 == matrix.x0);
        assert (m.y0 == matrix.y0);
    }

    public void
    test_transform_push ()
    {
        global::Cairo.Matrix matrix = global::Cairo.Matrix.identity ();

        double x = Test.rand_double_range (-500, 500);
        double y = Test.rand_double_range (-500, 500);
        matrix.scale (x, y);

        var s = new Graphic.Transform (x, 0, 0, y, 0, 0);
        s.parent = m_Transform;

        x = Test.rand_double_range (-500, 500);
        y = Test.rand_double_range (-500, 500);
        matrix.translate (x, y);

        var t = new Graphic.Transform (1, 0, 0, 1, x, y);
        t.parent = m_Transform;

        assert (m_Transform.matrix.xx == matrix.xx);
        assert (m_Transform.matrix.yx == matrix.yx);
        assert (m_Transform.matrix.xy == matrix.xy);
        assert (m_Transform.matrix.yy == matrix.yy);
        assert (m_Transform.matrix.x0 == matrix.x0);
        assert (m_Transform.matrix.y0 == matrix.y0);
    }

    public void
    test_transform_pop ()
    {
        global::Cairo.Matrix matrix = global::Cairo.Matrix.identity ();
        global::Cairo.Matrix matrix2 = global::Cairo.Matrix.identity ();

        double x = Test.rand_double_range (-500, 500);
        double y = Test.rand_double_range (-500, 500);
        matrix.scale (x, y);
        matrix2.scale (x, y);

        var s = new Graphic.Transform (x, 0, 0, y, 0, 0);
        s.parent = m_Transform;

        x = Test.rand_double_range (-500, 500);
        y = Test.rand_double_range (-500, 500);
        matrix.translate (x, y);

        var t = new Graphic.Transform (1, 0, 0, 1, x, y);
        t.parent = m_Transform;

        x = Test.rand_double_range (-500, 500);
        y = Test.rand_double_range (-500, 500);
        matrix.translate (x, y);
        matrix2.translate (x, y);

        var t2 = new Graphic.Transform (1, 0, 0, 1, x, y);
        t2.parent = m_Transform;

        assert (m_Transform.matrix.xx == matrix.xx);
        assert (m_Transform.matrix.yx == matrix.yx);
        assert (m_Transform.matrix.xy == matrix.xy);
        assert (m_Transform.matrix.yy == matrix.yy);
        assert (m_Transform.matrix.x0 == matrix.x0);
        assert (m_Transform.matrix.y0 == matrix.y0);

        t.parent = null;

        assert (m_Transform.matrix.xx == matrix2.xx);
        assert (m_Transform.matrix.yx == matrix2.yx);
        assert (m_Transform.matrix.xy == matrix2.xy);
        assert (m_Transform.matrix.yy == matrix2.yy);
        assert (m_Transform.matrix.x0 == matrix2.x0);
        assert (m_Transform.matrix.y0 == matrix2.y0);
    }
}
