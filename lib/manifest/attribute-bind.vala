/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * attribute-bind.vala
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

public class Maia.Manifest.AttributeBind : Attribute
{
    // Types
    [CCode (has_target = false)]
    public delegate void BindFunc (AttributeBind inAttributeBind, Object inSrc, string inProperty);
    [CCode (has_target = false)]
    public delegate void BindFuncArg1<T> (AttributeBind inAttributeBind, Object inSrc, string inProperty, T inArg);
    public delegate void TransformFunc (AttributeBind inAttributeBind, ref GLib.Value outValue) throws Error;

    private class BindClosure
    {
        protected AttributeBind  attribute;
        protected string         quark;
        protected string         property;
        protected unowned Object src;
        protected ulong          id;
        protected BindFunc       func;

        protected BindClosure.init (AttributeBind inAttribute, Object inSrc, string inProperty, string inSignalName, BindFunc inFunc)
        {
            attribute = inAttribute;
            src = inSrc;
            func = inFunc;
            property = inProperty;
        }

        public BindClosure (AttributeBind inAttribute, Object inSrc, string inProperty, string inSignalName, BindFunc inFunc)
        {
            this.init (inAttribute, inSrc, inProperty, inSignalName, inFunc);

            id = GLib.Signal.connect_swapped (inSrc, inSignalName, (GLib.Callback)on_bind, this);

            quark = "MaiaAttributeBind%s%s%lu".printf (inProperty, inSignalName, id);
            inSrc.set_data_full (quark, this, (GLib.DestroyNotify)on_source_destroy);
        }

        private void
        on_bind ()
        {
            func (attribute, src, property);
        }

        protected static void
        on_source_destroy (BindClosure inThis)
        {
            if (inThis.id != 0)
            {
                inThis.id = 0;
                inThis.src = null;
            }
        }

        public void
        disconnect ()
        {
            if (id != 0 && src != null && src is Object && src.ref_count > 0)
            {
                GLib.SignalHandler.disconnect (src, id);
                id = 0;
                src.steal_data<ulong> (quark);
            }
        }
    }

    private class BindClosureArg1<T> : BindClosure
    {
        public BindClosureArg1 (AttributeBind inAttribute, Object inSrc, string inProperty, string inSignalName, BindFuncArg1<T> inFunc)
        {
            this.init (inAttribute, inSrc, inProperty, inSignalName, (BindFunc)inFunc);

            id = GLib.Signal.connect_swapped (inSrc, inSignalName, (GLib.Callback)on_bind, this);

            quark = "MaiaAttributeBind%s%s%lu".printf (inProperty, inSignalName, id);
            inSrc.set_data_full (quark, this, (GLib.DestroyNotify)on_source_destroy);
        }

        private void
        on_bind (T inArg)
        {
            ((BindFuncArg1)func) (attribute, src, property, inArg);
        }
    }

    private class Transform : Core.Object
    {
        public GLib.Type     gtype;
        public TransformFunc func;

        public Transform (GLib.Type inType, owned TransformFunc inFunc)
        {
            gtype = inType;
            func = (owned)inFunc;
        }

        public override int
        compare (Core.Object inOther)
        {
            return (int)(gtype - (inOther as Transform).gtype);
        }

        public int
        compare_with_type (GLib.Type inType)
        {
            return (int)(gtype - inType);
        }

        public inline bool
        compare_type_is_a (GLib.Type inType)
        {
            return inType.is_a (gtype);
        }
    }

    // Static properties
    private static Core.Map<string, Core.Set<Transform>> s_Transforms;

    // Static methods
    private static void
    on_bind_closure_destroy (void* inpData)
    {
        BindClosure* pClosure = (BindClosure*)inpData;

        pClosure->disconnect ();

        delete pClosure;
    }

    public static new void
    register_transform_func (GLib.Type inType, string inName, owned TransformFunc inFunc)
    {
        if (s_Transforms == null)
        {
            s_Transforms = new Core.Map<string, Core.Set<Transform>> ();
        }

        unowned Core.Set<Transform> binds = s_Transforms[inName];
        if (binds == null)
        {
            Transform transform = new Transform (inType, (owned)inFunc);
            Core.Set<Transform> transform_functions = new Core.Set<Transform> ();
            transform_functions.insert (transform);
            s_Transforms[inName] = transform_functions;
        }
        else
        {
            Transform transform = new Transform (inType, (owned)inFunc);
            binds.insert (transform);
        }
    }


    // Methods
    /**
     * Create a new attribute bind
     *
     * @param inOwner owner of attribute
     * @param inValue attribute bind value
     */
    internal AttributeBind (Object? inOwner, string inValue)
    {
        base (inOwner, inValue.substring (1));
    }

    internal override void
    on_transform (GLib.Type inType, ref GLib.Value outValue) throws Error
    {
        if (owner != null)
        {
            unowned Core.Set<Transform>? binds = s_Transforms[get ()];
            if (binds != null)
            {
                // Search type
                unowned Transform? transform = binds.search<GLib.Type> (owner.get_type (), Transform.compare_with_type);
                if (transform == null)
                {
                    // Type not found search for derived type
                    foreach (unowned Transform bind in binds)
                    {
                        if (bind.compare_type_is_a (owner.get_type ()))
                        {
                            transform = bind;
                            break;
                        }
                    }
                }
                if (transform != null)
                {
                    transform.func (this, ref outValue);
                    return;
                }
                else
                {
                    throw new Error.INVALID_TYPE ("Unknown attribute bind %s for value %s", get(), inType.name ());
                }
            }
        }

        throw new Error.BIND_ATTRIBUTE ("Bind attribute %s", get ());
    }

    internal override string
    to_string ()
    {
        return "@" + get ();
    }

    public bool
    is_bind (string inSignalName, string inProperty)
    {
        string quark = "MaiaAttributeBind%s%s%s".printf (get (), inSignalName, inProperty);
        return owner != null ? owner.get_data<BindClosure*> (quark) != null : false;
    }

    public void
    bind (Object inSrc, string inSignalName, string inProperty, BindFunc inFunc)
    {
        if (owner != null)
        {
            BindClosure* pClosure = new BindClosure (this, inSrc, inProperty, inSignalName, inFunc);
            string quark = "MaiaAttributeBind%s%s%s".printf (get (), inSignalName, inProperty);

            owner.set_data_full (quark, pClosure, on_bind_closure_destroy);
        }
    }

    public void
    bind_with_arg1<T> (Object inSrc, string inSignalName, string inProperty, BindFuncArg1<T> inFunc)
    {
        if (owner != null)
        {
            BindClosureArg1<T>* pClosure = new BindClosureArg1<T> (this, inSrc, inProperty, inSignalName, inFunc);
            string quark = "MaiaAttributeBind%s%s%s".printf (get (), inSignalName, inProperty);

            owner.set_data_full (quark, pClosure, on_bind_closure_destroy);
        }
    }
}
