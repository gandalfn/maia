/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xml-node.vala
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

public enum Maia.Xml.NodeType
{
    INVALID_NODE = 0,
    ELEMENT_NODE,
    ATTRIBUTE_NODE,
    TEXT_NODE,
    CDATA_SECTION_NODE,
    ENTITY_REFERENCE_NODE,
    ENTITY_NODE,
    PROCESSING_INSTRUCTION_NODE,
    COMMENT_NODE,
    DOCUMENT_NODE,
    DOCUMENT_TYPE_NODE,
    DOCUMENT_FRAGMENT_NODE,
    NOTATION_NODE
}

public abstract class Maia.Xml.Node : Object
{
    /**
     * Node type
     */
    public abstract Xml.NodeType node_type { get; default = Xml.NodeType.INVALID_NODE; }
}
