/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * function.vala
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

public class Maia.Manifest.Function : Attribute
{
    // Types
    public delegate void TransformFunc (Function inFunction, ref GLib.Value outValue);

    private class Transform : Object
    {
        public string        name;
        public TransformFunc func;

        public Transform (string inName, owned TransformFunc inFunc)
        {
            name = inName;
            func = (owned)inFunc;
        }

        public override int
        compare (Object inOther)
        {
            return GLib.strcmp (name, (inOther as Transform).name);
        }

        public int
        compare_with_name (string inName)
        {
            return GLib.strcmp (name, inName);
        }
    }

    // Static properties
    private static Map<GLib.Type, Set<Transform>> s_Transforms;

    // Static methods
    public static new void
    register_transform_func (GLib.Type inType, string inName, owned TransformFunc inFunc)
    {
        if (s_Transforms == null)
        {
            s_Transforms = new Map<GLib.Type, Set<Transform>> ();
        }

        unowned Set<Transform> functions = s_Transforms[inType];
        if (functions == null)
        {
            Transform transform = new Transform (inName, (owned)inFunc);
            Set<Transform> transform_functions = new Set<Transform> ();
            transform_functions.insert (transform);
            s_Transforms[inType] = transform_functions;
        }
        else
        {
            Transform transform = new Transform (inName, (owned)inFunc);
            functions.insert (transform);
        }
    }

    // Methods
    /**
     * Create a new function attribute
     *
     * @param inOwner owner of function
     * @param inFunctionName function name
     */
    public Function (Object inOwner, string inFunctionName)
    {
        base (inOwner, inFunctionName);
    }

    protected override void
    on_transform (GLib.Type inType, ref GLib.Value outValue)
    {
        unowned Set<Transform>? functions = s_Transforms[inType];
        if (functions != null)
        {
           unowned Transform? transform = functions.search<string> (get (), Transform.compare_with_name);
            if (transform != null)
            {
                transform.func (this, ref outValue);
                return;
            }
        }

        base.on_transform (inType, ref outValue);
    }

    public void
    parse (AttributeScanner inScanner) throws ParseError
    {
        foreach (Parser.Token token in inScanner)
        {
            switch (token)
            {
                case Parser.Token.START_ELEMENT:
                    Function function = new Function (owner, inScanner.element);
                    function.parent = this;
                    function.parse (inScanner);
                    break;

                case Parser.Token.END_ELEMENT:
                    if (inScanner.element == get ())
                        return;
                    break;

                case Parser.Token.ATTRIBUTE:
                    if (inScanner.attribute.has_prefix("@"))
                    {
                        AttributeBind attr = new AttributeBind (owner, inScanner.attribute);
                        attr.parent = this;
                    }
                    else
                    {
                        Attribute attr = new Attribute (owner, inScanner.attribute);
                        attr.parent = this;
                    }
                    break;

                case Parser.Token.EOF:
                    break;
            }
        }
    }
}
