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

namespace Maia
{
    public delegate R ActionFunc<R> ();
    public delegate R ActionFunc1<R, A> (A inA);
    public delegate R ActionFunc2<R, A, B> (A inA, B inB);
    public delegate R ActionFunc3<R, A, B, C> (A inA, B inB, C inC);
    public delegate R ActionFunc4<R, A, B, C, D> (A inA, B inB, C inC, D inD);
    public delegate R ActionFunc5<R, A, B, C, D, E> (A inA, B inB, C inC, D inD, E inE);
    public delegate R ActionFunc6<R, A, B, C, D, E, F> (A inA, B inB, C inC, D inD, E inE, F inF);
}

public class Maia.Observer<R>
{
    // types
    private class Bind1<R, A> : Observer<R> 
    {
        public Bind1 (ActionFunc1<R, A> inFunc, A inA)
        {
            func = () => { return inFunc (inA); };
        }
    }

    private class Bind2<R, A, B> : Observer<R> 
    {
        public Bind2 (ActionFunc2<R, A, B> inFunc, A inA, B inB)
        {
            func = () => { return inFunc (inA, inB); };
        }
    }

    private class Bind3<R, A, B, C> : Observer<R> 
    {
        public Bind3 (ActionFunc3<R, A, B, C> inFunc, A inA, B inB, C inC)
        {
            func = () => { return inFunc (inA, inB, inC); };
        }
    }

    // Properties
    internal ActionFunc   func;

    // Methods
    internal Observer.with_fun (ActionFunc<R> inFunc)
    {
        func = inFunc;
    }

    public static Observer<R>
    fun<R> (ActionFunc<R> inFunc)
    {
        return new Observer<R>.with_fun (inFunc);
    }

    public static Observer<R>
    bind1<R, A> (ActionFunc1<R, A> inFunc, A inA)
    {
        return new Observer.Bind1<R, A> (inFunc, inA);
    }

    public static Observer<R>
    bind2<R, A, B> (ActionFunc2<R, A, B> inFunc, A inA, B inB)
    {
        return new Observer.Bind2<R, A, B> (inFunc, inA, inB);
    }

    public static Observer<R>
    bind3<R, A, B, C> (ActionFunc3<R, A, B, C> inFunc, A inA, B inB, C inC)
    {
        return new Observer.Bind3<R, A, B, C> (inFunc, inA, inB, inC);
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

    // Methods
    internal Observer1.with_fun (ActionFunc1<R, A> inFunc)
    {
        func = (ActionFunc)inFunc;
    }

    public static new Observer1<R, A>
    fun<R, A> (ActionFunc1<R, A> inFunc)
    {
        return new Observer1<R, A>.with_fun (inFunc);
    }

    public override R
    notify (void* inOwner, va_list inArgs)
    {
        ActionFunc1<R, A> callback = (ActionFunc1<R, A>)func;
        A args1 = inArgs.arg ();

        return callback (args1);
    }
}

public class Maia.Observer2<R, A, B> : Observer<R>
{
    // types

    // Methods
    internal Observer2.with_fun (ActionFunc2<R, A, B> inFunc)
    {
        func = (ActionFunc)inFunc;
    }

    public static new Observer2<R, A, B>
    fun<R, A, B> (ActionFunc2<R, A, B> inFunc)
    {
        return new Observer2<R, A, B>.with_fun (inFunc);
    }

    public override R
    notify (void* inOwner, va_list inArgs)
    {
        ActionFunc2<R, A, B> callback = (ActionFunc2<R, A, B>)func;
        A args1 = inArgs.arg ();
        B args2 = inArgs.arg ();

        return callback (args1, args2);
    }
}
