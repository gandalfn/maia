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

public abstract class Maia.Object
{
    // Types
    [CCode (has_target = false)]
    public delegate Object CreateFunc (GLib.Type inType, va_list inArgs);

    // Static properties
    static Map<Type, CreateFunc?>       s_Factory = null;
    static Map<Type, Set<Type>>         s_Delegations = null;

    // Class properties
    internal class bool                 c_Initialized = false;
    internal class unowned Set<Type>    c_Delegations = null;

    // Properties
    private GLib.Type                   m_Type;
    private string                      m_Id = null;
    private unowned Object              m_Parent = null;
    private unowned Object              m_Delegator = null;
    private Array<Object>               m_Childs = null; 
    private Set<unowned Object>         m_IdentifiedChilds = null;
    private Set<Object>                 m_Delegates = null;
    private GLib.Mutex                  m_Mutex;
    private GLib.Cond                   m_Cond;

    // Accessors
    /**
     * Object type
     */
    public virtual GLib.Type object_type {
        get {
            return typeof (Object);
        }
    }

    /**
     * Object identifier
     */
    public virtual string id {
        get {
            return m_Delegator == null ? m_Id : m_Delegator.m_Id;
        }
        set {
            if (m_Delegator == null)
            {
                // object have a old id
                if (m_Parent != null && m_Id != null && m_Parent.m_IdentifiedChilds != null)
                    // remove object from identified object
                    m_Parent.identified_childs.remove (this);

                // set identifier
                m_Id = value;

                // object have a parent
                if (m_Id != null && m_Parent != null)
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

    /**
     * Object parent
     */
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
                    // remove object from childs of old parent
                    if (m_Parent.m_Childs != null)
                        m_Parent.m_Childs.remove (this);
                    // remove object from identified childs of old parent
                    if (m_Id != null && m_Parent.m_IdentifiedChilds != null)
                        m_Parent.m_IdentifiedChilds.remove (this);
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
                            m_Parent.childs.insert (this);
                            if (m_Id != null)
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
    public unowned Object? delegator {
        get {
            return m_Delegator;
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
                        return GLib.strcmp (a.m_Id, b.m_Id);
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
        return inA < inB ? -1 : (inA > inB ? 1 : 0);
    }

    static int
    compare_object_with_type (Object inA, Type inB)
    {
        return inA.m_Type < inB ? -1 : (inA.m_Type > inB ? 1 : 0);
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
        debug ("%s: type = %s, delegate type = %s", GLib.Log.METHOD,
               typeof (T).name (), inType.name ());

        if (s_Delegations == null)
            s_Delegations = new Map<Type, Set<Type>> ();

        if (s_Delegations[typeof (T)] == null)
            s_Delegations[typeof (T)] = new Set<Type> ();

        s_Delegations[typeof (T)].insert (inType);
    }

    /**
     * Register a create function for a specified type. The function can be
     * called multiple time but only first call is really effective
     *
     * @param inType type to register
     * @param inFromString create function
     */
    public static void
    register_object (Type inType, CreateFunc inCreateFunc)
    {
        if (s_Factory == null)
            s_Factory = new Map<Type, CreateFunc?> ();

        CreateFunc? func = s_Factory[inType];

        if (func == null)
        {
            s_Factory[inType] = inCreateFunc;
        }
    }

    public static Object?
    create (Type inType, ...)
    {
        Object? object = null;
        CreateFunc? func = s_Factory[inType];

        if (func != null)
        {
            va_list args = va_list();
            object = func (inType, args);
        }

        return object;
    }

    public Object ()
    {
        GLib.debug ("%s: create", GLib.Log.METHOD);

        m_Type = object_type;

        // Create delegate objects
        if (!c_Initialized)
        {
            if (s_Delegations != null)
                c_Delegations = s_Delegations[m_Type];
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

        m_Mutex = new GLib.Mutex ();
        m_Cond = new GLib.Cond ();
    }

    public Object.new (GLib.Type inType, ...)
    {
        va_list args = va_list ();

        this.newv (args);
    }

    public Object.newv (va_list inArgs)
    {
        this ();

        constructor (inArgs);
    }

    protected virtual void
    constructor (va_list inArgs)
    {
        va_list args = va_list.copy (inArgs);

        bool end = false;

        while (!end) 
        {
            string? property = args.arg();
            switch (property)
            {
                case null:
                    end = true;
                    break;
                case "id":
                    id = args.arg ();
                    break;
                case "parent":
                    GLib.debug ("%s: set parent", GLib.Log.METHOD);
                    parent = args.arg ();
                    break;
                case "delegator":
                    m_Delegator = args.arg ();
                    break;
            }
        }
    }

    protected virtual Object
    create_delegate (Type inType)
    {
        GLib.debug ("%s: delegate type = %s", GLib.Log.METHOD, inType.name ());

        return Object.create (inType, id: m_Id, parent: m_Parent, delegator: this);
    }

    protected void
    lock_signal ()
    {
        m_Cond.broadcast ();
    }

    public void
    @lock ()
    {
        m_Mutex.lock ();
    }

    public void
    lock_wait ()
    {
        m_Mutex.lock ();
        m_Cond.wait (m_Mutex);
    }

    public void
    unlock ()
    {
        m_Mutex.unlock ();
    }

    /**
     * Cast object to implemented delegate object
     * 
     * @return Delegate object
     */
    public unowned T?
    delegate_cast<T> ()
    {
        if (m_Delegates == null) return null;

        return m_Delegates.search<Type> (typeof (T), compare_object_with_type);
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
     * @param inId the id whose object is to be retrieved
     *
     * @return the object associated with the id, or null if the id
     *         couldn't be found
     */
    public Object
    get_child (string inId)
    {
        return m_IdentifiedChilds.search<string> (inId, (o, i) => {
                   return GLib.strcmp (o.m_Id, i);
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
        return m_Id;
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
        return (void*)this > (void*)inOther ? 1 : ((void*)this < (void*)inOther ? -1 : 0);
    }
}