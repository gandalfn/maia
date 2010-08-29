/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-object.h
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

#ifndef __MAIA_OBJECT_H__
#define __MAIA_OBJECT_H__

#include <glib-object.h>

G_BEGIN_DECLS

#define MAIA_TYPE_OBJECT            (maia_object_get_type ())
#define MAIA_OBJECT(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), MAIA_TYPE_OBJECT, MaiaObject))
#define MAIA_OBJECT_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass),  MAIA_TYPE_OBJECT, MaiaObjectClass))
#define MAIA_IS_OBJECT(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), MAIA_TYPE_OBJECT))
#define MAIA_IS_OBJECT_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass),  MAIA_TYPE_OBJECT))
#define MAIA_OBJECT_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj),  MAIA_TYPE_OBJECT, MaiaObjectClass))

typedef struct _MaiaObjectClass    MaiaObjectClass;
typedef struct _MaiaObject         MaiaObject;

struct _MaiaObjectClass
{
    GObjectClass parent_class;
};

struct _MaiaObject
{
    GObject parent_instance;
};

GType maia_object_get_type (void) G_GNUC_CONST;

MaiaObject* maia_object_construct (GType inObjectType);

void maia_object_register   (GType inObjectType, GType inType);
void maia_object_unregister (GType inObjectType);

G_END_DECLS

#endif /* __MAIA_OBJECT_H__ */
