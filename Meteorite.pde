final class Meteorite extends Particle {
  // Globals
  PVector position;
  int gameWidth, gameHeight;
  int meteoriteWidth, meteoriteHeight;
  int meteoriteSize;
  int initialWidth, initialHeight;
  float invMass;
  PVector velocity;
  PVector acceleration;
  boolean exploding = false;
  boolean exploded = false;
  boolean hasShrunk = false;
  int BOMB_SIZE_PROPORTION = 50;
  int explosionWidth;
  int explosionHeight;
  int bombTimer = 20;
  float explosionMultiplier = 1.09;
  boolean smartBomb;
  int redCycle;
  int greenCycle;
  int blueCycle;
  boolean redDone;
  boolean greenDone;
  boolean blueDone;
  boolean redDoneDecrementing;
  boolean greenDoneDecrementing;
  boolean blueDoneDecrementing;
  int vision;
  boolean dodged;

  // Vector to accumulate forces before integration
  PVector forceAccumulator;
  
  // Constructor
  Meteorite(int x, int y, int meteoriteWidth, int meteoriteHeight, int gameWidth, int gameHeight, int mass, PVector force, PVector acceleration, boolean smartBomb) {
    this.position = new PVector(x, y);
    this.gameWidth = gameWidth;
    this.gameHeight = gameHeight;
    this.explosionWidth = gameWidth / BOMB_SIZE_PROPORTION;
    this.explosionHeight = gameWidth / BOMB_SIZE_PROPORTION;
    this.meteoriteWidth = meteoriteWidth;
    this.meteoriteHeight = meteoriteHeight;
    this.meteoriteSize = meteoriteWidth;
    this.initialWidth = meteoriteWidth;
    this.initialHeight = meteoriteHeight;
    this.invMass = 1/mass;
    this.velocity = getAcceleration(force, this.invMass);
    this.acceleration = acceleration;
    this.forceAccumulator = new PVector(0, 0);
    this.smartBomb = smartBomb;
    this.redCycle = 255;
    this.greenCycle = 0;
    this.blueCycle = 0;
    this.redDone = false;
    this.greenDone = false;
    this.blueDone = false;
    this.redDoneDecrementing = false;
    this.greenDoneDecrementing = false;
    this.blueDoneDecrementing = false;
    this.vision = 50;
    this.dodged = false;
  }
  
  void draw(boolean earth, boolean paused) {
    // If the meteorite is exploding
    if (exploding) {
      if (paused) {
          colorMode(RGB);
          fill(255, 91, 20);
          ellipse(position.x, position.y, meteoriteWidth, meteoriteHeight);
          return;
      }
      if (bombTimer < 0) {
        // Shrink the explosion after 50 frames of exploding
        if (bombTimer > -50) {
          meteoriteWidth *= 0.9;
          meteoriteHeight *= 0.9;
          ellipse(position.x, position.y, meteoriteWidth, meteoriteHeight);
        } else { // After 50 frames, the meteorite has exploded
          exploded = true;
          exploding = false;
        }
      }
      colorMode(RGB);
      fill(255, 91, 20);
      // Explosions begin by shrinking for one frame to immitate a real explosion
      if (!hasShrunk) {
        ellipse(position.x, position.y, meteoriteWidth/2, meteoriteHeight/2);
        hasShrunk = true;
      } else { // After shrinking, the explosion will grow by a factor of 'explosionMultiplier' each frame
        meteoriteWidth *= explosionMultiplier;
        meteoriteHeight *= explosionMultiplier;
        ellipse(position.x, position.y, meteoriteWidth, meteoriteHeight);
        bombTimer -= 1;
      }
    } else if (!exploding && !exploded) { // If the Meteorite is not exploding then appear grey and regular size
      if (!smartBomb) {
        if (earth) {
          fill(0, 0, 0);
        } else {
          fill(247, 231, 200);
        }
        ellipse(position.x, position.y, meteoriteWidth, meteoriteHeight);
      } else {
        // colorMode(HSB, 360, 100, 100);
        // fill(redCycle%255, greenCycle%255, blueCycle%255);
        fill(redCycle, greenCycle, blueCycle);
        ellipse(position.x, position.y, meteoriteWidth, meteoriteHeight);
        if ((greenCycle <= 255) && (!greenDone)) {
          greenCycle+=3;
        } else {
          greenDone = true;
          if ((redCycle > 0) && (!redDoneDecrementing)) {
            redCycle-=3;
          } else {
            redDoneDecrementing = true;
            if ((blueCycle <= 255) && (!blueDone)) {
              blueCycle+=3;
            } else {
              blueDone = true;
              if ((greenCycle > 0) && (!greenDoneDecrementing)) {
                greenCycle-=3;
              } else {
                greenDoneDecrementing = true;
                if ((redCycle <= 255) && (!redDone)) {
                  redCycle+=3;
                } else {
                  redDone = true;
                  if ((blueCycle > 0) && (!blueDoneDecrementing)) {
                    blueCycle-=3;
                  } else {
                    redCycle = 255;
                    greenCycle = 0;
                    blueCycle = 0;
                    redDone = false;
                    greenDone = false;
                    blueDone = false;
                    redDoneDecrementing = false;
                    greenDoneDecrementing = false;
                    blueDoneDecrementing = false;
                  }
                }
              }
            }
          }
        }
        colorMode(RGB);
        if (earth) {
          fill(0, 0, 0);
        } else {
          fill(247, 231, 200);
        }
      }
    }
    meteoriteSize = meteoriteWidth;
  }
  
  // Handle reset
  void reset(int x, int y) {
    position.x = x;
    position.y = y;
    meteoriteSize = meteoriteWidth;
    if (x >= 3*(gameWidth/4)) {
      velocity = new PVector(int(random(-3, 0)), 0);
    } else if (x <= gameWidth/4){
      velocity = new PVector(int(random(0, 3)), 0);
    } else {
      velocity = new PVector(int(random(-4, 4)), 0);
    }
    exploding = false;
    exploded = false;
    hasShrunk = false;
    bombTimer = 20;
    meteoriteWidth = initialWidth;
    meteoriteHeight = initialHeight;
  }

  // Return true if the meteorite is on the screen and set as exploded if not
  boolean move() {
    if ((position.x > gameWidth + 50) || (position.x < -50) || (position.y > gameWidth + 50)) {
      this.explode();
    }
    return((position.x < gameWidth) && (position.x > 0) && (position.y < gameHeight));
  }

  // Apply gravity, drag, and other forces to the meteorite
  void integrate() {
    // If mass is infinite forces will have no effect
    if (invMass <= 0) {
      return;
    }
    // Increment position by current velocity
    position.add(velocity);
    // Get a copy of the 'forceAccumulator' vector
    PVector resultingAcceleration = forceAccumulator.copy();
    // Multiply the accumulated forces by the inverse mass to get the resulting acceleration
    resultingAcceleration.mult(invMass);
    // Increment velocity by current acceleration
    velocity.add(resultingAcceleration);
    // Reset the force accumulator
    forceAccumulator.x = 0;
    forceAccumulator.y = 0;
  }

  void addForce(PVector force) {
    forceAccumulator.add(force);
  }

  void dodge(PVector force) {
    dodged = true;
    addForce(force);
  }
  
  void explode() {
    exploding = true;
    meteoriteWidth = explosionWidth;
    meteoriteHeight = explosionHeight;
  }

  void setExploded() {
    exploded = true;
  }

  void teleportTo(Meteorite meteorite) {
    this.position = meteorite.position.copy();
  }

  void copyKinematics(Meteorite meteorite) {
    this.velocity = meteorite.velocity.copy();
    this.acceleration = meteorite.acceleration.copy();
  }
  
  boolean isExploding() {
    return exploding;
  }
  
  boolean isExploded() {
    return exploded;
  }
  
  int getSize() {
    return meteoriteWidth;
  }

  int getX() {
     return (int)position.x;
  }
  
  int getY() {
     return (int)position.y;
  }

  PVector getAcceleration(PVector force, float invMass) {
    return(force.mult(invMass));
  }

  float getMass() {
    return 1/invMass;
  }
}
