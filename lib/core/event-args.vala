/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * event-args.vala
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

public abstract class Maia.EventArgs
{
}

public class Maia.EventArgs1<A> : EventArgs
{
    public A a { get; private set; }

    public EventArgs1 (A inA)
    {
        a = inA;
    }
}

public class Maia.EventArgs2<A, B> : EventArgs1<A>
{
    public B b { get; private set; }

    public EventArgs2 (A inA, B inB)
    {
        base (inA);
        b = inB;
    }
}