/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * token.vala
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

public class Maia.Token : GLib.Object
{
    // types
    private class ThreadTokenNode
    {
        public unowned Token?           m_Token;
        public ulong                    m_Ref;

        public ThreadTokenNode (Token inToken)
        {
            m_Token = inToken;
        }
    }

    private class Thread : GLib.Object
    {
        public uint32                 m_Id;
        public Array<ThreadTokenNode> m_Tokens = null;

        public Thread (GLib.Thread<void*> inThreadId)
        {
            m_Id = (uint32)inThreadId;
            m_Tokens = new Array<ThreadTokenNode> ();
        }

        public void
        add_token (Token inToken)
        {
            ThreadTokenNode node = new ThreadTokenNode (inToken);
            m_Tokens.insert (node);
        }

        public void
        remove_token (Token inToken)
        {
            foreach (unowned ThreadTokenNode node in m_Tokens)
            {
                if (node.m_Token.m_Id == inToken.m_Id)
                {
                    m_Tokens.remove (node);
                    break;
                }
            }
        }

        public void
        sleep ()
        {
            foreach (unowned ThreadTokenNode node in m_Tokens)
            {
                ulong current_ref = node.m_Token.m_Ref;
                if ((uint32)(current_ref >> 32) == m_Id)
                {
                    node.m_Ref = current_ref;
                    Os.Atomic.ulong_compare_and_exchange (&node.m_Token.m_Ref, current_ref, 0);
                }
            }
        }

        public bool
        wake_up ()
        {
            foreach (unowned ThreadTokenNode node in m_Tokens)
            {
                if (!Os.Atomic.ulong_compare_and_exchange (&node.m_Token.m_Ref, 0, node.m_Ref))
                    return false;
            }

            return true;
        }
    }

    private class Pool : GLib.Object
    {
        // properties
        private GLib.Private        m_Private;
        private Set<Token>          m_Tokens;
        private SpinLock            m_TokensSpin;

        // methods
        public Pool ()
        {
            m_Private = new GLib.Private (GLib.Object.unref);
            m_Tokens = new Set<Token> ();
            m_Tokens.compare_func = (CompareFunc<unowned Token>)Token.compare;
            m_TokensSpin = SpinLock ();
        }

        public inline unowned Thread?
        current_thread ()
        {
            unowned GLib.Thread<void*> self = GLib.Thread.self<void*> ();
            unowned Thread? thread = (Thread?)m_Private.get ();

            if (thread == null)
            {
                Thread new_thread = new Thread (self);
                m_Private.set (new_thread.ref ());
                thread = new_thread;
            }
            return thread;
        }

        public inline Token
        get_token (ulong inTokenId)
        {
            Token token = null;

            m_TokensSpin.lock ();
            {
                token = m_Tokens.search<ulong> (inTokenId, (t, i) => {
                    return (int)(t.m_Id - i);
                });

                if (token == null)
                {
                    token = new Token (inTokenId);
                    m_Tokens.insert (token);
                }
            }
            m_TokensSpin.unlock ();

            return token;
        }

        public void
        remove_token (Token inToken)
        {
            m_TokensSpin.lock ();
            {
                m_Tokens.remove (inToken);
            }
            m_TokensSpin.unlock ();
        }
    }

    // static properties
    private static Pool s_Pool;

    // properties
    private ulong     m_Id;
    private ulong     m_Ref = 0;

    // static methods
    public static new Token
    get (ulong inTokenId)
    {
        Token token = null;

        if (Os.Atomic.pointer_compare (s_Pool, null))
        {
            Object.atomic_compare_and_exchange (&s_Pool, null, new Pool ());
        }
        token = s_Pool.get_token (inTokenId);

        return token;
    }

    public static Token
    get_for_class (void* inClass)
    {
        ulong id = (ulong)inClass;

        Token token = get (id);
        token.acquire ();

        return token;
    }

    public static Token
    get_for_object (Object inObject)
    {
        ulong id = (ulong)inObject;

        if (id != 0)
        {
            unowned Object? delegator = inObject.delegator;
            if (delegator != null)
            {
                id = (ulong)delegator;
            }
        }

        Token token = get (id);
        token.acquire ();

        return token;
    }

    // methods
    internal Token (ulong inId)
    {
        m_Id = inId;
    }

    ~Token ()
    {
        s_Pool.remove_token (this);
    }

    internal int
    compare (Token inOther)
    {
        return (int)(m_Id - inOther.m_Id);
    }

    public void
    acquire ()
    {
        unowned Thread? self = s_Pool.current_thread ();

        while (true)
        {
            ulong current_ref = m_Ref;

            if (current_ref == 0)
            {
                ulong new_ref = ((ulong)self.m_Id << 32) + 1;
                if (Os.Atomic.ulong_compare_and_exchange (&m_Ref, 0, new_ref))
                {
                    self.add_token (this);
                    break;
                }
                continue;
            }

            if ((uint32)(current_ref >> 32) == self.m_Id)
            {
                ulong new_ref = current_ref + 1;
                if (Os.Atomic.ulong_compare_and_exchange (&m_Ref, current_ref, new_ref))
                {
                    break;
                }
                continue;
            }

            self.sleep ();

            while (!Os.Atomic.ulong_compare_and_exchange(&m_Ref, 0, ((ulong)self.m_Id << 32) + 1))
            {
                Os.Cpu.relax ();
                Os.Cpu.relax ();
            }
            if (self.wake_up ())
                break;
        }
    }

    public void
    release ()
    {
        unowned Thread? self = s_Pool.current_thread ();
        ulong current_ref = m_Ref;

        if (self.m_Id == (uint32)(current_ref >> 32))
        {
            int32 depth = (int32)((current_ref << 32) >> 32) - 1;

            if (depth <= 0)
            {
                self.remove_token (this);
                Os.Atomic.ulong_compare_and_exchange (&m_Ref, current_ref, 0);
            }
            else
            {
                Os.Atomic.ulong_compare_and_exchange (&m_Ref, current_ref, ((ulong)self.m_Id << 32) + (ulong)depth);
            }
        }
    }
}
