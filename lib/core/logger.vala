/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * logger.vala
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

namespace Maia.Log
{
    // types
    public enum Level
    {
        ERROR    = 0,
        CRITICAL = 1,
        WARNING  = 2,
        INFO     = 3,
        AUDIT    = 4,
        DEBUG    = 5;

        public string
        to_string ()
        {
            switch (this)
            {
                case ERROR:
                    return "[error]";
                case CRITICAL:
                    return "[critical]";
                case WARNING:
                    return "[warning]";
                case INFO:
                    return "[info]";
                case AUDIT:
                    return "[audit]";
                case DEBUG:
                    return "[debug]";
            }

            return "";
        }
    }

    /**
     * Logger wrapper class
     */
    public abstract class Logger : GLib.Object
    {
        // types
        private enum ConsoleColor
        {
            BLACK   = 0,
            RED     = 1,
            GREEN   = 2,
            YELLOW  = 3,
            BLUE    = 4,
            MAGENTA = 5,
            CYAN    = 6,
            WHITE   = 7;

            public string
            to_string (bool inHighlight = true)
            {
                return "\033[%i;%im".printf (inHighlight ? 1 : 0, this + 30);
            }
        }

        // properties
        private  string   m_Domain     = "";
        internal Level    m_Level      = Level.INFO;
        private  bool     m_Colorized  = false;

        // accessors
        public Level level {
            get {
                return m_Level;
            }
            construct set {
                m_Level = value;
            }
        }

        public string domain {
            get {
                return m_Domain;
            }
            construct {
                m_Domain = value;
            }
        }

        public bool colorized {
            get {
                return m_Colorized;
            }
            set {
                m_Colorized = value;
            }
        }

        // methods
        protected string
        colorize (Level inLevel, string inMessage)
        {
            string prefix = "";
            string postfix = "\033[m";

            switch (inLevel)
            {
                case Level.DEBUG:
                    prefix = ConsoleColor.WHITE.to_string ();
                    break;
                case Level.INFO:
                    prefix = ConsoleColor.GREEN.to_string ();
                    break;
                case Level.AUDIT:
                    prefix = ConsoleColor.BLUE.to_string ();
                    break;
                case Level.WARNING:
                    prefix = ConsoleColor.YELLOW.to_string ();
                    break;
                case Level.CRITICAL:
                    prefix = ConsoleColor.RED.to_string ();
                    break;
                case Level.ERROR:
                    prefix = ConsoleColor.RED.to_string ();
                    break;
                default:
                    prefix = "";
                    postfix = "";
                    break;
            }

            return "%s%s%s".printf (prefix, inMessage, postfix );
        }

        /**
         * Write log trace
         *
         * @param inLevel log level
         * @param inMessage log message
         */
        internal void
        log (Level inLevel, string inMessage)
        {
            if (inLevel <= m_Level)
            {
                Posix.timeval now = Posix.timeval ();
                now.get_time_of_day ();
                GLib.Time time = GLib.Time.local (now.tv_sec);

                string msg = "[%.2d:%.2d:%.2d.%.6lu] [%s] %s %s".printf (time.hour,
                                                                        time.minute,
                                                                        time.second,
                                                                        now.tv_usec,
                                                                        m_Domain,
                                                                        inLevel.to_string (),
                                                                        inMessage);
                write (m_Domain, inLevel, m_Colorized ? colorize (inLevel, msg) : msg);
            }
        }

        /**
         * Write log message, must be implemented by child class
         *
         * @param inDomain log domain
         * @param inLevel log level
         * @param inMessage log message
         */
         internal abstract void write (string inDomain, Level inLevel, string inMessage);
    }

    /**
     * File logger wrapper
     */
    public class File : Logger
    {
        // properties
        private int m_Fd;
        private bool m_CloseOnDestroy = true;

        // accessors
        public int fd {
            get {
                return m_Fd;
            }
            construct set {
                m_Fd = value;
            }
        }

        public bool close_on_destroy {
            get {
                return m_CloseOnDestroy;
            }
            construct set {
                m_CloseOnDestroy = value;
            }
        }

        // methods
        public File (string inFilename, Level inLevel, string inDomain)
        {
            int f = Posix.open (inFilename, Posix.O_RDWR | Posix.O_CREAT | Posix.O_TRUNC, 0644);
            GLib.Object (domain: inDomain, level: inLevel, fd: f, close_on_destroy: true);
        }

        ~File ()
        {
            if (m_CloseOnDestroy)
            {
                Os.close (m_Fd);
            }
        }

        internal override void
        write (string inDomain, Level inLevel, string inMessage)
        {
            if (fd > 0)
            {
                string msg = "%s\n".printf (inMessage);
                Os.write (fd, msg, msg.length);
            }
        }
    }

    /**
     * Logger redirected in standard error
     */
    public class Stderr : File
    {
        // methods
        /**
         * Create a new logger redirected in standard error
         *
         * @param inLevel default log level
         * @param inDomain log domain
         */
        public Stderr (Level inLevel, string inDomain)
        {
            GLib.Object (domain: inDomain, level: inLevel, fd: 2, close_on_destroy: false);
            colorized = true;
        }
    }

    // static properties
    private static Logger s_Logger = null;

    // static methods
    private static inline string
    remove_filename_line_number (string inMessage)
    {
        char* str = (char*)inMessage.data;
        if (GLib.PatternSpec.match_simple ("*.vala:*:*", inMessage))
        {
            int vala_pos = inMessage.index_of (".vala:");
            str = (char*)inMessage.data + vala_pos + ".vala:".length;
            vala_pos = ((string)str).index_of (": ");
            str = str + vala_pos + ": ".length;
        }
        return (string)str;
    }

    private static void
    glib_log_handler (string? inLogDomain, LogLevelFlags inLogLevels, string inMessage)
    {
        Level level = Level.ERROR;

        switch (inLogLevels)
        {
            case GLib.LogLevelFlags.LEVEL_ERROR:
                level = Level.ERROR;
                break;
            case GLib.LogLevelFlags.LEVEL_CRITICAL:
                level = Level.CRITICAL;
                break;
            case GLib.LogLevelFlags.LEVEL_WARNING:
                level = Level.WARNING;
                break;
            case GLib.LogLevelFlags.LEVEL_MESSAGE:
                level = Level.INFO;
                break;
            case GLib.LogLevelFlags.LEVEL_INFO:
                level = Level.INFO;
                break;
            case GLib.LogLevelFlags.LEVEL_DEBUG:
                level = Level.DEBUG;
                break;
            default:
                break;
        }

        logger ().log (level, remove_filename_line_number (inMessage));
    }

    private static inline unowned Logger?
    logger ()
    {
        if (s_Logger == null)
        {
            s_Logger = new Stderr (Level.WARNING, "");
            GLib.Log.set_default_handler (glib_log_handler);
        }

        return s_Logger;
    }

    /**
     * Set default logger object
     */
    public static inline void
    set_default_logger (Logger inLogger)
    {
        s_Logger = inLogger;
        GLib.Log.set_default_handler (glib_log_handler);
    }

    /**
     * A convenience function to log a debug message.
     *
     * @param inFunction function name
     * @param inMessage log message
     */
    [PrintfFormat]
    public static inline void
    debug (string inFunction, string inMessage, ...)
    {
        if (logger ().m_Level >= Level.DEBUG)
        {
            va_list args = va_list ();
            string msg = inMessage.vprintf (args);
            logger ().log (Level.DEBUG, "%s: %s".printf (inFunction, msg));
        }
    }

    /**
     * A convenience function to log a debug message.
     *
     * @param inCond condition which determines the trace
     * @param inFunction function name
     * @param inMessage log message
     */
    [PrintfFormat]
    public static inline void
    debug_cond (bool inCond, string inFunction, string inMessage, ...)
    {
        if (logger ().m_Level >= Level.DEBUG && inCond)
        {
            va_list args = va_list ();
            string msg = inMessage.vprintf (args);
            logger ().log (Level.DEBUG, "%s: %s".printf (inFunction, msg));
        }
    }

    /**
     * A convenience function to log a info message.
     *
     * @param inFunction function name
     * @param inMessage log message
     */
    [PrintfFormat]
    public static inline void
    info (string inFunction, string inMessage, ...)
    {
        if (logger ().m_Level >= Level.INFO)
        {
            va_list args = va_list ();
            string msg = inMessage.vprintf (args);
            logger ().log (Level.INFO, "%s: %s".printf (inFunction, msg));
        }
    }

    /**
     * A convenience function to log a info message.
     *
     * @param inCond condition which determines the trace
     * @param inFunction function name
     * @param inMessage log message
     */
    [PrintfFormat]
    public static inline void
    info_cond (bool inCond, string inFunction, string inMessage, ...)
    {
        if (logger ().m_Level >= Level.INFO && inCond)
        {
            va_list args = va_list ();
            string msg = inMessage.vprintf (args);
            logger ().log (Level.INFO, "%s: %s".printf (inFunction, msg));
        }
    }

    /**
     * A convenience function to log a audit message.
     *
     * @param inFunction function name
     * @param inMessage log message
     */
    [PrintfFormat]
    public static inline void
    audit (string inFunction, string inMessage, ...)
    {
        if (logger ().m_Level >= Level.AUDIT)
        {
            va_list args = va_list ();
            string msg = inMessage.vprintf (args);
            logger ().log (Level.AUDIT, "%s: %s".printf (inFunction, msg));
        }
    }

    /**
     * A convenience function to log a audit message.
     *
     * @param inCond condition which determines the trace
     * @param inFunction function name
     * @param inMessage log message
     */
    [PrintfFormat]
    public static inline void
    audit_cond (bool inCond, string inFunction, string inMessage, ...)
    {
        if (logger ().m_Level >= Level.AUDIT && inCond)
        {
            va_list args = va_list ();
            string msg = inMessage.vprintf (args);
            logger ().log (Level.AUDIT, "%s: %s".printf (inFunction, msg));
        }
    }

    /**
     * A convenience function to log a warning message.
     *
     * @param inFunction function name
     * @param inMessage log message
     */
    [PrintfFormat]
    public static inline void
    warning (string inFunction, string inMessage, ...)
    {
        if (logger ().m_Level >= Level.WARNING)
        {
            va_list args = va_list ();
            string msg = inMessage.vprintf (args);
            logger ().log (Level.WARNING, "%s: %s".printf (inFunction, msg));
        }
    }

    /**
     * A convenience function to log a warning message.
     *
     * @param inCond condition which determines the trace
     * @param inFunction function name
     * @param inMessage log message
     */
    [PrintfFormat]
    public static inline void
    warning_cond (bool inCond, string inFunction, string inMessage, ...)
    {
        if (logger ().m_Level >= Level.WARNING && inCond)
        {
            va_list args = va_list ();
            string msg = inMessage.vprintf (args);
            logger ().log (Level.WARNING, "%s: %s".printf (inFunction, msg));
        }
    }

    /**
     * A convenience function to log a critical message.
     *
     * @param inFunction function name
     * @param inMessage log message
     */
    [PrintfFormat]
    public static inline void
    critical (string inFunction, string inMessage, ...)
    {
        if (logger ().m_Level >= Level.CRITICAL)
        {
            va_list args = va_list ();
            string msg = inMessage.vprintf (args);
            logger ().log (Level.CRITICAL, "%s: %s".printf (inFunction, msg));
        }
    }

    /**
     * A convenience function to log a critical message.
     *
     * @param inCond condition which determines the trace
     * @param inFunction function name
     * @param inMessage log message
     */
    [PrintfFormat]
    public static inline void
    critical_cond (bool inCond, string inFunction, string inMessage, ...)
    {
        if (logger ().m_Level >= Level.CRITICAL && inCond)
        {
            va_list args = va_list ();
            string msg = inMessage.vprintf (args);
            logger ().log (Level.CRITICAL, "%s: %s".printf (inFunction, msg));
        }
    }

    /**
     * A convenience function to log a error message.
     *
     * @param inFunction function name
     * @param inMessage log message
     */
    [PrintfFormat]
    public static inline void
    error (string inFunction, string inMessage, ...)
    {
        if (logger ().m_Level >= Level.ERROR)
        {
            va_list args = va_list ();
            string msg = inMessage.vprintf (args);
            logger ().log (Level.ERROR, "%s: %s".printf (inFunction, msg));
        }
    }

    /**
     * A convenience function to log a error message.
     *
     * @param inCond condition which determines the trace
     * @param inFunction function name
     * @param inMessage log message
     */
    [PrintfFormat]
    public static inline void
    error_cond (bool inCond, string inFunction, string inMessage, ...)
    {
        if (logger ().m_Level >= Level.ERROR && inCond)
        {
            va_list args = va_list ();
            string msg = inMessage.vprintf (args);
            logger ().log (Level.ERROR, "%s: %s".printf (inFunction, msg));
        }
    }
}
