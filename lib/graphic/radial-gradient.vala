/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * radial-gradient.vala
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

public class Maia.Graphic.RadialGradient : Gradient
{
    // properties
    private Point  m_Start;
    private double m_StartRadius;
    private Point  m_End;
    private double m_EndRadius;

    // accessors
    public Point start {
        get {
            return m_Start;
        }
    }

    public double start_radius {
        get {
            return m_StartRadius;
        }
    }

    public Point end {
        get {
            return m_End;
        }
    }

    public double end_radius {
        get {
            return m_EndRadius;
        }
    }

    // methods
    public RadialGradient (Point inStart, double inStartRadius, Point inEnd, double inEndRadius)
    {
        m_Start = inStart;
        m_StartRadius = inStartRadius;
        m_End = inEnd;
        m_EndRadius = inEndRadius;
    }

    internal RadialGradient.from_function (Manifest.Function inFunction) throws Manifest.Error
    {
        int cpt = 0;
        foreach (unowned Core.Object child in inFunction)
        {
            unowned Manifest.Attribute arg = (Manifest.Attribute)child;
            switch (cpt)
            {
                case 0:
                    m_Start.x = (double)arg.transform (typeof (double));
                    break;

                case 1:
                    m_Start.y = (double)arg.transform (typeof (double));
                    break;

                case 2:
                    m_StartRadius = (double)arg.transform (typeof (double));
                    break;

                case 3:
                    m_End.x = (double)arg.transform (typeof (double));
                    break;

                case 4:
                    m_End.y = (double)arg.transform (typeof (double));
                    break;

                case 5:
                    m_EndRadius = (double)arg.transform (typeof (double));
                    break;

                default:
                    add ((Gradient.ColorStop)arg.transform (typeof (Gradient.ColorStop)));
                    break;
            }
            cpt++;
        }

        if (cpt <= 5)
        {
            throw new Manifest.Error.MISSING_FUNCTION_ARGUMENT ("Missing argument in %s function", inFunction.to_string ());
        }
    }
}
