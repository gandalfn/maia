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
    public abstract uint num { get; set; }

    public override void
    constructor (va_list inArgs)
    {
        base.constructor (inArgs);

        bool end = false;
        va_list args = va_list.copy (inArgs);

        while (!end)
        {
            string? property = args.arg ();
            switch (property)
            {
                case null:
                    end = true;
                    break;
                case "num":
                    num = args.arg ();
                    break;
            }
        }
    }
}