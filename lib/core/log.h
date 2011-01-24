/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * log.h
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

#ifndef __MAIA_LOG_H__
#define __MAIA_LOG_H__

#include <glib.h>

G_BEGIN_DECLS 

typedef enum 
{
    MAIA_LOG_LEVEL_ERROR   = 1,
    MAIA_LOG_LEVEL_WARNING = 2,
    MAIA_LOG_LEVEL_AUDIT   = 3,
    MAIA_LOG_LEVEL_DEBUG   = 4
} MaiaLogLevel;

typedef struct _MaiaLogContext MaiaLogContext;

struct _MaiaLogContext {
    unsigned int log_level;
    char* name;
};

#ifndef MAIA_LOG_CONTEXT
#define MAIA_LOG_CONTEXT ""
#endif

extern unsigned int __log_level;

void            maia_log_print_valist    (const char*      ctx,
                                          const char*      function,
                                          unsigned int     level,
                                          const char*      format,
                                          va_list          varargs);
void            maia_log_print           (const char*      ctx,
                                          const char*      function,
                                          unsigned int     level,
                                          const char*      format,
                                          ...);
void            maia_log_print_backtrace (const char*      ctx);

void            maia_log_backtrace_on_crash ();

#define maia_log_set_level(level) G_STMT_START {                               \
    __log_level = level;                                                       \
} G_STMT_END

#ifdef G_HAVE_ISO_VARARGS

#define maia_debug(function, ...) G_STMT_START {                               \
    if (__log_level >= MAIA_LOG_LEVEL_DEBUG)                                   \
        maia_log_print (MAIA_LOG_CONTEXT, function,                            \
                        MAIA_LOG_LEVEL_DEBUG, __VA_ARGS__);                    \
} G_STMT_END

#define maia_audit(function, ...) G_STMT_START {                               \
    if (__log_level >= MAIA_LOG_LEVEL_AUDIT)                                   \
        maia_log_print (MAIA_LOG_CONTEXT, function,                            \
                        MAIA_LOG_LEVEL_AUDIT, __VA_ARGS__);                    \
} G_STMT_END

#define maia_warning(function, ...) G_STMT_START {                             \
    if (__log_level >= MAIA_LOG_LEVEL_WARNING)                                 \
        maia_log_print (MAIA_LOG_CONTEXT, function,                            \
                        MAIA_LOG_LEVEL_WARNING, __VA_ARGS__);                  \
} G_STMT_END

#define maia_error(function, ...) G_STMT_START {                               \
    if (__log_level >= MAIA_LOG_LEVEL_ERROR)                                   \
        maia_log_print (MAIA_LOG_CONTEXT, function,                            \
                        MAIA_LOG_LEVEL_ERROR, __VA_ARGS__);                    \
} G_STMT_END

#else /* G_HAVE_GNUC_VARARGS */

#ifdef G_HAVE_GNUC_VARARGS

#define maia_debug(function, format...) G_STMT_START {                         \
    if (__log_level >= MAIA_LOG_LEVEL_DEBUG)                                   \
        maia_log_print (MAIA_LOG_CONTEXT, function,                            \
                        MAIA_LOG_LEVEL_DEBUG, ##format);                       \
} G_STMT_END

#define maia_audit(function, format...) G_STMT_START {                         \
    if (__log_level >= MAIA_LOG_LEVEL_AUDIT)                                   \
        maia_log_print (MAIA_LOG_CONTEXT, function,                            \
                        MAIA_LOG_LEVEL_AUDIT, ##format);                       \
} G_STMT_END

#define maia_warning(function, format...) G_STMT_START {                       \
    if (__log_level >= MAIA_LOG_LEVEL_WARNING)                                 \
        maia_log_print (MAIA_LOG_CONTEXT, function,                            \
                        MAIA_LOG_LEVEL_WARNING, ##format);                     \
} G_STMT_END

#define maia_error(function, format...) G_STMT_START {                         \
    if (__log_level >= MAIA_LOG_LEVEL_ERROR)                                   \
        maia_log_print (MAIA_LOG_CONTEXT, function,                            \
                        MAIA_LOG_LEVEL_ERROR, ##format);                       \
} G_STMT_END

#else /* no variadic macros, use inline */

static inline void
maia_debug (const char* function, const char *format, ...)
{
    va_list varargs;

    if (__log_level >= MAIA_LOG_LEVEL_DEBUG)
    {
        va_start (varargs, format);
        maia_log_print_valist (MAIA_LOG_CONTEXT, function,
                               MAIA_LOG_LEVEL_DEBUG,
                               format, varargs);
        va_end (varargs);
    }
}

static inline void
maia_audit (const char* function, const char *format, ...)
{
    va_list varargs;

    if (__log_level >= MAIA_LOG_LEVEL_AUDIT)
    {
        va_start (varargs, format);
        maia_log_print_valist (MAIA_LOG_CONTEXT, function,
                               MAIA_LOG_LEVEL_AUDIT,
                               format, varargs);
        va_end (varargs);
    }
}

static inline void
maia_warning (const char* function, const char *format, ...)
{
    va_list varargs;

    if (__log_level >= MAIA_LOG_LEVEL_WARNING)
    {
        va_start (varargs, format);
        maia_log_print_valist (MAIA_LOG_CONTEXT, function,
                               MAIA_LOG_LEVEL_WARNING,
                               format, varargs);
        va_end (varargs);
    }
}

static inline void
maia_error (const char* function, const char *format, ...)
{
    va_list varargs;

    if (__log_level >= MAIA_LOG_LEVEL_ERROR)
    {
        va_start (varargs, format);
        maia_log_print_valist (MAIA_LOG_CONTEXT, function,
                               MAIA_LOG_LEVEL_ERROR,
                               format, varargs);
        va_end (varargs);
    }
}

#endif

#endif /* G_HAVE_ISO_VARARGS */

G_END_DECLS

#endif /* __MAIA_LOG_H__ */
