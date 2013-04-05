/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * gradient.vala
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

public abstract class Maia.Graphic.Gradient : Pattern
{
    // type
    public class ColorStop : Object
    {
        public double offset { get; construct set; default = 0.0; }
        public Color  color  { get; construct set; default = null; }

        public ColorStop (double inOffset, Color inColor)
        {
            GLib.Object (offset: inOffset, color: inColor);
        }

        internal ColorStop.from_function (Manifest.Function inFunction)
        {
            int cpt = 0;
            foreach (unowned Object child in inFunction)
            {
                unowned Manifest.Attribute arg = (Manifest.Attribute)child;
                switch (cpt)
                {
                    case 0:
                        offset = (double)arg.transform (typeof (double));
                        break;
                    case 1:
                        color = (Color)arg.transform (typeof (Color));
                        break;
                    default:
                        break;
                }
                cpt++;
                if (cpt > 1) break;
            }
        }

        internal override int
        compare (Object inOther)
            requires (inOther is ColorStop)
        {
            return (int)(offset - (inOther as ColorStop).offset);
        }
    }

    // methods
    internal override bool
    can_append_child (Object inChild)
    {
        return inChild is ColorStop;
    }
}
