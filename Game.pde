// Imports

import ddf.minim.*;

// Globals

final int GAME_WIDTH = 800;
final int GAME_HEIGHT = 800;

int BALLISTAE_WIDTH_PROPORTION = 25,
    BALLISTAE_HEIGHT_PROPORTION = 16;
int CITY_WIDTH_PROPORTION = 10,
    CITY_HEIGHT_PROPORTION = 25;
int CROSSHAIR_SIZE_PROPORTION = 100;
int BOMB_FORCE_PROPORTION = 25,
    BOMB_SIZE_PROPORTION = 50,
    BOMB_MASS = 1,
    BOMB_COUNT = 30;
int METEORITE_SIZE_PROPORTION = 60,
    METEORITE_INIT_X_PROPORTION = 2,
    METEORITE_INCREMENT_PROPORTION = 800,
    METEORITE_MASS = 1;
int BOMBER_SIZE_PROPORTION = 25,
    BOMBER_INIT_Y_PROPORTION = 15,
    BOMBER_SPEED_PROPORTION = 800,
    BOMBER_MAX_COUNT = 3;
int SMART_BOMB_CHANCE = 15;

int xStart, yStart, xEnd, yEnd;
int xStartLeft, xStartMiddle, xStartRight;
float magnitude;
PVector startPosition;
PVector startPositionLeft;
PVector startPositionRight;
boolean atHomepage, atPregame, atGame, atEndgame;
Ballistae[] ballistae;
int ballistaeWidth, ballistaeHeight;
int activeBallistae;
boolean disableFiring;
City[] cities;
int cityWidth, cityHeight;
int METEORITE_MAX_COUNT;
Meteorite[] meteorites;
boolean[] meteoriteActive;
int meteoriteWidth;
int meteoriteHeight;
int meteoriteSize;
int nextMeteorite;
PVector v, n;
boolean[] firing;
Projectile[] bomb;
int nextBomb;
int bomberSize;
Bomber bombers[];
boolean[] bomberActive;
int bomberWidth;
int bomberHeight;
int nextBomber;
PVector initialForce;
PVector accelerationDueToGravity;
int score;
int timer;
int wave;
int spawnTimer;
int bomberSpawnTimer;
int bomberDropMeteoriteTime;
int enemiesLeft;
int waveEnemies;
int wavePoints;
int scoreMultiplier;
int numOfParticles;
int chanceOfSplitting;
int enemiesLeftOnLastBomberSpawn;
int bomberMeteorites;
int waveBombers;
int highScore;
int lastHighScore;
Cloud[] clouds;
int cloudWidth;
int cloudHeight;
Planet planetEarth, foreignPlanet;
int planetWidth, planetHeight;
Gravity gravity;
Drag drag;
ForceRegistry forceRegistry;
boolean earth;
boolean paused;

Minim minim;
AudioPlayer s0, s1, s2, s3, s4, s5, s6, s7, s8;

void setup() {
  /*
  INITIAL SETUP
  */
  size(800, 800);
  // fullScreen();
  frameRate(30);
  earth = true;
  ballistae = new Ballistae[3];
  activeBallistae = 1;
  disableFiring = false;
  METEORITE_MAX_COUNT = 5;
  meteorites = new Meteorite[METEORITE_MAX_COUNT];
  meteoriteActive = new boolean[METEORITE_MAX_COUNT];
  firing = new boolean[BOMB_COUNT];
  bomb = new Projectile[BOMB_COUNT];
  bombers = new Bomber[BOMBER_MAX_COUNT];
  bomberActive = new boolean[BOMBER_MAX_COUNT];
  cities = new City[6];
  accelerationDueToGravity = new PVector(0, 0.1);
  nextMeteorite = 0;
  v = new PVector(0, 0);
  n = new PVector(0, 0);
  nextBomb = 0;
  nextBomber = 0;
  score = 0;
  timer = 0;
  wave = 1;
  atHomepage = true;
  atPregame = false;
  atGame = false;
  atEndgame = false;
  spawnTimer = 50;
  bomberDropMeteoriteTime = 250;
  enemiesLeft = METEORITE_MAX_COUNT;
  waveEnemies = enemiesLeft;
  bomberSpawnTimer = (int)(waveEnemies / 2);
  wavePoints = 0;
  scoreMultiplier = 1;
  numOfParticles = METEORITE_MAX_COUNT + BOMBER_MAX_COUNT;
  chanceOfSplitting = 800;
  enemiesLeftOnLastBomberSpawn = 0;
  bomberMeteorites = 0;
  waveBombers = 0;
  highScore = -1;
  paused = false;
  if (earth) {
    gravity = new Gravity(new PVector(0f, .075f));
    drag = new Drag(10, 10);
  } else {
    gravity = new Gravity(new PVector(0f, .012f));
    drag = new Drag(0, 0);
  }
  forceRegistry = new ForceRegistry();
  clouds = new Cloud[3];
  minim = new Minim(this);
  // s0 = minim.loadFile("./sounds/music.wav", 1024);
  s1 = minim.loadFile("./sounds/fire.mp3", 1024);
  s2 = minim.loadFile("./sounds/waveComplete.mp3", 1024);
  s3 = minim.loadFile("./sounds/groundExplosion.mp3", 1024);
  s4 = minim.loadFile("./sounds/groundExplosion.mp3", 1024);
  s5 = minim.loadFile("./sounds/airExplosion.mp3", 1024);
  s6 = minim.loadFile("./sounds/airExplosion.mp3", 1024);
  s7 = minim.loadFile("./sounds/airExplosion.mp3", 1024);
  s8 = minim.loadFile("./sounds/gameOver.mp3", 1024);
  // s0.loop();
  /*
  INSTANTIATE BALLISTAE
  */
  ballistaeWidth = GAME_WIDTH / BALLISTAE_WIDTH_PROPORTION;
  ballistaeHeight = GAME_WIDTH / BALLISTAE_HEIGHT_PROPORTION;
  startPosition = new PVector(GAME_WIDTH/2 - ballistaeWidth/2, GAME_HEIGHT - ballistaeHeight);
  xStartMiddle = (int)startPosition.x + (ballistaeWidth/2);
  xStart = xStartMiddle;
  yStart = (int)startPosition.y;
  ballistae[1] = new Ballistae(startPosition, ballistaeWidth, ballistaeHeight, GAME_HEIGHT);
  ballistae[1].activate();
  startPositionLeft = new PVector(16, GAME_HEIGHT-ballistaeHeight);
  xStartLeft = (int)startPositionLeft.x + (ballistaeWidth/2);
  ballistae[0] = new Ballistae(startPositionLeft, ballistaeWidth, ballistaeHeight, GAME_HEIGHT);
  startPositionRight = new PVector(752, GAME_HEIGHT-ballistaeHeight);
  xStartRight = (int)startPositionRight.x + (ballistaeWidth/2);
  ballistae[2] = new Ballistae(startPositionRight, ballistaeWidth, ballistaeHeight, GAME_HEIGHT);
  /*
  INSTANTIATE CITIES
  */
  cityWidth = GAME_WIDTH / CITY_WIDTH_PROPORTION;
  cityHeight = GAME_HEIGHT / CITY_HEIGHT_PROPORTION;
  int cityInitX = int(2.25 * ballistaeWidth);
  for (int c = 0; c < 6; c++) {
    PVector cityPosition = new PVector(cityInitX, GAME_HEIGHT - cityHeight);
    cities[c] = new City(cityPosition, cityWidth, cityHeight, GAME_HEIGHT);
    cityInitX += (cityWidth + (0.75 * ballistaeWidth));
    if (c == 2) {
      cityInitX += (1.75 * ballistaeWidth);
    }
  }
  /*
  INSTANTIATE BOMBS
  */
  initialForce = new PVector(0, 0);
  for (int i = 0; i < BOMB_COUNT; i++) {
    bomb[i] = new Projectile(xStart, yStart, GAME_WIDTH/BOMB_SIZE_PROPORTION, GAME_WIDTH/BOMB_SIZE_PROPORTION, BOMB_MASS, initialForce, accelerationDueToGravity, GAME_WIDTH, GAME_HEIGHT);
    firing[i] = false;
  }
  /*
  INSTANTIATE METEORITES
  */
  meteoriteWidth = GAME_WIDTH/METEORITE_SIZE_PROPORTION;
  meteoriteHeight = GAME_WIDTH/METEORITE_SIZE_PROPORTION;
  for (int j = 0; j < METEORITE_MAX_COUNT; j++) {
    int meteoriteInitX = int(random(meteoriteWidth, GAME_WIDTH-meteoriteWidth));
    int meteoriteInitY = 0;
    PVector meteoriteInitForce = new PVector(0, 0);
    if (meteoriteInitX >= 3*(GAME_WIDTH/4)) {
      meteoriteInitForce = new PVector(int(random(-3, 0)), 0);
    } else if (meteoriteInitX <= GAME_WIDTH/4) {
      meteoriteInitForce = new PVector(int(random(0, 3)), 0);
    } else {
      meteoriteInitForce = new PVector(int(random(-4, 4)), 0);
    }
    meteorites[j] = new Meteorite(meteoriteInitX, meteoriteInitY, meteoriteWidth, meteoriteHeight, GAME_WIDTH, GAME_HEIGHT, METEORITE_MASS, meteoriteInitForce, accelerationDueToGravity, false);
    meteoriteActive[j] = false;
  }
  /*
  INSTANTIATE BOMBERS
  */
  bomberWidth = GAME_WIDTH/BOMBER_SIZE_PROPORTION;
  bomberHeight = GAME_HEIGHT/BOMBER_SIZE_PROPORTION;
  bomberSize = bomberWidth;
  for (int k = 0; k < BOMBER_MAX_COUNT; k++) {
    int bomberInitX = int(random(-2, 2));
    int bomberInitY;
    if (k == 0) {
      bomberInitY = GAME_HEIGHT/BOMBER_INIT_Y_PROPORTION;
    } else if (k == 1) {
      bomberInitY = (GAME_HEIGHT/BOMBER_INIT_Y_PROPORTION) + bomberHeight + 5;
    } else {
      bomberInitY = (GAME_HEIGHT/BOMBER_INIT_Y_PROPORTION) + (2 * bomberHeight) + 10;
    }
    PVector bomberInitVelocity = new PVector(int(random(1, 2)), 0);
    boolean startLeft = true;
    if (bomberInitX > 0) {
      bomberInitX = GAME_WIDTH-1;
      bomberInitVelocity = new PVector(int(random(-2, -1)), 0);
      startLeft = false;
    }
    bombers[k] = new Bomber(bomberInitX, bomberInitY, bomberWidth, bomberHeight, GAME_WIDTH, GAME_HEIGHT, startLeft);
    bomberActive[k] = false;
  }
  /*
  INSTANTIATE PROPS
  */
  cloudWidth = 150;
  cloudHeight = 100;
  clouds[0] = new Cloud(GAME_WIDTH - 100, 130, cloudWidth, cloudHeight); // Big
  clouds[1] = new Cloud(90, 240, (int)(cloudWidth * 0.75), (int)(cloudHeight * 0.75)); // Medium
  clouds[2] = new Cloud(GAME_WIDTH - 310, 320, (int)(cloudWidth * 0.5), (int)(cloudHeight * 0.5)); // Small
  planetWidth = 260;
  planetHeight = 260;
  planetEarth = new Planet(180, 530, planetWidth, planetWidth, true);
  planetWidth = 180;
  planetHeight = 180;
  foreignPlanet = new Planet(630, 240, planetWidth, planetWidth, false);
}

void draw() {
  if (earth) {
    background(135, 206, 235);
  } else {
    background(10, 10, 10);
  }
  stroke(0);
  textSize(50);
  /*
  RENDER MAIN OBJECTS ON TOP LAYER
  */
  if (earth) {
    clouds[0].draw();
    clouds[1].draw();
    clouds[2].draw();
    clouds[0].offsetX(1);
    clouds[1].offsetX(1);
    clouds[2].offsetX(2);
  } else {
    planetEarth.draw();
    foreignPlanet.draw();
  }
  for (int b = 0; b < 3; b++) {
    ballistae[b].draw(earth, paused);
  }
  for (int c = 0; c < 6; c++) {
    cities[c].draw(earth, paused);
  }
  if (earth) {
    fill(0);
  } else {
    fill(255);
  }
  if (paused) {
    textAlign(LEFT);
    textSize(25);
    text("Score: " + score, 50, 50);
    text("Wave: " + wave, 50, 80);
    text("Enemies Left: " + enemiesLeft, 50, 110);
    textAlign(CENTER);
    textSize(0);
    text("Press 'Q' to Unpause", GAME_WIDTH/2, GAME_HEIGHT/2);
    // Draw meteorites
    for (int im = 0; im < METEORITE_MAX_COUNT; im++) {
      if (meteoriteActive[im]) {
        meteorites[im].draw(earth, paused);
      }
    }
    // Draw bombers
    for (int ib = 0; ib < 3; ib++) {
      if (bomberActive[ib]) {
        bombers[ib].draw(earth, paused);
      }
    }
    // Draw bombs
    for (int ibo = 0; ibo < BOMB_COUNT; ibo++) {
      if (firing[ibo]) {
        bomb[ibo].draw(earth, paused);
      }
    }
    return;
  }
  /*
  HOMEPAGE
  */
  if (atHomepage) {
    textAlign(CENTER);
    stroke(255);
    strokeWeight(2);
    fill(155, 226, 255);
    rect(50, 50, 120, 70, 15);
    textSize(30);
    fill(0);
    text("Earth", 50 + 60, 50 + 45);
    fill(30, 30, 30);
    rect(50, 150, 120, 70, 15);
    fill(255);
    text("Moon", 50 + 60, 150 + 45);
    strokeWeight(1);
    if (highScore > 0) {
      textSize(50);
      text("Press Enter to Play Again!", GAME_WIDTH/2, (GAME_HEIGHT/2) - 50);
      textSize(30);
      text("High Score = " + highScore, GAME_WIDTH/2, (GAME_HEIGHT/2) + 50);
    } else {
      textSize(50);
      text("Press Enter to Play!", GAME_WIDTH/2, GAME_HEIGHT/2);
    }
    return;
  }
  textSize(25);
  /*
  ENDGAME
  */
  if (atEndgame) {
    if (earth) {
      fill(0);
    } else {
      fill(255);
    }
    textAlign(CENTER);
    text("Game Over!", GAME_WIDTH/2, (GAME_HEIGHT/2) - 50);
    text("Your Score is " + score, GAME_WIDTH/2, GAME_HEIGHT/2);
    text("Press Enter to Go Back to Main Menu", GAME_WIDTH/2, (GAME_HEIGHT/2) + 50);
    return;
  }
  /*
  PREGAME
  */
  if (atPregame) {
    if (earth) {
      fill(0);
    } else {
      fill(255);
    }
    textAlign(CENTER);
    text("Wave: "+ wave, GAME_WIDTH/2, (GAME_HEIGHT/2) - 50);
    text("Enemies: " + enemiesLeft, GAME_WIDTH/2, (GAME_HEIGHT/2) + 50);
    text("Press Enter to Start", GAME_WIDTH/2, GAME_HEIGHT/2);
    textAlign(LEFT);
    text("Score: " + score, 50, 50);
    text("Wave: " + wave, 50, 80);
    text("Enemies Left: " + enemiesLeft, 50, 110);
    return;
  }
  if (atGame) {
    /*
    ENDGAME CONDITIONS
    */
    if ((cities[0].exploded) && (cities[1].exploded) && (cities[2].exploded) && (cities[3].exploded) && (cities[4].exploded) && (cities[5].exploded)) {
      endGame();
    }
    if (disableFiring && (enemiesLeft == waveBombers) && (ballistae[0].destroyed) && (ballistae[1].destroyed) && (ballistae[2].destroyed)) {
      endGame();
    }
    /*
    UPDATE ALL FORCES IN THE FORCE REGISTRY
    */
    forceRegistry.updateForces();
    /*
    WAVE CONTROL
    */
    // On wave one
    if (wave == 1) {
      // Spawn a new meteorite every 'spawnTimer' frames
      if ((timer % spawnTimer) == 0) {
        if (nextMeteorite < METEORITE_MAX_COUNT) {
          meteoriteActive[nextMeteorite] = true;
          // Apply gravity and drag to the new meteorite
          forceRegistry.add(meteorites[nextMeteorite], gravity);
          forceRegistry.add(meteorites[nextMeteorite], drag);
          nextMeteorite++;
        }
      }
    } else if (wave >= 2) { // On each wave after wave one
      // For each meteorite
      for (int m = 0; m < METEORITE_MAX_COUNT; m++) {
        // If the meteorite is active, not exploding, and hasn't exploded.
        if (meteoriteActive[m] && !meteorites[m].exploding && !meteorites[m].exploded) {
          // There is a 1/'chanceOfSplitting' chance every frame that each meteorite splits
          int split = (int)random(0, chanceOfSplitting);
          if (split == 1) {
            if (nextMeteorite < METEORITE_MAX_COUNT) {
              if (!meteoriteActive[nextMeteorite]) {
                // Put new meteorite in correct position with correct kinematics
                meteorites[nextMeteorite].teleportTo(meteorites[m]);
                meteorites[nextMeteorite].copyKinematics(meteorites[m]);
                // Activate new meteorite
                meteoriteActive[nextMeteorite] = true;
                // Apply gravity and drag to the new meteorite
                forceRegistry.add(meteorites[nextMeteorite], gravity);
                forceRegistry.add(meteorites[nextMeteorite], drag);
                // Apply equal but opposite horizontal forces on fragments
                PVector splittingForce = new PVector(-1, 0);
                meteorites[m].addForce(splittingForce);
                splittingForce.mult(-1);
                meteorites[nextMeteorite].addForce(splittingForce);
                nextMeteorite++;
              }
            }
          }
        }
      }
      // Apply the score multiplier for waves past wave two
      if (wave == 2) {
        scoreMultiplier = 1;
      } else if (wave <= 4) {
        scoreMultiplier = 2;
      } else if (wave <= 6) {
        scoreMultiplier = 3;
      } else if (wave <= 8) {
        scoreMultiplier = 4;
      } else if (wave <= 10) {
        scoreMultiplier = 5;
      } else {
        scoreMultiplier = 6;
      }
      // Spawn a new meteorite every 'spawnTimer' frames
      if ((timer % spawnTimer) == 0) {
        if (nextMeteorite < METEORITE_MAX_COUNT) {
          meteoriteActive[nextMeteorite] = true;
          // Apply gravity and drag to the new meteorite
          forceRegistry.add(meteorites[nextMeteorite], gravity);
          forceRegistry.add(meteorites[nextMeteorite], drag);
          nextMeteorite++;
        }
      }
      // Spawn a new bomber every 'bomberSpawnTimer' frames
      if ((enemiesLeft != waveEnemies) && (enemiesLeft != 0)) {
        if (((enemiesLeft % bomberSpawnTimer) == 0) && (enemiesLeft != waveEnemies - 1)) {
          if (enemiesLeft != enemiesLeftOnLastBomberSpawn) {
            if (nextBomber < BOMBER_MAX_COUNT) {
              bomberActive[nextBomber] = true;
              nextBomber++;
              enemiesLeftOnLastBomberSpawn = enemiesLeft;
            }
          }
        }
      }
      // Each bomber drops a meteorite every 'bomberDropMeteoriteTime' frames
      for (int b = 0; b < BOMBER_MAX_COUNT; b++) {
        if (bomberActive[b] && !bombers[b].exploding && !bombers[b].exploded) {
          if (bombers[b].age != 0) {
            if ((int)(bombers[b].age % bomberDropMeteoriteTime) == 0) {
              bomberDropMeteorite(b);
            }
          }
        }
      }
    }
    // The wave is over when there are no enemies left
    if (enemiesLeft <= 0) {
      // Award 100 bonus points for each surviving city
      int bonusCityPoints = 0;
      for (int sc = 0; sc < 6; sc++) {
        if (!cities[sc].destroyed) {
          bonusCityPoints += 100;
        }
      }
      score = score + (bonusCityPoints * scoreMultiplier);
      // Award 5 bonus points for each unused bomb
      int bonusAmmoPoints = 0;
      for (int bal = 0; bal < 3; bal++) {
        if (!ballistae[bal].destroyed) {
          bonusAmmoPoints += (ballistae[bal].ammo * 5);
        }
      }
      score = score + (bonusAmmoPoints * scoreMultiplier);
      // For each 10,000 points earned in a single wave, a city will be rebuilt
      for (int p = 0; p < 6; p++) {
        if (wavePoints > 10000) {
          if (cities[p].destroyed) {
            cities[p].rebuild();
            wavePoints -= 10000;
          }
        }
      }
      setupNextWave();
    }
    /*
    DRAW AND MOVE EVERY ACTIVE METEORITE
    */
    for (int m = 0; m < METEORITE_MAX_COUNT; m++) {
      if (meteoriteActive[m]) {
        boolean alive = meteorites[m].move();
        if (alive) {
          meteorites[m].draw(earth, paused);
          if (!meteorites[m].isExploding()) {
            meteorites[m].integrate();
          }
        } else {
          meteoriteActive[m] = false;
          meteorites[m].setExploded();
          incrementScore(0);
        }
      }
    }
    /*
    DRAW AND MOVE EVERY ACTIVE BOMBER
    */
    for (int b = 0; b < BOMBER_MAX_COUNT; b++) {
      if (bombers[b].exploded) {
        bomberActive[b] = false;
      }
      if (bomberActive[b]) {
        bombers[b].draw(earth, paused);
        bombers[b].age();
        if (!bombers[b].move()) {
          bombers[b].flipDirection();
        }
        if (!bombers[b].exploding) {
          bombers[b].integrate();
        }
      }
    }
    /*
    DRAW CROSSHAIR
    */
    line(mouseX, mouseY-(GAME_HEIGHT/CROSSHAIR_SIZE_PROPORTION), mouseX, mouseY+(GAME_HEIGHT/CROSSHAIR_SIZE_PROPORTION));
    line(mouseX-(GAME_HEIGHT/CROSSHAIR_SIZE_PROPORTION), mouseY, mouseX+(GAME_HEIGHT/CROSSHAIR_SIZE_PROPORTION), mouseY);
    /*
    COLLISION DETECTION
    */
    // For each bomb
    for (int i = 0; i < BOMB_COUNT; i++) {
      // Move and draw firing bombs
      if (firing[i]) {
        if (bomb[i].move() && !bomb[i].isExploded()) {
          bomb[i].draw(earth, paused);
        } else {
          firing[i] = false;
        }
      }
      // If the bomb is not exploding calculate new position and velocity
      if (!bomb[i].isExploding()) {
        bomb[i].integrate();
      } else {
        // If the bomb is exploding
        meteoriteSize = GAME_WIDTH/METEORITE_SIZE_PROPORTION;
        int bombSize = bomb[i].getSize();
        // For each meteorite
        for (int m = 0; m < METEORITE_MAX_COUNT; m++) {
          // If the meteorite is active
          if (meteoriteActive[m]) {
            // If meteorite is a smart bomb
            if (meteorites[m].smartBomb && !meteorites[m].dodged) {
              // If an explosion is within its vision
              if (sqrt(pow(bomb[i].position.x-meteorites[m].position.x, 2) + pow(bomb[i].position.y-meteorites[m].position.y, 2)) < (bomb[i].projectileSize/2) + (meteorites[m].meteoriteSize/2) + meteorites[m].vision) {
                // Jump in other direction
                if (meteorites[m].position.x <= bomb[i].position.x) { // If meteorite is to the left of the explosion
                  if (meteorites[m].position.y <= bomb[i].position.y) { // If meteorite is below the explosion
                    meteorites[m].dodge(new PVector(-2, -5));
                  } else { // If meteorite is above the explosion
                    meteorites[m].dodge(new PVector(-2, 0));
                  }
                } else { // If meteorite is to the right of the explosion
                  if (meteorites[m].position.y <= bomb[i].position.y) { // If meteorite is below the explosion
                    meteorites[m].dodge(new PVector(2, -5));
                  } else { // If meteorite is above the explosion
                    meteorites[m].dodge(new PVector(2, 0));
                  }
                }
              }
            }
            // If the exploding bomb is touching the meteorite
            if (sqrt(pow(bomb[i].position.x-meteorites[m].position.x, 2) + pow(bomb[i].position.y-meteorites[m].position.y, 2)) < (bomb[i].projectileSize/2) + (meteorites[m].meteoriteSize/2)) {
              // And the meteorite hasnt exploded yet
              if (!meteorites[m].exploding && !meteorites[m].exploded) {
                // Explode the meteorite
                meteorites[m].explode();
                if (!s5.isPlaying()) {
                  s5.play();
                  s5.rewind();
                } else if (!s6.isPlaying()) {
                  s6.play();
                  s6.rewind();
                } else if (!s7.isPlaying()) {
                  s7.play();
                  s7.rewind();
                } else {
                  s5.rewind();
                  s5.play();
                  s5.rewind();
                }
                incrementScore(25);
              }
            }
          }
        }
        // For each bomber
        for (int d = 0; d < BOMBER_MAX_COUNT; d++) {
          // If the bomber is active
          if (bomberActive[d]) {
            // If the exploding bomb is touching the bomber
            if (sqrt(pow(bomb[i].position.x-bombers[d].position.x, 2) + pow(bomb[i].position.y-bombers[d].position.y, 2)) < (bomb[i].projectileSize/2) + (bombers[d].bomberSize/2)) {
              // If the bomber hasnt exploded yet
              if (!bombers[d].exploding && !bombers[d].exploded) {
                // Explode the bomber
                bombers[d].explode();
                if (!s5.isPlaying()) {
                  s5.play();
                  s5.rewind();
                } else if (!s6.isPlaying()) {
                  s6.play();
                  s6.rewind();
                } else if (!s7.isPlaying()) {
                  s7.play();
                  s7.rewind();
                } else {
                  s5.rewind();
                  s5.play();
                  s5.rewind();
                }
                incrementScore(100);
              }
            }
          }
        }
      }
      if (bomb[i].isExploded()) {
        firing[i] = false;
      }
    }

    // For each bomber
    for (int bomberOne = 0; bomberOne < BOMBER_MAX_COUNT; bomberOne++) {
      if (bomberActive[bomberOne]) {
        for (int bomberTwo = 0; bomberTwo < BOMBER_MAX_COUNT; bomberTwo++) {
          if (bomberOne != bomberTwo) {
            if (bomberActive[bomberTwo]) {
              if (sqrt(pow(bombers[bomberOne].position.x - bombers[bomberTwo].position.x, 2) + pow(bombers[bomberOne].position.x - bombers[bomberTwo].position.x, 2)) < bombers[bomberOne].bomberSize + bombers[bomberTwo].bomberSize) {
                // If the first one is exploding
                if (bombers[bomberOne].exploding && !bombers[bomberTwo].exploding) {
                  // Explode the second one
                  bombers[bomberTwo].explode();
                  if (!s5.isPlaying()) {
                    s5.play();
                    s5.rewind();
                  } else if (!s6.isPlaying()) {
                    s6.play();
                    s6.rewind();
                  } else if (!s7.isPlaying()) {
                    s7.play();
                    s7.rewind();
                  } else {
                    s5.rewind();
                    s5.play();
                    s5.rewind();
                  }
                  incrementScore(100);
                } else if (bombers[bomberTwo].exploding && !bombers[bomberOne].exploding) { // If the second one is exploding
                  // Explode the first one
                  bombers[bomberOne].explode();
                  if (!s5.isPlaying()) {
                    s5.play();
                    s5.rewind();
                  } else if (!s6.isPlaying()) {
                    s6.play();
                    s6.rewind();
                  } else if (!s7.isPlaying()) {
                    s7.play();
                    s7.rewind();
                  } else {
                    s5.rewind();
                    s5.play();
                    s5.rewind();
                  }
                  incrementScore(100);
                }
              }
            }
          }
        }
      }
    }

    // For each meteorite
    for (int m = 0; m < METEORITE_MAX_COUNT; m++) {
      if (meteorites[m].exploded) {
        meteoriteActive[m] = false;
      }
      // If the meteorite is active
      if (meteoriteActive[m]) {
        // If the meteorite has reached ground level
        if ((meteorites[m].position.y <= GAME_HEIGHT) && (meteorites[m].position.y >= GAME_HEIGHT - (cityHeight/2))) {
          // For each city
          for (int t = 0; t < 6; t++) {
            // If the meteorite is in a city
            if ((cities[t].position.x <= meteorites[m].position.x) && (meteorites[m].position.x <= cities[t].position.x + cityWidth)) {
              // If the meteorite hasnt exploded
              if (!meteorites[m].exploded && !meteorites[m].exploding) {
                // Explode the meteorite
                meteorites[m].explode();
                if (!s5.isPlaying()) {
                  s5.play();
                  s5.rewind();
                } else if (!s6.isPlaying()) {
                  s6.play();
                  s6.rewind();
                } else if (!s7.isPlaying()) {
                  s7.play();
                  s7.rewind();
                } else {
                  s5.rewind();
                  s5.play();
                  s5.rewind();
                }
                incrementScore(0);
                // If the city hasn't been destroyed
                if (!cities[t].destroyed) {
                  // Destroy the city
                  cities[t].explode();
                  if (!s3.isPlaying()) {
                    s3.play();
                    s3.rewind();
                  } else if (!s4.isPlaying()) {
                    s4.play();
                    s4.rewind();
                  } else {
                    s3.rewind();
                    s3.play();
                    s3.rewind();
                  }
                }
              }
            }
          }
        }
        // If the meteorite has reached the ballistae
        if ((meteorites[m].position.y <= GAME_HEIGHT) && (meteorites[m].position.y >= GAME_HEIGHT - (ballistaeHeight-meteoriteSize))) {
          // For each ballistae
          for (int b = 0; b < 3; b++) {
            // If the meteorite is in a ballistae
            if ((ballistae[b].position.x <= meteorites[m].position.x) && (meteorites[m].position.x <= ballistae[b].position.x + ballistaeWidth)) {
              // If the meteorite hasnt exploded
              if (!meteorites[m].exploded && !meteorites[m].exploding) {
                // Explode the meteorite
                meteorites[m].explode();
                if (!s5.isPlaying()) {
                  s5.play();
                  s5.rewind();
                } else if (!s6.isPlaying()) {
                  s6.play();
                  s6.rewind();
                } else if (!s7.isPlaying()) {
                  s7.play();
                  s7.rewind();
                } else {
                  s5.rewind();
                  s5.play();
                  s5.rewind();
                }
                incrementScore(0);
                // If the ballistae hasn't been destroyed
                if (!ballistae[b].destroyed) {
                  // Destroy the ballistae
                  ballistae[b].explode();
                  if (!s3.isPlaying()) {
                    s3.play();
                    s3.rewind();
                  } else if (!s4.isPlaying()) {
                    s4.play();
                    s4.rewind();
                  } else {
                    s3.rewind();
                    s3.play();
                    s3.rewind();
                  }
                  // If the destroyed ballistae was active, switch the active ballistae to an alive one
                  // If all ballistae are destroyed, disable firing
                  if (ballistae[b].active) {
                    if (b == 0) {
                      if (!ballistae[b+1].destroyed) {
                        ballistae[b].deactivate();
                        ballistae[b+1].activate();
                        xStart = xStartMiddle;
                        activeBallistae = 1;
                      } else if (!ballistae[b+2].destroyed) {
                        ballistae[b].deactivate();
                        ballistae[b+2].activate();
                        xStart = xStartRight;
                        activeBallistae = 2;
                      } else {
                        disableFiring = true;
                      }
                    } else if (b == 1) {
                      if (!ballistae[b-1].destroyed) {
                        ballistae[b].deactivate();
                        ballistae[b-1].activate();
                        xStart = xStartLeft;
                        activeBallistae = 0;
                      } else if (!ballistae[b+1].destroyed) {
                        ballistae[b].deactivate();
                        ballistae[b+1].activate();
                        xStart = xStartRight;
                        activeBallistae = 2;
                      } else {
                        disableFiring = true;
                      }
                    } else {
                      if (!ballistae[b-1].destroyed) {
                        ballistae[b].deactivate();
                        ballistae[b-1].activate();
                        xStart = xStartMiddle;
                        activeBallistae = 1;
                      } else if (!ballistae[b-2].destroyed) {
                        ballistae[b].deactivate();
                        ballistae[b-2].activate();
                        xStart = xStartLeft;
                        activeBallistae = 1;
                      } else {
                        disableFiring = true;
                      }
                    }
                  }
                }
              }
            }
          }
        }
        // For each meteorite
        for (int n = 0; n < METEORITE_MAX_COUNT; n++) {
          // If the meteorite is unique from the one referenced by the outer for loop
          if (m != n) {
            // If the meteorite is active
            if (meteoriteActive[n]) {
              // If meteorite is a smart bomb
              if (meteorites[m].smartBomb && meteorites[n].exploding && !meteorites[m].dodged) {
                // If an explosion is within its vision
                if (sqrt(pow(meteorites[n].position.x-meteorites[m].position.x, 2) + pow(meteorites[n].position.y-meteorites[m].position.y, 2)) < (meteorites[n].meteoriteSize/2) + (meteorites[m].meteoriteSize/2) + meteorites[m].vision) {
                  // Jump in other direction
                  if (meteorites[m].position.x <= meteorites[n].position.x) { // If meteorite is to the left of the explosion
                    if (meteorites[m].position.y <= meteorites[n].position.y) { // If meteorite is below the explosion
                      meteorites[m].dodge(new PVector(-2, -5));
                    } else { // If meteorite is above the explosion
                      meteorites[m].dodge(new PVector(-2, 0));
                    }
                  } else { // If meteorite is to the right of the explosion
                    if (meteorites[m].position.y <= meteorites[n].position.y) { // If meteorite is below the explosion
                      meteorites[m].dodge(new PVector(2, -5));
                    } else { // If meteorite is above the explosion
                      meteorites[m].dodge(new PVector(2, 0));
                    }
                  }
                }
              } else if (meteorites[n].smartBomb && meteorites[m].exploding && !meteorites[n].dodged) {
                // If an explosion is within its vision
                if (sqrt(pow(meteorites[n].position.x-meteorites[m].position.x, 2) + pow(meteorites[n].position.y-meteorites[m].position.y, 2)) < (meteorites[n].meteoriteSize/2) + (meteorites[m].meteoriteSize/2) + meteorites[n].vision) {
                  // Jump in other direction
                  if (meteorites[n].position.x <= meteorites[m].position.x) { // If meteorite is to the left of the explosion
                    if (meteorites[n].position.y <= meteorites[m].position.y) { // If meteorite is below the explosion
                      meteorites[n].dodge(new PVector(-2, -5));
                    } else { // If meteorite is above the explosion
                      meteorites[n].dodge(new PVector(-2, 0));
                    }
                  } else { // If meteorite is to the right of the explosion
                    if (meteorites[n].position.y <= meteorites[m].position.y) { // If meteorite is below the explosion
                      meteorites[n].dodge(new PVector(2, -5));
                    } else { // If meteorite is above the explosion
                      meteorites[n].dodge(new PVector(2, 0));
                    }
                  }
                }
              }
              // If the two meteorites are touching
              if (sqrt(pow(meteorites[n].position.x-meteorites[m].position.x, 2) + pow(meteorites[n].position.y-meteorites[m].position.y, 2)) < (meteorites[n].meteoriteSize/2) + (meteorites[m].meteoriteSize/2)) {
                // If the first one is exploding
                if (meteorites[m].exploding && !meteorites[n].exploding) {
                  // Explode the second one
                  meteorites[n].explode();
                  if (!s5.isPlaying()) {
                    s5.play();
                    s5.rewind();
                  } else if (!s6.isPlaying()) {
                    s6.play();
                    s6.rewind();
                  } else if (!s7.isPlaying()) {
                    s7.play();
                    s7.rewind();
                  } else {
                    s5.rewind();
                    s5.play();
                    s5.rewind();
                  }
                  incrementScore(25);
                } else if (meteorites[n].exploding && !meteorites[m].exploding) { // If the second one is exploding
                  // Explode the first one
                  meteorites[m].explode();
                  if (!s5.isPlaying()) {
                    s5.play();
                    s5.rewind();
                  } else if (!s6.isPlaying()) {
                    s6.play();
                    s6.rewind();
                  } else if (!s7.isPlaying()) {
                    s7.play();
                    s7.rewind();
                  } else {
                    s5.rewind();
                    s5.play();
                    s5.rewind();
                  }
                  incrementScore(25);
                }
              }
            }
          }
        }
        // For each bomber
        for (int c = 0; c < BOMBER_MAX_COUNT; c++) {
          // If the bomber is active
          if (bomberActive[c]) {
            if (bombers[c].exploding) {
              // If meteorite is a smart bomb
              if (meteorites[m].smartBomb && !meteorites[m].dodged) {
                // If an explosion is within its vision
                if (sqrt(pow(bombers[c].position.x-meteorites[m].position.x, 2) + pow(bombers[c].position.y-meteorites[m].position.y, 2)) < (bombers[c].bomberSize/2) + (meteorites[m].meteoriteSize/2) + meteorites[m].vision) {
                  // Jump in other direction
                  if (meteorites[m].position.x <= bombers[c].position.x) { // If meteorite is to the left of the explosion
                    if (meteorites[m].position.y <= bombers[c].position.y) { // If meteorite is below the explosion
                      meteorites[m].dodge(new PVector(-2, -5));
                    } else { // If meteorite is above the explosion
                      meteorites[m].dodge(new PVector(-2, 0));
                    }
                  } else { // If meteorite is to the right of the explosion
                    if (meteorites[m].position.y <= bombers[c].position.y) { // If meteorite is below the explosion
                      meteorites[m].dodge(new PVector(2, -5));
                    } else { // If meteorite is above the explosion
                      meteorites[m].dodge(new PVector(2, 0));
                    }
                  }
                }
              }
            }
            // If the meteorite and the bomber are touching
            if (sqrt(pow(bombers[c].position.x-meteorites[m].position.x, 2) + pow(bombers[c].position.y-meteorites[m].position.y, 2)) < (bombers[c].bomberSize/2) + (meteorites[m].meteoriteSize/2)) {
              // If the meteorite is exploding, the bomber isn't exploding, and the bomber hasn't exploded
              if (!bombers[c].exploding &&  !bombers[c].exploded && meteorites[m].exploding) {
                // Explode the bomber
                bombers[c].explode();
                if (!s5.isPlaying()) {
                  s5.play();
                  s5.rewind();
                } else if (!s6.isPlaying()) {
                  s6.play();
                  s6.rewind();
                } else if (!s7.isPlaying()) {
                  s7.play();
                  s7.rewind();
                } else {
                  s5.rewind();
                  s5.play();
                  s5.rewind();
                }
                incrementScore(100);
              } else if (bombers[c].exploding && !meteorites[m].exploding && !meteorites[m].exploded) { // If the bomber is exploding, the meteorite isn't exploding, and the meteorite hasn't exploded
                // Explode the meteorite
                meteorites[m].explode();
                if (!s5.isPlaying()) {
                  s5.play();
                  s5.rewind();
                } else if (!s6.isPlaying()) {
                  s6.play();
                  s6.rewind();
                } else if (!s7.isPlaying()) {
                  s7.play();
                  s7.rewind();
                } else {
                  s5.rewind();
                  s5.play();
                  s5.rewind();
                }
                incrementScore(25);
              }
            }
          }
        } 
      }
    }
    /*
    TEXT DISPLAYS
    */
    if (true) {
      if (earth) {
        fill(0);
      } else {
        fill(255);
      }
      textAlign(LEFT);
      text("Score: " + score, 50, 50);
      text("Wave: " + wave, 50, 80);
      text("Enemies Left: " + enemiesLeft, 50, 110);
      if (earth) {
        fill(255);
      } else {
        fill(0);
      }
      textAlign(CENTER);
      if (!ballistae[0].destroyed) {
        text(ballistae[0].ammo, xStartLeft, GAME_HEIGHT-(ballistaeHeight/2));
      }
      if (!ballistae[1].destroyed) {
        text(ballistae[1].ammo, xStartMiddle, GAME_HEIGHT-(ballistaeHeight/2));
      }
      if (!ballistae[2].destroyed) {
        text(ballistae[2].ammo, xStartRight, GAME_HEIGHT-(ballistaeHeight/2));
      }
      timer++;
    }
  }
}

// When the player clicks
void mousePressed() {
  // Clicking at the homepage takes you to the pre-game
  if (atHomepage) {
    if ((50 <= mouseX) && (mouseX <= 50+120)) {
      if ((50 <= mouseY) && (mouseY <= 50+70)) {
        earth = true;
        gravity = new Gravity(new PVector(0f, .075f));
        drag = new Drag(10, 10);
      } else if ((150 <= mouseY) && (mouseY <= 150 + 70)) {
        earth = false;
        gravity = new Gravity(new PVector(0f, .012f));
        drag = new Drag(0, 0);
      }
    }
  } else if (atGame) { // Clicking in the game throws a bomb
    xEnd = mouseX;
    yEnd = mouseY;
    v = new PVector(xEnd - xStart, yEnd - yStart);
    magnitude = v.mag();
    n = v.copy();
    n.normalize();
    fire();
  }
}

void keyPressed() {
  // 'Space' explodes all bombs on screen
  if (key==' ') {
    for (int i = 0; i < BOMB_COUNT; i++) {
      if (firing[i]) {
        bomb[i].explode();
        if (!s5.isPlaying()) {
          s5.play();
          s5.rewind();
        } else if (!s6.isPlaying()) {
          s6.play();
          s6.rewind();
        } else if (!s7.isPlaying()) {
          s7.play();
          s7.rewind();
        } else {
          s5.rewind();
          s5.play();
          s5.rewind();
        }
      }
    }
  } else if (key == 'a') { // 'a' switches the active ballistae to the one on the left
    if (!ballistae[0].destroyed) {
      ballistae[0].activate();
      ballistae[1].deactivate();
      ballistae[2].deactivate();
      xStart = xStartLeft;
      activeBallistae = 0;
    }
  } else if ((key == 's') || (key == 'w')) { // 's' or 'w' switches the active ballistae to the one in the middle
    if (!ballistae[1].destroyed) {
      ballistae[0].deactivate();
      ballistae[1].activate();
      ballistae[2].deactivate();
      xStart = xStartMiddle;
      activeBallistae = 1;
    }
  } else if (key == 'd') { // 'd' switches the active ballistae to the one on the right
    if (!ballistae[2].destroyed) {
      ballistae[0].deactivate();
      ballistae[1].deactivate();
      ballistae[2].activate();
      xStart = xStartRight;
      activeBallistae = 2;
    }
  } else if (key == '\n') { // ENTER or RETURN will either start the wave or restart the game
    if (atHomepage) {
      atHomepage = false;
      atPregame = true;
    } else if (atPregame) {
      atPregame = false;
      atGame = true;
      timer = 0;
      // s0.play();
      // s0.loop();
      for (int b = 0; b < 3; b++) {
        ballistae[b].rebuild();
      }
    } else if (atEndgame) {
      setup();
      highScore = lastHighScore;
    }
  } else if (key == 'e') {
    setupNextWave();
  } else if (key == 'q') {
    if (atGame) {
      paused = true;
      atGame = false;
      // s0.pause();
    } else if (paused) {
      paused = false;
      atGame = true;
      // s0.play();
      // s0.loop();
    }
  }
}

// Fire a bomb from the active ballistae
void fire() {
  // If firing is not disabled
  if (!disableFiring) {
    // If the active ballistae has ammo
    if (ballistae[activeBallistae].hasAmmo()) {
      if (!firing[nextBomb]) {
        // Set the initial bomb force from mouse input
        PVector initialBombForce = new PVector(v.x / BOMB_FORCE_PROPORTION, v.y / BOMB_FORCE_PROPORTION);
        // Instantiate the Projectile object
        bomb[nextBomb] = new Projectile(xStart, yStart, GAME_WIDTH/BOMB_SIZE_PROPORTION, GAME_WIDTH/BOMB_SIZE_PROPORTION, BOMB_MASS, initialBombForce, accelerationDueToGravity, GAME_WIDTH, GAME_HEIGHT);
        // Apply the effects of gravity and drag to the bomb
        forceRegistry.add(bomb[nextBomb], gravity);
        forceRegistry.add(bomb[nextBomb], drag);
        // Set the bomb as 'firing'
        firing[nextBomb] = true;
        // Decrement the active ballistae's ammo count
        ballistae[activeBallistae].decrementAmmo();
        nextBomb++;
        s1.play();
        s1.rewind();
        // if (nextBomb >= 10) {
        //   nextBomb = 0;
        // }
      }
    }
  }
}

// When the game ends, move from the game view to the endgame view
void endGame() {
  // s0.pause();
  s8.play();
  s8.rewind();
  if (score > highScore) {
    highScore = score;
    lastHighScore = highScore;
  }
  atGame = false;
  atEndgame = true;
}

// Increment the score and decrement the number of enemies left
void incrementScore(int amount) {
  enemiesLeft--;
  score = score + (amount * scoreMultiplier);
  wavePoints = wavePoints + (amount * scoreMultiplier);
}

// Drop a meteorite from a bomber
void bomberDropMeteorite(int bomber) {
  // Cycling index allows the bombers to continuously drop bombs if not blown up
  if (bomberMeteorites >= METEORITE_MAX_COUNT) {
    bomberMeteorites = 0;
  }
  // If the meteorite to be overwritten isn't in use
  if (meteorites[bomberMeteorites].exploded && !meteoriteActive[bomberMeteorites]) {
    int chance = (int)(random(0, SMART_BOMB_CHANCE));
    // Set the initial meteorite force as equal to the bomber's
    PVector meteoriteInitForce = new PVector(bombers[bomber].velocity.x, bombers[bomber].velocity.y);
    // Instantiate the Meteorite object
    if ((wave >= 6) && (chance == 1)) {
      meteorites[bomberMeteorites] = new Meteorite(int(bombers[bomber].position.x), int(bombers[bomber].position.y), meteoriteWidth, meteoriteHeight, GAME_WIDTH, GAME_HEIGHT, METEORITE_MASS, meteoriteInitForce, accelerationDueToGravity, true);
    } else {
      meteorites[bomberMeteorites] = new Meteorite(int(bombers[bomber].position.x), int(bombers[bomber].position.y), meteoriteWidth, meteoriteHeight, GAME_WIDTH, GAME_HEIGHT, METEORITE_MASS, meteoriteInitForce, accelerationDueToGravity, false);
    }
    // Set the meteorite as active
    meteoriteActive[bomberMeteorites] = true;
    // Apply the effects of gravity and drag to the new meteorite
    forceRegistry.add(meteorites[bomberMeteorites], gravity);
    forceRegistry.add(meteorites[bomberMeteorites], drag);
    bomberMeteorites++;
    enemiesLeft++;
  }
}

void stop() {
  s1.close();
  s2.close();
  s3.close();
  s4.close();
  s5.close();
  s6.close();
  s7.close();
  minim.stop();
}

// Setup environment for next wave
void setupNextWave() {
  /*
  RESET GLOBALS AND INCREMENT DIFFICULTY PARAMETERS
  */
  // s0.pause();
  s2.play();
  s2.rewind();
  wave++;
  atGame = false;
  atPregame = true;
  disableFiring = false;
  timer = 0;
  METEORITE_MAX_COUNT += 2;
  meteorites = new Meteorite[METEORITE_MAX_COUNT];
  meteoriteActive = new boolean[METEORITE_MAX_COUNT];
  firing = new boolean[BOMB_COUNT];
  bomb = new Projectile[BOMB_COUNT];
  bombers = new Bomber[BOMBER_MAX_COUNT];
  bomberActive = new boolean[BOMBER_MAX_COUNT];
  nextMeteorite = 0;
  nextBomb = 0;
  nextBomber = 0;
  spawnTimer = 50 - wave;
  bomberDropMeteoriteTime -= 10;
  enemiesLeftOnLastBomberSpawn = 0;
  bomberMeteorites = 0;
  if (wave == 1) {
    enemiesLeft = METEORITE_MAX_COUNT; // No bombers on wave one
  } else if (wave <= 4) {
    waveBombers = 1;
    enemiesLeft = METEORITE_MAX_COUNT + 1; // One bomber up to wave four
    bomberSpawnTimer = (int)(enemiesLeft / 2); // One bomber at halfway
  } else if (wave <= 6) {
    waveBombers = 2;
    enemiesLeft = METEORITE_MAX_COUNT + 2; // Two bombers up to wave six
    bomberSpawnTimer = (int)(enemiesLeft / 3); // Two bomber at thirdways
    SMART_BOMB_CHANCE -= 1;
  } else {
    waveBombers = 3;
    enemiesLeft = METEORITE_MAX_COUNT + 3; // Three bombers from wave seven onwards
    bomberSpawnTimer = (int)(enemiesLeft / 4); // Three bomber at quarterways
    SMART_BOMB_CHANCE -= 1;
  }
  waveEnemies = enemiesLeft;
  wavePoints = 0;
  forceRegistry = new ForceRegistry();
  /*
  INSTANTIATE BALLISTAE
  */
  for (int b = 0; b < 3; b++) {
    ballistae[b].resetAmmo();
    //ballistae[b].resetAmmo();
  }
  /*
  INSTANTIATE BOMBS
  */
  initialForce = new PVector(0, 0); // CHANGE THIS
  for (int i = 0; i < BOMB_COUNT; i++) {
    bomb[i] = new Projectile(xStart, yStart, GAME_WIDTH/BOMB_SIZE_PROPORTION, GAME_WIDTH/BOMB_SIZE_PROPORTION, BOMB_MASS, initialForce, accelerationDueToGravity, GAME_WIDTH, GAME_HEIGHT);
    firing[i] = false;
  }
  /*
  INSTANTIATE METEORITES
  */
  for (int j = 0; j < METEORITE_MAX_COUNT; j++) {
    int meteoriteInitX = int(random(meteoriteWidth, GAME_WIDTH-meteoriteWidth));
    int meteoriteInitY = 0;
    PVector meteoriteInitForce = new PVector(0, 0);
    if (meteoriteInitX >= 3*(GAME_WIDTH/4)) {
      meteoriteInitForce = new PVector(int(random(-3, 0)), 0);
    } else if (meteoriteInitX <= GAME_WIDTH/4) {
      meteoriteInitForce = new PVector(int(random(0, 3)), 0);
    } else {
      meteoriteInitForce = new PVector(int(random(-4, 4)), 0);
    }
    int chance = (int)(random(0, SMART_BOMB_CHANCE));
    if ((wave >= 6) && (chance == 1)) {
      meteorites[j] = new Meteorite(meteoriteInitX, meteoriteInitY, meteoriteWidth, meteoriteHeight, GAME_WIDTH, GAME_HEIGHT, METEORITE_MASS, meteoriteInitForce, accelerationDueToGravity, true);
    } else {
      meteorites[j] = new Meteorite(meteoriteInitX, meteoriteInitY, meteoriteWidth, meteoriteHeight, GAME_WIDTH, GAME_HEIGHT, METEORITE_MASS, meteoriteInitForce, accelerationDueToGravity, false);
    }
    meteoriteActive[j] = false;
  }
  /*
  INSTANTIATE BOMBERS
  */
  for (int k = 0; k < BOMBER_MAX_COUNT; k++) {
    int bomberInitX = int(random(-2, 2));
    int bomberInitY;
    if (k == 0) {
      bomberInitY = GAME_HEIGHT/BOMBER_INIT_Y_PROPORTION;
    } else if (k == 1) {
      bomberInitY = (GAME_HEIGHT/BOMBER_INIT_Y_PROPORTION) + bomberHeight + 5;
    } else {
      bomberInitY = (GAME_HEIGHT/BOMBER_INIT_Y_PROPORTION) + (2 * bomberHeight) + 10;
    }
    PVector bomberInitVelocity = new PVector(int(random(1, 2)), 0);
    boolean startLeft = true;
    if (bomberInitX > 0) {
      bomberInitX = GAME_WIDTH-1;
      bomberInitVelocity = new PVector(int(random(-2, -1)), 0);
      startLeft = false;
    }
    bombers[k] = new Bomber(bomberInitX, bomberInitY, bomberWidth, bomberHeight, GAME_WIDTH, GAME_HEIGHT, startLeft);
    bomberActive[k] = false;
  }
}