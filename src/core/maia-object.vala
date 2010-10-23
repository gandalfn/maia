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

public abstract class Maia.Object
{
    [CCode (has_target = false)]
    public delegate Object Create (GLib.Parameter[] inProperties);

    static Vala.HashMap <GLib.Type, Create> s_Factory;

    /**
     * Register a create function for a specified type. The function can be
     * called multiple time but only first call is really effective
     *
     * @param inType type to register
     * @param inFunc create function
     */
    public static void
    register (GLib.Type inType, Create inFunc)
    {
        if (s_Factory == null)
        {
            s_Factory = new Vala.HashMap <GLib.Type, Create> ();
        }

        if (!(inType in s_Factory))
        {
            s_Factory[inType] = inFunc;
        }
    }

    /**
     * Unregister a create function for a specified type
     *
     * @param inType type to register
     * @param inFunc create function
     */
    public static void
    unregister (GLib.Type inType)
    {
        if (s_Factory == null)
        {
            s_Factory = new Vala.HashMap <GLib.Type, Create> ();
        }

        if (inType in s_Factory)
        {
            s_Factory.remove (inType);
        }
    }

    /**
     * Create a new object for a specified type. The create function must be
     * registered before.
     *
     * @param inType type of object
     * @param inProperties array of properties to pass of creation of object
     */
    public static Object
    newv (GLib.Type inType, GLib.Parameter[] inProperties)
    {
        Object result = null;
        Create func = s_Factory[inType];

        if (func != null)
        {
            result = func (inProperties);
        }

        return result;
    }
}