/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * dispatcher.vala
 * Copyright (C) Nicolas Bruguier 2010-2013 <gandalfn@club-internet.fr>
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

public class Maia.Dispatcher : Watch
{
    // types
    internal enum MessageType
    {
        NONE,
        WAKEUP,
        TASK_READY,
        EVENT,
        DESTROY_EVENT,
        QUIT
    }

    internal struct Message
    {
        public size_t      size;
        public MessageType type;

        public Message ()
        {
            size = 0;
            type = MessageType.NONE;
        }

        public void
        post ()
        {
            s_PipeLock.lock ();
            {
                foreach (int fd in s_Pipe)
                {
                    write (fd);
                }
            }
            s_PipeLock.unlock ();
        }

        internal void
        write (int inFd)
        {
            Os.write (inFd, &this, size);
        }

        internal static Message*
        read (Dispatcher inDispatcher)
        {
            Message* ret = null;
            Message msg = Message ();

            if (Os.read (inDispatcher.m_Pipe[0], &msg, sizeof (Message)) != sizeof (Message))
                return null;
            if (msg.size > sizeof (Message))
            {
                ret = GLib.malloc0 (msg.size);
                size_t size = msg.size - sizeof (Message);
                if (Os.read (inDispatcher.m_Pipe[0], ret + 1, size) != size)
                    return null;
                ret->type = msg.type;
                ret->size = msg.size;
            }

            return ret;
        }
    }

    internal struct MessageWakeUp
    {
        public Message             header;
        public unowned Dispatcher? dispatcher;

        public MessageWakeUp (Dispatcher? inDispatcher)
        {
            header = Message ();
            header.type = MessageType.WAKEUP;
            dispatcher = inDispatcher;
            header.size = sizeof (MessageWakeUp);
        }

        public void
        post ()
        {
            if (dispatcher != null)
            {
                header.write (dispatcher.m_Pipe[1]);
            }
            else
            {
                header.post ();
            }
        }
    }

    internal struct MessageEvent
    {
        public Message    header;
        public EventArgs? args;
        public Event.Hash event;

        public MessageEvent (Event.Hash inEventId, EventArgs? inArgs)
        {
            header = Message ();
            header.type = MessageType.EVENT;
            event = inEventId;
            args = inArgs;
            header.size = sizeof (MessageEvent);
            Log.audit (GLib.Log.METHOD, "New event message %u", event.id);
        }

        public void
        post ()
        {
            s_PipeLock.lock ();
            {
                foreach (int fd in s_Pipe)
                {
                    if (args != null)
                    {
                        args.ref ();
                    }
                    header.write (fd);
                }
            }
            s_PipeLock.unlock ();
        }
    }

    internal struct MessageDestroyEvent
    {
        public Message    header;
        public Event.Hash event;

        public MessageDestroyEvent (Event.Hash inEventId)
        {
            header = Message ();
            header.type = MessageType.DESTROY_EVENT;
            event = inEventId;
            header.size = sizeof (MessageDestroyEvent);
        }

        public void
        post ()
        {
            header.post ();
        }
    }

    internal struct MessageTaskReady
    {
        public Message header;
        public unowned Task? task;

        public MessageTaskReady (Task inTask)
        {
            header = Message ();
            header.type = MessageType.TASK_READY;
            header.size = sizeof (MessageTaskReady);
        }

        public void
        post ()
        {
            header.post ();
        }
    }

    internal struct MessageQuit
    {
        public Message header;
        public unowned Dispatcher? dispatcher;

        public MessageQuit (Dispatcher? inDispatcher)
        {
            header = Message ();
            header.type = MessageType.QUIT;
            dispatcher = inDispatcher;
            header.size = sizeof (MessageQuit);
        }

        public void
        post ()
        {
            if (dispatcher != null)
            {
                header.write (dispatcher.m_Pipe[1]);
            }
            else
            {
                header.post ();
            }
        }
    }

    // properties
    private GLib.MainContext?       m_Context = null;
    private GLib.Thread<void*>      m_Thread = null;
    private GLib.MainLoop           m_Loop;
    private int                     m_IsRunning = 0;
    private TimeoutPool             m_TimeoutPool;
    private int                     m_Pipe[2];
    private Set<unowned Task>       m_Tasks;
    private Set<EventListenerPool>  m_Events;

    // static properties
    static GLib.StaticPrivate  s_Private;
    static GLib.Mutex          s_PipeLock;
    static Set<int>            s_Pipe;


    // static accessors
    /**
     * Get the dispatcher for the current thread if exist, null otherwise
     */
    public static unowned Dispatcher? self {
        get {
            return (Dispatcher?)s_Private.get ();
        }
    }

    // accessors
    /**
     * Indicate if the dispatcher is currently running
     */
    public bool is_running {
        get {
            return GLib.AtomicInt.get (ref m_IsRunning) != 0;
        }
        set {
            GLib.AtomicInt.set (ref m_IsRunning, value ? 1 : 0);
        }
    }

    /**
     * Main context associated to dispatcher
     */
    public GLib.MainContext? context {
        get {
            return m_Context == null ? GLib.MainContext.default () : m_Context;
        }
    }

    // static methods
    static construct
    {
        s_PipeLock = GLib.Mutex ();
        s_Pipe = new Set<int> ();
    }

    static void
    add_pipe (int inFd)
    {
        s_PipeLock.lock ();
        {
            s_Pipe.insert (inFd);
        }
        s_PipeLock.unlock ();
    }

    static void
    remove_pipe (int inFd)
    {
        s_PipeLock.lock ();
        {
            s_Pipe.remove (inFd);
        }
        s_PipeLock.unlock ();
    }

    // signals
    /**
     * Emitted on dispatcher finish
     */
    public signal void finished ();

    // static methods
    /**
     * Post event
     *
     * @param inName event name
     * @param inOwner owner of event
     * @param inArgs event args
     */
    public static void
    post_event (string inName, void* inOwner, EventArgs inArgs)
    {
        Dispatcher.MessageEvent (Event.Hash (inOwner, GLib.Quark.from_string (inName)), inArgs as EventArgs).post ();
    }

    // methods
    /**
     * Create a new dispatcher, you can only create one main dispatcher
     *
     * @return a new Dispatcher object
     */
    public Dispatcher ()
    {
        if (self == null)
        {
            int fd[2];

            Os.pipe (fd);

             try
            {
                GLib.Unix.set_fd_nonblocking (fd[0], true);
                GLib.Unix.set_fd_nonblocking (fd[1], true);
            }
            catch (GLib.Error err)
            {
            }
            base (fd[0], GLib.MainContext.default (), GLib.Priority.DEFAULT - 20);

            Log.audit (GLib.Log.METHOD, "0x%lx", (ulong)this);

            add_pipe (fd[1]);
            m_Pipe = fd;
            m_TimeoutPool = new TimeoutPool (null, GLib.Priority.DEFAULT);
            m_Loop = new GLib.MainLoop (null, false);
            m_Tasks = new Set<unowned Task> ();
            m_Tasks.compare_func = (a, b) => {
                return (int)((ulong)a - (ulong)b);
            };
            m_Events = new Set<EventListenerPool> ();

            s_Private.set (this, null);
        }
        else
        {
            Log.critical (GLib.Log.METHOD, "A main dispatcher already exist");
        }
    }

    /**
     * Create a new threaded dispatcher
     *
     * @return a new Dispatcher object
     */
    public Dispatcher.thread ()
    {
        GLib.MainContext ctx = new GLib.MainContext ();
        int fd[2];

        Os.pipe (fd);
        try
        {
            GLib.Unix.set_fd_nonblocking (fd[0], true);
            GLib.Unix.set_fd_nonblocking (fd[1], true);
        }
        catch (GLib.Error err)
        {
        }

        base (fd[0], ctx, GLib.Priority.DEFAULT - 20);
        Log.audit (GLib.Log.METHOD, "0x%lx", (ulong)this);

        add_pipe (fd[1]);
        m_Pipe = fd;
        m_Context = ctx;
        m_TimeoutPool = new TimeoutPool (m_Context, GLib.Priority.DEFAULT);
        m_Loop = new GLib.MainLoop (m_Context, false);
        m_Tasks = new Set<unowned Task> ();
        m_Tasks.compare_func = (a, b) => {
            return (int)((ulong)a - (ulong)b);
        };
        m_Events = new Set<EventListenerPool> ();
    }

    ~Dispatcher ()
    {
        Log.audit ("Maia.Dispatcher.finalize", "");

        remove_pipe (m_Pipe[1]);
        Os.close (m_Pipe[0]);
        Os.close (m_Pipe[1]);
    }

    private void*
    main ()
    {
        Log.audit (GLib.Log.METHOD, "");

        m_Context.push_thread_default ();

        s_Private.set (this, null);

        is_running = true;

        m_Loop.run ();

        return null;
    }

    internal unowned EventListener?
    create_event_listener (Event.Hash inEventHash, owned Event.Handler inHandler)
    {
        unowned EventListener? ret = null;

        // Create new event listener
        EventListener listener = new EventListener ((owned)inHandler);

        // Get pool for event
        unowned EventListenerPool? pool = m_Events.search<Event.Hash?> (inEventHash, (o, v) => {
            return o.compare_with_event_hash (v);
        });

        // Pool has not been created , create it
        if (pool == null)
        {
            EventListenerPool new_pool = new EventListenerPool (inEventHash);
            m_Events.insert (new_pool);
            pool = new_pool;
        }

        // Associate listener to pool
        listener.parent = pool;

        ret = listener;

        return ret;
    }

    internal override void
    insert_child (Object inObject)
    {
        base.insert_child (inObject);

        if (inObject is Task)
        {
            m_Tasks.insert (inObject as Task);
        }
    }

    internal override void
    remove_child (Object inObject)
    {
        base.remove_child (inObject);

        if (inObject is Task)
        {
            m_Tasks.remove (inObject as Task);
        }
    }

    internal override bool
    on_prepare (out int outTimeOut)
    {
        bool ret = base.on_prepare (out outTimeOut);

        if (!ret)
        {
            unowned Task? first = first () as Task;

            if (first != null && first.state == Task.State.READY)
            {
                outTimeOut = 0;
                ret = true;
            }
        }

        return ret;
    }

    internal override bool
    on_check ()
    {
        bool ret = base.on_check ();

        if (!ret)
        {
            unowned Task? first = first () as Task;

            if (first != null && first.state == Task.State.READY)
            {
                ret = true;
            }
        }

        return ret;
    }

    internal override void
    on_error ()
    {
        is_running = false;
        m_Loop.quit ();
    }

    internal override bool
    on_process ()
    {
        Log.audit (GLib.Log.METHOD, "0x%lx", (ulong)this);

        // Process all received message
        Message* msg = null;
        while ((msg = Message.read (this)) != null)
        {
            switch (msg.type)
            {
                case MessageType.TASK_READY:
                    Log.audit (GLib.Log.METHOD, "Task ready");
                    MessageTaskReady? msg_task_ready = (MessageTaskReady?)msg;
                    if (msg_task_ready.task in m_Tasks)
                    {
                        msg_task_ready.task.state = Task.State.READY;
                    }
                    break;

                case MessageType.EVENT:
                    MessageEvent? msg_event = (MessageEvent?)msg;
                    Log.audit (GLib.Log.METHOD, "Received event %u", msg_event.event.id);
                    unowned EventListenerPool? pool = m_Events.search<Event.Hash?> (msg_event.event, (o, v) => {
                        return o.compare_with_event_hash (v);
                    });
                    if (pool != null)
                    {
                        pool.notify (msg_event.args);
                    }
                    if (msg_event.args != null) msg_event.args.unref ();
                    break;

                case MessageType.DESTROY_EVENT:
                    Log.audit (GLib.Log.METHOD, "Destroy event");
                    MessageDestroyEvent? msg_event = (MessageDestroyEvent?)msg;
                    unowned EventListenerPool? pool = m_Events.search<Event.Hash?> (msg_event.event, (o, v) => {
                        return o.compare_with_event_hash (v);
                    });
                    if (pool != null)
                    {
                        m_Events.remove (pool);
                    }
                    break;


                case MessageType.QUIT:
                    Log.audit (GLib.Log.METHOD, "Receive quit");
                    is_running = false;
                    m_Loop.quit ();
                    return false;
            }
            GLib.free (msg);
        }

        // Process all ready tasks
        Object.Iterator iter = iterator ();

        unowned Object? child = iter.get ();

        while (child != null)
        {
            unowned Object? next = iter.next_value ();
            if (child is Task)
            {
                unowned Task? task = child as Task;

                if (task.state == Task.State.READY)
                {
                    task.run ();
                }
                else
                    break;
            }
            child = next;
        }

        return true;
    }

    /**
     * {@inheritDoc}
     */
    internal override bool
    can_append_child (Object inChild)
    {
        return inChild is Task;
    }

    /**
     * Run the dispatcher
     */
    public void
    run ()
    {
        Log.audit (GLib.Log.METHOD, "0x%lx", (ulong)this);
        if (m_Context == null)
        {
            is_running = true;
            m_Loop.run ();
        }
        else if (m_Thread == null)
        {
            m_Thread = new Thread<void*> (to_string (), main);
        }
    }

    /**
     * Stop the dispatcher
     */
    public void
    stop ()
    {
        if (is_running)
        {
            Log.info (GLib.Log.METHOD, "Send quit");

            MessageQuit (this).post ();

            if (m_Context != null && m_Thread != GLib.Thread.self<void*> ())
            {
                m_Thread.join ();
            }
        }
    }

    /**
     * Add a timeout
     *
     * @param inTimeoutMs timeout in milliseconds
     * @param inCallback callback function to call when timeout is reached
     * @param inPriority priority of timeout
     */
    public void
    add_timeout (int inTimeoutMs, owned Timeout.ElapsedFunc inCallback, int inPriority = GLib.Priority.DEFAULT)
    {
        Timeout timeout = new Timeout (inTimeoutMs, (owned)inCallback, inPriority);
        timeout.parent = m_TimeoutPool;
        m_Context.wakeup ();
    }
}
