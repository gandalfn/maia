/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * symbolic-weight.vala
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

public class Maia.Cassowary.SymbolicWeight : Core.Object
{
    // static properties
    private static SymbolicWeight s_Zero;

    // properties
    private double[] m_Values;

    // accessors
    public int levels {
        get {
          return m_Values.length;
        }
    }

    public bool is_negative {
        get {
            return compare (zero) < 0;
        }
    }

    // static accessors
    public static SymbolicWeight zero {
        get {
            return s_Zero;
        }
    }

    // static methods
    static construct
    {
        s_Zero = new SymbolicWeight.with_weights (0.0, 0.0, 0.0);
    }

    // methods
    public SymbolicWeight (int inLevels)
    {
        m_Values = new double[inLevels];
    }

    public SymbolicWeight.with_weights (double inW1, double inW2, double inW3)
    {
        m_Values = { inW1, inW2, inW3 };
    }

    public SymbolicWeight.with_values (double[] inWeights)
    {
        m_Values = inWeights;
    }

    public SymbolicWeight
    clone ()
    {
      return new SymbolicWeight.with_values (m_Values);
    }

    public SymbolicWeight
    times (double inN)
    {
        SymbolicWeight ret = clone();

        for (int cpt = 0; cpt < m_Values.length; ++cpt)
        {
            ret.m_Values[cpt] *= inN;
        }

        return ret;
    }

    public SymbolicWeight
    divide_by (double inN)
        requires (inN != 0)
    {
        SymbolicWeight ret = clone();

        for (int cpt = 0; cpt < m_Values.length; ++cpt)
        {
            ret.m_Values[cpt] *= inN;
        }

        return ret;
    }

    public new SymbolicWeight
    add (SymbolicWeight inOther)
        requires (inOther.m_Values.length == m_Values.length)
    {
        SymbolicWeight ret = clone();

        for (int cpt = 0; cpt < m_Values.length; ++cpt)
        {
            ret.m_Values[cpt] += inOther.m_Values[cpt];
        }

        return ret;
    }

    public SymbolicWeight
    subtract (SymbolicWeight inOther)
        requires (inOther.m_Values.length == m_Values.length)
    {
        SymbolicWeight ret = clone();

        for (int cpt = 0; cpt < m_Values.length; ++cpt)
        {
            ret.m_Values[cpt] -= inOther.m_Values[cpt];
        }

        return ret;
    }

    public double
    to_double ()
    {
        double sum = 0;
        double factor = 1;
        double multiplier = 1000;

        for (int cpt = m_Values.length - 1; cpt >= 0; --cpt)
        {
            sum += m_Values[cpt] * factor;
            factor *= multiplier;
        }

        return sum;
    }

    internal override int
    compare (Core.Object inOther)
        requires (inOther is SymbolicWeight)
        requires ((inOther as SymbolicWeight).m_Values.length == m_Values.length)
    {
        unowned SymbolicWeight? sw = inOther as SymbolicWeight;

        for (int cpt = 0; cpt < m_Values.length; ++cpt)
        {
            if (m_Values[cpt] < sw.m_Values[cpt])
                return -1;
            else if (m_Values[cpt] > sw.m_Values[cpt])
                return 1;
        }

        return 0;
    }

    internal override string
    to_string ()
    {
        string result = "";

        if (m_Values.length > 0)
        {
            result = "[";

            for (int cpt = 0; cpt < m_Values.length - 1; ++cpt)
            {
                result += m_Values[cpt].to_string () + ",";
            }

            result += m_Values[m_Values.length - 1].to_string () + "]";
        }

        return result;
    }
}
