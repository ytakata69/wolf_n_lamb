class MenuBar {
  void draw() {
    for (int x = 0; x < width; x += imageStock.bShadow.width) {
      image(imageStock.bShadow, x, 5);
    }
    fill(0);
    noStroke();
    rect(0, 0, width, 10);
    fill(255);
    textFont(fontStock.menu);
    textSize(18);
    textAlign(LEFT, TOP);
    text("Reset", 10, 3);
    text((autoMode == null ? "Auto" : "Manual"), 100, 3);
  }

  boolean resetIsPointed(float mx, float my) {
    return 10 < mx && mx < 60 && 0 < my && my < 20;
  }
  boolean autoIsPointed(float mx, float my) {
    return 100 < mx && mx < 160 && 0 < my && my < 20;
  }
}

class Footer {
  int width, height;
  int x, y;
  Footer(int width_, int height_, int x_, int y_) {
    width  = width_;
    height = height_;
    x = x_;
    y = y_;
  }

  void draw() {
    String copyright = imageStock.copyright() + ", "
                     + audioStock.copyright();
    fill(204);
    noStroke();
    rect(0, y, width, height);
    fill(128);
    textFont(fontStock.menu);
    textSize(12);
    textAlign(RIGHT, CENTER);
    text(copyright, width - 10, y + height/2);
  }
}

class Screen {
  int width, height;
  int x, y;
  Screen(int width_, int height_, int x_, int y_) {
    width  = width_;
    height = height_;
    x = x_;
    y = y_;
  }

  void draw() {
    translate(x, 0);
    water.draw();
    green.draw();
    wolfL.draw();
    lambL.draw();
    wolfR.draw();
    lambR.draw();
    translate(-x, 0);
  }
}

class Animal {
  final int MAX_N = 3;
  int n;
  int pos;
  int x, y, h;
  Animal opp;
  PImage img;

  Animal(int pos_) {
    pos = pos_;
  }

  void draw() {
    for (int i = -MAX_N; i < 0; i++) {
      if (i + n >= 0) {
        image(img, x + (pos == LEFT ? 0 : width - green.bankW), y + i * h);
      }
    }
  }
  void drawOnBoat(int pos) {
    float yy = boat.y - img.height + 50;
    switch (pos) {
    case LEFT:
      image(img, boat.x + 15, yy);
      break;
    case RIGHT:
      image(img, boat.x + 100, yy);
      break;
    }
  }
  void drawCross() {
    image(imageStock.cross, x + (pos == LEFT ? 0 : width - green.bankW) + 50, y + 100);
  }

  boolean isPointed(float mx, float my) {
    float xx = x + (pos == LEFT ? 0 : width - green.bankW);
    return n > 0 &&
      xx + 2 < mx && mx < xx + 98 &&
      y - n * h + 5 < my && my < y + 120;
  }
  boolean isPointedOnBoat(float mx, float my, int pos) {
    float minX = boat.x + (pos == LEFT ?  17 : 115);
    float maxX = boat.x + (pos == LEFT ? 105 : 200);
    return minX < mx && mx < maxX &&
      boat.y - 145 < my && my < boat.y + 20;
  }

  void moveToBoat() {
    if (boat.crewL == null) {
      boat.crewL = this;
      n--;
    } else if (boat.crewR == null) {
      boat.crewR = this;
      n--;
    }
  }
}

class Wolf extends Animal {
  Wolf(int pos) {
    super(pos);
    x = 30;
    y = int(screen.height * 0.55);
    h = 60;
    img = imageStock.wolf;
  }
}

class Lamb extends Animal {
  Lamb(int pos) {
    super(pos);
    x = 155;
    y = int(screen.height * 0.55) + 20;
    h = 60;
    img = imageStock.lamb;
  }
}


class Boat {
  Boat() {
    x = green.bankW;
    y = screen.height/2;
  }
  float x, y;
  int dir = RIGHT;
  Animal crewL = null;
  Animal crewR = null;
  int boatW = imageStock.boatRL.width;

  boolean isEmpty() {
    return crewL == null && crewR == null;
  }
  int nWolf() {
    int n = 0;
    if (crewL != null && crewL instanceof Wolf) n++;
    if (crewR != null && crewR instanceof Wolf) n++;
    return n;
  }
  int nLamb() {
    int n = 0;
    if (crewL != null && crewL instanceof Lamb) n++;
    if (crewR != null && crewR instanceof Lamb) n++;
    return n;
  }

  boolean goAhead() {
    if (dir == LEFT  && x <= green.bankW) return false;
    if (dir == RIGHT && x >= width - green.bankW - boatW) return false;
    x += (dir == RIGHT ? 1.0 : -1.0);
    return true;
  }

  void moveBackCrewL() {
    if (boat.crewL != null) {
      boat.crewL.n++;
      boat.crewL = null;
    }
  }
  void moveBackCrewR() {
    if (boat.crewR != null) {
      boat.crewR.n++;
      boat.crewR = null;
    }
  }
  boolean crewLIsPointed(float mx, float my) {
    return crewL != null && crewL.isPointedOnBoat(mx, my, LEFT);
  }
  boolean crewRIsPointed(float mx, float my) {
    return crewR != null && crewR.isPointedOnBoat(mx, my, RIGHT);
  }

  final int upper = 19;
  void draw() {
    PImage imgU = (dir == RIGHT ? imageStock.boatRU : imageStock.boatLU);
    PImage imgL = (dir == RIGHT ? imageStock.boatRL : imageStock.boatLL);
    image(imgU, x, y - upper);
    if (crewL != null) crewL.drawOnBoat(LEFT);
    if (crewR != null) crewR.drawOnBoat(RIGHT);
    image(imgL, x, y);
    if (state == RESETTING) {
      image(imageStock.boatRU, width, y - upper);
      image(imageStock.boatRL, width, y);
    }
  }

  boolean arrowIsPointed(float mx, float my) {
    return ! isEmpty() &&
      x + 70 < mx && mx < x + 150 &&
      y + 70 < my && my < y + 140;
  }
  void drawArrow() {
    PImage img = (dir == RIGHT ? imageStock.arrowR : imageStock.arrowL);
    image(img, x + 60, y + 60);
    //noFill();
    //rect(boat.x + 70, boat.y + 70, 80, 70);
  }
}

class Water {
  float[] x, y, fx, fy, ax, ay;
  int t = 300;
  int boatPos;
  Water() {
    int n = (screen.height + 200) / 50;
    x  = new float[n];
    y  = new float[n];
    fx = new float[n];
    fy = new float[n];
    ax = new float[n];
    ay = new float[n];
    for (int i = 0; i < x.length; i++) {
      x[i] = 200 + random(-70, 70);
      y[i] = -100 + 50 * i + random(-5, 5);
      fx[i] = random(90, 180);
      fy[i] = random(90, 180);
      ax[i] = random(5, 10);
      ay[i] = random(2, 5);
    }
    boatPos = n / 2 + 2;
  }
  void draw() {
    for (int i = 0; i < x.length; i++) {
      float xx = x[i] + ax[i] * sin(t * TWO_PI/fx[i]);
      float yy = y[i] + ay[i] * sin(t * TWO_PI/fy[i]);
      if (i == boatPos) {
        boat.y = yy - 25;
        boat.draw();
      }
      image(imageStock.water, xx, yy);
      if (state == RESETTING) {
        image(imageStock.water, xx + width - green.bankW, yy);
      }
    }
    t++;
  }

  String banner = "CONGRATULATION!";
  void drawBanner() {
    textFont(fontStock.banner);
    textAlign(CENTER, CENTER);
    int n = banner.length();
    for (int i = 0; i < banner.length(); i++) {
      char c = banner.charAt(i);
      int j = i % y.length;
      float yy = 100 + ay[j] * sin(t * TWO_PI/fy[j]);
      textSize(40);
      fill(0);
      text("" + c, width/2 + (i - n/2) * 45 + 4, yy + 4);
      textSize(40);
      fill(255, 50, 50);
      text("" + c, width/2 + (i - n/2) * 45, yy);
    }
  }
}

class Green {
  void draw() {
    // shadow
    for (int y = 0; y < screen.height; y += shadowTileH) {
      image(imageStock.shadow, bankW - shadowTileW + 20, y);
      image(imageStock.shadow, width - bankW - 20, y);
      if (state == RESETTING) {
        image(imageStock.shadow, width - shadowTileW + 20, y);
        image(imageStock.shadow, (width - bankW) * 2 - 20, y);
      }
    }
    // green
    for (int x = 0; x < bankW; x += tileW) {
      for (int y = 0; y < screen.height; y += tileH) {
        image(imageStock.green, x, y);
        image(imageStock.green, width - bankW + x, y);
        if (state == RESETTING) {
          image(imageStock.green, (width - bankW) * 2 + x, y);
        }
      }
    }
  }
  int tileW = imageStock.green.width;
  int tileH = imageStock.green.height;
  int shadowTileW = imageStock.shadow.width;
  int shadowTileH = imageStock.shadow.height;
  int bankW = tileW * 2;
}
