/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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
    internal class bool         c_Initialized = false;
    internal class Set<Type>    c_Delegations = null;

    // Properties
    private GLib.Type           m_Type;
    private uint32              m_Id = 0;
    private unowned Object      m_Parent = null;
    private unowned Object      m_Delegator = null;
    private Array<Object>       m_Childs = null; 
    private Set<unowned Object> m_IdentifiedChilds = null;
    private Set<Object>         m_Delegates = null;

    // Accessors

    [CCode (notify = false)]
    internal bool sorted_childs {
        set {
            if (m_Delegator == null)
            {
                // check array
                check_childs_array ();
                // TODO resort if array contains any items
                m_Childs.is_sorted = value;
            }
            else
                m_Delegator.sorted_childs = value;
        }
    }

    /**
     * Object identifier
     */
    [CCode (notify = false)]
    public uint32 id {
        get {
            return m_Delegator == null ? m_Id : m_Delegator.m_Id;
        }
        construct set {
            if (m_Delegator == null)
            {
                Token token = Token.get_for_object (this);
                if (m_Parent != null)
                {
                    // object have a old id
                    if (m_Id != 0)
                        // remove object from identified object
                        m_Parent.remove_identified_child (this);

                    // set identifier
                    m_Id = value;

                    // object have a parent
                    if (m_Id != 0)
                        // add object in identified childs
                        m_Parent.insert_identified_child (this);
                }
                else
                {
                    // set identifier
                    m_Id = value;
                }
                token.release ();
            }
            else
            {
                m_Delegator.id = value;
            }
        }
    }

    /**
     * Object parent
     */
    [CCode (notify = false)]
    public virtual Object parent {
        get {
            return m_Delegator == null ? m_Parent : m_Delegator.m_Parent;
        }
        construct set {
            if (m_Delegator == null)
            {
                Token token = Token.get_for_object (this);
                {
                    if (m_Parent != value)
                    {
                        ref ();

                        // object have already a parent
                        if (m_Parent != null)
                        {
                            m_Parent.remove_child (this);
                        }

                        if (value != null)
                        {
                            value.insert_child (this);
                        }

                        unref ();
                    }
                }
                token.release ();
            }
            else
            {
                m_Delegator.parent = value;
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
            if (m_Delegator == null)
            {
                return m_Childs.nb_items;
            }
            else
            {
                return m_Delegator.nb_childs;
            }
        }
    }

    // Methods
    static inline int
    compare_type (Type inA, Type inB)
    {
        int ret = inA - inB;
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
        audit (GLib.Log.METHOD, "type = %s, delegate type = %s",
               typeof (T).name (), inType.name ());

        if (s_Delegations == null)
            s_Delegations = new Map<Type, Set<Type>> ();

        if (s_Delegations[typeof (T)] == null)
            s_Delegations[typeof (T)] = new Set<Type> ();

        s_Delegations[typeof (T)].insert (inType);
    }

    public static bool
    atomic_compare_and_exchange (void* inObject, GLib.Object? inOldObject,
                                 owned GLib.Object? inNewObject)
    {
        bool ret = GLib.AtomicPointer.compare_and_exchange (inObject, inOldObject, inNewObject);

        if (ret)
        {
            if (inNewObject != null)
                inNewObject.ref ();
            else if (inOldObject != null)
                inOldObject.unref ();
        }

        return ret;
    }

    construct
    {
        // Get object type 
        m_Type = get_type ();

        audit ("Maia.Object.construct", "construct %s", m_Type.name ());

        // Create delegate objects
        if (!c_Initialized)
        {
            if (s_Delegations != null)
            {
                for (Type type = m_Type; type != typeof (Object); type = type.parent ())
                {
                    if (type in s_Delegations)
                    {
                        foreach (Type delegate_type in s_Delegations[type])
                        {
                            audit ("Maia.Object.construct", "add delegate %s for %s", delegate_type.name (), m_Type.name ());
                            if (c_Delegations == null)
                            {
                                c_Delegations = new Set<Type> ();
                            }
                            c_Delegations.insert (delegate_type);
                        }
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
            foreach (Type type in c_Delegations)
            {
                m_Delegates.insert (create_delegate (type));
            }
        }
    }

    ~Object ()
    {
        audit ("Maia.~Object", "destroy %s", m_Type.name ());

        if (m_Childs != null)
        {
            int nb = m_Childs.nb_items;
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
            Token token = Token.get_for_object (this);
            if (m_Childs == null)
            {
                m_Childs = new Array<Object> ();
            }
            token.release ();
        }
    }

    private inline void
    check_identified_childs_array ()
    {
        if (m_IdentifiedChilds == null)
        {
            Token token = Token.get_for_object (this);
            if (m_IdentifiedChilds == null)
            {
                m_IdentifiedChilds = new Set<unowned Object> ();
                m_IdentifiedChilds.compare_func = (a, b) => {
                    return atom_compare (a.id, b.id);
                };
            }
            token.release ();
        }
    }

    private void
    insert_child (Object inObject)
    {
        if (m_Delegator == null)
        {
            Token token = Token.get_for_object (this);
            if (inObject is Object && can_append_child (inObject))
            {
                // check array
                check_childs_array ();

                // set parent property
                inObject.m_Parent = this;

                // add object to childs of parent
                debug (GLib.Log.METHOD, "Insert object %s to parent %s",
                       inObject.m_Type.name (), m_Type.name ());

                m_Childs.insert (inObject);

                // insert object in identified if needed
                insert_identified_child (inObject);
            }
            token.release ();
        }
        else
            m_Delegator.insert_child (inObject);
    }

    private void
    insert_identified_child (Object inObject)
    {
        if (m_Delegator == null)
        {
            Token token = Token.get_for_object (this);
            if (this is Object && inObject.m_Id != 0)
            {
                // check array
                check_identified_childs_array ();

                m_IdentifiedChilds.insert (inObject);
            }
            token.release ();
        }
        else
            m_Delegator.insert_identified_child (inObject);
    }

    private void
    remove_child (Object inObject)
    {
        if (m_Delegator == null)
        {
            Token token = Token.get_for_object (this);
            if (inObject.m_Parent == this)
            {
                debug ("Maia.Object.parent.set", "Remove object %s from parent %s",
                       inObject.m_Type.name (), m_Type.name ());

                // remove object from childs of old parent
                m_Childs.remove (inObject);
                // remove object from identified childs of old parent
                remove_identified_child (inObject);
                // unset parent object
                inObject.m_Parent = null;
            }
            token.release ();
        }
        else
            m_Delegator.remove_child (inObject);
    }

    private void
    remove_identified_child (Object inObject)
    {
        if (m_Delegator == null)
        {
            // remove object from identified childs of old parent
            Token token = Token.get_for_object (this);
            if (m_IdentifiedChilds != null && inObject.m_Id != 0)
                m_IdentifiedChilds.remove (inObject);
            token.release ();
        }
        else
            m_Delegator.remove_child (inObject);
    }

    private Object
    create_delegate (Type inType)
    {
        audit (GLib.Log.METHOD, "delegate type = %s", inType.name ());

        return GLib.Object.new (inType, delegator: this, id: id, parent: m_Parent) as Object;
    }

    internal void
    check_child_pos (int inIndex)
    {
        if (m_Delegator == null)
            m_Childs.sort (inIndex);
        else
            m_Delegator.check_child_pos (inIndex);
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

        if (m_Delegator == null)
        {
            check_childs_array ();
            ret = m_Childs.nb_items > 0 ? m_Childs.at (0) : null;
        }
        else
            ret = m_Delegator.first ();

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
        check_childs_array ();
        return m_Delegator == null ? m_Childs.iterator () : m_Delegator.iterator ();
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
        return m_Delegator == null ? get (inId) != null : m_Delegator.contains (inId);
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

        if (m_Delegator == null)
        {
            Token token = Token.get_for_object (this);
            check_identified_childs_array ();
            ret = m_IdentifiedChilds.search<uint32> (inId, (o, i) => {
                return atom_compare (o.m_Id, i);
            });
            token.release ();
        }
        else
            ret = m_Delegator.get (inId);

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
        return m_Delegator == null ? m_Childs.index_of (inObject) : m_Delegator.index_of_child (inObject);
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
        return m_Delegator == null ? m_Childs.at (inIndex) : m_Delegator.get_child_at (inIndex);
    }

    /**
     * Returns string representation of object
     *
     * @return string representation of object
     */
    public virtual string
    to_string ()
    {
        return Atom.to_string (m_Id);
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