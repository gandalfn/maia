/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * workspace-proxy.vala
 * Copyright (C) Nicolas Bruguier 2010-2011 <gandalfn@club-internet.fr>
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

public abstract class Maia.WorkspaceProxy : View
{
    // accessors
    public abstract uint                  num   { get; }
    public abstract Window                root  { get; }
    public abstract Array<unowned Window> stack { get; }

    // events
    public abstract CreateWindowEvent create_window_event { get; }
    public abstract DestroyWindowEvent destroy_window_event { get; }
    public abstract ReparentWindowEvent reparent_window_event { get; }
}