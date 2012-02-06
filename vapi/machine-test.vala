public class Atomic.Stack<T>
{
    [Compact]
    private class Entry<T>
    {
        public T val;
        public Machine.Memory.Atomic.Pointer next;
    }

    Machine.Memory.Atomic.Pointer head;
}

static int
main (string[] inArgs)
{
    Machine.Memory.Atomic.char val = Machine.Memory.Atomic.char ();
    val.set (10);
    char v = val.fetch_and_store (20);
    char va = val.fetch_and_add (5);
    val.inc ();
    val.inc ();
    val.dec ();

    val.compare_and_swap (26, 30);

    message ("%i %i %i", v, va, (int)val.get ());

    return 0;
}
