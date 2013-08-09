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
    public delegate void TransformFunc (Function inFunction, ref GLib.Value outValue) throws Error;

    private class Transform : Core.Object
    {
        public string        name;
        public TransformFunc func;

        public Transform (string inName, owned TransformFunc inFunc)
        {
            name = inName;
            func = (owned)inFunc;
        }

        public override int
        compare (Core.Object inOther)
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
    private static Core.Map<GLib.Type, Core.Set<Transform>> s_Transforms;

    // Static methods
    public static new void
    register_transform_func (GLib.Type inType, string inName, owned TransformFunc inFunc)
    {
        if (s_Transforms == null)
        {
            s_Transforms = new Core.Map<GLib.Type, Core.Set<Transform>> ();
        }

        unowned Core.Set<Transform> functions = s_Transforms[inType];
        if (functions == null)
        {
            Transform transform = new Transform (inName, (owned)inFunc);
            Core.Set<Transform> transform_functions = new Core.Set<Transform> ();
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
    internal Function (Object? inOwner, string inFunctionName)
    {
        base (inOwner, inFunctionName);
    }

    internal override void
    on_transform (GLib.Type inType, ref GLib.Value outValue) throws Error
    {
        Log.debug (GLib.Log.METHOD, Log.Category.MANIFEST_ATTRIBUTE, "type: %s, name: %s", inType.name (), get ());
        unowned Core.Set<Transform>? functions = s_Transforms[inType];
        if (functions != null)
        {
            unowned Transform? transform = functions.search<string> (get (), Transform.compare_with_name);
            if (transform != null)
            {
                Log.debug (GLib.Log.METHOD, Log.Category.MANIFEST_ATTRIBUTE, "found name: %s", get ());
                transform.func (this, ref outValue);
                return;
            }
            else
            {
                throw new Error.INVALID_TYPE ("Unknown function %s for value %s", get(), inType.name ());
            }
        }

        base.on_transform (inType, ref outValue);
    }

    internal void
    parse (AttributeScanner inScanner) throws Core.ParseError
    {
        foreach (Core.Parser.Token token in inScanner)
        {
            switch (token)
            {
                case Core.Parser.Token.START_ELEMENT:
                    Function function = new Function (owner, inScanner.element);
                    function.parent = this;
                    function.parse (inScanner);
                    break;

                case Core.Parser.Token.END_ELEMENT:
                    if (inScanner.element == get ())
                        return;
                    break;

                case Core.Parser.Token.ATTRIBUTE:
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

                case Core.Parser.Token.EOF:
                    break;
            }
        }
    }

    internal override string
    to_string ()
    {
        string ret = get ();
        ret += "(";

        bool first = true;
        foreach (unowned Core.Object child in this)
        {
            if (first)
                ret += child.to_string ();
            else
                ret += ", " + child.to_string ();
            first = false;
        }
        ret += ")";

        return ret;
    }
}
