/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * widget.vala
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

public abstract class Maia.Widget : View
{
    // accessors
    public Window window {
        get {
            unowned Window? ret = null;
            for (unowned Object? p = parent; p != null; p = p.parent)
            {
                if (p is Window)
                {
                    ret = (Window)p;
                    break;
                }
            }

            return ret;
        }
    }

    public override Graphic.Device? device {
        get {
            return window.device;
        }
    }

    // methods
    public virtual void
    get_requested_size (out Graphic.Size outSize)
    {
        outSize = Graphic.Size (0, 0);
    }

    /**
     * {@inheritDoc}
     */
    public override bool
    can_append_child (Object inChild)
    {
        return inChild is View;
    }
}