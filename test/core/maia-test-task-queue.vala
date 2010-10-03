/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * maia-test-task_queue.vala
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

public class Maia.TestTaskQueue : Maia.TestCase
{
    const int NB_TASKS = 1000;

    private TaskQueue m_Queue;
    private Task[] m_Tasks;

    public TestTaskQueue ()
    {
        base ("task-queue");

        add_test ("add-linear", test_task_add_linear);
        add_test ("add-random", test_task_add_random);
        add_test ("remove", test_task_remove);
    }

    private void
    test_task_callback ()
    {
    }

    private void
    create_tasks (bool inRandom)
    {
        for (uint cpt = 0; cpt  < NB_TASKS; ++cpt)
        {
            if (inRandom)
                m_Tasks[cpt] = new Task (test_task_callback, 
                                         (Task.Priority)Test.rand_int_range (Task.Priority.HIGH,
                                                                             Task.Priority.LOW));
            else
                m_Tasks[cpt] = new Task (test_task_callback);

            m_Queue.add (m_Tasks[cpt]);
            assert (m_Queue.size == cpt + 1);
        }
    }

    public override void
    set_up ()
    {
        m_Queue = new TaskQueue ();
        m_Tasks = new Task[NB_TASKS];
    }

    public override void
    tear_down ()
    {
        m_Queue = null;
        m_Tasks = null;
    }

    public void
    test_task_add_linear ()
    {
        create_tasks (false);

        uint cpt = 0;

        foreach (Task task in m_Queue)
        {
            assert (m_Tasks[cpt] == task);
            cpt++;
        }
    }

    public void
    test_task_add_random ()
    {
        create_tasks (true);

        unowned Task? prev = null;
        foreach (Task task in m_Queue)
        {
            if (prev != null)
            {
                assert (prev.priority <= task.priority);
            }
            prev = task;
        }
    }

    public void
    test_task_remove ()
    {
        create_tasks (true);

        assert (m_Queue.remove (m_Tasks[24]));
        assert (m_Queue.size == NB_TASKS - 1);
        assert (m_Queue.remove (m_Tasks[74]));
        assert (m_Queue.size == NB_TASKS - 2);

        unowned Task? prev = null;
        foreach (Task task in m_Queue)
        {
            if (prev != null)
            {
                assert (prev.priority <= task.priority);
            }
            prev = task;
        }
    }
}
