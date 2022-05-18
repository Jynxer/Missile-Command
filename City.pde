class City {
    // Globals
    PVector position;
    int cityWidth, cityHeight;
    int explosionWidth, explosionHeight;
    int initialWidth, initialHeight;
    int gameHeight;
    boolean exploding = false;
    boolean exploded = false;
    int bombTimer = 10;
    float explosionMultiplier = 1.09;
    boolean destroyed;
    int[] buildingHeight;
    int[] debrisSize;
    int[] debrisXOffset;
    int[] debrisYOffset;

    // Constructor
    City(PVector position, int cityWidth, int cityHeight, int gameHeight) {// 32, 50
        this.position = position;
        this.cityWidth = cityWidth;
        this.cityHeight = cityHeight;
        this.initialWidth = cityWidth;
        this.initialHeight = cityHeight;
        this.gameHeight = gameHeight;
        this.explosionWidth = cityWidth / 2;
        this.explosionHeight = cityWidth / 2;
        this.destroyed = false;
        this.buildingHeight = new int[8];
        this.debrisSize = new int[8];
        this.debrisXOffset = new int[8];
        this.debrisYOffset = new int[8];
        for (int b = 0; b < 8; b++) {
            buildingHeight[b] = (int)random(10, 32);
            debrisSize[b] = (int)random(10, (int)(initialHeight * 1.5));
            debrisXOffset[b] = (int)random(1+(debrisSize[b]/2), 79-(debrisSize[b]/2));
            debrisYOffset[b] = (int)random(1, debrisSize[b] * 0.5);
        }
    }

    void draw(boolean earth, boolean paused) {
        // If the city is destroyed, it appears grey
        if (destroyed) {
            if (!earth) {
                fill(100, 100, 100);
            } else {
                fill(50, 50, 50);
            }
            for (int d = 0; d < 8; d++) {
                ellipse(position.x + debrisXOffset[d], gameHeight-debrisYOffset[d], debrisSize[d], debrisSize[d]);
            }
        } else { // If the city isn't destroyed, it appears grey
            if (earth) {
                fill(100, 100, 100);
            } else {
                fill(200, 200, 200);
            }
            for (int b = 0; b < 8; b++) {
                rect(position.x + 1 + (10 * b), gameHeight-buildingHeight[b], cityWidth/10, buildingHeight[b]);
            }
        }
        // If the city is exploding
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
                ellipse(position.x + (cityWidth/2), position.y + (cityHeight/2), explosionWidth, explosionHeight);
                } else { // After 50 frames, the city has exploded
                    exploded = true;
                    exploding = false;
                }
            }
            colorMode(RGB);
            fill(255, 91, 20);
            // The explosion will grow by a factor of 'explosionMultiplier' each frame
            explosionWidth *= explosionMultiplier;
            explosionHeight *= explosionMultiplier;
            ellipse(position.x + (cityWidth/2), position.y + (cityHeight/2), explosionWidth, explosionHeight);
            bombTimer -= 1;
        }
    };

    void destroy() {
        if (!destroyed) {
            destroyed = true;
            cityHeight = cityHeight / 2;
            position.y = gameHeight - cityHeight;
        }    
    }

    void rebuild() {
        if (destroyed) {
            destroyed = false;
            cityHeight = cityHeight * 2;
            position.y = gameHeight - cityHeight;
            exploding = false;
            exploded = false;
            bombTimer = 20;
            cityWidth = initialWidth;
            cityHeight = initialHeight;
        }
    }

    void explode() {
        exploding = true;
    }
}