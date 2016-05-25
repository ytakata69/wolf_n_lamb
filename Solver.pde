import java.io.*;
import java.util.*;

/**
 * The interface to an external puzzle solver.
 * This interface object executes the solver and communicates with it
 * through stdin and stdout.
 * Programmed by Yoshiaki Takata, 2013.
 *
 * Note: The solver is just a Java program but we execute it in
 * a separate JVM, because it may consume much memory and interfere
 * the animation of this sketch.
 * The solver code (Solver.jar) is placed in the sketch folder
 * as like as an imported library.
 */
class Solver implements Runnable {
  public volatile boolean finished = false;
  public volatile int nReached = 0;
  private Trail trail;
  private int wolfL, wolfB, wolfR;
  private int lambL, lambB, lambR;
  private boolean boatL;

  public Solver(int wolfL_, int lambL_, int wolfB_, int lambB_, int wolfR_, int lambR_, boolean boatL_, Trail trail_) {
    wolfL = wolfL_;
    lambL = lambL_;
    wolfB = wolfB_;
    lambB = lambB_;
    wolfR = wolfR_;
    lambR = lambR_;
    boatL = boatL_;
    trail = trail_;
  }

  final String SOLVER_CLASS = "wolf_n_lamb.Solver";
  final String CLASS_PATH = System.getProperty("java.class.path");
  final String[] CMD_SOLVER = { "java", "-cp", CLASS_PATH, SOLVER_CLASS };

  public void run() {
    try {
      run(CMD_SOLVER);
    } catch (IOException e) {
    }
    finished = true;
  }

  protected void run(String[] cmd) throws IOException
  {
    for (String c : cmd) {
      System.out.print((c.length() <= 64 ? c : c.substring(0, 64) + "...") + " ");
    }
    System.out.print("...");
    System.out.flush();

    Process proc = Runtime.getRuntime().exec(cmd);
    this.writeTo (proc.getOutputStream());
    this.readFrom(proc.getInputStream());

    try {
      proc.waitFor();
    } catch (InterruptedException e) {
    }
    System.out.println("done");
  }

  public void writeTo(OutputStream outStream) throws IOException {
    PrintWriter out = new PrintWriter(new OutputStreamWriter(outStream));
    out.print( "" + wolfL + " " + lambL);
    out.print(" " + wolfB + " " + lambB);
    out.print(" " + wolfR + " " + lambR);
    out.print(" " + (boatL ? 0 : 1));
    out.println();
    out.close();
  }

  public void readFrom(InputStream in) throws IOException {
    BufferedReader reader = new BufferedReader(new InputStreamReader(in));
    boolean solved = false;
    String line;
    while ((line = reader.readLine()) != null) {
      if (line.equals("SUCCESS")) {
        solved = true;
        continue;
      }
      Scanner scanner = new Scanner(line);
      if (solved) {
        String cmd = scanner.next();
        if (cmd.equals("go")) {
          trail.add(trail.GO, 0, 0);
        } else {
          int vw = scanner.nextInt();
          int vl = scanner.nextInt();
          trail.add(trail.BOAT, vw, vl);
        }
      } else {
        nReached = scanner.nextInt();
      }
    }
    System.out.print(" (" + trail.size() + " steps) ");
    reader.close();
  }
}

class Trail {
  private List<TrailStep> list = new LinkedList<TrailStep>();
  private Iterator<TrailStep> iterator = null;
  final public int GO   = 1;
  final public int BOAT = 2;
  public void add(int cmd, int vw, int vl) {
    list.add(new TrailStep(cmd, vw, vl));
  }
  public int size() {
    return list.size();
  }
  private int t = 0;
  final int WOLF = 1;
  final int LAMB = 2;
  public void run() {
    if (state != AT_LEFT && state != AT_RIGHT) {
      t = 0;
      return;
    }
    if (iterator == null) {
      iterator = list.iterator();
    }
    if (++t % 10 != 0) return;

    if (! iterator.hasNext()) return;
    TrailStep step = iterator.next();
    switch (step.cmd) {
    case GO:
      if (state == AT_LEFT) state = MOVING_TO_RIGHT;
      else                  state = MOVING_TO_LEFT;
      break;
    case BOAT:
      Wolf wolf = (state == AT_LEFT ? wolfL : wolfR);
      Lamb lamb = (state == AT_LEFT ? lambL : lambR);
      if (step.vw == -1) {
        if (boat.crewL == wolf) {
          boat.moveBackCrewL();
        } else {
          boat.moveBackCrewR();
        }
      } else if (step.vl == -1) {
        if (boat.crewL == lamb) {
          boat.moveBackCrewL();
        } else {
          boat.moveBackCrewR();
        }
      } else if (step.vw == 1) {
        wolf.moveToBoat();
      } else if (step.vl == 1) {
        lamb.moveToBoat();
      }
      break;
    }
  }
}

class TrailStep {
  int cmd, vw, vl;
  TrailStep(int cmd_, int vw_, int vl_) {
    cmd = cmd_;
    vw = vw_;
    vl = vl_;
  }
}

class AutoMode {
  Solver solver;
  Trail trail;
  AutoMode() {
    trail = new Trail();
    solver = new Solver(wolfL.n, lambL.n,
                        boat.nWolf(), boat.nLamb(),
                        wolfR.n, lambR.n, (state == AT_LEFT),
                        trail);
    new Thread(solver).start();
  }
  boolean canRun() {
    return solver.finished;
  }
  void draw() {
    drawBanner();
    if (canRun()) {
      trail.run();
    }
  }

  final String banner = "AUTOMODE";
  final float Y = 100;
  int t = 0;
  final int F = 360;
  void drawBanner() {
    textAlign(CENTER, CENTER);
    int n = banner.length();
    float alpha = 355 * sin(TWO_PI * t / F);
    for (int i = 0; i < banner.length(); i++) {
      char c = banner.charAt(i);
      textFont(fontStock.banner);
      textSize(40);
      fill(210, 50, 50, alpha);
      text("" + c, width/2 + (i - (n - 1)/2.0) * 45, Y);
    }
    t++;
  }
}

