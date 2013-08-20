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

#define MAIA_CORE_TYPE_ANY            (maia_core_any_get_type ())
#define MAIA_CORE_ANY(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), MAIA_CORE_TYPE_ANY, MaiaCoreAny))
#define MAIA_CORE_ANY_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass),  MAIA_CORE_TYPE_ANY, MaiaCoreAnyClass))
#define MAIA_CORE_IS_ANY(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), MAIA_CORE_TYPE_ANY))
#define MAIA_CORE_IS_ANY_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass),  MAIA_CORE_TYPE_ANY))
#define MAIA_CORE_ANY_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj),  MAIA_CORE_TYPE_ANY, MaiaCoreAnyClass))

typedef struct _MaiaCoreAnyClass    MaiaCoreAnyClass;
typedef struct _MaiaCoreAny         MaiaCoreAny;

struct _MaiaCoreAnyClass
{
    GObjectClass    parent_class;

    void (*delegate_construct) (MaiaCoreAny* inpSelf);
};

struct _MaiaCoreAny
{
    GObject         parent_instance;
};

GType maia_core_any_get_type (void) G_GNUC_CONST;
MaiaCoreAny* maia_core_any_construct (GType inObjectType);

void maia_core_any_delegate_construct (MaiaCoreAny* inpSelf);

void maia_core_any_delegate   (GType inObjectType, GType inType);
void maia_core_any_undelegate (GType inObjectType);

G_END_DECLS

#endif /* __MAIA_ANY_H__ */
