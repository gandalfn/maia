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
    static Map<Type, Set<Type>>         s_Delegations = null;

    // Class properties
    internal class bool                 c_Initialized = false;
    internal class Set<Type>            c_Delegations = null;

    // Properties
    private uint32                      m_Id = 0;
    private unowned Object              m_Parent = null;
    private unowned Object              m_Delegator = null;
    private Array<Object>               m_Childs = null; 
    private Set<unowned Object>         m_IdentifiedChilds = null;
    private Set<Object>                 m_Delegates = null;
    private GLib.Mutex                  m_Mutex;
    private GLib.Cond                   m_Cond;

    // Accessors

    /**
     * Object identifier
     */
    [CCode (notify = false)]
    public uint32 id {
        get {
            return m_Delegator == null ? m_Id : m_Delegator.m_Id;
        }
        set {
            if (m_Delegator == null)
            {
                // object have a old id
                if (m_Parent != null && m_Id != 0 && m_Parent.m_IdentifiedChilds != null)
                    // remove object from identified object
                    m_Parent.identified_childs.remove (this);

                // set identifier
                m_Id = value;

                // object have a parent
                if (m_Id != 0 && m_Parent != null)
                {
                    // add object in identified childs
                    m_Parent.identified_childs.insert (this);
                }
            }
            else
            {
                m_Delegator.id = value;
            }
        }
    }

    [CCode (notify = false)]
    public virtual string name {
        get {
            return m_Delegator == null ? Atom.to_string (m_Id) : m_Delegator.name;
        }
        set {
            id = Atom.from_string (value);
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
        set {
            if (m_Delegator == null)
            {
                // object have already a parent
                if (m_Parent != null)
                {
                    debug ("Maia.Object.parent.set", "Remove object %s from parent %s", get_type ().name (), m_Parent.get_type ().name ());
                    // remove object from childs of old parent
                    m_Parent.childs.remove (this);
                    // remove object from identified childs of old parent
                    if (m_Id != 0)
                        m_Parent.identified_childs.remove (this);
                }

                if (value != null)
                {
                    if (value.can_append_child (this))
                    {
                        // set parent property
                        m_Parent = value;

                        // add object to childs of parent
                        if (m_Parent != null)
                        {
                            debug ("Maia.Object.parent.set", "Add object %s from parent %s", get_type ().name (), m_Parent.get_type ().name ());
                            m_Parent.childs.insert (this);
                            if (m_Id != 0)
                                m_Parent.identified_childs.insert (this);
                        }
                    }
                    else
                    {
                        m_Parent = null;
                    }
                }
                else
                {
                    // set parent property
                    m_Parent = value;
                }
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
     * Object childs
     */
    public Array<Object> childs {
        get {
            if (m_Delegator == null)
            {
                if (m_Childs == null)
                    m_Childs = new Array<Object> ();
                return m_Childs;
            }
            else
            {
                return m_Delegator.childs;
            }
        }
    }

    private Set<unowned Object> identified_childs {
        get {
            if (m_Delegator == null)
            {
                if (m_IdentifiedChilds == null)
                {
                    m_IdentifiedChilds = new Set<unowned Object> ();
                    m_IdentifiedChilds.compare_func = (a, b) => {
                        return atom_compare (a.id, b.id);
                    };
                }
                return m_IdentifiedChilds;
            }
            else
            {
                return m_Delegator.identified_childs;
            }
        }
    }

    // Methods
    static inline int
    compare_type (Type inA, Type inB)
    {
        Type aParentType = inA.parent ();
        Type bParentType = inB.parent ();

        return inA == inB         ||
               aParentType == inB ||
               inA == bParentType ||
               aParentType == bParentType ? 0 : inA - inB;
    }

    static inline int
    compare_object_with_type (Object? inA, Type inB)
    {
        return compare_type (inA.get_type (), inB);
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

    construct
    {
        audit ("Maia.Object.construct", "construct %s", get_type ().name ());

        // Create delegate objects
        if (!c_Initialized)
        {
            if (s_Delegations != null)
            {
                for (Type type = get_type (); type != typeof (Object); type = type.parent ())
                {
                    if (type in s_Delegations)
                    {
                        foreach (Type delegate_type in s_Delegations[type])
                        {
                            audit ("Maia.Object.construct", "add delegate %s for %s", delegate_type.name (), get_type ().name ());
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
                return compare_type (a.get_type (), b.get_type ());
            };
            foreach (Type type in c_Delegations)
            {
                m_Delegates.insert (create_delegate (type));
            }
        }

        m_Mutex = new GLib.Mutex ();
        m_Cond = new GLib.Cond ();
    }

    ~Object ()
    {
        audit ("Maia.~Object", "destroy %s", get_type ().name ());
    }

    protected Object
    create_delegate (Type inType)
    {
        audit (GLib.Log.METHOD, "delegate type = %s", inType.name ());

        return GLib.Object.new (inType, name: name, parent: m_Parent, delegator: this) as Object;
    }

    protected void
    lock_broadcast ()
    {
        audit (GLib.Log.METHOD, "%lx", (ulong)GLib.Thread.self<void*> ());
        m_Mutex.lock ();
        m_Cond.broadcast ();
        m_Mutex.unlock ();
    }

    public void
    @lock ()
    {
        audit (GLib.Log.METHOD, "%lx", (ulong)GLib.Thread.self<void*> ());
        m_Mutex.lock ();
    }

    public void
    lock_wait ()
    {
        audit (GLib.Log.METHOD, "%lx", (ulong)GLib.Thread.self<void*> ());
        m_Mutex.lock ();
        m_Cond.wait (m_Mutex);
    }

    public void
    unlock ()
    {
        audit (GLib.Log.METHOD, "%lx", (ulong)GLib.Thread.self<void*> ());
        m_Mutex.unlock ();
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
     * Determines whether this object contains the object identified by inId.
     *
     * @param inId the object id to locate in this object
     *
     * @return true if object is found, false otherwise
     */
    public bool
    contains (string inId)
    {
        return get_child (inId) != null;
    }

    /**
     * Returns the object of the specified id in this object.
     *
     * @param inName the name whose object is to be retrieved
     *
     * @return the object associated with the id, or null if the id
     *         couldn't be found
     */
    public Object
    get_child (string inName)
    {
        uint32 id = Atom.from_string (inName);
        return m_IdentifiedChilds.search<uint32> (id, (o, i) => {
                    return atom_compare (o.m_Id, i);
                });
    }

    /**
     * Returns string representation of object
     *
     * @return string representation of object
     */
    public virtual string
    to_string ()
    {
        return m_Id.to_string ();
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