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
    private struct ThreadTokenNode
    {
        public unowned Token?           m_Token;
        public int                      m_Depth;
        public unowned ThreadTokenNode? m_Prev;
        public ThreadTokenNode?         m_Next;

        public ThreadTokenNode (Token inToken)
        {
            m_Token = inToken;
        }
    }

    private class Thread : GLib.Object
    {
        public uint32                   m_Id;
        public ThreadTokenNode?         m_Head = null;
        public unowned ThreadTokenNode? m_Tail = null;

        public Thread (GLib.Thread<void*> inThreadId)
        {
            m_Id = (uint32)inThreadId;
        }

        public void
        add_token (Token inToken)
        {
            if (m_Head == null)
            {
                m_Head = ThreadTokenNode (inToken);
                m_Tail = m_Head;
            }
            else
            {
                m_Tail.m_Next = ThreadTokenNode (inToken);
                m_Tail.m_Next.m_Prev = m_Tail;
                m_Tail = m_Tail.m_Next;
            }
        }

        public void
        remove_token (Token inToken)
        {
            for (unowned ThreadTokenNode? node = m_Head; node != null; node = node.m_Next)
            {
                if (node.m_Token.m_Id == inToken.m_Id)
                {
                    if (node.m_Prev == null)
                    {
                        m_Head = node.m_Next;
                    }
                    else
                    {
                        node.m_Prev.m_Next = node.m_Next;
                    }

                    if (node.m_Next == null)
                    {
                        m_Tail = node.m_Prev;
                    }

                    break;
                }
            }
        }

        public void
        sleep (Token inToken)
        {
            for (unowned ThreadTokenNode? node = m_Head; node != null; node = node.m_Next)
            {
                if (node.m_Token.m_Id != inToken.m_Id &&
                    Os.Atomic.pointer_compare_and_exchange (&node.m_Token.m_Ref, this, null))
                {
                    do
                    {
                        node.m_Depth = node.m_Token.m_Depth;
                    } while (!Os.Atomic.int_compare_and_exchange (&node.m_Token.m_Depth, node.m_Depth, 0));

                    message ("sleep: 0x%lx", (ulong)GLib.Thread.self<void*> ());
                    if (node.m_Token.m_SpinLocked != 0)
                        node.m_Token.m_Spin.unlock ();
                }
            }
        }

        public void
        wake_up ()
        {
            for (unowned ThreadTokenNode? node = m_Head; node != null; node = node.m_Next)
            {
                if (Os.Atomic.pointer_compare_and_exchange (&node.m_Token.m_Ref, null, this))
                {
                    Os.Atomic.int_fetch_and_add (ref node.m_Token.m_Depth, node.m_Depth);
                }
            }
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
        get_token (uint32 inTokenId)
        {
            Token token = null;

            m_TokensSpin.lock ();
            {
                token = m_Tokens.search<uint32> (inTokenId, (t, i) => {
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
    private uint32          m_Id;
    private unowned Thread? m_Ref = null;
    private int             m_Depth = 0;
    private SpinLock        m_Spin;
    private ushort          m_SpinLocked = 0;
 

    // static methods
    public static new Token
    get (uint32 inTokenId)
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
        uint32 id = (uint32)inClass;

        Token token = get (id);
        token.acquire ();

        return token;
    }

    public static Token
    get_for_object (Object inObject)
    {
        uint32 id = (uint32)inObject;

        if (id != 0)
        {
            unowned Object? delegator = inObject.delegator;
            if (delegator != null)
            {
                id = (uint32)delegator;
            }
        }

        Token token = get (id);
        token.acquire ();

        return token;
    }

    // methods
    internal Token (uint32 inId)
    {
        m_Id = inId;
        m_Spin = SpinLock ();
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
            Os.Memory.barrier ();
            unowned Thread? ref = m_Ref;

            if (ref == null)
            {
                if (Os.Atomic.pointer_compare_and_exchange (&m_Ref, null, self))
                {
                    self.add_token (this);
                    break;
                }
                continue;
            }

            if (ref == self)
            {
                Os.Atomic.int_inc (ref m_Depth);
                break;
            }

            self.sleep (this);
            message ("acquire: 0x%lx", (ulong)GLib.Thread.self<void*> ());
            m_SpinLocked = m_Spin.lock ();
            self.wake_up ();
        }
    }

    public void
    release ()
    {
        unowned Thread? self = s_Pool.current_thread ();

        if (self == m_Ref && !Os.Atomic.int_compare (m_Depth, 0))
        {
            int depth = 0;

            do
            {
                depth = m_Depth;
                if (depth == 0) break;
            } while (!Os.Atomic.int_compare_and_exchange (&m_Depth, depth, depth - 1));

            if (depth == 0)
            {
                if (Os.Atomic.pointer_compare_and_exchange (&m_Ref, self, null))
                {
                    self.remove_token (this);

                    message ("release: 0x%lx", (ulong)GLib.Thread.self<void*> ());
                    if (m_SpinLocked != 0)
                    {
                        m_Spin.unlock ();
                    }
                }
            }
        }
    }
}
