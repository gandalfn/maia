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
    [CCode (has_target = false)]
    public delegate R ActionFunc<R> (void* inTarget, void* inOwner);

    // Properties
    internal ActionFunc   func;
    internal void*        target;

    // Methods
    public Observer (ActionFunc<R> inFunc, void* inTarget)
    {
        func = inFunc;
        target = inTarget;
    }

    public virtual R
    notify (void* inOwner, va_list inArgs)
    {
        return func (target, inOwner);
    }

    internal bool
    equals (Observer inOther)
    {
        return func == inOther.func && target == inOther.target;
    }
}

public class Maia.Observer1<R, A> : Observer<R>
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R, A> (void* inTarget, A inA, void* inOwner);

    // Methods
    public Observer1 (ActionFunc<R, A> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override R
    notify (void* inOwner, va_list inArgs)
    {
        ActionFunc<R, A> callback = (ActionFunc<R, A>)func;
        A args1 = inArgs.arg ();

        return callback (target, args1, inOwner);
    }
}

public class Maia.Observer2<R, A, B> : Observer<R>
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R, A, B> (void* inTarget, A inA, B inB, void* inOwner);

    // Methods
    public Observer2 (ActionFunc<R, A, B> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override R
    notify (void* inOwner, va_list inArgs)
    {
        ActionFunc<R, A, B> callback = (ActionFunc<R, A, B>)func;
        A args1 = inArgs.arg ();
        B args2 = inArgs.arg ();

        return callback (target, args1, args2, inOwner);
    }
}

public class Maia.Observer3<R, A, B, C> : Observer<R>
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R, A, B, C> (void* inTarget, A inA,
                                              B inB, C inC, void* inOwner);

    // Methods
    public Observer3 (ActionFunc<R, A, B, C> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override R
    notify (void* inOwner, va_list inArgs)
    {
        ActionFunc<R, A, B, C> callback = (ActionFunc<R, A, B, C>)func;
        A args1 = inArgs.arg ();
        B args2 = inArgs.arg ();
        C args3 = inArgs.arg ();

        return callback (target, args1, args2, args3, inOwner);
    }
}