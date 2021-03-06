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
            switch (inValue.down ())
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
            switch (inValue.down ())
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
            switch (inValue.down ())
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
    [CCode (notify = false)]
    public string        font_description { get; construct set; }
    [CCode (notify = false)]
    public Alignment     alignment        { get; set; default = Alignment.CENTER; }
    [CCode (notify = false)]
    public WrapMode      wrap             { get; set; default = WrapMode.WORD; }
    [CCode (notify = false)]
    public EllipsizeMode ellipsize        { get; set; default = EllipsizeMode.NONE; }
    [CCode (notify = false)]
    public bool          use_markup       { get; set; default = true; }
    [CCode (notify = false)]
    public string        text             { get; set; }
    [CCode (notify = false)]
    public Point         origin           { get; set; }

    [CCode (notify = false)]
    public virtual Size size {
        get {
            return Size (0, 0);
        }
        set {
        }
    }

    public virtual int line_count {
        get {
            return 0;
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

    public virtual void
    get_line_position (int inIndex, bool inTrailing, out int outLine)
    {
        outLine = 0;
    }

    public virtual void
    get_index_from_position (Graphic.Point inPosition, out int outIndex, out int outTrailing)
    {
        outIndex = 0;
        outTrailing = 0;
    }
}
