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

public abstract class Maia.Observer
{
    // types
    [CCode (has_target = false)]
    public delegate void ActionFunc (void* inTarget);

    public abstract class Args
    {
    }

    // Properties
    private ActionFunc   m_Func;
    private void*        m_pTarget;

    // Accessors
    public ActionFunc func {
        get {
            return m_Func;
        }
    }

    public void* target {
        get {
            return m_pTarget;
        }
    }

    // Methods
    public Observer (ActionFunc inFunc, void* inTarget)
    {
        m_Func = inFunc;
        m_pTarget = inTarget;
    }

    public abstract void notify (Args? inArgs = null);

    internal bool
    equals (Observer inOther)
    {
        return m_Func == inOther.m_Func && m_pTarget == inOther.m_pTarget;
    }
}

public class Maia.Observer0 : Observer
{
    // types
    [CCode (has_target = false)]
    public delegate void ActionFunc (void* inTarget);

    public class Args : Observer.Args
    {
    }

    // Methods
    public Observer0 (ActionFunc inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override void
    notify (Observer.Args? inArgs = null)
    {
        ActionFunc callback = (ActionFunc)func;

        callback (target);
    }
}

public class Maia.ObserverR0<R> : Observer
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R> (void* inTarget);

    public class Args<R> : Observer.Args
    {
        private R m_ReturnVal;
        internal AccumulateFunc accumulator;

        public R return_val {
            get {
                return m_ReturnVal;
            }
            set {
                m_ReturnVal = accumulator == null ? value : accumulator (m_ReturnVal, value);
            }
        }

        public Args (AccumulateFunc? inFunc = null)
        {
            accumulator = inFunc;
        }
    }

    // Methods
    public ObserverR0 (ActionFunc<R> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override void
    notify (Observer.Args? inArgs = null)
    {
        unowned Args<R> args = inArgs == null ? new Args<R> () : (Args<R>)inArgs;
        ActionFunc<R> callback = (ActionFunc)func;

        args.return_val = callback (target);
    }
}

public class Maia.Observer1<A> : Observer
{
    // types
    [CCode (has_target = false)]
    public delegate void ActionFunc<A> (void* inTarget, A inArgs1);

    public class Args<A> : Observer.Args
    {
        public A args1;

        public Args (A inArgs1)
        {
            args1 = inArgs1;
        }
    }

    // Methods
    public Observer1 (ActionFunc<A> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override void
    notify (Observer.Args? inArgs = null)
        requires (inArgs != null)
    {
        unowned Args<A> args = (Args<A>)inArgs;
        ActionFunc<A> callback = (ActionFunc<A>)func;

        callback (target, args.args1);
    }
}

public class Maia.ObserverR1<R, A> : Observer
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R, A> (void* inTarget, A inArgs1);

    public class Args<R, A> : ObserverR0.Args<R>
    {
        public A args1;

        public Args (A inArgs1, AccumulateFunc? inFunc = null)
        {
            base (inFunc);
            args1 = inArgs1;
        }
    }

    // Methods
    public ObserverR1 (ActionFunc<R, A> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override void
    notify (Observer.Args? inArgs = null)
        requires (inArgs != null)
    {
        unowned Args<R, A> args = (Args<R, A>)inArgs;
        ActionFunc<R, A> callback = (ActionFunc<R, A>)func;

        args.return_val = callback (target, args.args1);
    }
}

public class Maia.Observer2<A, B> : Observer
{
    // types
    [CCode (has_target = false)]
    public delegate void ActionFunc<A, B> (void* inTarget, A inArgs1, B inArgs2);

    public class Args<A, B> : Observer.Args
    {
        public A args1;
        public B args2;

        public Args (A inArgs1, B inArgs2)
        {
            args1 = inArgs1;
            args2 = inArgs2;
        }
    }

    // Methods
    public Observer2 (ActionFunc<A, B> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override void
    notify (Observer.Args? inArgs = null)
        requires (inArgs != null)
    {
        unowned Args<A, B> args = (Args<A, B>)inArgs;
        ActionFunc<A, B> callback = (ActionFunc<A, B>)func;

        callback (target, args.args1, args.args2);
    }
}

public class Maia.ObserverR2<R, A, B> : Observer
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R, A, B> (void* inTarget, A inArgs1, B inArgs2);

    public class Args<R, A, B> : ObserverR0.Args<R>
    {
        public A args1;
        public B args2;

        public Args (A inArgs1, B inArgs2, AccumulateFunc? inFunc = null)
        {
            base (inFunc);
            args1 = inArgs1;
            args2 = inArgs2;
        }
    }

    // Methods
    public ObserverR2 (ActionFunc<R, A, B> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override void
    notify (Observer.Args? inArgs = null)
        requires (inArgs != null)
    {
        unowned Args<R, A, B> args = (Args<R, A, B>)inArgs;
        ActionFunc<R, A, B> callback = (ActionFunc<R, A, B>)func;

        args.return_val = callback (target, args.args1, args.args2);
    }
}

public class Maia.Observer3<A, B, C> : Observer
{
    // types
    [CCode (has_target = false)]
    public delegate void ActionFunc<A, B, C> (void* inTarget, A inArgs1,
                                              B inArgs2, C inArgs3);

    public class Args<A, B, C> : Observer.Args
    {
        public A args1;
        public B args2;
        public C args3;

        public Args (A inArgs1, B inArgs2, C inArgs3)
        {
            args1 = inArgs1;
            args2 = inArgs2;
            args3 = inArgs3;
        }
    }

    // Methods
    public Observer3 (ActionFunc<A, B, C> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override void
    notify (Observer.Args? inArgs = null)
        requires (inArgs != null)
    {
        unowned Args<A, B, C> args = (Args<A, B, C>)inArgs;
        ActionFunc<A, B, C> callback = (ActionFunc<A, B, C>)func;

        callback (target, args.args1, args.args2, args.args3);
    }
}

public class Maia.ObserverR3<R, A, B, C> : Observer
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R, A, B, C> (void* inTarget, A inArgs1,
                                              B inArgs2, C inArgs3);

    public class Args<R, A, B, C> : ObserverR0.Args<R>
    {
        public A args1;
        public B args2;
        public C args3;

        public Args (A inArgs1, B inArgs2, C inArgs3, AccumulateFunc? inFunc = null)
        {
            base (inFunc);
            args1 = inArgs1;
            args2 = inArgs2;
            args3 = inArgs3;
        }
    }

    // Methods
    public ObserverR3 (ActionFunc<R, A, B, C> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override void
    notify (Observer.Args? inArgs = null)
        requires (inArgs != null)
    {
        unowned Args<R, A, B, C> args = (Args<R, A, B, C>)inArgs;
        ActionFunc<R, A, B, C> callback = (ActionFunc<R, A, B, C>)func;

        args.return_val = callback (target, args.args1, args.args2, args.args3);
    }
}