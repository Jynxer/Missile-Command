final class Bomber {
    // Globals
    PVector position;
    int gameWidth, gameHeight;
    int bomberWidth, bomberHeight;
    int bomberSize;
    PVector velocity;
    boolean exploding = false;
    boolean exploded = false;
    boolean hasShrunk = false;
    int bombTimer = 20;
    int age = 0;
    float explosionMultiplier = 1.07;
    boolean startLeft;

    // Constructor
    Bomber(int x, int y, int bomberWidth, int bomberHeight, int gameWidth, int gameHeight, boolean startLeft) {
        this.position = new PVector(x, y);
        this.bomberWidth = bomberWidth;
        this.bomberHeight = bomberHeight;
        this.bomberSize = bomberWidth;
        this.gameWidth = gameWidth;
        this.gameHeight = gameHeight;
        this.startLeft = startLeft;
        if (x < 0) {
            this.velocity = new PVector(2, 0);
        } else {
            this.velocity = new PVector(-2, 0);
        }
    }

    void draw(boolean earth, boolean paused) {
        // If the bomber is exploding
        if (exploding) {
            if (paused) {
                colorMode(RGB);
                fill(255, 91, 20);
                ellipse(position.x, position.y, bomberWidth, bomberHeight);
                return;
            }
            if (bombTimer < 0) {
                // Shrink the explosion after 50 frames
                if (bombTimer > -50) {
                    bomberWidth *= 0.9;
                    bomberHeight *= 0.9;
                ellipse(position.x, position.y, bomberWidth, bomberHeight);
                } else { // After 50 frames, the bomber has exploded
                    exploded = true;
                    exploding = false;
                }
            }
            colorMode(RGB);
            fill(255, 91, 20);
            // Explosions begin by shrinking for one frame to immitate a real explosion
            if (!hasShrunk) {
                ellipse(position.x, position.y, bomberWidth/2, bomberHeight/2);
                hasShrunk = true;
            } else { // After shrinking the explosion will grow by a factor of 'explosionMultiplier' each frame
                bomberWidth *= explosionMultiplier;
                bomberHeight *= explosionMultiplier;
                ellipse(position.x, position.y, bomberWidth, bomberHeight);
                bombTimer -= 1;
            }
        } else if (!exploding && !exploded) { // If the bomber is not exploding then appear grey and regular size
            if (earth) {
                fill(100, 100, 100);
            } else {
                fill(200, 200, 200);
            }
            ellipse(position.x, position.y, bomberWidth, bomberHeight);
        }
        bomberSize = bomberWidth;
    }

    // Return true if the bomber is on the screen
    boolean move() {
        return ((position.x <= gameWidth) && (position.x >= 0));
    }

    // The bombers have constant velocity with no gravity or drag acting on them
    void integrate() {
        position.add(velocity);
    }

    void reset(int x, int y) {
        position.x = x;
        position.y = y;
        bomberSize = bomberWidth;
        exploded = false;
    }

    void flipDirection() {
        velocity.mult(-1);
        pushOutOfWall();
    }

    void pushOutOfWall() {
        if (position.x >= gameWidth) {
            position.x = gameWidth;
        } else if (position.x <= 0) {
            position.x = 0;
        }
    }

    void explode() {
        exploding = true;
    }

    void age() {
        age++;
    }

}