/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * create-window-event.vala
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

public class Maia.CreateWindowEventArgs : EventArgs
{
    // accessors
    [CCode (notify = false)]
    public Window window { get; construct; }

    // methods
    internal CreateWindowEventArgs (Window inWindow)
    {
        GLib.Object (window: inWindow);
    }
}

public class Maia.CreateWindowEvent : Event<CreateWindowEventArgs>
{
    // static methods
    internal static new void
    post_event (void* inOwner, CreateWindowEventArgs inArgs)
    {
        Dispatcher.post_event ("create-window-event", inOwner, inArgs);
    }

    // methods
    internal CreateWindowEvent (void* inOwner)
    {
        base ("create-window-event", inOwner);
    }
}
