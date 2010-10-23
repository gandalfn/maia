/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-task-queue.vala
 * Copyright (C) Nicolas Bruguier 2010 <gandalfn@club-internet.fr>
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

public class Maia.TaskQueue : Object
{
    private TaskNode? m_Head = null;
    private unowned TaskNode? m_Tail = null;

    private int m_Size = 0;
    public int size {
        get {
            return m_Size;
        }
    }

    public TaskQueue ()
    {
    }

    private inline unowned TaskNode?
    get_node (Task inTask)
    {
        unowned TaskNode? ret = null;

        // Search task node in queue
        for (unowned TaskNode node = m_Head; node != null && ret == null; node = node.m_Next)
        {
            if (node.m_Task == inTask)
            {
                ret = node;
            }
        }

        return ret;
    }

    private void
    remove_node (TaskNode inNode)
    {
        TaskNode n;
        unowned TaskNode next;

        if (inNode == m_Head)
        {
            n = (owned)m_Head;
            next = m_Head = (owned) n.m_Next;
        }
        else
        {
            n = (owned)inNode.m_Prev.m_Next;
            next = n.m_Prev.m_Next = (owned)n.m_Next;
        }

        if (n == m_Tail)
        {
            m_Tail = n.m_Prev;
        }
        else
        {
            next.m_Prev = n.m_Prev;
        }

        n.m_Prev = null;
        n.m_Next = null;
        n.m_Task = null;
        m_Size--;
    }

    public void
    reorder ()
    {
        // Check each node in queue
        for (unowned TaskNode node = m_Head; node != null && node.m_Next != null; node = node.m_Next)
        {
            if (Task.compare(node.m_Task, node.m_Next.m_Task) > 0)
            {
                // swap node data
                Task swap = node.m_Task;
                node.m_Task = node.m_Next.m_Task;
                node.m_Next.m_Task = swap;
            }
        }
    }

    public bool
    add (Task inTask)
    {
        // Create new node
        TaskNode new_node = new TaskNode (inTask);

        // Queue is empty
        if (m_Head == null && m_Tail == null)
        {
            m_Tail = new_node;
            m_Head = (owned)new_node;
        }
        // Append task in queue according its priority
        else
        {
            unowned TaskNode? found = null;

            // Search node position
            for (unowned TaskNode node = m_Tail; node != null; node = node.m_Prev)
            {
                if (Task.compare (new_node.m_Task, node.m_Task) >= 0)
                {
                    found = node;
                    break;
                }
            }
            // Insert task after found
            if (found != null)
            {
                if (found == m_Tail) m_Tail = new_node;
                new_node.m_Prev = found;
                new_node.m_Next = (owned)found.m_Next;
                if (new_node.m_Next !=null) new_node.m_Next.m_Prev = new_node;
                found.m_Next = (owned)new_node;
            }
            // Insert task on head of queue
            else
            {
                new_node.m_Next = (owned)m_Head;
                new_node.m_Next.m_Prev = new_node;
                m_Head = (owned)new_node;
            }
        }

        m_Size++;

        return true;
    }

    public bool
    remove (Task inTask)
        requires (m_Size > 0)
    {
        bool ret = false;
        unowned TaskNode? node = get_node (inTask);

        if (node != null)
        {
            remove_node (node);
            ret = true;
        }

        return ret;
    }

    public Task
    first ()
        requires (m_Size > 0)
    {
        return m_Head.m_Task;
    }

    public Iterator
    iterator ()
        requires (m_Size > 0)
    {
        return new Iterator (this);
    }

    [Compact]
    private class TaskNode
    {
        public Task m_Task;
        public unowned TaskNode? m_Prev = null;
        public TaskNode? m_Next = null;

        public TaskNode (owned Task inTask) 
        {
            m_Task = inTask;
        }
    }

    public class Iterator : Object
    {
        private bool m_Started = false;
        private unowned TaskNode? m_Current;
        private TaskQueue m_Queue;

        internal Iterator (TaskQueue inQueue)
        {
            m_Queue = inQueue;
            m_Current = null;
        }

        public bool
        next ()
        {
            bool ret = false;

            if (!m_Started && m_Queue.m_Head != null)
            {
                m_Started = true;
                m_Current = m_Queue.m_Head;
                ret = true;
            }
            else if (m_Current != null && m_Current.m_Next != null)
            {
                m_Current = m_Current.m_Next;
                ret = true;
            }

            return ret;
        }

        public Task
        @get ()
            requires (m_Current != null)
        {
            return m_Current.m_Task;
        }
    }
}
