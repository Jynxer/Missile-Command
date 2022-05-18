class Cloud {
    int x, y;
    int initialX, initialY;
    int cloudWidth, cloudHeight;
    int leftEdge, rightEdge;
    color colour;

    Cloud(int x, int y, int cloudWidth, int cloudHeight) {
        this.x = x;
        this.y = y;
        this.initialX = x;
        this.initialY = y;
        this.cloudWidth = cloudWidth;
        this.cloudHeight = cloudHeight;
        this.leftEdge = x-(cloudWidth * 5/6);
        this.rightEdge = x+(cloudWidth/2)+(int)(cloudWidth * 0.9 * 0.5);
        this.colour = #e6e6e6;
    }

    void draw() {
        fill(color(colour));
        noStroke();
        ellipse(x, y-(cloudHeight/4), (int)(cloudWidth * 1.25), (int)(cloudHeight * 1));
        ellipse(x+(cloudWidth/2), y, (int)(cloudWidth * 0.9), (int)(cloudHeight * 1.1));
        ellipse(x+(cloudWidth/6), y+(cloudHeight/2), (int)(cloudWidth * 1.25), (int)(cloudHeight * 0.9));
        ellipse(x-(cloudWidth/3), y+(cloudWidth/4), (int)(cloudWidth * 1), (int)(cloudHeight * 1.25));
        stroke(255);
        leftEdge = x-(cloudWidth * 5/6);
        rightEdge = x+(int)(cloudWidth * 0.95);
    }

    void offsetX(int pixels) {
        if (leftEdge >= 800) {
            reset();
        }
        x += pixels;
    }

    void reset() {
        x = -1 * (int)(cloudWidth * 0.95);
    }
}