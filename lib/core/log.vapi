/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * log.vapi
 * Copyright (C) Nicolas Bruguier 2010-2011 <gandalfn@club-internet.fr>
 * 
 * libmaia is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * maiawm is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Maia
{
    [CCode (cheader_filename = "log.h", cname = "maia_log_set_level")]
    public static void log_set_level (Level inLevel);

    [PrintfFormat]
    [CCode (cheader_filename = "log.h", cname = "maia_debug")]
    public static void debug (string inFunction, string inMessage, ...);

    [PrintfFormat]
    [CCode (cheader_filename = "log.h", cname = "maia_audit")]
    public static void audit (string inFunction, string inMessage, ...);

    [PrintfFormat]
    [CCode (cheader_filename = "log.h", cname = "maia_warning")]
    public static void warning (string inFunction, string inMessage, ...);

    [PrintfFormat]
    [CCode (cheader_filename = "log.h", cname = "maia_error")]
    public static void error (string inFunction, string inMessage, ...);

    [PrintfFormat]
    [CCode (cheader_filename = "log.h", cname = "maia_log_print")]
    public static void log_print (string inContext, string inFunction,
                                  uint inLevel, string inMessage, ...);

    [CCode (cheader_filename = "log.h", cname = "maia_log_print_backtrace")]
    public static void print_backtrace ();

    [CCode (cheader_filename = "log.h", cname = "maia_log_backtrace_on_crash")]
    public static void backtrace_on_crash ();

    [CCode (cheader_filename = "log.h", cname = "MaiaLogLevel", cprefix = "MAIA_LOG_LEVEL_")]
    public enum Level
    {
        ERROR,
        WARNING,
        AUDIT,
        DEBUG
    }
}
