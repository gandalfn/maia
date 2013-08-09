/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * linear-gradient.vala
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

public class Maia.Graphic.LinearGradient : Gradient
{
    // properties
    private Point m_Start;
    private Point m_End;

    // accessors
    public Point start {
        get {
            return m_Start;
        }
    }

    public Point end {
        get {
            return m_End;
        }
    }

    public double start_x {
        set {
            m_Start.x = value;
        }
    }

    public double start_y {
        set {
            m_Start.y = value;
        }
    }

    public double end_x {
        set {
            m_End.x = value;
        }
    }

    public double end_y {
        set {
            m_End.y = value;
        }
    }

    // methods
    public LinearGradient (Point inStart, Point inEnd)
    {
        m_Start = inStart;
        m_End = inEnd;
    }

    internal LinearGradient.from_function (Manifest.Function inFunction) throws Manifest.Error
    {
        int cpt = 0;
        foreach (unowned Core.Object child in inFunction)
        {
            unowned Manifest.Attribute arg = (Manifest.Attribute)child;
            switch (cpt)
            {
                case 0:
                    if (arg is Manifest.AttributeBind)
                        (arg as Manifest.AttributeBind).bind (this, "start-x");
                    else
                        m_Start.x = (double)arg.transform (typeof (double));
                    break;

                case 1:
                    if (arg is Manifest.AttributeBind)
                        (arg as Manifest.AttributeBind).bind (this, "start-y");
                    else
                        m_Start.y = (double)arg.transform (typeof (double));
                    break;

                case 2:
                    if (arg is Manifest.AttributeBind)
                        (arg as Manifest.AttributeBind).bind (this, "end-x");
                    else
                        m_End.x = (double)arg.transform (typeof (double));
                    break;

                case 3:
                    Log.debug (GLib.Log.METHOD, Log.Category.GRAPHIC_PARSING, "%s", (arg is Manifest.AttributeBind).to_string ());
                    if (arg is Manifest.AttributeBind)
                        (arg as Manifest.AttributeBind).bind (this, "end-y");
                    else
                        m_End.y = (double)arg.transform (typeof (double));
                    break;

                default:
                    add ((Gradient.ColorStop)arg.transform (typeof (Gradient.ColorStop)));
                    break;
            }
            cpt++;
        }

        if (cpt <= 3)
        {
            throw new Manifest.Error.MISSING_FUNCTION_ARGUMENT ("Missing argument in %s function", inFunction.to_string ());
        }
    }
}