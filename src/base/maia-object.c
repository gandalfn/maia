/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-object.c
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

#include <glib.h>
#include <glib-object.h>

#include "maia-object.h"

G_DEFINE_ABSTRACT_TYPE (MaiaObject, maia_object, G_TYPE_OBJECT)

typedef struct _MaiaObjectTypeNode MaiaObjectTypeNode;

struct _MaiaObjectTypeNode 
{
    GType m_Orig;
    GType m_Derived;
};

static int                   s_ObjectFactoryLength   = 0;
static MaiaObjectTypeNode*   s_ObjectFactory         = NULL;

static MaiaObjectTypeNode*
maia_object_factory_get (GType inObjectType)
{
    if (s_ObjectFactory != NULL)
    {
        int left = 0, right = s_ObjectFactoryLength - 1;

        if (right != -1)
        {
            while (right >= left)
            {
                const int medium = (left + right) / 2;
                MaiaObjectTypeNode* node = &s_ObjectFactory[medium];

                if (inObjectType == node->m_Orig)
                {
                    return node;
                }
                else if (inObjectType < node->m_Orig)
                {
                    right = medium - 1;
                }
                else
                {
                    left = medium + 1;
                }
            }
        }
    }

    return NULL;
}

static void
maia_object_init (MaiaObject* inSelf)
{
}

static GObject*
maia_object_constructor (GType inType, guint inNConstructProperties,
                         GObjectConstructParam* inConstructProperties)
{
    GObject* object;
    GObjectClass* parent_class;
    GType type = inType;
    const MaiaObjectTypeNode* node = maia_object_factory_get (type);

    if (node != NULL && node->m_Derived != 0) type = node->m_Derived;

    parent_class = G_OBJECT_CLASS (maia_object_parent_class);
    object = parent_class->constructor (type, inNConstructProperties, inConstructProperties);

    return object;
}

static void
maia_object_class_init (MaiaObjectClass * inKlass)
{
    G_OBJECT_CLASS (inKlass)->constructor = maia_object_constructor;
}

MaiaObject*
maia_object_construct (GType inObjectType)
{
    return g_object_newv (inObjectType, 0, NULL);
}

/**
 * maia_object_register:
 *
 * @inObjectType: Base object type
 * @inType: Derived base object type
 *
 * Associate a new @inType to an @inObjectType. After this call all object 
 * of @inObjectType or derived from @inObjectType creation return an Object of 
 * @inType. @inType must be direct derived from @inObjectType.
 */
void
maia_object_register (GType inObjectType, GType inType)
{
    g_return_if_fail (g_type_parent (inType) == inObjectType);

    MaiaObjectTypeNode* node = maia_object_factory_get (inObjectType);

    if (node == NULL)
    {
        int index = s_ObjectFactoryLength;

        s_ObjectFactoryLength++;
        if (s_ObjectFactory == NULL)
            s_ObjectFactory = g_slice_alloc (s_ObjectFactoryLength * sizeof (MaiaObjectTypeNode));
        else
            s_ObjectFactory = g_slice_copy (s_ObjectFactoryLength * sizeof (MaiaObjectTypeNode), s_ObjectFactory);

        while (index > 0 && s_ObjectFactory[index - 1].m_Orig > inObjectType)
        {
            s_ObjectFactory[index].m_Orig = s_ObjectFactory[index - 1].m_Orig;
            s_ObjectFactory[index].m_Derived = s_ObjectFactory[index - 1].m_Derived;
            index--;
        }

        s_ObjectFactory[index].m_Orig = inObjectType;
        node = &s_ObjectFactory[index];
    }

    node->m_Derived = inType;
}

/**
 * maia_object_unregister:
 *
 * @inObjectType: Base object type
 *
 * Remove any association to an @inObjectType.
 */
void
maia_object_unregister (GType inObjectType)
{
    MaiaObjectTypeNode* node = maia_object_factory_get (inObjectType);

    if (node != NULL) node->m_Derived = 0;
}

