/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * item-packable.vala
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

public interface Maia.ItemPackable : Item
{
    // accessors
    public abstract uint   row     { get; set; default = 0; }
    public abstract uint   column  { get; set; default = 0; }
    public abstract uint   rows    { get; set; default = 1; }
    public abstract uint   columns { get; set; default = 1; }

    public abstract bool   xexpand { get; set; default = true; }
    public abstract bool   xfill   { get; set; default = true; }
    public abstract double xalign  { get; set; default = 0.5; }

    public abstract bool   yexpand { get; set; default = true; }
    public abstract bool   yfill   { get; set; default = true; }
    public abstract double yalign  { get; set; default = 0.5; }

    public abstract double top_padding    { get; set; default = 0; }
    public abstract double bottom_padding { get; set; default = 0; }
    public abstract double left_padding   { get; set; default = 0; }
    public abstract double right_padding  { get; set; default = 0; }
}
