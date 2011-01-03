/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-object.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
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
    // Types
    [CCode (has_target = false)]
    public delegate Object CreateFromString (string inValue);

    // Static properties
    static Map<Type, CreateFromString?> s_Factory = null;
    static Map<Type, Set<Type>>         s_Delegations = null;

    // Class properties
    internal class bool                 c_Initialized = false;
    internal class unowned Set<Type>    c_Delegations = null;

    // Properties
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
    static void
    object_to_string (GLib.Value inSrc, out GLib.Value outDest)
    {
        outDest = ((Object)inSrc).to_string ();
    }

    static void
    string_to_object (GLib.Value inSrc, out GLib.Value outDest)
    {
        outDest = create_from_string (outDest.get_gtype(), (string)inSrc);
    }

    static int
    compare_type (Type inA, Type inB)
    {
        return inA < inB ? -1 : (inA > inB ? 1 : 0);
    }

    static int
    compare_object_with_type (Object inA, Type inB)
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
        debug ("%s: type = %s, delegate type = %s", GLib.Log.METHOD,
               typeof (T).name (), inType.name ());

        if (s_Delegations == null)
            s_Delegations = new Map<Type, Set<Type>> ();

        if (s_Delegations[typeof (T)] == null)
            s_Delegations[typeof (T)] = new Set<Type> ();

        s_Delegations[typeof (T)].insert (inType);
    }

    construct
    {
        // Create delegate objects
        if (!c_Initialized)
        {
            if (s_Delegations != null)
                c_Delegations = s_Delegations[get_type ()];
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

    protected virtual Object
    create_delegate (Type inType)
    {
        return GLib.Object.new (inType, delegator: this, id: m_Id, parent: m_Parent) as Object;
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

    protected void
    lock_signal ()
    {
        m_Cond.signal ();
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
     * Check if an object equals this object 
     *
     * @param inOther the object to compare to
     *
     * @return true if object are same
     */
    public virtual bool
    equals (Object inOther)
    {
        return inOther == this;
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

    /**
     * Register a create function for a specified type. The function can be
     * called multiple time but only first call is really effective
     *
     * @param inType type to register
     * @param inFromString create function with string
     */
    public static void
    register_create_from_string (Type inType, CreateFromString inFromString)
    {
        if (s_Factory == null)
            s_Factory = new Map<Type, CreateFromString?> ();

        CreateFromString? func = s_Factory[inType];

        if (func == null)
        {
            s_Factory[inType] = inFromString;

            GLib.Value.register_transform_func (typeof (string), inType,
                                                (ValueTransform)string_to_object);
            GLib.Value.register_transform_func (inType, typeof (string),
                                                (ValueTransform)object_to_string);
        }
    }

    /**
     * Create an object from string
     *
     * @param inType object type
     * @param inParameters string representation of object properties
     *
     * @return a new Object
     */
    public static Object?
    create_from_string (Type inType, string inParameters)
    {
        Object ret = null;

        if (s_Factory != null)
        {
            CreateFromString? func = s_Factory[inType];

            if (func != null)
            {
                ret = func (inParameters);
            }
        }

        return ret;
    }
}