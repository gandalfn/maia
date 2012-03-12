/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * object.vala
 * Copyright (C) Nicolas Bruguier 2010-2011 <gandalfn@club-internet.fr>
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

public abstract class Maia.Object : GLib.Object
{
    // Static properties
    static Map<Type, Set<Type>> s_Delegations = null;

    // Class properties
    private class bool         c_Initialized = false;
    private class Set<Type>    c_Delegations = null;

    // Properties
    private GLib.Type           m_Type;
    private uint32              m_Id = 0;
    private unowned Object      m_Parent = null;
    private unowned Object      m_Delegator = null;
    private Array<Object>       m_Childs = null;
    private Set<unowned Object> m_IdentifiedChilds = null;
    private Set<Object>         m_Delegates = null;

    protected ReadWriteSpinLock rw_lock;

    // accessors
    [CCode (notify = false)]
    internal bool sorted_childs {
        set {
            if (delegator == null)
            {
                // check array
                check_childs_array ();
                // TODO resort if array contains any items
                rw_lock.write_lock ();
                m_Childs.is_sorted = value;
                rw_lock.write_unlock ();
            }
            else
                delegator.sorted_childs = value;
        }
    }

    /**
     * Object identifier
     */
    public uint32 id {
        get {
            rw_lock.read_lock ();
            uint32 ret = delegator == null ? m_Id : delegator.id;
            rw_lock.read_unlock ();
            return ret;
        }
        construct set {
            if (delegator == null)
            {
                if (parent != null)
                {
                    // object have a old id
                    if (id != 0)
                        // remove object from identified object
                        parent.remove_identified_child (this);

                    // set identifier
                    rw_lock.write_lock ();
                    m_Id = value;
                    rw_lock.write_unlock ();

                    // object have a parent
                    if (id != 0)
                        // add object in identified childs
                        parent.insert_identified_child (this);
                }
                else
                {
                    // set identifier
                    rw_lock.write_lock ();
                    m_Id = value;
                    rw_lock.write_unlock ();
                }
            }
            else
            {
                delegator.id = value;
            }
        }
    }

    /**
     * Object parent
     */
    [CCode (notify = false)]
    public virtual Object parent {
        get {
            rw_lock.read_lock ();
            unowned Object? ret = delegator == null ? m_Parent : delegator.m_Parent;
            rw_lock.read_unlock ();

            return ret;
        }
        construct set {
            if (delegator == null)
            {
                if (parent != value)
                {
                    ref ();

                    // object have already a parent
                    if (parent != null)
                        parent.remove_child (this);

                    if (value != null)
                        value.insert_child (this);

                    unref ();
                }
            }
            else
            {
                delegator.parent = value;
            }
        }
    }

    /**
     * Object delegator
     */
    [CCode (notify = false)]
    public unowned Object? delegator {
        get {
            return m_Delegator;
        }
        construct {
            m_Delegator = value;
        }
    }

    /**
     * Number of child objects
     */
    public int nb_childs {
        get {
            int ret = 0;
            rw_lock.read_lock ();
            if (m_Delegator == null)
            {
                ret = m_Childs.length;
            }
            else
            {
                ret = m_Delegator.nb_childs;
            }
            rw_lock.read_unlock ();
            return ret;
        }
    }

    // Methods
    static inline int
    compare_type (Type inA, Type inB)
    {
        int ret = (int)((uint32)inA - (uint32)inB);
        if (ret != 0)
        {
            Type bParentType = inB.parent ();

            if ((inA - bParentType) == 0)
            {
                return 0;
            }
            else
            {
                Type aParentType = inA.parent ();
                if ((aParentType - inB) == 0 || (aParentType - bParentType) == 0)
                {
                    return 0;
                }
            }
        }

        return ret;
    }

    static inline int
    compare_object_with_type (Object? inA, Type inB)
    {
        return compare_type (inA.m_Type, inB);
    }

    /**
     * Register a Object delegation
     *
     * @param inType delegate object type
     */
    protected static void
    @delegate<T> (Type inType)
        requires (inType.is_a (typeof (Object)))
        requires (inType != typeof (T))
    {
        Log.audit (GLib.Log.METHOD, "type = %s, delegate type = %s",
                   typeof (T).name (), inType.name ());

        if (s_Delegations == null)
            s_Delegations = new Map<Type, Set<Type>> ();

        if (s_Delegations[typeof (T)] == null)
            s_Delegations[typeof (T)] = new Set<Type> ();

        s_Delegations[typeof (T)].insert (inType);
    }

    public static bool
    atomic_compare_and_exchange (void** inObject, GLib.Object? inOldObject,
                                 owned GLib.Object? inNewObject)
    {
        bool ret = Machine.Memory.Atomic.Pointer.cast (&inObject).compare_and_swap (inOldObject, inNewObject);

        if (ret)
        {
            if (inNewObject != null)
                inNewObject.ref ();
            if (inOldObject != null)
                inOldObject.unref ();
        }

        return ret;
    }

    construct
    {
        // Get object type
        m_Type = get_type ();

        Log.audit ("Maia.Object.construct", "construct %s", m_Type.name ());

        // Create delegate objects
        if (!c_Initialized)
        {
            if (s_Delegations != null)
            {
                for (Type type = m_Type; type != typeof (Object); type = type.parent ())
                {
                    if (type in s_Delegations)
                    {
                        s_Delegations[type].iterator ().foreach ((delegate_type) => {
                            Log.audit ("Maia.Object.construct", "add delegate %s for %s", delegate_type.name (), m_Type.name ());
                            if (c_Delegations == null)
                            {
                                c_Delegations = new Set<Type> ();
                            }
                            c_Delegations.insert (delegate_type);
                            return true;
                        });
                    }
                }
            }
            c_Initialized = true;
        }

        if (c_Delegations != null)
        {
            m_Delegates = new Set<Object> ();
            m_Delegates.compare_func = (a, b) => {
                return compare_type (a.m_Type, b.m_Type);
            };
            c_Delegations.iterator ().foreach ((type) => {
                m_Delegates.insert (create_delegate (type));
                return true;
            });
        }
    }

    ~Object ()
    {
        Log.audit ("Maia.~Object", "destroy %s", m_Type.name ());

        if (m_Childs != null)
        {
            int nb = m_Childs.length;
            for (int cpt = 0; cpt < nb; ++cpt)
            {
                m_Childs.at(0).parent = null;
            }
        }
    }

    private inline void
    check_childs_array ()
    {
        if (m_Childs == null)
        {
            m_Childs = new Array<Object> ();
        }
    }

    private inline void
    check_identified_childs_array ()
    {
        if (m_IdentifiedChilds == null)
        {
            m_IdentifiedChilds = new Set<unowned Object> ();
            m_IdentifiedChilds.compare_func = (a, b) => {
                return atom_compare (a.m_Id, b.m_Id);
            };
        }
    }

    private void
    insert_child (Object inObject)
    {
        if (delegator == null)
        {
            if (inObject is Object && can_append_child (inObject))
            {
                // check array
                check_childs_array ();

                // set parent property
                inObject.rw_lock.write_lock ();
                inObject.m_Parent = this;
                inObject.rw_lock.write_unlock ();

                // add object to childs of parent
                Log.debug (GLib.Log.METHOD, "Insert object %s to parent %s",
                           inObject.m_Type.name (), m_Type.name ());

                rw_lock.write_lock ();
                m_Childs.insert (inObject);
                rw_lock.write_unlock ();

                // insert object in identified if needed
                insert_identified_child (inObject);
            }
        }
        else
            delegator.insert_child (inObject);
    }

    private void
    insert_identified_child (Object inObject)
    {
        if (delegator == null)
        {
            if (this is Object && inObject.id != 0)
            {
                // check array
                check_identified_childs_array ();

                rw_lock.write_lock ();
                m_IdentifiedChilds.insert (inObject);
                rw_lock.write_unlock ();
            }
        }
        else
            delegator.insert_identified_child (inObject);
    }

    private void
    remove_child (Object inObject)
    {
        if (delegator == null)
        {
            if (inObject.parent == this)
            {
                Log.debug ("Maia.Object.parent.set", "Remove object %s from parent %s",
                           inObject.m_Type.name (), m_Type.name ());

                // remove object from childs of old parent
                rw_lock.write_lock ();
                m_Childs.remove (inObject);
                rw_lock.write_unlock ();

                // remove object from identified childs of old parent
                remove_identified_child (inObject);

                // unset parent object
                inObject.rw_lock.write_lock ();
                inObject.m_Parent = null;
                inObject.rw_lock.write_unlock ();
            }
        }
        else
            delegator.remove_child (inObject);
    }

    private void
    remove_identified_child (Object inObject)
    {
        if (delegator == null)
        {
            // remove object from identified childs of old parent
            if (m_IdentifiedChilds != null && inObject.id != 0)
            {
                rw_lock.write_lock ();
                m_IdentifiedChilds.remove (inObject);
                rw_lock.write_unlock ();
            }
        }
        else
            delegator.remove_child (inObject);
    }

    private Object
    create_delegate (Type inType)
    {
        Log.audit (GLib.Log.METHOD, "delegate type = %s", inType.name ());

        return GLib.Object.new (inType, delegator: this, id: id, parent: m_Parent) as Object;
    }

    internal void
    check_child_pos (int inIndex)
    {
        if (delegator == null)
        {
            rw_lock.read_lock ();
            m_Childs.sort (inIndex);
            rw_lock.read_unlock ();
        }
        else
            delegator.check_child_pos (inIndex);
    }

    /**
     * Cast object to implemented delegate object
     *
     * @return Delegate object
     */
    public unowned T?
    delegate_cast<T> ()
        requires (m_Delegates != null)
    {
        return m_Delegates.search<Type> (typeof (T), (ValueCompareFunc<Type>)compare_object_with_type);
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
     * Returns the first child of Object.
     *
     * @return the first child of Object
     */
    public unowned Object?
    first ()
    {
        unowned Object? ret = null;

        if (delegator == null)
        {
            check_childs_array ();
            rw_lock.read_lock ();
            ret = m_Childs.length > 0 ? m_Childs.at (0) : null;
            rw_lock.read_unlock ();
        }
        else
            ret = delegator.first ();

        return ret;
    }

    /**
     * Returns a Iterator that can be used for simple iteration over
     * childs object.
     *
     * @return a Iterator that can be used for simple iteration over childs
     *         object
     */
    public Iterator<Object>
    iterator ()
    {
        if (delegator != null)
        {
            return delegator.iterator ();
        }

        check_childs_array ();
        rw_lock.read_lock ();
        Iterator<Object> iter = m_Childs.iterator ();
        iter.end_iterate_func = () => {
            rw_lock.read_unlock ();
        };

        return iter;
    }

    /**
     * Determines whether this object contains the object identified by inId.
     *
     * @param inId the object id to locate in this object
     *
     * @return true if object is found, false otherwise
     */
    public bool
    contains (uint32 inId)
    {
        check_childs_array ();
        rw_lock.read_lock ();
        bool ret = delegator == null ? get (inId) != null : delegator.contains (inId);
        rw_lock.read_unlock ();

        return ret;
    }

    /**
     * Returns the object of the specified id in this object.
     *
     * @param inId the id whose object is to be retrieved
     *
     * @return the object associated with the id, or null if the id
     *         couldn't be found
     */
    public new unowned Object?
    @get (uint32 inId)
    {
        unowned Object? ret = null;

        if (delegator == null)
        {
            check_identified_childs_array ();
            rw_lock.read_lock ();
            ret = m_IdentifiedChilds.search<uint32> (inId, (o, i) => {
                return atom_compare (o.m_Id, i);
            });
            rw_lock.read_unlock ();
        }
        else
            ret = delegator.get (inId);

        return ret;
    }

    /**
     * Returns the index of the specified object in childs of this object.
     *
     * @param inObject object child whose index is to be retrieved
     *
     * @return the index associated with the object child, or -1 if the value
     *         couldn't be found
     */
    public int
    index_of_child (Object inObject)
    {
        check_childs_array ();
        rw_lock.read_lock ();
        int ret = delegator == null ? m_Childs.index_of (inObject) : delegator.index_of_child (inObject);
        rw_lock.read_unlock ();

        return ret;
    }

    /**
     * Returns the child object at the specified index in object childs.
     *
     * @param inIndex zero-based index of the child object to be returned
     *
     * @return the child objet at the specified index in object childs
     */
    public unowned Object?
    get_child_at (int inIndex)
    {
        check_childs_array ();
        rw_lock.read_lock ();
        unowned Object? ret = delegator == null ? m_Childs.at (inIndex) : delegator.get_child_at (inIndex);
        rw_lock.read_unlock ();

        return ret;
    }

    /**
     * Returns string representation of object
     *
     * @return string representation of object
     */
    public virtual string
    to_string ()
    {
        rw_lock.read_lock ();
        string ret = Atom.to_string (m_Id);
        rw_lock.read_unlock ();

        return ret;
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
        return direct_compare (this, inOther);
    }
}
