/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * object.vala
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

public abstract class Maia.Core.Object : Any
{
    // types
    private class PlugProperty
    {
        public struct Hash
        {
            public string          m_SrcProperty;
            public unowned Object? m_Dst;
            public string          m_DstProperty;

            public Hash (string inSrcProperty, Object inDst, string inDstProperty)
            {
                m_SrcProperty = inSrcProperty;
                m_Dst = inDst;
                m_DstProperty = inDstProperty;
            }

            public inline int
            compare (Hash inHash)
            {
                int ret = GLib.strcmp (m_SrcProperty, inHash.m_SrcProperty);
                if (ret == 0)
                {
                    ret = direct_compare (m_Dst, inHash.m_Dst);
                    if (ret == 0)
                    {
                        ret = GLib.strcmp (m_DstProperty, inHash.m_DstProperty);
                    }
                }
                return ret;
            }
        }

        public unowned Object? m_Src;
        public Hash            m_Hash;
        public GLib.Value      m_Value;
        public bool            m_Locked = false;

        static construct
        {
            s_QuarkPluggedProperty = GLib.Quark.from_string ("MaiaCoreObjectPluggedProperty");
        }

        public PlugProperty (Object inSrc, string inSrcProperty, Object inDst, string inDstProperty)
        {
            m_Src = inSrc;
            m_Hash = Hash (inSrcProperty, inDst, inDstProperty);

            // connect onto dest object destroy
            m_Hash.m_Dst.weak_ref (on_dest_destroyed);

            var src_paramspec = m_Src.get_class ().find_property (m_Hash.m_SrcProperty);
            if (src_paramspec != null)
            {
                var dst_paramspec = m_Hash.m_Dst.get_class ().find_property (m_Hash.m_DstProperty);
                if (dst_paramspec != null)
                {
                    if (src_paramspec.value_type.is_a (dst_paramspec.value_type))
                    {
                        m_Value = GLib.Value (src_paramspec.value_type);

                        // Connect onto property change
                        m_Src.notify[m_Hash.m_SrcProperty].connect (on_src_property_changed);

                        // Set initial value
                        on_src_property_changed ();

                        // Update plugged property
                        unowned Set<string>? plugged_properties = m_Hash.m_Dst.get_qdata<unowned Set<string>> (s_QuarkPluggedProperty);
                        if (plugged_properties == null)
                        {
                            var new_plugged_properties = new Core.Set<string> ();
                            m_Hash.m_Dst.set_qdata<Set<string>> (s_QuarkPluggedProperty, new_plugged_properties);
                            plugged_properties = new_plugged_properties;
                        }

                        plugged_properties.insert (m_Hash.m_DstProperty);
                    }
                    else
                    {
                        Log.error (GLib.Log.METHOD, Log.Category.CORE_OBJECT, @"error on bind property: incompatible $(m_Hash.m_DstProperty) $(m_Hash.m_SrcProperty) properties");
                    }
                }
                else
                {
                    Log.error (GLib.Log.METHOD, Log.Category.CORE_OBJECT, @"error on bind property: invalid $(m_Hash.m_DstProperty)");
                }
            }
            else
            {
                Log.error (GLib.Log.METHOD, Log.Category.CORE_OBJECT, @"error on bind property: invalid $(m_Hash.m_SrcProperty)");
            }
        }

        ~PlugProperty ()
        {
            if (m_Hash.m_Dst != null)
            {
                unowned Set<string>? plugged_properties = m_Hash.m_Dst.get_qdata<unowned Set<string>> (s_QuarkPluggedProperty);
                if (plugged_properties != null)
                {
                    plugged_properties.remove (m_Hash.m_DstProperty);
                }
                m_Hash.m_Dst.weak_unref (on_dest_destroyed);
            }
            m_Src.notify[m_Hash.m_SrcProperty].disconnect (on_src_property_changed);
        }

        private void
        on_dest_destroyed ()
        {
            m_Hash.m_Dst = null;
            m_Src.m_Plugs.remove (this);
        }

        private void
        on_src_property_changed ()
        {
            m_Src.get_property (m_Hash.m_SrcProperty, ref m_Value);
            m_Hash.m_Dst.set_property (m_Hash.m_DstProperty, m_Value);
        }

        public void
        lock ()
        {
            if (!m_Locked)
            {
                m_Src.notify[m_Hash.m_SrcProperty].disconnect (on_src_property_changed);
                m_Locked = true;
            }
        }

        public void
        unlock ()
        {
            if (m_Locked)
            {
                m_Src.notify[m_Hash.m_SrcProperty].connect (on_src_property_changed);
                m_Locked = false;
            }
        }

        public int
        compare (PlugProperty inProperty)
        {
            return compare_with_hash (inProperty.m_Hash);
        }

        public int
        compare_with_hash (Hash? inHash)
        {
            return m_Hash.compare (inHash);
        }
    }

    public class Iterator
    {
        private unowned Object? m_Current;

        internal Iterator (Object inObject)
        {
            m_Current = inObject.m_Head;
        }

        internal Iterator.end (Object inObject)
        {
            m_Current = null;
        }

        public unowned Object?
        next_value ()
        {
            unowned Object? ret = m_Current;

            if (m_Current != null)
                m_Current = m_Current.m_Next;

            return ret;
        }

        public unowned Object?
        get ()
        {
            return m_Current;
        }

        public bool
        is_end ()
        {
            return m_Current == null;
        }
    }

    // static properties
    private static GLib.Quark s_QuarkPluggedProperty;

    // Properties
    private unowned Object?        m_Parent;
    private Object?                m_Head;
    private unowned Object?        m_Tail;
    private Object?                m_Next;
    private unowned Object?        m_Prev;
    private Core.Set<PlugProperty> m_Plugs;
    private Notifications m_Notifications = new Notifications ();
    
    // accessors
    /**
     * Object identifier
     */
    public uint32 id { get; construct set; default = 0; }

    /**
     * Object parent
     */
    [CCode (notify = false)]
    public virtual unowned Object? parent {
        get {
            return m_Parent;
        }
        construct set {
            if (m_Parent != value)
            {
                ref ();

                // object have already a parent
                if (m_Parent != null)
                    m_Parent.remove_child (this);

                m_Parent = null;

                if (value != null)
                    value.insert_child (this);

                unref ();
            }
        }
    }

    /**
     * Object notifications
     */
    public Notifications notifications {
        get {
            return m_Notifications;
        }
    }

    // Methods
    construct
    {
        m_Plugs = new Core.Set<PlugProperty> ();
        m_Plugs.compare_func = PlugProperty.compare;
    }

    ~Object ()
    {
        Log.audit ("Maia.~Object", Log.Category.CORE_OBJECT, "destroy %s", get_type ().name ());

        clear_childs ();
    }

    private inline void
    rotate ()
    {
        Object? next = m_Next;
        unowned Object? prev = m_Prev;

        m_Prev = prev.m_Prev;
        m_Next = prev;

        if (m_Parent.m_Tail == this)
            m_Parent.m_Tail = prev;
        else
            next.m_Prev = prev;

        if (m_Parent.m_Head == prev)
            m_Parent.m_Head = this;
        else
            m_Prev.m_Next = this;

        prev.m_Prev = this;
        prev.m_Next = next;
    }

    /**
     * Insert inObject in child list if can be append
     *
     * @param inObject object to add to childs object
     */
    protected virtual void
    insert_child (Object inObject)
    {
        if (can_append_child (inObject))
        {
            // set parent property
            inObject.m_Parent = this;

            // add object to childs of parent
            Log.audit (GLib.Log.METHOD, Log.Category.CORE_OBJECT, "Insert object %s to parent %s", inObject.get_type ().name (), get_type ().name ());

            // child list is empty insert object has first
            if (m_Head == null && m_Tail == null)
            {
                m_Head = inObject;
                m_Head.m_Prev = null;
                m_Head.m_Next = null;
                m_Tail = m_Head;
            }
            // check if child must be inserted has first
            else if (inObject.compare (m_Head) < 0)
            {
                inObject.m_Next = m_Head;
                m_Head.m_Prev = inObject;
                m_Head = inObject;
            }
            else
            {
                // search from tail to head the child position
                unowned Object? found = null;
                for (unowned Object item = m_Tail; item != null; item = item.m_Prev)
                {
                    if (inObject.compare (item) >= 0)
                    {
                        found = item;
                        break;
                    }
                }

                // we found the first sibling object insert after
                if (found != null)
                {
                    if (found == m_Tail) m_Tail = inObject;
                    inObject.m_Prev = found;
                    inObject.m_Next = found.m_Next;
                    if (inObject.m_Next != null) inObject.m_Next.m_Prev = inObject;
                    found.m_Next = inObject;
                }
                // does not found any sibling child add to first position (normally never reached)
                else
                {
                    inObject.m_Next = m_Head;
                    m_Head.m_Prev = inObject;
                    m_Head = inObject;
                }
            }
        }
        else
        {
            Log.error (GLib.Log.METHOD, Log.Category.CORE_OBJECT, "Cannot add %s object in %s object", inObject.get_type().name (), get_type().name ());
        }
    }

    /**
     * Remove inObject from child list
     *
     * @param inObject object to remove from childs object
     */
    protected virtual void
    remove_child (Object inObject)
    {
        if (inObject.parent == this)
        {
            Log.audit ("Maia.Object.parent.set", Log.Category.CORE_OBJECT, "Remove object %s from parent %s", inObject.get_type ().name (), get_type ().name ());

            unowned Object? next = inObject.m_Next;

            if (inObject == m_Head)
            {
                m_Head = inObject.m_Next;
            }
            else
            {
                inObject.m_Prev.m_Next = inObject.m_Next;
            }

            if (inObject == m_Tail)
            {
                m_Tail = inObject.m_Prev;
            }
            else
            {
                next.m_Prev = inObject.m_Prev;
            }

            inObject.m_Prev = null;
            inObject.m_Next = null;

            // unset parent object
            inObject.m_Parent = null;
        }
    }

    /**
     * Clear child object list
     */
    public virtual void
    clear_childs ()
    {
        while (m_Head != null)
        {
            Object? object = m_Head;

            m_Head = object.m_Next;

            object.m_Prev = null;
            object.m_Next = null;
            object.m_Parent = null;
        }
        m_Tail = null;
    }

    /**
     * Check object position in parent childs array
     */
    public void
    reorder ()
    {
        if (m_Parent != null)
        {
            // the child must be move before
            if (m_Prev != null && compare (m_Prev) < 0)
            {
                rotate ();
                reorder ();
            }
            // the child must be move after
            else if (m_Next != null && compare (m_Next) >= 0)
            {
                m_Next.rotate ();
                reorder ();
            }
        }
    }

    /**
     * Check if an object can be added to this object
     *
     * @param inChild object child to test
     *
     * @return `true` if the child object can be added to this node,
     *         `false` otherwise
     */
    public virtual bool
    can_append_child (Object inChild)
    {
        return true;
    }

    /**
     * Returns a Iterator that can be used for simple iteration over
     * childs object.
     *
     * @return a Iterator that can be used for simple iteration over childs
     *         object
     */
    public Iterator
    iterator ()
    {
        return new Iterator (this);
    }

    /**
     * Returns a Iterator that can be used for simple iteration over
     * childs object.
     *
     * @return a Iterator that can be used for simple iteration over childs
     *         object
     */
    public virtual Iterator
    iterator_begin ()
    {
        return iterator ();
    }

    /**
     * Returns the last Iterator of childs object.
     *
     * @return the last Iteratorof childs object
     */
    public virtual Iterator
    iterator_end ()
    {
        return new Iterator.end (this);
    }

    /**
     * Returns string representation of object
     *
     * @return string representation of object
     */
    public virtual string
    to_string ()
    {
        return id.to_string ();
    }

    /**
     * Add child to object
     *
     * @param inObject child to add
     */
    public void
    add (Object inObject)
    {
        inObject.parent = this;
    }

    /**
     * Determines whether this object contains the child object.
     *
     * @param inObject the child object to locate in the object
     *
     * @return true if child is found, false otherwise
     */
    public bool
    contains (Object inObject)
    {
        return inObject.m_Parent == this;
    }

    /**
     * Compare this object with another
     *
     * @param inOther the object to compare to.
     *
     * @return < 0 if this object is lesser then inOther, > 0 if this object is
     *             greater than inObject, 0 otherwise.
     */
    public virtual int
    compare (Object inOther)
    {
        int ret = (int)(id - inOther.id);
        if (ret == 0)
        {
            ret = direct_compare (this, inOther);
        }

        return ret;
    }

    /**
     * Get the next child object
     *
     * @return the next child object else null if object have no next child
     */
    public unowned Object?
    next ()
    {
        return m_Next;
    }

    /**
     * Get the previous child object
     *
     * @return the previous child object else null if object have no next child
     */
    public unowned Object?
    prev ()
    {
        return m_Prev;
    }

    /**
     * Get the first child object
     *
     * @return the first child object else null if object have no child
     */
    public unowned Object?
    first ()
    {
        return m_Head;
    }

    /**
     * Get the last child object
     *
     * @return the last child object else null if object have no child
     */
    public unowned Object?
    last ()
    {
        return m_Tail;
    }

    /**
     * Find object by id
     *
     * @param inId the id of the object to found in child
     * @param inRecursive search also in childs
     *
     * @return the corresponding object to inId else `null`
     */
    public virtual unowned Object?
    find (uint32 inId, bool inRecursive = true)
    {
        foreach (unowned Object? child in this)
        {
            if (child.id == inId)
            {
                return child;
            }
        }

        if (inRecursive)
        {
            foreach (unowned Object? child in this)
            {
                unowned Object? ret = child.find (inId, inRecursive);
                if (ret != null)
                    return ret;
            }
        }

        return null;
    }

    /**
     * Find object by type
     *
     * @param inRecursive search also in childs
     *
     * @return the corresponding object to inId else `null`
     */
    public virtual List<unowned T?>
    find_by_type<T> (bool inRecursive = true)
    {
        List<unowned T?> list = new List<unowned T?> ();

        foreach (unowned Object? child in this)
        {
            if (child.get_type ().is_a (typeof (T)))
            {
                list.insert (child);
            }
        }

        if (inRecursive)
        {
            foreach (unowned Object? child in this)
            {
                foreach (unowned T? c in child.find_by_type<T> (inRecursive))
                {
                    list.insert (c);
                }
            }
        }

        return list;
    }

    /**
     * Property is plugged on src object
     *
     * @param inProperty property name to check if is plugged
     *
     * @return ``true`` if property is updated from an another object
     */
    public bool
    is_plugged_property (string inProperty)
    {
        bool ret = false;

        unowned Set<string>? plugged_properties = get_qdata<unowned Set<string>> (s_QuarkPluggedProperty);
        if (plugged_properties != null)
        {
            return inProperty in plugged_properties;
        }

        return ret;
    }

    /**
     * Plug property to another object
     *
     * @param inProperty property to plug
     * @param inDest destination object
     * @param inDestProperty destination object property
     */
    public void
    plug_property (string inProperty, Object inDest, string inDestProperty)
    {
        PlugProperty.Hash hash = PlugProperty.Hash (inProperty, inDest, inDestProperty);
        unowned PlugProperty? prop = m_Plugs.search<PlugProperty.Hash?> (hash, PlugProperty.compare_with_hash);

        if (prop == null)
        {
            m_Plugs.insert (new PlugProperty (this, inProperty, inDest, inDestProperty));
        }
    }

    /**
     * Unplug property
     *
     * @param inProperty property to unplug
     * @param inDest destination object
     * @param inDestProperty destination object property
     */
    public void
    unplug_property (string inProperty, Object inDest, string inDestProperty)
    {
        PlugProperty.Hash hash = PlugProperty.Hash (inProperty, inDest, inDestProperty);
        unowned PlugProperty? prop = m_Plugs.search<PlugProperty.Hash?> (hash, PlugProperty.compare_with_hash);

        if (prop != null)
        {
            m_Plugs.remove (prop);
        }
    }

    /**
     * Lock plug property
     *
     * @param inProperty property to unplug
     * @param inDest destination object
     * @param inDestProperty destination object property
     */
    public void
    lock_property (string inProperty, Object inDest, string inDestProperty)
    {
        PlugProperty.Hash hash = PlugProperty.Hash (inProperty, inDest, inDestProperty);
        unowned PlugProperty? prop = m_Plugs.search<PlugProperty.Hash?> (hash, PlugProperty.compare_with_hash);

        if (prop != null)
        {
            prop.lock ();
        }
    }

    /**
     * Unlock plug property
     *
     * @param inProperty property to unplug
     * @param inDest destination object
     * @param inDestProperty destination object property
     */
    public void
    unlock_property (string inProperty, Object inDest, string inDestProperty)
    {
        PlugProperty.Hash hash = PlugProperty.Hash (inProperty, inDest, inDestProperty);
        unowned PlugProperty? prop = m_Plugs.search<PlugProperty.Hash?> (hash, PlugProperty.compare_with_hash);

        if (prop != null)
        {
            prop.unlock ();
        }
    }
}
