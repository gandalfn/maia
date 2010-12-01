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
    // Type
    public delegate R ActionFunc<R> ();

    // Properties
    internal ActionFunc   func;

    // Methods
    public Observer (ActionFunc<R> inFunc)
    {
        func = inFunc;
    }

    internal Observer.inherit ()
    {
    }

    public virtual R
    notify (int inNbArgs, va_list inArgs)
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
    // Type
    public delegate R ActionFunc<R, A> (A inA);

    // Methods
    public Observer1 (ActionFunc<R, A> inFunc)
    {
        base.inherit ();
        func = (Observer.ActionFunc)inFunc;
    }

    public Observer1.bind (ActionFunc<R, A> inFunc, A inA)
    {
        base.inherit ();
        func = () => { return inFunc (inA); };
    }

    public override R
    notify (int inNbArgs, va_list inArgs)
    {
        if (inNbArgs >= 1)
        {
            ActionFunc<R, A> callback = (ActionFunc<R, A>)func;
            A a = inArgs.arg ();

            return callback (a);
        }

        return base.notify (inNbArgs, inArgs);
    }
}

public class Maia.Observer2<R, A, B> : Observer<R>
{
    // Type
    public delegate R ActionFunc<R, A, B> (A inA, B inB);

    // Methods
    public Observer2 (ActionFunc<R, A, B> inFunc)
    {
        base.inherit ();
        func = (Observer.ActionFunc)inFunc;
    }

    public Observer2.bind (ActionFunc<R, A, B> inFunc, A inA, B inB)
    {
        base.inherit ();
        func = () => { return inFunc (inA, inB); };
    }

    public Observer2.bind1 (ActionFunc<R, A, B> inFunc, B inB)
    {
        base.inherit ();
        Observer1.ActionFunc<R, A> callback = (a) => { return inFunc (a, inB); };
        func = (Observer.ActionFunc)callback;
    }

    public override R
    notify (int inNbArgs, va_list inArgs)
    {
        if (inNbArgs >= 2)
        {
            ActionFunc<R, A, B> callback = (ActionFunc<R, A, B>)func;
            A a = inArgs.arg ();
            A b = inArgs.arg ();

            return callback (a, b);
        }
        else if (inNbArgs == 1)
        {
            Observer1.ActionFunc<R, A> callback = (Observer1.ActionFunc<R, A>)func;
            A a = inArgs.arg ();

            return callback (a);
        }

        return base.notify (inNbArgs, inArgs);
    }
}