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
    const int NB_TASKS = 10000;

    private Array<Task> m_Queue;
    private Task[] m_Tasks;

    public TestTaskQueue ()
    {
        base ("task-queue");

        add_test ("add-linear", test_task_add_linear);
        add_test ("add-random", test_task_add_random);
        add_test ("remove", test_task_remove);
    }

    private void
    create_tasks (bool inRandom)
    {
        for (uint cpt = 0; cpt  < NB_TASKS; ++cpt)
        {
            if (inRandom)
            {
                m_Tasks[cpt] = new Task ((Task.Priority)Test.rand_int_range (Task.Priority.HIGH,
                                                                             Task.Priority.LOW));
                m_Tasks[cpt].state = (Task.State)Test.rand_int_range (Task.State.UNKNOWN,
                                                                      Task.State.READY);
            }
            else
                m_Tasks[cpt] = new Task ();

            m_Queue.insert (m_Tasks[cpt]);
            assert (m_Queue.nb_items == cpt + 1);
        }
    }

    public override void
    set_up ()
    {
        m_Queue = new Array<Task> ();
        m_Queue.compare_func = get_compare_func_for<Task> ();
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
        Test.timer_start ();
        create_tasks (false);
        double elapsed = Test.timer_elapsed ();
        Test.message ("Add linear time %f ms", elapsed); 

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
        Test.timer_start ();
        create_tasks (true);
        double elapsed = Test.timer_elapsed ();
        Test.message ("Add random time %f ms", elapsed); 

        unowned Task? prev = null;
        foreach (Task task in m_Queue)
        {
            if (prev != null)
            {
                assert (prev.state > task.state || (prev.state == task.state && prev.priority <= task.priority));
            }
            prev = task;
        }
    }

    public void
    test_task_remove ()
    {
        create_tasks (true);

        for (int cpt = 0; cpt < NB_TASKS; ++cpt)
        {
            int nb_items = m_Queue.nb_items;
            m_Queue.remove (m_Tasks[cpt]);
            assert (m_Queue.nb_items == nb_items - 1);
        }
    }
}
