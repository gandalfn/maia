/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * any.h
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

#ifndef __MAIA_ANY_H__
#define __MAIA_ANY_H__

#include <glib-object.h>

G_BEGIN_DECLS

#define MAIA_TYPE_ANY            (maia_any_get_type ())
#define MAIA_ANY(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), MAIA_TYPE_ANY, MaiaAny))
#define MAIA_ANY_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass),  MAIA_TYPE_ANY, MaiaAnyClass))
#define MAIA_IS_ANY(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), MAIA_TYPE_ANY))
#define MAIA_IS_ANY_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass),  MAIA_TYPE_ANY))
#define MAIA_ANY_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj),  MAIA_TYPE_ANY, MaiaAnyClass))

typedef struct _MaiaAnyClass    MaiaAnyClass;
typedef struct _MaiaAnyPrivate  MaiaAnyPrivate;
typedef struct _MaiaAny         MaiaAny;

struct _MaiaAnyClass
{
    GObjectClass    parent_class;

    void (*delegate_construct) (MaiaAny* inpSelf);
};

struct _MaiaAny
{
    GObject         parent_instance;
    MaiaAnyPrivate* priv;
};

MaiaAny* maia_any_construct (GType inObjectType);

void maia_any_delegate_construct (MaiaAny* inpSelf);

void maia_any_lock   (MaiaAny* inpSelf);
void maia_any_unlock (MaiaAny* inpSelf);

void maia_any_delegate   (GType inObjectType, GType inType);
void maia_any_undelegate (GType inObjectType);

G_END_DECLS

#endif /* __MAIA_ANY_H__ */
