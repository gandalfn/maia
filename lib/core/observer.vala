/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * observer.vala
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

public class Maia.Observer<R> : Object
{
    // Type
    public delegate R ActionFunc<R> ();

    // Properties
    internal ActionFunc   func;

    // Accessors
    public override Type object_type {
        get {
            return typeof (Observer);
        }
    }

    // Methods
    public Observer (ActionFunc<R> inFunc)
    {
        func = inFunc;
    }

    internal Observer.inherit ()
    {
    }

    public new virtual R
    notify (va_list inArgs)
    {
        return func ();
    }

    public override int
    compare (Object inOther)
    {
        int ret = 1;
        Observer other = (Observer)inOther;
        if (func == other.func && 
            (void*)(&func + sizeof (ActionFunc)) == (void*)(&other.func + sizeof (ActionFunc)))
            ret = 0;
        return ret;
    }
}

public class Maia.Observer1<R, A> : Observer<R>
{
    // Type
    public delegate R ActionFunc<R, A> (A inA);

    // Accessors
    public override Type object_type {
        get {
            return typeof (Observer1);
        }
    }

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
    notify (va_list inArgs)
    {
        A a = inArgs.arg ();
        if (a == null)
        {
            Observer.ActionFunc<R> callback = (Observer.ActionFunc<R>)func;
            return callback ();
        }

        ActionFunc<R, A> callback = (ActionFunc<R, A>)func;
        return callback (a);
    }
}

public class Maia.Observer2<R, A, B> : Observer<R>
{
    // Type
    public delegate R ActionFunc<R, A, B> (A inA, B inB);

    // Accessors
    public override Type object_type {
        get {
            return typeof (Observer2);
        }
    }

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
    notify (va_list inArgs)
    {
        A a = inArgs.arg ();
        if (a == null)
        {
            Observer.ActionFunc<R> callback = (Observer.ActionFunc<R>)func;
            return callback ();
        }

        B b = inArgs.arg ();
        if (b == null)
        {
            Observer1.ActionFunc<R, A> callback = (Observer1.ActionFunc<R, A>)func;
            return callback (a);
        }

        ActionFunc<R, A, B> callback = (ActionFunc<R, A, B>)func;

        return callback (a, b);
    }
}

public class Maia.Observer3<R, A, B, C> : Observer<R>
{
    // Type
    public delegate R ActionFunc<R, A, B, C> (A inA, B inB, C inC);

    // Accessors
    public override Type object_type {
        get {
            return typeof (Observer3);
        }
    }

    // Methods
    public Observer3 (ActionFunc<R, A, B, C> inFunc)
    {
        base.inherit ();
        func = (Observer.ActionFunc)inFunc;
    }

    public Observer3.bind (ActionFunc<R, A, B, C> inFunc, A inA, B inB, C inC)
    {
        base.inherit ();
        func = () => { return inFunc (inA, inB, inC); };
    }

    public Observer3.bind1 (ActionFunc<R, A, B, C> inFunc, C inC)
    {
        base.inherit ();
        Observer2.ActionFunc<R, A, B> callback = (a, b) => { return inFunc (a, b, inC); };
        func = (Observer.ActionFunc)callback;
    }

    public Observer3.bind2 (ActionFunc<R, A, B, C> inFunc, B inB, C inC)
    {
        base.inherit ();
        Observer1.ActionFunc<R, A> callback = (a) => { return inFunc (a, inB, inC); };
        func = (Observer.ActionFunc)callback;
    }

    public override R
    notify (va_list inArgs)
    {
        A a = inArgs.arg ();
        if (a == null)
        {
            Observer.ActionFunc<R> callback = (Observer.ActionFunc<R>)func;
            return callback ();
        }

        B b = inArgs.arg ();
        if (b == null)
        {
            Observer1.ActionFunc<R, A> callback = (Observer1.ActionFunc<R, A>)func;
            return callback (a);
        }

        C c = inArgs.arg ();
        if (c == null)
        {
            Observer2.ActionFunc<R, A, B> callback = (Observer2.ActionFunc<R, A, B>)func;
            return callback (a, b);
        }

        ActionFunc<R, A, B, C> callback = (ActionFunc<R, A, B, C>)func;

        return callback (a, b, c);
    }
}

public class Maia.Observer4<R, A, B, C, D> : Observer<R>
{
    // Type
    public delegate R ActionFunc<R, A, B, C, D> (A inA, B inB, C inC, D inD);

    // Accessors
    public override Type object_type {
        get {
            return typeof (Observer4);
        }
    }

    // Methods
    public Observer4 (ActionFunc<R, A, B, C, D> inFunc)
    {
        base.inherit ();
        func = (Observer.ActionFunc)inFunc;
    }

    public Observer4.bind (ActionFunc<R, A, B, C, D> inFunc, A inA, B inB, C inC, D inD)
    {
        base.inherit ();
        func = () => { return inFunc (inA, inB, inC, inD); };
    }

    public Observer4.bind1 (ActionFunc<R, A, B, C, D> inFunc, D inD)
    {
        base.inherit ();
        Observer3.ActionFunc<R, A, B, C> callback = (a, b, c) => { return inFunc (a, b, c, inD); };
        func = (Observer.ActionFunc)callback;
    }

    public Observer4.bind2 (ActionFunc<R, A, B, C, D> inFunc, C inC, D inD)
    {
        base.inherit ();
        Observer2.ActionFunc<R, A, B> callback = (a, b) => { return inFunc (a, b, inC, inD); };
        func = (Observer.ActionFunc)callback;
    }

    public Observer4.bind3 (ActionFunc<R, A, B, C, D> inFunc, B inB, C inC, D inD)
    {
        base.inherit ();
        Observer1.ActionFunc<R, A> callback = (a) => { return inFunc (a, inB, inC, inD); };
        func = (Observer.ActionFunc)callback;
    }

    public override R
    notify (va_list inArgs)
    {
        A a = inArgs.arg ();
        if (a == null)
        {
            Observer.ActionFunc<R> callback = (Observer.ActionFunc<R>)func;
            return callback ();
        }

        B b = inArgs.arg ();
        if (b == null)
        {
            Observer1.ActionFunc<R, A> callback = (Observer1.ActionFunc<R, A>)func;
            return callback (a);
        }

        C c = inArgs.arg ();
        if (c == null)
        {
            Observer2.ActionFunc<R, A, B> callback = (Observer2.ActionFunc<R, A, B>)func;
            return callback (a, b);
        }

        D d = inArgs.arg ();
        if (d == null)
        {
            Observer3.ActionFunc<R, A, B, C> callback = (Observer3.ActionFunc<R, A, B, C>)func;
            return callback (a, b, c);
        }

        ActionFunc<R, A, B, C, D> callback = (ActionFunc<R, A, B, C, D>)func;

        return callback (a, b, c, d);
    }
}

public class Maia.Observer5<R, A, B, C, D, E> : Observer<R>
{
    // Type
    public delegate R ActionFunc<R, A, B, C, D, E> (A inA, B inB, C inC, D inD, E inE);

    // Accessors
    public override Type object_type {
        get {
            return typeof (Observer5);
        }
    }

    // Methods
    public Observer5 (ActionFunc<R, A, B, C, D, E> inFunc)
    {
        base.inherit ();
        func = (Observer.ActionFunc)inFunc;
    }

    public Observer5.bind (ActionFunc<R, A, B, C, D, E> inFunc, A inA, B inB, C inC, D inD, E inE)
    {
        base.inherit ();
        func = () => { return inFunc (inA, inB, inC, inD, inE); };
    }

    public Observer5.bind1 (ActionFunc<R, A, B, C, D, E> inFunc, E inE)
    {
        base.inherit ();
        Observer4.ActionFunc<R, A, B, C, D> callback = (a, b, c, d) => { return inFunc (a, b, c, d, inE); };
        func = (Observer.ActionFunc)callback;
    }

    public Observer5.bind2 (ActionFunc<R, A, B, C, D, E> inFunc, D inD, E inE)
    {
        base.inherit ();
        Observer3.ActionFunc<R, A, B, C> callback = (a, b, c) => { return inFunc (a, b, c, inD, inE); };
        func = (Observer.ActionFunc)callback;
    }

    public Observer5.bind3 (ActionFunc<R, A, B, C, D, E> inFunc, C inC, D inD, E inE)
    {
        base.inherit ();
        Observer2.ActionFunc<R, A, B> callback = (a, b) => { return inFunc (a, b, inC, inD, inE); };
        func = (Observer.ActionFunc)callback;
    }

    public Observer5.bind4 (ActionFunc<R, A, B, C, D, E> inFunc, B inB, C inC, D inD, E inE)
    {
        base.inherit ();
        Observer1.ActionFunc<R, A> callback = (a) => { return inFunc (a, inB, inC, inD, inE); };
        func = (Observer.ActionFunc)callback;
    }

    public override R
    notify (va_list inArgs)
    {
        A a = inArgs.arg ();
        if (a == null)
        {
            Observer.ActionFunc<R> callback = (Observer.ActionFunc<R>)func;
            return callback ();
        }

        B b = inArgs.arg ();
        if (b == null)
        {
            Observer1.ActionFunc<R, A> callback = (Observer1.ActionFunc<R, A>)func;
            return callback (a);
        }

        C c = inArgs.arg ();
        if (c == null)
        {
            Observer2.ActionFunc<R, A, B> callback = (Observer2.ActionFunc<R, A, B>)func;
            return callback (a, b);
        }

        D d = inArgs.arg ();
        if (d == null)
        {
            Observer3.ActionFunc<R, A, B, C> callback = (Observer3.ActionFunc<R, A, B, C>)func;
            return callback (a, b, c);
        }

        E e = inArgs.arg ();
        if (e == null)
        {
            Observer4.ActionFunc<R, A, B, C, D> callback = (Observer4.ActionFunc<R, A, B, C, D>)func;
            return callback (a, b, c, d);
        }

        ActionFunc<R, A, B, C, D, E> callback = (ActionFunc<R, A, B, C, D, E>)func;

        return callback (a, b, c, d, e);
    }
}

public class Maia.Observer6<R, A, B, C, D, E, F> : Observer<R>
{
    // Type
    public delegate R ActionFunc<R, A, B, C, D, E, F> (A inA, B inB, C inC, D inD, E inE, F inF);

    // Accessors
    public override Type object_type {
        get {
            return typeof (Observer6);
        }
    }

    // Methods
    public Observer6 (ActionFunc<R, A, B, C, D, E, F> inFunc)
    {
        base.inherit ();
        func = (Observer.ActionFunc)inFunc;
    }

    public Observer6.bind (ActionFunc<R, A, B, C, D, E, F> inFunc, A inA, B inB, C inC, D inD, E inE, F inF)
    {
        base.inherit ();
        func = () => { return inFunc (inA, inB, inC, inD, inE, inF); };
    }

    public Observer6.bind1 (ActionFunc<R, A, B, C, D, E, F> inFunc, F inF)
    {
        base.inherit ();
        Observer5.ActionFunc<R, A, B, C, D, E> callback = (a, b, c, d, e) => { return inFunc (a, b, c, d, e, inF); };
        func = (Observer.ActionFunc)callback;
    }

    public Observer6.bind2 (ActionFunc<R, A, B, C, D, E, F> inFunc, E inE, F inF)
    {
        base.inherit ();
        Observer4.ActionFunc<R, A, B, C, D> callback = (a, b, c, d) => { return inFunc (a, b, c, d, inE, inF); };
        func = (Observer.ActionFunc)callback;
    }

    public Observer6.bind3 (ActionFunc<R, A, B, C, D, E, F> inFunc, D inD, E inE, F inF)
    {
        base.inherit ();
        Observer3.ActionFunc<R, A, B, C> callback = (a, b, c) => { return inFunc (a, b, c, inD, inE, inF); };
        func = (Observer.ActionFunc)callback;
    }

    public Observer6.bind4 (ActionFunc<R, A, B, C, D, E, F> inFunc, C inC, D inD, E inE, F inF)
    {
        base.inherit ();
        Observer2.ActionFunc<R, A, B> callback = (a, b) => { return inFunc (a, b, inC, inD, inE, inF); };
        func = (Observer.ActionFunc)callback;
    }

    public Observer6.bind5 (ActionFunc<R, A, B, C, D, E, F> inFunc, B inB, C inC, D inD, E inE, F inF)
    {
        base.inherit ();
        Observer1.ActionFunc<R, A> callback = (a) => { return inFunc (a, inB, inC, inD, inE, inF); };
        func = (Observer.ActionFunc)callback;
    }

    public override R
    notify (va_list inArgs)
    {
        A a = inArgs.arg ();
        if (a == null)
        {
            Observer.ActionFunc<R> callback = (Observer.ActionFunc<R>)func;
            return callback ();
        }

        B b = inArgs.arg ();
        if (b == null)
        {
            Observer1.ActionFunc<R, A> callback = (Observer1.ActionFunc<R, A>)func;
            return callback (a);
        }

        C c = inArgs.arg ();
        if (c == null)
        {
            Observer2.ActionFunc<R, A, B> callback = (Observer2.ActionFunc<R, A, B>)func;
            return callback (a, b);
        }

        D d = inArgs.arg ();
        if (d == null)
        {
            Observer3.ActionFunc<R, A, B, C> callback = (Observer3.ActionFunc<R, A, B, C>)func;
            return callback (a, b, c);
        }

        E e = inArgs.arg ();
        if (e == null)
        {
            Observer4.ActionFunc<R, A, B, C, D> callback = (Observer4.ActionFunc<R, A, B, C, D>)func;
            return callback (a, b, c, d);
        }

        F f = inArgs.arg ();
        if (f == null)
        {
            Observer5.ActionFunc<R, A, B, C, D, E> callback = (Observer5.ActionFunc<R, A, B, C, D, E>)func;
            return callback (a, b, c, d, e);
        }

        ActionFunc<R, A, B, C, D, E, F> callback = (ActionFunc<R, A, B, C, D, E, F>)func;

        return callback (a, b, c, d, e, f);
    }
}

public class Maia.Observer7<R, A, B, C, D, E, F, G> : Observer<R>
{
    // Type
    public delegate R ActionFunc<R, A, B, C, D, E, F, G> (A inA, B inB, C inC, D inD, E inE, F inF, G inG);

    // Accessors
    public override Type object_type {
        get {
            return typeof (Observer7);
        }
    }

    // Methods
    public Observer7 (ActionFunc<R, A, B, C, D, E, F, G> inFunc)
    {
        base.inherit ();
        func = (Observer.ActionFunc)inFunc;
    }

    public Observer7.bind (ActionFunc<R, A, B, C, D, E, F, G> inFunc, A inA, B inB, C inC, D inD, E inE, F inF, G inG)
    {
        base.inherit ();
        func = () => { return inFunc (inA, inB, inC, inD, inE, inF, inG); };
    }

    public Observer7.bind1 (ActionFunc<R, A, B, C, D, E, F, G> inFunc, G inG)
    {
        base.inherit ();
        Observer6.ActionFunc<R, A, B, C, D, E, F> callback = (a, b, c, d, e, f) => { return inFunc (a, b, c, d, e, f, inG); };
        func = (Observer.ActionFunc)callback;
    }

    public Observer7.bind2 (ActionFunc<R, A, B, C, D, E, F, G> inFunc, F inF, G inG)
    {
        base.inherit ();
        Observer5.ActionFunc<R, A, B, C, D, E> callback = (a, b, c, d, e) => { return inFunc (a, b, c, d, e, inF, inG); };
        func = (Observer.ActionFunc)callback;
    }

    public Observer7.bind3 (ActionFunc<R, A, B, C, D, E, F, G> inFunc, E inE, F inF, G inG)
    {
        base.inherit ();
        Observer4.ActionFunc<R, A, B, C, D> callback = (a, b, c, d) => { return inFunc (a, b, c, d, inE, inF, inG); };
        func = (Observer.ActionFunc)callback;
    }

    public Observer7.bind4 (ActionFunc<R, A, B, C, D, E, F, G> inFunc, D inD, E inE, F inF, G inG)
    {
        base.inherit ();
        Observer3.ActionFunc<R, A, B, C> callback = (a, b, c) => { return inFunc (a, b, c, inD, inE, inF, inG); };
        func = (Observer.ActionFunc)callback;
    }

    public Observer7.bind5 (ActionFunc<R, A, B, C, D, E, F, G> inFunc, C inC, D inD, E inE, F inF, G inG)
    {
        base.inherit ();
        Observer2.ActionFunc<R, A, B> callback = (a, b) => { return inFunc (a, b, inC, inD, inE, inF, inG); };
        func = (Observer.ActionFunc)callback;
    }

    public Observer7.bind6 (ActionFunc<R, A, B, C, D, E, F, G> inFunc, B inB, C inC, D inD, E inE, F inF, G inG)
    {
        base.inherit ();
        Observer1.ActionFunc<R, A> callback = (a) => { return inFunc (a, inB, inC, inD, inE, inF, inG); };
        func = (Observer.ActionFunc)callback;
    }

    public override R
    notify (va_list inArgs)
    {
        A a = inArgs.arg ();
        if (a == null)
        {
            Observer.ActionFunc<R> callback = (Observer.ActionFunc<R>)func;
            return callback ();
        }

        B b = inArgs.arg ();
        if (b == null)
        {
            Observer1.ActionFunc<R, A> callback = (Observer1.ActionFunc<R, A>)func;
            return callback (a);
        }

        C c = inArgs.arg ();
        if (c == null)
        {
            Observer2.ActionFunc<R, A, B> callback = (Observer2.ActionFunc<R, A, B>)func;
            return callback (a, b);
        }

        D d = inArgs.arg ();
        if (d == null)
        {
            Observer3.ActionFunc<R, A, B, C> callback = (Observer3.ActionFunc<R, A, B, C>)func;
            return callback (a, b, c);
        }

        E e = inArgs.arg ();
        if (e == null)
        {
            Observer4.ActionFunc<R, A, B, C, D> callback = (Observer4.ActionFunc<R, A, B, C, D>)func;
            return callback (a, b, c, d);
        }

        F f = inArgs.arg ();
        if (f == null)
        {
            Observer5.ActionFunc<R, A, B, C, D, E> callback = (Observer5.ActionFunc<R, A, B, C, D, E>)func;
            return callback (a, b, c, d, e);
        }

        G g = inArgs.arg ();
        if (g == null)
        {
            Observer6.ActionFunc<R, A, B, C, D, E, F> callback = (Observer6.ActionFunc<R, A, B, C, D, E, F>)func;
            return callback (a, b, c, d, e, f);
        }

        ActionFunc<R, A, B, C, D, E, F, G> callback = (ActionFunc<R, A, B, C, D, E, F, G>)func;

        return callback (a, b, c, d, e, f, g);
    }
}