/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * any.c
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

#include <stdlib.h>
#include <glib.h>
#include <glib-object.h>

#include "maia-any.h"

static GQuark quarkDelegation = 0;

typedef struct _MaiaCoreAnyDelegation MaiaCoreAnyDelegation;

struct _MaiaCoreAnyDelegation
{
    volatile int ref_count;
    GType        type;
    GType        derived;
};

static MaiaCoreAnyDelegation*
maia_core_any_delegation_new (GType inType, GType inDerived)
{
    MaiaCoreAnyDelegation* pSelf;

    pSelf = g_slice_new (MaiaCoreAnyDelegation);
    pSelf->ref_count = 1;
    pSelf->type = inType;
    pSelf->derived = inDerived;

    return pSelf;
}

static MaiaCoreAnyDelegation*
maia_core_any_delegation_ref (MaiaCoreAnyDelegation* inpSelf)
{
    g_atomic_int_inc (&inpSelf->ref_count);
    return inpSelf;
}

static void
maia_core_any_delegation_unref (MaiaCoreAnyDelegation* inpSelf)
{
    if (g_atomic_int_dec_and_test (&inpSelf->ref_count))
    {
        g_slice_free (MaiaCoreAnyDelegation, inpSelf);
    }
}

static int
maia_core_any_delegation_compare (MaiaCoreAnyDelegation* inpSelf, MaiaCoreAnyDelegation* inpOther)
{
    return (int)(inpSelf->type - inpOther->type);
}

static int
maia_core_any_delegation_compare_with_type (MaiaCoreAnyDelegation* inpSelf, GType inType)
{
    return (int)(inpSelf->type - inType);
}

G_DEFINE_ABSTRACT_TYPE (MaiaCoreAny, maia_core_any, G_TYPE_OBJECT)

#define MAIA_CORE_ANY_GET_PRIVATE(o) \
        (G_TYPE_INSTANCE_GET_PRIVATE ((o), MAIA_CORE_TYPE_ANY, MaiaCoreAnyPrivate))


static GObject*
maia_core_any_constructor (GType inType, guint inNConstructProperties,
                           GObjectConstructParam* inConstructProperties)
{
    GObject* object;
    GObjectClass* parent_class = (GObjectClass*)maia_core_any_parent_class;
    GType type = inType;

    if (inType)
    {
        MaiaCoreAnyDelegation* pDelegation = (MaiaCoreAnyDelegation*)g_type_get_qdata (inType, quarkDelegation);
        if (pDelegation != NULL && pDelegation->derived != 0)
        {
            type = pDelegation->derived;
        }
    }

    object = parent_class->constructor (type, inNConstructProperties, inConstructProperties);
    maia_core_any_delegate_construct ((MaiaCoreAny*)object);

    return object;
}

static void
maia_core_any_init (MaiaCoreAny* inSelf)
{
    inSelf->cpp_instance = NULL;
}

static void
maia_core_any_class_init (MaiaCoreAnyClass* inKlass)
{
    quarkDelegation = g_quark_from_static_string ("MaiaAnyDelegation");
    inKlass->delegate_construct = NULL;
    G_OBJECT_CLASS (inKlass)->constructor  = maia_core_any_constructor;
}

MaiaCoreAny*
maia_core_any_construct (GType inObjectType)
{
    return g_object_newv (inObjectType, 0, NULL);
}

void
maia_core_any_delegate_construct (MaiaCoreAny* inpSelf)
{
    MaiaCoreAnyClass* class = MAIA_CORE_ANY_GET_CLASS(inpSelf);
    if (class->delegate_construct != NULL)
    {
        class->delegate_construct (inpSelf);
    }
}

void
maia_core_any_delegate (GType inObjectType, GType inType)
{
    if (inObjectType)
    {
        MaiaCoreAnyDelegation* pDelegation = (MaiaCoreAnyDelegation*)g_type_get_qdata (inObjectType, quarkDelegation);
        if (pDelegation != NULL)
        {
            maia_core_any_delegation_unref (pDelegation);
        }
        pDelegation = maia_core_any_delegation_new (inObjectType, inType);
        g_type_set_qdata (inObjectType, quarkDelegation, pDelegation);
    }
}

void
maia_core_any_undelegate (GType inObjectType)
{
    if (inObjectType)
    {
        MaiaCoreAnyDelegation* pDelegation = (MaiaCoreAnyDelegation*)g_type_get_qdata (inObjectType, quarkDelegation);
        if (pDelegation != NULL)
        {
            maia_core_any_delegation_unref (pDelegation);
        }
        g_type_set_qdata (inObjectType, quarkDelegation, NULL);
    }
}
