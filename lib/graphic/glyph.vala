/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * glyph.vala
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

public class Maia.Graphic.Glyph : Core.Object
{
    // types
    public enum Alignment
    {
        LEFT,
        CENTER,
        RIGHT;

        public string
        to_string ()
        {
            switch (this)
            {
                case LEFT:
                    return "left";

                case CENTER:
                    return "center";

                case RIGHT:
                    return "right";
            }

            return "center";
        }

        public static Alignment
        from_string (string inValue)
        {
            switch (inValue)
            {
                case "left":
                    return LEFT;

                case "center":
                    return CENTER;

                case "right":
                    return RIGHT;
            }

            return CENTER;
        }
    }

    public enum WrapMode
    {
        CHAR,
        WORD;

        public string
        to_string ()
        {
            switch (this)
            {
                case CHAR:
                    return "char";

                case WORD:
                    return "word";
            }

            return "word";
        }

        public static WrapMode
        from_string (string inValue)
        {
            switch (inValue)
            {
                case "char":
                    return CHAR;

                case "word":
                    return WORD;
            }

            return WORD;
        }
    }

    public enum EllipsizeMode
    {
        NONE,
        START,
        MIDDLE,
        END;

        public string
        to_string ()
        {
            switch (this)
            {
                case NONE:
                    return "none";

                case START:
                    return "start";

                case MIDDLE:
                    return "middle";

                case END:
                    return "end";
            }

            return "none";
        }

        public static EllipsizeMode
        from_string (string inValue)
        {
            switch (inValue)
            {
                case "none":
                    return NONE;

                case "start":
                    return START;

                case "middle":
                    return MIDDLE;

                case "end":
                    return END;
            }

            return NONE;
        }
    }

    public class Line : Core.Object
    {
        // accessors
        public virtual Size size {
            get {
                return Size (0, 0);
            }
        }
    }

    // accessors
    public string        font_description { get; construct set; }
    public Alignment     alignment        { get; set; default = Alignment.CENTER; }
    public WrapMode      wrap             { get; set; default = WrapMode.WORD; }
    public EllipsizeMode ellipsize        { get; set; default = EllipsizeMode.NONE; }
    public string        text             { get; set; }
    public Point         origin           { get; set; }

    public virtual Size size {
        get {
            return Size (0, 0);
        }
        set {
        }
    }

    // methods
    public Glyph (string inFontDescription)
    {
        GLib.Object (font_description: inFontDescription);
    }

    internal override bool
    can_append_child (Core.Object inObject)
    {
        return inObject is Line;
    }

    public virtual void
    update (Context inContext)
    {
    }

    public virtual Rectangle
    get_cursor_position (int inIndex)
    {
        return Rectangle (0, 0, 0, 0);
    }
}
