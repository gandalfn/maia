/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * clone-renderer.vala
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

public class Maia.Graphic.CloneRenderer : Renderer
{
    // types
    public class Looper : Renderer.Looper
    {
        public Graphic.Device device { get; construct; }

        public Looper (Graphic.Device inDevice)
        {
            GLib.Object (device: inDevice);
        }

        internal override void
        prepare (Renderer.RenderFunc inFunc)
        {
        }

        internal override void
        finish ()
        {
        }
    }

    // methods
    public CloneRenderer (Graphic.Size inSize, Graphic.Device inDevice)
    {
        base (inSize);

        init (inDevice);
    }

    protected virtual void
    init (Graphic.Device inDevice)
    {
    }
}
