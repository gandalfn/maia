/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
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

// constants
private int TOKEN_POOL_SIZE = 4001;

// static properties
private Maia.Token s_TokenPool [4001];

public struct Maia.Token
{
    // properties
    internal Os.Atomic.Pointer m_Ref;

    // static methods
    /**
     * Get token identified by inTokenId
     *
     * @param inTokenId token identifier
     *
     * @return Token associated to inTokenId
     */
    public static unowned Token?
    get (void* inTokenId)
    {
        unowned Token* pToken = &s_TokenPool [(ulong)inTokenId % TOKEN_POOL_SIZE];
        unowned Token? ret = (Token?)pToken;

        unowned Thread? self = Thread.self ();
        TokenRef* pRef = self.push (ret);
        if (!ret.try_acquire (pRef, self))
        {
            self.yield ();
        }

        return ret;
    }

    // methods
    internal Token ()
    {
        m_Ref.set (null);
    }

    internal bool
    try_spin (TokenRef* inpRef)
    {
        for (int n = 0; n < 5; ++n)
        {
            if (m_Ref.compare_and_exchange (null, inpRef))
            {
                return true;
            }
            Os.Cpu.relax ();
        }

        return false;
    }

    internal void
    release_spin ()
    {
        m_Ref.set (null);
    }

    internal bool
    try_acquire (TokenRef* inpRef, Thread inThread)
    {
        unowned Token? token = inpRef->m_Token;
        while (true)
        {
            TokenRef* pRef = token.m_Ref.get ();
            if (pRef == null)
            {
                if (token.m_Ref.compare_and_exchange (null, inpRef))
                    return true;
                continue;
            }

            if (pRef in inThread)
                return true;

            if (try_spin (inpRef))
                return true;

            return false;
        }
    }

    public void
    release ()
    {
        Thread.self ().pop (this);
    }
}

public struct Maia.TokenRef
{
    // properties
    internal unowned Token? m_Token;
    internal Thread         m_Owner;

    // methods
    internal void
    init (Token? inToken, Thread inThread)
    {
        m_Token = inToken;
        m_Owner = inThread;
    }
}

public class Maia.Thread : GLib.Object
{
    // static properties
    static bool s_Initialized = false;
    static GLib.StaticPrivate s_Private;

    // properties
    private TokenRef  m_TokenRefs[32];
    private TokenRef* m_pTokenStop;

    // static methods
    internal static unowned Thread?
    self ()
    {
        if (!s_Initialized)
        {
            s_Private = GLib.StaticPrivate ();
        }

        unowned Thread? thread = (Thread?)s_Private.get ();
        if (thread == null)
        {
           Thread t = new Thread ();
           t.ref ();
           s_Private.set (t, t.unref);
           thread = t;
        }

        return thread;
    }

    // methods
    /**
     * description
     */
    internal Thread ()
    {
        m_pTokenStop = &m_TokenRefs[0];
    }

    private bool
    get_all_tokens ()
    {
        Log.audit (GLib.Log.METHOD, "0x%x", Os.gettid());
        for (TokenRef* pScan = &m_TokenRefs[0]; pScan < m_pTokenStop; pScan++)
        {
            unowned Token? token = pScan->m_Token;
            while (true)
            {
                TokenRef* pRef = token.m_Ref.get ();
                if  (pRef == null)
                {
                    if (token.m_Ref.compare_and_exchange (null, pScan))
                        break;
                    continue;
                }

                if (pRef in this)
                    break;

                if (token.try_spin (pScan))
                    break;

                release_all_tokens ();

                return false;
            }
        }

        return true;
    }

    private void
    release_all_tokens ()
    {
        Log.audit (GLib.Log.METHOD, "0x%x", Os.gettid());
        for (TokenRef* pRef = m_pTokenStop - 1; pRef >= &m_TokenRefs[0]; pRef--)
        {
            unowned Token? token = pRef->m_Token;
            if (token.m_Ref.compare (pRef))
                token.release_spin ();
        }
    }

    /**
     * Add a token to thread
     *
     * @param inToken token to add to thread
     */
    internal TokenRef*
    push (Token? inToken)
        requires (m_pTokenStop < &m_TokenRefs[31])
    {
        Log.audit (GLib.Log.METHOD, "0x%x 0x%x", inToken, Os.gettid());
        TokenRef* pRef = m_pTokenStop;
        m_pTokenStop++;

        unowned TokenRef? r = (TokenRef?)pRef;
        r.init (inToken, this);

        return pRef;
    }

    internal void
    pop (Token? inToken)
    {
        Log.audit (GLib.Log.METHOD, "0x%x 0x%x", inToken, Os.gettid());
        TokenRef* pRef = m_pTokenStop - 1;

        if (inToken.m_Ref.compare (pRef))
            inToken.release_spin ();
        GLib.Memory.set (pRef, 0, sizeof (Token));
        m_pTokenStop--;
    }

    /**
     * Yield thread
     */
    internal void
    @yield ()
    {
        Log.audit (GLib.Log.METHOD, "Begin 0x%x", Os.gettid());
        while (!get_all_tokens ())
        {
            Os.usleep (10);
        }
        Log.audit (GLib.Log.METHOD, "End 0x%x", Os.gettid());
    }

    /**
     * Return true if ref is owned by thread
     */
    internal inline bool
    contains (TokenRef* inpRef)
    {
        return inpRef >= &m_TokenRefs[0] && inpRef < m_pTokenStop;
    }
}
