/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-observer.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
 * 
 * libmaia is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * maiawm is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public class Maia.Observer<R>
{
    // types
    public delegate R ActionFunc<R> ();
    public delegate R ActionFunc1<R, A> (A inArgs1);

    // Properties
    internal ActionFunc   func;

    // Methods
    private Observer (ActionFunc<R> inFunc)
    {
        func = inFunc;
    }

    public static Observer<R>
    mem_fun<R> (ActionFunc<R> inFunc)
    {
        return new Observer<R> (inFunc);
    }

    public static Observer<R>
    bind<R, A> (ActionFunc1<R, A> inFunc, A inArgs1)
    {
        return new Observer<R> (() => { return inFunc (inArgs1); });
    }

    public virtual R
    notify (void* inOwner, va_list inArgs)
    {
        return func ();
    }

    internal bool
    equals (Observer inOther)
    {
        return func == inOther.func && 
               (void*)(&func + sizeof (ActionFunc)) == (void*)(&inOther.func + sizeof (ActionFunc));
    }
}

public class Maia.Observer1<R, A> : Observer<R>
{
    // types
    public delegate R ActionFunc<R, A> (A inA);

    // Methods
    public Observer1 (ActionFunc<R, A> inFunc)
    {
        base ((Observer.ActionFunc)inFunc);
    }

    public override R
    notify (void* inOwner, va_list inArgs)
    {
        ActionFunc<R, A> callback = (ActionFunc<R, A>)func;
        A args1 = inArgs.arg ();

        return callback (args1);
    }
}

public class Maia.Observer2<R, A, B> : Observer<R>
{
    // types
    public delegate R ActionFunc<R, A, B> (A inA, B inB);

    // Methods
    public Observer2 (ActionFunc<R, A, B> inFunc)
    {
        base ((Observer.ActionFunc)inFunc);
    }

    public override R
    notify (void* inOwner, va_list inArgs)
    {
        ActionFunc<R, A, B> callback = (ActionFunc<R, A, B>)func;
        A args1 = inArgs.arg ();
        B args2 = inArgs.arg ();

        return callback (args1, args2);
    }
}
