final class Ballistae {
  // Globals
  PVector position;
  int ballistaeWidth, ballistaeHeight;
  int initialWidth, initialHeight;
  int explosionWidth, explosionHeight;
  int gameHeight;
  boolean exploding = false;
  boolean exploded = false;
  int bombTimer = 10;
  float explosionMultiplier = 1.09;
  int ammo;
  boolean active;
  boolean destroyed;
  int[] debrisSize;
  int[] debrisXOffset;
  int[] debrisYOffset;
  
  // Constructor
  Ballistae(PVector position, int ballistaeWidth, int ballistaeHeight, int gameHeight) {
    this.position = position;
    this.ballistaeWidth = ballistaeWidth;
    this.ballistaeHeight = ballistaeHeight;
    this.initialWidth = ballistaeWidth;
    this.initialHeight = ballistaeHeight;
    this.explosionWidth = (int)(ballistaeHeight / 1.5);
    this.explosionHeight = (int)(ballistaeHeight / 1.5);
    this.gameHeight = gameHeight;
    this.ammo = 10;
    this.active = false;
    this.destroyed = false;
    this.debrisSize = new int[4];
    this.debrisXOffset = new int[4];
    this.debrisYOffset = new int[4];
    for (int b = 0; b < 4; b++) {
        debrisSize[b] = (int)random(10, (int)(initialHeight * 0.7));
        debrisXOffset[b] = (int)random(1+(debrisSize[b]/3), 32-(debrisSize[b]/3));
        debrisYOffset[b] = (int)random(1, debrisSize[b] * 0.5);
    }
  }
  
  void draw(boolean earth, boolean paused) {
    stroke(0);
    strokeWeight(1);
    // If the ballistae is destroyed, it appears grey
    if (destroyed) {
      if (!earth) {
          fill(100, 100, 100);
      } else {
          fill(50, 50, 50);
      }
      for (int d = 0; d < 4; d++) {
          ellipse(position.x + debrisXOffset[d], gameHeight-debrisYOffset[d], debrisSize[d], debrisSize[d]);
      }
    } else { // If the ballistae isn't destroyed
      if (earth) {
        fill(80, 40, 0); // Appear as brown
      } else {
        fill(219, 179, 150); // Appear as light brown
      }
      if (active) { // Outline yellow if active
        stroke(250, 231, 57);
        strokeWeight(5);
        rect(position.x, position.y, ballistaeWidth, ballistaeHeight);
        stroke(0);
        strokeWeight(1);
      } else {
        rect(position.x, position.y, ballistaeWidth, ballistaeHeight);
      }
    }
    // If the ballistae is exploding
    if (exploding) {
      if (paused) {
        colorMode(RGB);
        fill(255, 91, 20);
        ellipse(position.x, position.y, bomberWidth, bomberHeight);
        return;
      }
      destroy();
      if (bombTimer < 0) {
          // Shrink the explosion after 50 frames of exploding
          if (bombTimer > -50) {
              explosionWidth *= 0.9;
              explosionHeight *= 0.9;
          ellipse(position.x + (ballistaeWidth/2), position.y + (ballistaeHeight/2), explosionWidth, explosionHeight);
          } else { // After 50 frames, the ballistae has exploded
              exploded = true;
              exploding = false;
          }
      }
      colorMode(RGB);
      fill(255, 91, 20);
      // The explosion will grow by a factor of 'explosionMultiplier' each frame
      explosionWidth *= explosionMultiplier;
      explosionHeight *= explosionMultiplier;
      ellipse(position.x + (ballistaeWidth/2), position.y + (ballistaeHeight/2), explosionWidth, explosionHeight);
      bombTimer -= 1;
    }
  }

  // Return the coordinates of where bombs should be thrown from
  PVector getCannonX() {
    PVector temp = position.copy();
    temp.add(new PVector(ballistaeWidth/2, 0));
    return temp;
  }

  void decrementAmmo() {
    ammo--;
  }

  void resetAmmo() {
    ammo = 10;
  }

  boolean hasAmmo() {
    if (ammo <= 0) {
      return false;
    } else {
      return true;
    }
  }

  void activate() {
    active = true;
  }

  void deactivate() {
    active = false;
  }

  void destroy() {
    if (!destroyed) {
      destroyed = true;
      ballistaeHeight = ballistaeHeight / 2;
      position.y = gameHeight - ballistaeHeight;
    }
  }

  void rebuild() {
    if (destroyed) {
      destroyed = false;
      ballistaeHeight = ballistaeHeight * 2;
      position.y = gameHeight - ballistaeHeight;
    }
  }

  void explode() {
    exploding = true;
  }
}
