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

    public class Args<R>
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
            accumulator = inFunc == null ? get_accumulator_func_for<R> () : inFunc;
        }
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
    public Observer (ActionFunc<R> inFunc, void* inTarget)
    {
        m_Func = inFunc;
        m_pTarget = inTarget;
    }

    public virtual void notify (Args<R>? inArgs = null)
    {
        if (inArgs != null)
            inArgs.return_val = func (target);
        else
            func (target);
    }

    internal bool
    equals (Observer inOther)
    {
        return m_Func == inOther.m_Func && m_pTarget == inOther.m_pTarget;
    }
}

public class Maia.Observer1<R, A> : Observer<R>
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R, A> (void* inTarget, A inArgs1);

    public class Args<R, A> : Observer.Args<R>
    {
        public A args1;

        public Args (A inArgs1, AccumulateFunc? inFunc = null)
        {
            base (inFunc);

            args1 = inArgs1;
        }
    }

    // Methods
    public Observer1 (ActionFunc<R, A> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override void
    notify (Observer.Args<R>? inArgs = null)
        requires (inArgs != null)
    {
        unowned Args<R, A> args = (Args<R, A>)inArgs;
        ActionFunc<R, A> callback = (ActionFunc<R, A>)func;

        args.return_val = callback (target, args.args1);
    }
}

public class Maia.Observer2<R, A, B> : Observer<R>
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R, A, B> (void* inTarget, A inArgs1, B inArgs2);

    public class Args<R, A, B> : Observer.Args<R>
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
    public Observer2 (ActionFunc<R, A, B> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override void
    notify (Observer.Args<R>? inArgs = null)
        requires (inArgs != null)
    {
        unowned Args<R, A, B> args = (Args<R, A, B>)inArgs;
        ActionFunc<R, A, B> callback = (ActionFunc<R, A, B>)func;

        args.return_val = callback (target, args.args1, args.args2);
    }
}

public class Maia.Observer3<R, A, B, C> : Observer<R>
{
    // types
    [CCode (has_target = false)]
    public delegate R ActionFunc<R, A, B, C> (void* inTarget, A inArgs1,
                                              B inArgs2, C inArgs3);

    public class Args<R, A, B, C> : Observer.Args<R>
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
    public Observer3 (ActionFunc<R, A, B, C> inFunc, void* inTarget)
    {
        base ((Observer.ActionFunc)inFunc, inTarget);
    }

    public override void
    notify (Observer.Args<R>? inArgs = null)
        requires (inArgs != null)
    {
        unowned Args<R, A, B, C> args = (Args<R, A, B, C>)inArgs;
        ActionFunc<R, A, B, C> callback = (ActionFunc<R, A, B, C>)func;

        args.return_val = callback (target, args.args1, args.args2, args.args3);
    }
}