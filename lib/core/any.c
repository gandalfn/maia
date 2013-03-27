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

#include "maia-core.h"
#include "maia-any.h"

static MaiaSet* g_ObjectDelegations = 0;

typedef struct _MaiaAnyDelegation MaiaAnyDelegation;

struct _MaiaAnyDelegation
{
    volatile int ref_count;
    GType        type;
    GType        derived;
};

static MaiaAnyDelegation*
maia_any_delegation_new (GType inType, GType inDerived)
{
    MaiaAnyDelegation* pSelf;

    pSelf = g_slice_new (MaiaAnyDelegation);
    pSelf->ref_count = 1;
    pSelf->type = inType;
    pSelf->derived = inDerived;

    return pSelf;
}

static MaiaAnyDelegation*
maia_any_delegation_ref (MaiaAnyDelegation* inpSelf)
{
    g_atomic_int_inc (&inpSelf->ref_count);
    return inpSelf;
}

static void
maia_any_delegation_unref (MaiaAnyDelegation* inpSelf)
{
    if (g_atomic_int_dec_and_test (&inpSelf->ref_count))
    {
        g_slice_free (MaiaAnyDelegation, inpSelf);
    }
}

static int
maia_any_delegation_compare (MaiaAnyDelegation* inpSelf, MaiaAnyDelegation* inpOther)
{
    return (int)(inpSelf->type - inpOther->type);
}

static int
maia_any_delegation_compare_with_type (MaiaAnyDelegation* inpSelf, GType inType)
{
    return (int)(inpSelf->type - inType);
}

struct _MaiaAnyPrivate
{
    MaiaSpinLock m_SpinLock;
};

G_DEFINE_ABSTRACT_TYPE (MaiaAny, maia_any, G_TYPE_OBJECT)

#define MAIA_ANY_GET_PRIVATE(o) \
        (G_TYPE_INSTANCE_GET_PRIVATE ((o), MAIA_TYPE_ANY, MaiaAnyPrivate))


static GObject*
maia_any_constructor (GType inType, guint inNConstructProperties,
                      GObjectConstructParam* inConstructProperties)
{
    GObject* object;
    GObjectClass* parent_class = G_OBJECT_CLASS (maia_any_parent_class);
    GType type = inType;

    if (g_ObjectDelegations != NULL)
    {
        MaiaAnyDelegation* pDelegation;

        pDelegation = maia_collection_search (MAIA_COLLECTION (g_ObjectDelegations),
                                                               G_TYPE_GTYPE, NULL, NULL,
                                                               inType, maia_any_delegation_compare_with_type);

        if (pDelegation != NULL && pDelegation->derived != 0)
        {
            type = pDelegation->derived;
            maia_log_debug ("maia_any_constructor", "type %s -> %s", g_type_name (inType), g_type_name (type));
        }
    }

    object = parent_class->constructor (type, inNConstructProperties, inConstructProperties);
    maia_any_delegate_construct (MAIA_ANY (object));

    return object;
}

static void
maia_any_init (MaiaAny* inSelf)
{
    inSelf->priv = MAIA_ANY_GET_PRIVATE (inSelf);

    maia_spin_lock_init (&inSelf->priv->m_SpinLock);
}

static void
maia_any_class_init (MaiaAnyClass* inKlass)
{
    g_type_class_add_private (inKlass, sizeof (MaiaAnyPrivate));

    inKlass->delegate_construct = NULL;
    G_OBJECT_CLASS (inKlass)->constructor  = maia_any_constructor;
}

MaiaAny*
maia_any_construct (GType inObjectType)
{
    return g_object_newv (inObjectType, 0, NULL);
}

void
maia_any_delegate_construct (MaiaAny* inpSelf)
{
    MaiaAnyClass* class = MAIA_ANY_GET_CLASS(inpSelf);
    if (class->delegate_construct != NULL)
    {
        class->delegate_construct (inpSelf);
    }
}

void
maia_any_lock (MaiaAny* inpSelf)
{
    maia_spin_lock_lock (&inpSelf->priv->m_SpinLock);
}

void
maia_any_unlock (MaiaAny* inpSelf)
{
    maia_spin_lock_unlock (&inpSelf->priv->m_SpinLock);
}

void
maia_any_delegate (GType inObjectType, GType inType)
{
    if (g_ObjectDelegations == NULL)
    {
        g_ObjectDelegations = maia_set_new (G_TYPE_POINTER, (GBoxedCopyFunc)maia_any_delegation_ref, maia_any_delegation_unref);
        maia_collection_set_compare_func (MAIA_COLLECTION (g_ObjectDelegations), maia_any_delegation_compare);
    }
    MaiaAnyDelegation* delegation = maia_any_delegation_new (inObjectType, inType);
    maia_collection_insert (MAIA_COLLECTION (g_ObjectDelegations), delegation);
}

void
maia_any_undelegate (GType inObjectType)
{
    if (g_ObjectDelegations != NULL)
    {
        MaiaAnyDelegation* pDelegation;

        pDelegation = maia_collection_search (MAIA_COLLECTION (g_ObjectDelegations),
                                                               G_TYPE_GTYPE, NULL, NULL,
                                                               inObjectType,
                                                               maia_any_delegation_compare_with_type);

        if (pDelegation != NULL)
        {
            maia_collection_remove (MAIA_COLLECTION (g_ObjectDelegations), pDelegation);
        }
    }
}