package wolf_n_lamb;

import java.util.*;
import java.io.*;

/**
 * A solver for a wolfs-and-lambs (a classic river-crossing) puzzle.
 * The initial configuration is read from stdin, and the answer is
 * written to stdout.
 * Note that a very simple breadth-first search algorithm is adopted,
 * and thus there is the possibility of an OutOfMemoryError.
 * Programmed by Yoshiaki Takata, 2013.
 *
 * Input format:
 *   wL lL wB lB wR lR LorR
 *
 *   wL: the number of wolfs at the left bank
 *   lL: the number of lambs at the left bank
 *   wB: the number of wolfs on the boat
 *   lB: the number of lambs on the boat
 *   wR: the number of wolfs at the right bank
 *   lR: the number of lambs at the right bank
 *   LorR: zero if the boat is at the left bank
 *
 * Output format:
 *   num_of_reached_states_0
 *   num_of_reached_states_1
 *   ...
 *   SUCCESS
 *   boat w_0 l_0
 *   go
 *   boat w_1 l_1
 *   boat w_2 l_2
 *   go
 *   ...
 *
 *   w_i, l_i: the number of wolfs and lambs to ride on the boat.
 */
public class Solver implements Runnable {
  public static void main(String[] arg) {
    new Thread(new Solver()).start();
  }

  public void run() {
    State start = State.initialState();
    State goal  = search(start);
    goal.generateTrail();
  }

  /**
   * Run a breadth-first search.
   */
  protected State search(State initialState) {
    Set<State> prev  = new HashSet<State>(); // 0..(n-1)-th generation
    Set<State> queue = new HashSet<State>(); // n-th generation
    queue.add(initialState);
    int nState = 1;

    while (! queue.isEmpty()) {
      Set<State> next = new HashSet<State>(); // (n+1)-th generation
      for (State state : queue) {
        if (state.isGoal()) {
          System.out.println("SUCCESS");
          return state;
        }

        // Add new states, which are not in prev, to next.
        // The next states of the n-th generation never be
        // the n-th generation in this puzzle.
        for (State s : state.next()) {
          if (! prev.contains(s)) next.add(s);
        }
      }
      prev.addAll(queue);
      queue = next;
      nState += next.size();
      System.out.println(nState);
    }
    return null;
  }
}

/**
 * The class of the states of this game.
 */
class State {
  final private static int BOAT_CAPACITY = 2;

  private static int nWolf, nLamb;

  private byte wolfL, lambL;
  private byte wolfB, lambB;
  private boolean boatL;
  private State prev = null;  // used for generating the trail to the goal

  /**
   * Factory method for creating the initial state.
   */
  public static State initialState() {
    State state = new State();
    state.new Loader().load(System.in);
    return state;
  }

  private State() {}

  /**
   * Copy constructor
   */
  private State(State s) {
    this.wolfL = s.wolfL;
    this.lambL = s.lambL;
    this.wolfB = s.wolfB;
    this.lambB = s.lambB;
    this.boatL = s.boatL;
    this.prev  = s;
  }

  public boolean equals(Object o) {
    if (! (o instanceof State)) return false;
    State that = (State)o;
    return wolfL == that.wolfL && lambL == that.lambL
        && wolfB == that.wolfB && lambB == that.lambB
        && boatL == that.boatL;
  }
  public int hashCode() {
    int code = (wolfL << 12) + (lambL << 8)
             + (wolfB << 4)  + (lambB << 1)
             + (boatL ? 0 : 1);
    return code * 7;
  }
  public String toString() {
    StringBuffer buf = new StringBuffer();
    buf.append("(" + wolfL + "," + lambL + ","
                   + wolfB + "," + lambB + "," + boatL + ")");
    if (prev != null) {
      buf.append("\n" + prev.toString());
    }
    return buf.toString();
  }

  public boolean isGoal() {
    return wolfL == 0 && lambL == 0 && wolfB == 0 && lambB == 0;
  }

  /**
   * The next states of this state.
   */
  public Set<State> next() {
    Set<State> next = new HashSet<State>();

    // Move the boat to the opposite bank.
    if (canMove()) {
      next.add(stateAfterMove());
    }

    // Move one crew onto the boat.
    if (wolfB + lambB < BOAT_CAPACITY) {
      if ((boatL && wolfL > 0) || (! boatL && nWolf - wolfL > 0)) {
        next.add(stateAfterMoveToBoat(1, 0));
      }
      if ((boatL && lambL > 0) || (! boatL && nLamb - lambL > 0)) {
        next.add(stateAfterMoveToBoat(0, 1));
      }
    }

    // Move one crew back to the bank.
    if (wolfB > 0) {
      next.add(stateAfterMoveToBoat(-1, 0));
    }
    if (lambB > 0) {
      next.add(stateAfterMoveToBoat(0, -1));
    }
    return next;
  }

  private boolean canMove() {
    if (wolfB + lambB <= 0) return false;
    // wolfL and lambL after move
    int wL = wolfL + (boatL ? 0 : wolfB);
    int lL = lambL + (boatL ? 0 : lambB);
    if (lL > 0 && lL < wL) return false;
    if (nLamb - lL > 0 && nLamb - lL < nWolf - wL) return false;
    return true;
  }

  private State stateAfterMove() {
    State next = new State(this);
    next.wolfL += (boatL ? 0 : wolfB);
    next.lambL += (boatL ? 0 : lambB);
    next.wolfB =  0;
    next.lambB =  0;
    next.boatL =  ! boatL;
    return next;
  }

  private State stateAfterMoveToBoat(int w, int l) {
    State next = new State(this);
    next.wolfL -= (boatL ? w : 0);
    next.lambL -= (boatL ? l : 0);
    next.wolfB += w;
    next.lambB += l;
    next.boatL =  boatL;
    return next;
  }

  /**
   * Generate the sequence of moves from the start state to this state.
   */
  public void generateTrail() {
    new TrailGenerator().generate(System.out);
  }

  /**
   * A utility class for loading the initial state from the stdin.
   */
  class Loader {
    /**
     * Input format:
     *   wL lL wB lB wR lR LorR
     */
    public void load(InputStream in) {
      State state = State.this;
      Scanner scanner = new Scanner(in);
      state.wolfL = scanner.nextByte();
      state.lambL = scanner.nextByte();
      state.wolfB = scanner.nextByte();
      state.lambB = scanner.nextByte();
      nWolf       = scanner.nextInt() + state.wolfL + state.wolfB;
      nLamb       = scanner.nextInt() + state.lambL + state.lambB;
      state.boatL = (scanner.nextInt() == 0);
    }
  }

  /**
   * A utility class for writing the trail to the stdout.
   */
  class TrailGenerator {
    public void generate(PrintStream out) {
      // Reverse the sequence.
      LinkedList<State> deque = new LinkedList<State>();
      for (State s = State.this; s != null; s = s.prev) {
        deque.addFirst(s);
      }

      // Translate the sequence of state to the sequence of moves.
      for (State s : deque) {
        if (s.prev == null) continue;
        if (s.boatL != s.prev.boatL) {
          out.println("go");
        } else {
          int vw = s.wolfB - s.prev.wolfB;
          int vl = s.lambB - s.prev.lambB;
          out.println("boat " + vw + " " + vl);
        }
      }
      out.flush();
    }
  }
}
