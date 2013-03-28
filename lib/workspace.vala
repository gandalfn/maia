/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * workspace.vala
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

public class Maia.Workspace : View
{
    // accessors
    public unowned Dispatcher dispatcher {
        get {
            return (parent as Application).dispatcher;
        }
    }

    public override Object parent {
        get {
            return base.parent;
        }
        construct set {
            base.parent = value;

            if (value != null)
            {
                // listen events
                create_window_event.listen ((a) => {
                    on_window_added (a.window);
                }, dispatcher);
                destroy_window_event.listen ((a) => {
                    on_window_removed (a.window);
                }, dispatcher);

                // add refresh timeout
                dispatcher.add_timeout ((int)(1000.0 / 60.0), on_refresh);
            }
        }
    }

    // events
    public CreateWindowEvent  create_window_event  { get; set; default = null; }
    public DestroyWindowEvent destroy_window_event { get; set; default = null; }

    // methods
    private bool
    on_refresh ()
    {
        foreach (unowned Object child in this)
        {
            if (child is View)
            {
                unowned View view = child as View;
                if (view.is_damaged)
                {
                    view.draw ();

                    if (view is DoubleBufferView)
                    {
                        (view as DoubleBufferView).swap_buffer ();
                    }
                }
            }
        }

        return true;
    }

    internal override string
    to_string ()
    {
        string ret = "";

        foreach (unowned Object window in this)
        {
            ret += window.to_string () + "\n";
        }
        ret += "\n";

        return ret;
    }

    internal override bool
    can_append_child (Object inChild)
    {
        return inChild is Window;
    }

    protected virtual void
    on_window_added (Window inWindow)
    {
        inWindow.parent = this;
    }

    protected virtual void
    on_window_removed (Window inWindow)
    {
        inWindow.parent = null;
    }
}
