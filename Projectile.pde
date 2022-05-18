final class Projectile extends Particle {
  // Globals
  PVector position;
  int gameWidth, gameHeight;
  int projectileWidth, projectileHeight;
  int projectileSize;
  float invMass;
  PVector velocity;
  PVector acceleration;
  boolean exploding = false;
  boolean exploded = false;
  boolean hasShrunk = false;
  int bombTimer = 20;
  float explosionMultiplier = 1.09;

  // Vector to accumulate forces before integration
  PVector forceAccumulator;
  
  // Constructor
  Projectile(int x, int y, int projectileWidth, int projectileHeight, int mass, PVector force, PVector acceleration, int gameWidth, int gameHeight) {
    position = new PVector(x, y);
    this.gameWidth = gameWidth;
    this.gameHeight = gameHeight;
    this.projectileWidth = projectileWidth;
    this.projectileHeight = projectileHeight;
    this.projectileSize = projectileWidth;
    this.invMass = 1/mass;
    this.velocity = getAcceleration(force, this.invMass);
    this.acceleration = acceleration;
    this.forceAccumulator = new PVector(0, 0);
  }
  
  // Handle reset
  void reset(int x, int y) {
    position.x = x;
    position.y = y;
  }
  
  void draw(boolean earth, boolean paused) {
    // If the projectile is exploding
    if (exploding) {
      if (paused) {
        colorMode(RGB);
        fill(255, 91, 20);
        ellipse(position.x, position.y, projectileWidth, projectileHeight);
        return;
      }
      if (bombTimer < 0) {
        // Shrink the explosion after 50 frames of exploding
        if (bombTimer > -50) {
          projectileWidth *= 0.9;
          projectileHeight *= 0.9;
          ellipse(position.x, position.y, projectileWidth, projectileHeight);
        } else { // After 50 frames, the meteorite has exploded
          exploded = true;
          exploding = false;
        }
      }
      colorMode(RGB);
      fill(255, 91, 20);
      // Explosions begin by shrinking for one frame to immitate a real explosion
      if (!hasShrunk) {
        ellipse(position.x, position.y, projectileWidth/2, projectileHeight/2);
        hasShrunk = true;
      } else { // After shrinking, the explosion will grow by a factor of 'explosionMultiplier' each frame
        projectileWidth *= explosionMultiplier;
        projectileHeight *= explosionMultiplier;
        ellipse(position.x, position.y, projectileWidth, projectileHeight);
        bombTimer -= 1;
      }
    } else if (!exploding && !exploded) { // If the Projectile is not exploding then appear as white and regular size
      fill(255);
      ellipse(position.x, position.y, projectileWidth, projectileHeight);
    }
    projectileSize = projectileWidth;
  }

  void addForce(PVector force) {
    forceAccumulator.add(force); // Mass = 4 causes bug
    forceAccumulator.add(force); // Repeated application
    forceAccumulator.add(force); // of gravity gives
    forceAccumulator.add(force); // same effect.
  }
  
  void explode() {
    exploding = true;
  }
  
  // Return true if the meteorite is on the screen
  boolean move() {
    return((position.x < gameWidth) && (position.x > 0) && (position.y < gameHeight));
  }

  // Apply gravity, drag, and other forces to the projectile
  void integrate() {
    // If mass is infinite then forces will have no effect
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
  
  boolean isExploding() {
    return exploding;
  }
  
  boolean isExploded() {
    return exploded;
  }
  
  int getSize() {
    return projectileWidth;
  }
  
  PVector getAcceleration(PVector force, float invMass) {
    return (force.mult(invMass));
  }

  float getMass() {
    return 1/invMass;
  }
  
}
