/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * mesh-gradient.vala
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

public class Maia.Graphic.MeshGradient : Gradient
{
    // types
    public class Patch : Core.Object
    {
        public abstract class Control : Core.Object
        {
        }

        public class ControlPoint : Control
        {
            // properties
            private uint  m_Num;
            private Point m_Point;

            // accessors
            public uint num {
                get {
                    return m_Num;
                }
            }

            public Point point {
                get {
                    return m_Point;
                }
            }

            // methods
            public ControlPoint (uint inNum, Point inPoint)
                requires (inNum < 4)
            {
                m_Num = inNum;
                m_Point = inPoint;
            }

            internal override int
            compare (Core.Object inOther)
            {
                // do not sort control point
                return 0;
            }
        }

        public class CornerColor : Control
        {
            // properties
            private uint  m_Num;
            private Color m_Color;

            // accessors
            public uint num {
                get {
                    return m_Num;
                }
            }

            public Color color {
                get {
                    return m_Color;
                }
            }

            // methods
            public CornerColor (uint inNum, Color inColor)
                requires (inNum < 4)
            {
                m_Num = inNum;
                m_Color = inColor;
            }

            internal override int
            compare (Core.Object inOther)
            {
                // do not sort corner color
                return 0;
            }
        }

        // properties
        private Path m_Path;

        // accessors
        public Path path {
            get {
                return m_Path;
            }
        }

        // methods
        public Patch (Path inPath)
        {
            m_Path = inPath;
        }

        internal override int
        compare (Core.Object inOther)
        {
            // do not sort patch
            return 0;
        }
    }



    // methods
    public MeshGradient ()
    {
    }
}
