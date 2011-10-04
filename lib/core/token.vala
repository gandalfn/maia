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
    private class Thread : GLib.Object
    {
        // types
        private struct Node
        {
            public unowned Token? m_Token;
            public ulong          m_Ref;

            public int
            compare (Node? inNode)
            {
                return m_Token.compare (inNode.m_Token);
            }
        }

        // properties
        public uint32        m_Id;
        private Array<Node?> m_Tokens;

        // methods
        public Thread ()
        {
            m_Id = Os.gettid ();
            m_Tokens = new Array<Node?> ();
            m_Tokens.compare_func = Node.compare;
        }

        public inline void
        add_token (Token inToken)
        {
            Node node = {inToken, 0 };
            m_Tokens.insert (node);
            message ("%s 0x%x %i", GLib.Log.METHOD, Os.gettid (), m_Tokens.length); 
        }

        public inline void
        remove_token (Token inToken)
        {
            m_Tokens.remove ({inToken, 0 });
            message ("%s 0x%x %i", GLib.Log.METHOD, Os.gettid (), m_Tokens.length); 
        }

        public inline void
        sleep ()
        {
            m_Tokens.iterator ().foreach ((node) => {
                ulong current_ref = node.m_Token.m_Ref.get ();
                if ((uint32)(current_ref >> 16) == m_Id)
                {
                    ulong? new_ref = node.m_Token.m_WaitingRefs.pop ();
                    message ("%s pop 0x%x %lu 0x%lx", GLib.Log.METHOD, Os.gettid (), node.m_Token.m_Id, new_ref != null? new_ref : 0);
                    node.m_Token.m_WaitingRefs.push (current_ref);
                    message ("%s push 0x%x %lu 0x%lx", GLib.Log.METHOD, Os.gettid (), node.m_Token.m_Id, current_ref);
                    node.m_Ref = current_ref;
                    if (new_ref != null)
                        node.m_Token.m_Ref.compare_and_exchange (current_ref, new_ref);
                    else
                        node.m_Token.m_Ref.compare_and_exchange (current_ref, 0);
                    message ("%s 0x%x %lu 0x%lx", GLib.Log.METHOD, Os.gettid (), node.m_Token.m_Id, node.m_Token.m_Ref.get ()); 
                }

                return true;
            });
        }

        public inline void
        acquire_all ()
        {
            m_Tokens.iterator ().foreach ((node) => {
                ulong current_ref = node.m_Token.m_Ref.get ();

                while ((uint32)(current_ref >> 16) != m_Id)
                {
                    Os.usleep (1);
                    current_ref = node.m_Token.m_Ref.get ();
                }
                node.m_Ref = 0;

                message ("%s 0x%x %lu 0x%lx", GLib.Log.METHOD, Os.gettid (), node.m_Token.m_Id, node.m_Token.m_Ref.get ()); 

                return true;
            });
        }
    }

    private class Pool : GLib.Object
    {
        // properties
        private GLib.Private m_Private;
        private Set<Token>   m_Tokens;
        private SpinLock     m_TokensSpin;

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
            unowned Thread? thread = (Thread?)m_Private.get ();

            if (thread == null)
            {
                Thread new_thread = new Thread ();
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

    // const properties
    private const int c_MaxTime = 200;

    // static properties
    private static Pool s_Pool;

    // properties
    private ulong               m_Id;
    private Os.Atomic.ULong     m_Ref;
    private AtomicQueue<ulong?> m_WaitingRefs;

    // static methods
    public static new Token
    get (ulong inTokenId)
    {
        Token token = null;

        if (Os.Atomic.Pointer.cast (&s_Pool).compare (null))
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
        m_WaitingRefs = new AtomicQueue<ulong?> ();
    }

    ~Token ()
    {
        s_Pool.remove_token (this);
    }

    internal void
    wait ()
    {
        unowned Thread? self = s_Pool.current_thread ();

        self.sleep ();

        ulong current_ref = m_Ref.get ();
        while ((uint32)(current_ref >> 16) != self.m_Id)
        {
            Os.usleep (1);
            current_ref = m_Ref.get ();
        }
        message ("%s 0x%x %lu 0x%lx", GLib.Log.METHOD, Os.gettid (), m_Id, m_Ref.get ());
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
            ulong current_ref = m_Ref.get ();
            ulong new_ref = ((ulong)self.m_Id << 16) + 1;

            if ((uint32)(current_ref >> 16) == self.m_Id)
            {
                new_ref = current_ref + 1;
                if (m_Ref.compare_and_exchange (current_ref, new_ref))
                {
                    message ("%s 0x%x %lu 0x%lx", GLib.Log.METHOD, Os.gettid (), m_Id, m_Ref.get ());
                    return;
                }
                continue;
            }

            if (current_ref == 0)
            {
                if (m_Ref.compare_and_exchange (0, new_ref))
                {
                    message ("%s 0x%x %lu 0x%lx", GLib.Log.METHOD, Os.gettid (), m_Id, m_Ref.get ());
                    self.add_token (this);
                    return;
                }
                continue;
            }

            message ("%s push 0x%x %lu 0x%lx", GLib.Log.METHOD, Os.gettid (), m_Id, new_ref);
            m_WaitingRefs.push (new_ref);

            wait ();

            self.add_token (this);

            self.acquire_all ();

            return;
        }
    }

    public void
    release ()
    {
        unowned Thread? self = s_Pool.current_thread ();
        ulong current_ref = m_Ref.get ();

        message ("%s 0x%x %lu 0x%lx", GLib.Log.METHOD, Os.gettid (), m_Id, m_Ref.get ());
        if (self.m_Id == (uint32)(current_ref >> 16))
        {
            int32 depth = (int32)((current_ref & 0x0FFFF) - 1);

            if (depth <= 0)
            {
                self.remove_token (this);
                ulong? new_ref = m_WaitingRefs.pop ();
                message ("%s pop 0x%x %lu 0x%lx", GLib.Log.METHOD, Os.gettid (), m_Id, new_ref != null ? new_ref : 0);
                if (new_ref != null)
                    m_Ref.compare_and_exchange (current_ref, new_ref);
                else
                    m_Ref.compare_and_exchange (current_ref, 0);
                message ("%s 0x%x %lu 0x%lx", GLib.Log.METHOD, Os.gettid (), m_Id, m_Ref.get ());
            }
            else
            {
                m_Ref.compare_and_exchange (current_ref, ((ulong)self.m_Id << 16) + (ulong)depth);
                message ("%s 0x%x %lu 0x%lx", GLib.Log.METHOD, Os.gettid (), m_Id, m_Ref.get ());
            }
        }
    }
}
