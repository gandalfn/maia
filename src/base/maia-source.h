/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-source.c
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
 * 
 * libmaia is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * libmaia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef __MAIA_SOURCE_H__
#define __MAIA_SOURCE_H__

#include <glib.h>

G_BEGIN_DECLS 

typedef struct _MaiaSource MaiaSource;
typedef struct _MaiaSourceFuncs MaiaSourceFuncs;

struct _MaiaSourceFuncs
{
    gboolean (*prepare)  (gpointer inData,
                          gint* inTimeout);
    gboolean (*check)    (gpointer inData);
    gboolean (*dispatch) (gpointer inData,
                          GSourceFunc inCallback,
                          gpointer inUserData);
    void     (*finalize) (gpointer inData);
};

MaiaSource* maia_source_new               (MaiaSourceFuncs inFunc,
                                           gpointer inData);
MaiaSource* maia_source_new_from_pollfd   (MaiaSourceFuncs inFunc,
                                           GPollFD* inpFd, 
                                           gpointer inData);
MaiaSource* maia_source_ref               (MaiaSource* self);
void        maia_source_unref             (MaiaSource* self);
void        maia_source_destroy           (MaiaSource* self);

G_END_DECLS

#endif /* __MAIA_SOURCE_H__ */
