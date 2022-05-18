class Planet {
    int x, y;
    int initialX, initialY;
    int planetWidth, planetHeight;
    color waterColour, landColour;
    int spinTicker;
    boolean earthType;

    Planet(int x, int y, int planetWidth, int planetHeight, boolean earthType) {
        this.x = x;
        this.y = y;
        this.initialX = x;
        this.initialY = y;
        this.planetWidth = planetWidth;
        this.planetHeight = planetHeight;
        this.earthType = earthType;
        if (earthType) {
            this.waterColour = #2389da;
            this.landColour = #268b07;
        } else {
            this.landColour = #b835ad;
            this.waterColour = #7206d1;
        }
        this.spinTicker = 0;
    }

    void draw() {
        fill(color(waterColour));
        stroke(0);
        ellipse(x, y, planetWidth, planetHeight);
        fill(color(landColour));
        noStroke();
        x = 0;
        y = 0;
        pushMatrix();
        translate(initialX, initialY);
        if (earthType) {
            rotate(radians(spinTicker/2));
        } else {
            rotate(radians(spinTicker));
        }
        ellipse((int)(x-(planetWidth/4)-(planetWidth/16)), (int)(y+(planetHeight/4)-(planetWidth/8)), (int)(planetWidth/4), (int)(planetHeight/4));
        ellipse((int)(x+(planetWidth/5)-(planetWidth/6)), (int)(y-(planetHeight/5)-(planetWidth/10)), (int)(planetWidth/3), (int)(planetHeight/3));
        ellipse((int)(x+(planetWidth/7)), (int)(y+(planetHeight/7)), (int)(planetWidth/2), (int)(planetHeight/2));
        popMatrix();
        x = initialX;
        y = initialY;
        stroke(0);
        if (earthType) {
            spinTicker++;
        } else {
            spinTicker--;
        }
    }
}