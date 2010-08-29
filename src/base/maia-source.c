/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-source.c
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

#include "maia-source.h"

struct _MaiaSource
{
    GSource m_Source;
    MaiaSourceFuncs m_Funcs;
    gpointer m_Data;
};

static gboolean
maia_source_prepare (GSource* inSource, gint* outTimeout)
{
    MaiaSource* source = (MaiaSource*) inSource;

    *outTimeout = -1;

    if (source->m_Funcs.prepare)
        return source->m_Funcs.prepare(source->m_Data, outTimeout);
    else
        return FALSE;
}

static gboolean
maia_source_check (GSource* inSource)
{
    MaiaSource* source = (MaiaSource*) inSource;

    if (source->m_Funcs.check)
        return source->m_Funcs.check(source->m_Data);
    else
        return FALSE;
}

static gboolean
maia_source_dispatch (GSource* inSource, GSourceFunc inCallback, gpointer inUserData)
{
    MaiaSource* source = (MaiaSource*) inSource;
    gboolean ret = FALSE;

    g_source_ref (inSource);
    if (source->m_Funcs.dispatch)
        ret = source->m_Funcs.dispatch(source->m_Data, inCallback, inUserData);
    g_source_unref (inSource);

    return ret;
}

static void
maia_source_finalize (GSource* inSource)
{
    MaiaSource* source = (MaiaSource*) inSource;

    if (source->m_Funcs.finalize)
        source->m_Funcs.finalize(source->m_Data);
}

static GSourceFuncs s_MaiaSourceFuncs = {
    maia_source_prepare,
    maia_source_check,
    maia_source_dispatch,
    maia_source_finalize,
};

/**
 * maia_source_new:
 *
 * @inFuncs: structure containing functions that implement the sources behavior.
 * @inData: user data to pass to functions.
 *
 * Creates a new #MaiaSource. The source will not initially be associated with
 * any #GMainContext and must be added to one with g_source_attach() before it
 * will be executed.
 *
 * Returns: the newly-created #MaiaSource.
 */
MaiaSource* 
maia_source_new (MaiaSourceFuncs inFuncs, gpointer inData) 
{
    g_return_val_if_fail(inData != NULL, NULL);

    MaiaSource* self;

    self = (MaiaSource*)g_source_new (&s_MaiaSourceFuncs, sizeof (MaiaSource));
    self->m_Funcs = inFuncs;
    self->m_Data = inData;

    return self;
}

/**
 * maia_source_new_from_pollfd:
 *
 * @inFuncs: structure containing functions that implement the sources behavior.
 * @inpFd: a #GPollFD structure holding information about a file descriptor to
 *         watch.
 * @inData: user data to pass to functions.
 *
 * Creates a new #MaiaSource with a file descriptor polled for this source.
 * The event source's check function will typically test the @revents field in
 * the #GPollFD struct and return %TRUE if events need to be processed.
 *
 * The source will not initially be associated with any #GMainContext and must
 * be added to one with g_source_attach() before it will be executed.
 *
 * Returns: the newly-created #MaiaSource.
 */
MaiaSource* 
maia_source_new_from_pollfd (MaiaSourceFuncs inFuncs, GPollFD* inpFd,
                             gpointer inData) 
{
    g_return_val_if_fail(inpFd != NULL, NULL);
    g_return_val_if_fail(inData != NULL, NULL);

    MaiaSource* self;

    self = (MaiaSource*)g_source_new (&s_MaiaSourceFuncs, sizeof (MaiaSource));
    self->m_Funcs = inFuncs;
    self->m_Data = inData;
    g_source_add_poll ((GSource*) self, inpFd);
    g_source_set_can_recurse ((GSource*) self, TRUE);

    return self;
}

/**
 * maia_source_ref:
 * @self: a #MaiaSource
 *
 * Increases the reference count on a source by one.
 *
 * Return value: @self
 **/
MaiaSource*
maia_source_ref (MaiaSource* self)
{
    g_return_val_if_fail(self != NULL, NULL);

    g_source_ref ((GSource*)self);

    return self;
}

/**
 * maia_source_unref:
 * @self: a #MaiaSource
 *
 * Decreases the reference count of a source by one. If the
 * resulting reference count is zero the source and associated
 * memory will be destroyed.
 **/
void
maia_source_unref (MaiaSource* self)
{
    g_return_if_fail(self != NULL);

    g_source_unref ((GSource*)self);
}

/**
 * maia_source_destroy:
 * @self: a #MaiaSource
 *
 * Removes a source from its #GMainContext, if any, and mark it as
 * destroyed.  The source cannot be subsequently added to another
 * context.
 **/
void
maia_source_destroy (MaiaSource* self)
{
    g_return_if_fail(self != NULL);

    g_source_destroy ((GSource*)self);
}
