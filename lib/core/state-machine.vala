/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * state-machine.vala
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

public class Maia.StateMachine : Object
{
    // types
    private class Transition
    {
        private unowned StateMachine m_From;
        private unowned StateMachine? m_To;

        public class Transition (StateMachine inFrom, StateMachine? inTo)
        {
            m_From = inFrom;
            m_To = inTo;
        }

        ~Transition ()
        {
            Log.debug ("~Transition", "Remove transition");
        }

        public void
        activate ()
        {
            // from is active
            if (m_From.active)
            {
                // we go on new state
                if (m_To != null)
                {
                    // the new state is a initial state: leave from state and enter in state
                    if (m_To.parent != null &&
                        (((m_To.parent as StateMachine).initial_state != null &&
                          (m_To.parent as StateMachine).initial_state == m_To)) ||
                         (((m_To.parent as StateMachine).initial_state != null &&
                           (m_To.parent as StateMachine).active)))
                    {
                        m_From.leave ();
                        m_To.enter ();
                        // we go out from parent state leave it
                        if (m_From.parent != null && m_To.parent != m_From.parent)
                        {
                            (m_From.parent as StateMachine).leave ();
                        }
                    }
                    // the new state is standelone or the parent does not have any initial state:
                    // leave from state and enter in state
                    else if (m_To.parent == null ||
                             (m_To.parent as StateMachine).initial_state == null)
                    {
                        m_From.leave ();
                        m_To.enter ();
                    }
                }
                // we just leave from state
                else
                {
                    m_From.leave ();
                    // the from state have parent leave it
                    if (m_From.parent != null)
                    {
                        (m_From.parent as StateMachine).leave ();
                    }
                }
            }
            else
            {
                Log.warning (GLib.Log.METHOD, "State %s has not active", m_From.name);
            }
        }
    }

    // properties
    private unowned StateMachine? m_Initial = null;
    private unowned StateMachine? m_Current = null;
    private Set<StateMachine> m_Links;

    // signals
    /**
     * Emitted when state machine has been active
     */
    public virtual signal void enter ()
    {
        if (!active)
        {
            active = true;
            if (m_Initial != null)
            {
                m_Initial.enter ();
            }
        }
    }

    /**
     * Emitted when state machine has been inactive
     */
    public virtual signal void leave ()
    {
        if (active)
        {
            active = false;
            if (m_Current != null)
            {
                m_Current.leave ();
            }
        }
    }

    // accessors
    /**
     * Indicate if state machine is active
     */
    public bool active { get; set; default = false; }

    /**
     * State machine name
     */
    public string name {
        get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    /**
     * The initial state of machine
     */
    public StateMachine? initial_state {
        get {
            return m_Initial;
        }
        set {
            return_if_fail (value != null && value in this);

            m_Initial = value;
        }
    }

    /**
     * The current state of machine
     */
    public StateMachine? current_state {
        get {
            return m_Current;
        }
    }

    // methods
    public StateMachine (string inName)
    {
        GLib.Object (id: GLib.Quark.from_string (inName));
        m_Links = new Set<StateMachine> ();
    }

    private void
    on_child_enter (StateMachine inMachine)
    {
        if (!active) enter ();

        m_Current = inMachine;
    }

    private void
    on_child_leave (StateMachine inMachine)
    {
        if (m_Current == inMachine)
        {
            m_Current = null;
        }
    }

    internal override int
    compare (Object inOther)
    {
        return direct_compare (this, inOther);
    }

    internal override bool
    can_append_child (Object inChild)
    {
        return inChild is StateMachine;
    }

    internal override void
    insert_child (Object inObject)
    {
        base.insert_child (inObject);

        (inObject as StateMachine).enter.connect (on_child_enter);
        (inObject as StateMachine).leave.connect (on_child_leave);
    }

    internal override void
    remove_child (Object inObject)
    {
        base.remove_child (inObject);

        (inObject as StateMachine).enter.disconnect (on_child_enter);
        (inObject as StateMachine).leave.disconnect (on_child_leave);
    }

    /**
     * Watch a signal to switch from this state to inMachine state
     *
     * @param inObject object associated to signal
     * @param inSignalName signal name to watch
     * @param inMachine the state mahcine to switch on signal received
     */
    public void
    add_signal_transition (Object inObject, string inSignalName, StateMachine? inMachine)
    {
        Transition transition = new Transition (this, inMachine);
        if (inMachine != null)
            inObject.set_data (name + "->" + inMachine.name, transition);
        else
            inObject.set_data (name + "->", transition);

        GLib.Signal.connect_swapped (inObject, inSignalName, (GLib.Callback)Transition.activate, transition);

        if (inMachine != null)
            m_Links.insert (inMachine);
    }

    /**
     * Listen an event to switch from this state to inMachine state
     *
     * @param inObject object associated to event
     * @param inEventName event name to listen
     * @param inMachine the state mahcine to switch on signal received
     * @param inDispatcher the dispatcher where listen the event
     */
    public void
    add_event_transition (Object inObject, string inEventName, StateMachine? inMachine, Dispatcher inDispatcher = Dispatcher.self)
    {
        Transition transition = new Transition (this, inMachine);
        if (inMachine != null)
            inObject.set_data (name + "->" + inMachine.name, transition);
        else
            inObject.set_data (name + "->", transition);

        inDispatcher.create_event_listener (Event.Hash (inObject, GLib.Quark.from_string (inEventName)), (e) => {
            transition.activate ();
        });

        if (inMachine != null)
            m_Links.insert (inMachine);
    }

    /**
     * Watch a property changed to switch from this state to inMachine state
     *
     * @param inObject the object associated to property
     * @param inProperty property name to watch
     * @param inMachine the state mahcine to switch on property changed
     */
    public void
    add_notify_transition (Object inObject, string inProperty, StateMachine? inMachine)
    {
        Transition transition = new Transition (this, inMachine);
        if (inMachine != null)
            inObject.set_data (name + "->" + inMachine.name, transition);
        else
            inObject.set_data (name + "->", transition);

        inObject.notify[inProperty].connect (transition.activate);

        if (inMachine != null)
            m_Links.insert (inMachine);
    }

    /**
     * Return dot representation of the state machine
     */
    public string
    to_dot ()
    {
        string ret = "digraph %s {\n ".printf (name);

        foreach (unowned Object child in this)
        {
            unowned StateMachine state_child = (StateMachine)child;

            foreach (unowned StateMachine state in state_child.m_Links)
            {
                ret += "\"" + state_child.name + "\" -> \"" + state.name + "\";\n";
            }
        }
        ret += "}";

        return ret;
    }
}
