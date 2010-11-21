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
    public delegate R ActionFunc<R> (void* inTarget);

    public class Bind1<R, Z> : Observer<R>
    {
        [CCode (has_target = false)]
        public delegate R ActionFunc<R, Z> (void* inTarget, Z inArgs1);

        private Z m_Args1;

        public Bind1 (ActionFunc<R, Z> inFunc, void* inTarget, Z inArgs1)
        {
            base ((Observer.ActionFunc)inFunc, inTarget);
            m_Args1 = inArgs1;
        }

        public override R
        notify (void* inOwner, va_list inArgs)
        {
            ActionFunc<R, Z> callback = (ActionFunc<R, Z>)func;
            return callback (target, m_Args1);
        }
    }

    public class Bind2<R, Z, Y> : Observer<R>
    {
        [CCode (has_target = false)]
        public delegate R ActionFunc<R, Z, Y> (void* inTarget, Z inArgs1, Y inArgs2);

        private Z m_Args1;
        private Y m_Args2;

        public Bind2 (ActionFunc<R, Z, Y> inFunc, void* inTarget, Z inArgs1, Y inArgs2)
        {
            base ((Observer.ActionFunc)inFunc, inTarget);
            m_Args1 = inArgs1;
            m_Args2 = inArgs2;
        }

        public override R
        notify (void* inOwner, va_list inArgs)
        {
            ActionFunc<R, Z, Y> callback = (ActionFunc<R, Z, Y>)func;
            return callback (target, m_Args1, m_Args2);
        }
    }

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
        return func (target);
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
    public delegate R ActionFunc<R, A> (void* inTarget, A inA);

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

        return callback (target, args1);
    }
}

public class Maia.Observer2<R, A, B> : Observer<R>
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R, A, B> (void* inTarget, A inA, B inB);

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

        return callback (target, args1, args2);
    }
}

public class Maia.Observer3<R, A, B, C> : Observer<R>
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R, A, B, C> (void* inTarget, A inA, B inB, C inC);

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

        return callback (target, args1, args2, args3);
    }
}

public class Maia.Observer4<R, A, B, C, D> : Observer<R>
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R, A, B, C, D> (void* inTarget, A inA, B inB, C inC, D inD);

    // Methods
    public Observer4 (ActionFunc<R, A, B, C, D> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override R
    notify (void* inOwner, va_list inArgs)
    {
        ActionFunc<R, A, B, C, D> callback = (ActionFunc<R, A, B, C, D>)func;
        A args1 = inArgs.arg ();
        B args2 = inArgs.arg ();
        C args3 = inArgs.arg ();
        D args4 = inArgs.arg ();

        return callback (target, args1, args2, args3, args4);
    }
}

public class Maia.Observer5<R, A, B, C, D, E> : Observer<R>
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R, A, B, C, D, E> (void* inTarget, A inA, B inB, C inC, D inD, E inE);

    // Methods
    public Observer5 (ActionFunc<R, A, B, C, D, E> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override R
    notify (void* inOwner, va_list inArgs)
    {
        ActionFunc<R, A, B, C, D, E> callback = (ActionFunc<R, A, B, C, D, E>)func;
        A args1 = inArgs.arg ();
        B args2 = inArgs.arg ();
        C args3 = inArgs.arg ();
        D args4 = inArgs.arg ();
        E args5 = inArgs.arg ();

        return callback (target, args1, args2, args3, args4, args5);
    }
}

public class Maia.Observer6<R, A, B, C, D, E, F> : Observer<R>
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R, A, B, C, D, E, F> (void* inTarget, A inA, B inB, 
                                                       C inC, D inD, E inE, F inF);

    // Methods
    public Observer6 (ActionFunc<R, A, B, C, D, E, F> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override R
    notify (void* inOwner, va_list inArgs)
    {
        ActionFunc<R, A, B, C, D, E, F> callback = (ActionFunc<R, A, B, C, D, E, F>)func;
        A args1 = inArgs.arg ();
        B args2 = inArgs.arg ();
        C args3 = inArgs.arg ();
        D args4 = inArgs.arg ();
        E args5 = inArgs.arg ();
        F args6 = inArgs.arg ();

        return callback (target, args1, args2, args3, args4, args5, args6);
    }
}

public class Maia.Observer7<R, A, B, C, D, E, F, G> : Observer<R>
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R, A, B, C, D, E, F, G> (void* inTarget, A inA, B inB, 
                                                          C inC, D inD, E inE, F inF, G inG);

    // Methods
    public Observer7 (ActionFunc<R, A, B, C, D, E, F, G> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override R
    notify (void* inOwner, va_list inArgs)
    {
        ActionFunc<R, A, B, C, D, E, F, G> callback = (ActionFunc<R, A, B, C, D, E, F, G>)func;
        A args1 = inArgs.arg ();
        B args2 = inArgs.arg ();
        C args3 = inArgs.arg ();
        D args4 = inArgs.arg ();
        E args5 = inArgs.arg ();
        F args6 = inArgs.arg ();
        G args7 = inArgs.arg ();

        return callback (target, args1, args2, args3, args4, args5, args6, args7);
    }
}
