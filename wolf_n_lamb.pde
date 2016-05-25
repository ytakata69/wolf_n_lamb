/**
 * Wolfs & Lambs: an implementation of a classic river-crossing puzzle.
 * Programmed by Yoshiaki Takata, 2013.
 * See Stock.pde for the image materials and sound effects.
 */
void setup() {
  size(1024, 540);
  screen = new Screen(width, 520, 0, 0);
  footer = new Footer(width, 20, 0, 520);
  menuBar = new MenuBar();
  imageStock = new ImageStock();
  water = new Water();
  green = new Green();
  boat  = new Boat();
  wolfL = new Wolf(LEFT);
  lambL = new Lamb(LEFT);
  wolfR = new Wolf(RIGHT);
  lambR = new Lamb(RIGHT);
  wolfL.opp = wolfR;
  wolfR.opp = wolfL;
  lambL.opp = lambR;
  lambR.opp = lambL;
  initialize();
  audioStock = new AudioStock(this);
  fontStock  = new FontStock();
  audioStock.playBGM();
}

void stop() {
  audioStock.close();
  super.stop();
}

Water water;
Green green;
Boat  boat;
Wolf  wolfL, wolfR;
Lamb  lambL, lambR;
Screen screen;
Footer footer;
MenuBar menuBar;
ImageStock imageStock;
AudioStock audioStock;
FontStock  fontStock;
AutoMode autoMode = null;

final int AT_LEFT = 0;
final int MOVING_TO_RIGHT = 1;
final int AT_RIGHT = 2;
final int MOVING_TO_LEFT = 3;
final int GOAL = -1;
final int RESETTING = -2;
int state;

void draw() {
  screen.draw();

  if (state == AT_RIGHT && wolfL.n == 0 && lambL.n == 0) {
    state = GOAL;
    audioStock.playFanfare();
  }
  switch (state) {
  case AT_LEFT:
  case AT_RIGHT:
    if (! bankIsOk(wolfL, lambL)) {
      wolfL.drawCross();
    }
    if (! bankIsOk(wolfR, lambR)) {
      wolfR.drawCross();
    }
    if (canGo()) {
      boat.drawArrow();
    }
    break;
  case MOVING_TO_RIGHT:
  case MOVING_TO_LEFT:
    if (! boat.goAhead()) {
      if (boat.crewL != null) {
        boat.crewL = boat.crewL.opp;
        boat.moveBackCrewL();
      }
      if (boat.crewR != null) {
        boat.crewR = boat.crewR.opp;
        boat.moveBackCrewR();
      }
      state = (state == MOVING_TO_RIGHT ? AT_RIGHT : AT_LEFT);
      boat.dir = (boat.dir == RIGHT ? LEFT : RIGHT);
    }
    break;
  case GOAL:
    water.drawBanner();
    autoMode = null;
    break;
  case RESETTING:
    screen.x -= 2;
    if (screen.x <= green.bankW - screen.width) {
      screen.x = 0;
      initialize();
    }
    break;
  }

  if (autoMode != null) autoMode.draw();
  menuBar.draw();
  footer.draw();
}

void mousePressed() {
  if (state == AT_LEFT && autoMode == null) {
    if (wolfL.isPointed(mouseX, mouseY)) {
      wolfL.moveToBoat();
    } else if (lambL.isPointed(mouseX, mouseY)) {
      lambL.moveToBoat();
    } else if (boat.crewLIsPointed(mouseX, mouseY)) {
      boat.moveBackCrewL();
    } else if (boat.crewRIsPointed(mouseX, mouseY)) {
      boat.moveBackCrewR();
    } else if (canGo() && boat.arrowIsPointed(mouseX, mouseY)) {
      state = MOVING_TO_RIGHT;
    }
  } else if (state == AT_RIGHT && autoMode == null) {
    if (wolfR.isPointed(mouseX, mouseY)) {
      wolfR.moveToBoat();
    } else if (lambR.isPointed(mouseX, mouseY)) {
      lambR.moveToBoat();
    } else if (boat.crewLIsPointed(mouseX, mouseY)) {
      boat.moveBackCrewL();
    } else if (boat.crewRIsPointed(mouseX, mouseY)) {
      boat.moveBackCrewR();
    } else if (canGo() && boat.arrowIsPointed(mouseX, mouseY)) {
      state = MOVING_TO_LEFT;
    }
  }
  boolean canReset = (state != RESETTING && (autoMode == null || autoMode.canRun()));
  if (menuBar.resetIsPointed(mouseX, mouseY) && canReset) {
    if (state == GOAL) {
      state = RESETTING;
    } else {
      initialize();
    }
  }
  if (menuBar.autoIsPointed(mouseX, mouseY) &&
      canReset && state != GOAL)
  {
    if (autoMode == null) {
      if (state == AT_LEFT || state == AT_RIGHT) {
        autoMode = new AutoMode();
      }
    } else {
      autoMode = null;
    }
  }
}

void initialize() {
  wolfL.n = lambL.n = 3;
  wolfR.n = lambR.n = 0;
  boat.crewL = boat.crewR = null;
  boat.x = green.bankW;
  boat.dir = RIGHT;
  state = AT_LEFT;
  autoMode = null;
}

boolean canGo() {
  return ! boat.isEmpty() && bankIsOk(wolfL, lambL) && bankIsOk(wolfR, lambR);
}

boolean bankIsOk(Wolf wolf, Lamb lamb) {
  int wolfN = wolf.n;
  int lambN = lamb.n;
  if (0 < lambN && lambN < wolfN) return false;
  if (boat.crewL == wolf.opp) wolfN++;
  if (boat.crewL == lamb.opp) lambN++;
  if (boat.crewR == wolf.opp) wolfN++;
  if (boat.crewR == lamb.opp) lambN++;
  if (0 < lambN && lambN < wolfN) return false;
  return true;
}
