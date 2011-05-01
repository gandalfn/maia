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
        public uint32     m_Id;
        public Set<Token> m_Tokens;

        public Thread (GLib.Thread<void*> inThreadId)
        {
            m_Id = (uint32)inThreadId;
            m_Tokens = new Set<Token> ();
            m_Tokens.compare_func = Token.compare;
        }

        public int
        compare (Thread inOther)
        {
            return (int)(m_Id - inOther.m_Id);
        }

        public void
        sleep ()
        {
            audit (GLib.Log.METHOD, "Sleep 0x%lx", m_Id);
            foreach (unowned Token token in m_Tokens)
            {
                audit (GLib.Log.METHOD, "Unlock %u: 0x%lx", token.m_Id, m_Id);
                GLib.AtomicPointer.compare_and_exchange (&token.m_Ref, this, null);
                token.m_WaitDepth = token.m_Depth;
                token.m_Depth = 0;
                token.m_WaitMutex.lock ();
                token.m_WaitCond.signal ();
                token.m_WaitMutex.unlock ();
            }
        }

        public void
        wake_up ()
        {
            audit (GLib.Log.METHOD, "Wakeup 0x%lx", m_Id);
            foreach (unowned Token token in m_Tokens)
            {
                GLib.AtomicPointer.compare_and_exchange (&token.m_Ref, null, this);
                audit (GLib.Log.METHOD, "Lock %u: 0x%lx", token.m_Id, m_Id);
                token.m_Depth = token.m_WaitDepth;
                token.m_WaitDepth = 0;
            }
        }
    }

    private class Pool : GLib.Object
    {
        // properties
        private Set<Thread>         m_Pool;
        private Set<unowned Token?> m_Tokens;
        private GLib.StaticRWLock   m_Lock;

        // methods
        public Pool ()
        {
            m_Pool = new Set<Thread> ();
            m_Pool.compare_func = Thread.compare;
            m_Tokens = new Set<Token> ();
            m_Tokens.compare_func = (CompareFunc<unowned Token>)Token.compare;
        }

        public unowned Thread?
        current_thread ()
        {
            unowned GLib.Thread<void*> self = GLib.Thread.self<void*> ();

            m_Lock.reader_lock ();
            unowned Thread? thread = m_Pool.search<unowned GLib.Thread<void*>> (self, (t, i) => {
                return (int)(t.m_Id - (uint32)i);
            });
            m_Lock.reader_unlock ();

            if (thread == null)
            {
                Thread new_thread = new Thread (self);
                m_Lock.writer_lock ();
                m_Pool.insert (new_thread);
                m_Lock.writer_unlock ();
                thread = new_thread;
            }

            return thread;
        }

        public Token
        get_token (uint32 inTokenId)
        {
            m_Lock.reader_lock ();
            Token token = m_Tokens.search<uint32> (inTokenId, (t, i) => {
                return (int)(t.m_Id - i);
            });
            m_Lock.reader_unlock ();

            if (token == null)
            {
                m_Lock.writer_lock ();
                token = new Token (inTokenId);
                if (!(token in m_Tokens))
                {
                    m_Tokens.insert (token);
                }
                else
                {
                    token = m_Tokens.search<uint32> (inTokenId, (t, i) => {
                        return (int)(t.m_Id - i);
                    });
                }
                m_Lock.writer_unlock ();
            }

            return token;
        }

        public void
        remove_token (Token inToken)
        {
            s_Pool.m_Lock.writer_lock ();
            s_Pool.m_Tokens.remove (inToken);
            s_Pool.m_Lock.writer_unlock ();
        }
    }

    // static properties
    private static Pool s_Pool;

    // properties
    private uint32          m_Id;
    private unowned Thread? m_Ref = null;
    private uint            m_Depth = 0;
    private uint            m_WaitDepth = 0;
    private GLib.Mutex      m_WaitMutex;
    private GLib.Cond       m_WaitCond;

    // static methods
    static construct
    {
        lock (s_Pool)
        {
            if (s_Pool == null)
                s_Pool = new Pool ();
        }
    }

    public static new Token
    get (uint32 inTokenId)
    {
        if (s_Pool == null)
        {
            lock (s_Pool)
            {
                s_Pool = new Pool ();
            }
        }

        return s_Pool.get_token (inTokenId);
    }

    public static Token
    get_for_object (Object inObject)
    {
        Token token = get ((uint32)inObject);
        token.acquire ();

        return token;
    }

    // methods
    internal Token (uint32 inId)
    {
        m_Id = inId;
        m_WaitMutex = new GLib.Mutex ();
        m_WaitCond = new GLib.Cond ();
    }

    ~Token ()
    {
        release ();

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
            unowned Thread? ref = m_Ref;

            if (ref == null)
            {
                if (GLib.AtomicPointer.compare_and_exchange (&m_Ref, null, self))
                {
                    audit (GLib.Log.METHOD, "Lock %u: 0x%lx", m_Id, self.m_Id);
                    self.m_Tokens.insert (this);
                    break;
                }
                continue;
            }

            if (ref == self)
            {
                m_Depth++;
                break;
            }

            m_WaitMutex.lock ();
            self.sleep ();
            while (m_Ref != null)
            {
                audit (GLib.Log.METHOD, "Wait %u: 0x%lx", m_Id, self.m_Id);
                m_WaitCond.wait (m_WaitMutex);
            }
            self.wake_up ();
            m_WaitMutex.unlock ();
        }
    }

    public void
    release ()
    {
        unowned Thread? self = s_Pool.current_thread ();

        if (self == m_Ref)
        {
            if (m_Depth > 0) m_Depth--;

            if (m_Depth == 0)
            {
                self.m_Tokens.remove (this);
                if (GLib.AtomicPointer.compare_and_exchange (&m_Ref, self, null))
                {
                    audit (GLib.Log.METHOD, "Release %u: 0x%lx", m_Id, self.m_Id);
                    m_WaitMutex.lock ();
                    m_WaitCond.signal ();
                    m_WaitMutex.unlock ();
                }
            }
        }
    }
}