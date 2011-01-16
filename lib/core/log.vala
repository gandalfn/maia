/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * log.vala
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

public class Maia.Log : Object
{
    // static properties
    static Set<Log> s_Logs = null;

    // properties
    private GLib.Timer         m_Timer;
    private string             m_Filename;
    private string             m_Domain;
    private GLib.LogLevelFlags m_Level;

    // static methods
    static inline string
    level_name (GLib.LogLevelFlags inLevel)
    {
        if ((inLevel & GLib.LogLevelFlags.LEVEL_ERROR) == GLib.LogLevelFlags.LEVEL_ERROR)
            return "ERROR";
        else if ((inLevel & GLib.LogLevelFlags.LEVEL_CRITICAL) == GLib.LogLevelFlags.LEVEL_CRITICAL)
            return "CRITICAL";
        else if ((inLevel & GLib.LogLevelFlags.LEVEL_WARNING) == GLib.LogLevelFlags.LEVEL_WARNING)
            return "WARNING";
        else if ((inLevel & GLib.LogLevelFlags.LEVEL_MESSAGE) == GLib.LogLevelFlags.LEVEL_MESSAGE)
            return "INFO";
        else if ((inLevel & GLib.LogLevelFlags.LEVEL_DEBUG) == GLib.LogLevelFlags.LEVEL_DEBUG)
            return "DEBUG";
        else
            return "ERROR";
    }

    static int
    compare_with_domain (Log inLog, string inDomain)
    {
        if (inDomain == null && inLog.m_Domain == null)
            return 0;

        if (inDomain == null && inLog.m_Domain != null)
            return 1;

        if (inDomain != null && inLog.m_Domain == null)
            return -1;

        return GLib.strcmp (inLog.m_Domain, inDomain);
    }

    // methods
    internal Log (string? inDomain, GLib.LogLevelFlags inLevel, string? inFilename = null)
    {
        m_Domain   = inDomain;
        m_Timer    = new GLib.Timer ();
        m_Level    = inLevel;
        m_Filename = inFilename;
        GLib.Log.set_handler (m_Domain,
                              GLib.LogLevelFlags.LEVEL_MASK |
                              GLib.LogLevelFlags.FLAG_FATAL |
                              GLib.LogLevelFlags.FLAG_RECURSION,
                              handler);
    }

    internal void
    handler (string? inDomain, GLib.LogLevelFlags inLevel, string inMessage) 
    {
        if ((m_Level & inLevel) == inLevel)
        {
            string msg = "%s|%4.06f|%s|%s\n".printf (inDomain != null ? inDomain : "",
                                                     m_Timer.elapsed (),
                                                     level_name (inLevel),
                                                     inMessage);

            int fd = 0;
            if (m_Filename != null)
            {
                fd = Posix.open(m_Filename, Posix.O_CREAT | Posix.O_WRONLY | Posix.O_APPEND, 0666);
                if (fd < 0) fd = Posix.dup (2);
            }
            else
            {
                fd = Posix.dup (2);
            }

            Posix.write (fd, msg, Posix.strlen (msg));
            Posix.close (fd);
        }
    }

    internal override int
    compare (Object inOther)
        requires (inOther is Log)
    {
        return compare_with_domain (inOther as Log, m_Domain);
    }

    public static void
    init (string? inDomain, GLib.LogLevelFlags inLevel, string? inFilename = null)
    {
        if (s_Logs == null)
            s_Logs = new Set<Log> ();

        if (s_Logs.search<string> (inDomain, compare_with_domain) == null)
        {
            Log log = new Log (inDomain, inLevel, inFilename);
            s_Logs.insert (log);
        }
    }
}