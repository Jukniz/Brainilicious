/*
  Created by Jukniz(Chin Ho) and Màrius Mora
*/
import ddf.minim.*;
AudioPlayer zombieBite;
AudioPlayer music;
Minim minim;//audio context

ArrayList<Ball> aBall;
ArrayList<Ball> aBallToDestroy;
final static float gravityConst = 0.07;
ArrayList<Line> aLine;
ArrayList<Plataform> aPlataform;
final static float spring = 0.05;
Player player;
float leftSpeed;
float rightSpeed;

PImage graveyard, gameOverImage, bloodImage;
Animation ovniLights;

ScoreLabel scoreLabel;
BallGenerator ballGenerator;
GameTimer gameTimer;


void setup() {

  size(1200, 800);
  frameRate(120);

  noStroke();
  strokeWeight(0.3);
  fill(255);
  aBall = new ArrayList<Ball>();
  aBallToDestroy = new ArrayList<Ball>();
  aLine = new ArrayList<Line>();
  aPlataform = new ArrayList<Plataform>();

  PVector vector = new PVector(3, 3);
  CircleCollider circleCollider = new CircleCollider(420, height/8, 25, spring);
  Ball ball = new Ball(circleCollider, vector);
  aBall.add(ball);

  vector = new PVector(5, 3);
  circleCollider = new CircleCollider(900, height/8, 25, spring);
  ball = new Ball(circleCollider, vector);
  aBall.add(ball);


  vector = new PVector(4, 3);
  circleCollider = new CircleCollider(700, height/8, 25, spring);
  ball = new Ball(circleCollider, vector);
  aBall.add(ball);

  vector = new PVector(1, 5);
  circleCollider = new CircleCollider(100, height/8, 25, spring);
  ball = new Ball(circleCollider, vector);
  aBall.add(ball);


  vector = new PVector(3, 2);
  circleCollider = new CircleCollider(1000, height/8, 25, spring);
  ball = new Ball(circleCollider, vector);
  aBall.add(ball);


  //Linea de arriba
  Line  line = new Line(0, 0, width, 0);
  aLine.add(line);

  // Linea de abajo
  line = new Line(0, height-height/17, width, height-height/17);
  aLine.add(line);


  // Linea de izquierda
  line = new Line(0, 0, 0, height);
  aLine.add(line);

  // Linea de derecha
  line = new Line(width, 0, width, height);
  aLine.add(line);


  vector = new PVector(0, 0);

  PImage plataformImage = loadImage("ground_rectangle.png");
  BoxCollider boxCollider = new BoxCollider(330, 350, 300, 60);
  Box box = new Box(boxCollider, vector, 45); 
  Plataform plataform = new Plataform(plataformImage, box);
  aPlataform.add(plataform);

  boxCollider = new BoxCollider(870, 350, 300, 60);
  box = new Box(boxCollider, vector, -45); 
  plataform = new Plataform(plataformImage, box);
  aPlataform.add(plataform);

  player= new Player();

  textSize(18);
  scoreLabel=new ScoreLabel(0);
  gameTimer = new GameTimer();
  ballGenerator= new BallGenerator(10);

  graveyard = loadImage("graveyard1.png");
  gameOverImage = loadImage("gameover.png");
  bloodImage = loadImage("blood.png");
  ovniLights = new Animation("ovni_lights", 3);

  if (minim==null) {
    minim = new Minim(this);
    zombieBite = minim.loadFile("zombie_bite.mp3", 2048);
  }

  if (music==null) {
    music = minim.loadFile("thriller8bit.mp3", 2048);
    music.play();
    music.loop();
  }
}


void draw() {
  if (!gameTimer.isFinished) {
    background(graveyard);
    ovniLights.display(width/2 - 50, height/10 - 50);
    // DRAW STATIC LINE
    /*for (Line line : aLine) {
     line(line.lineX1, line.lineY1, line.lineX2, line.lineY2);
     }*/

    for (Ball ball : aBall) {
      ball.update();
    }
    stroke(255);
    for (Plataform plataform : aPlataform) {
      plataform.update();
    }
    noStroke();
    player.update();
    for (Ball ball : aBallToDestroy) {
      aBall.remove(ball);    
      scoreLabel.score+=1;
    }

    aBallToDestroy.clear();

    scoreLabel.update();

    ballGenerator.update();
    gameTimer.update();
  } else {
    image(gameOverImage, width/2-gameOverImage.width/2, height/2-gameOverImage.height);

    textSize(32);
    textAlign(CENTER);
    text("Press Enter to Restart", width/2, height/2+64);
    image(bloodImage, 0, 0, 1200, 600);
    textSize(18);
    textAlign(LEFT);
    scoreLabel.update();
    gameTimer.drawGameTimer();


    //ENTER
    if (keyCode == ENTER && gameTimer.isFinished) {
      setup();
    }
  }
  //println(mouseX, mouseY);
}


class Box {

  PVector vector;
  private float angle;
  BoxCollider boxCollider;


  Box(BoxCollider boxCollider, PVector vector, float angle) {
    this.boxCollider = boxCollider;
    this.vector = vector;
    this.angle = angle;
    this.angle= angle;

    float s = sin(radians(this.angle));
    float c = cos(radians(this.angle));
    float x1, x2, y1, y2;
    for (int i=0; i<boxCollider.aLine.size (); i++) {
      // translate point back to origin:
      x1 = boxCollider.aLine.get(i).lineX1-boxCollider.x;
      y1 = boxCollider.aLine.get(i).lineY1-boxCollider.y;
      x2 = boxCollider.aLine.get(i).lineX2-boxCollider.x;
      y2 = boxCollider.aLine.get(i).lineY2-boxCollider.y;

      // rotate point and translate point back:
      boxCollider.aLine.get(i).lineX1= (x1 * c - y1 * s)+boxCollider.x;
      boxCollider.aLine.get(i).lineY1= (x1 * s + y1 * c)+boxCollider.y;
      boxCollider.aLine.get(i).lineX2= (x2 * c - y2 * s)+boxCollider.x;
      boxCollider.aLine.get(i).lineY2= (x2 * s + y2 * c)+boxCollider.y;
    }
  }

  void setAngle(float angle) {
    // primero lo rotamos al angulo 0 porque si no rotaria desde la posicion actual
    float s = sin(radians(-this.angle));
    float c = cos(radians(-this.angle));
    float x1, x2, y1, y2;
    for (int i=0; i<boxCollider.aLine.size (); i++) {
      // translate point back to origin:
      x1 = boxCollider.aLine.get(i).lineX1-boxCollider.x;
      y1 = boxCollider.aLine.get(i).lineY1-boxCollider.y;
      x2 = boxCollider.aLine.get(i).lineX2-boxCollider.x;
      y2 = boxCollider.aLine.get(i).lineY2-boxCollider.y;

      // rotate point and translate point back:
      boxCollider.aLine.get(i).lineX1= (x1 * c - y1 * s)+boxCollider.x;
      boxCollider.aLine.get(i).lineY1= (x1 * s + y1 * c)+boxCollider.y;
      boxCollider.aLine.get(i).lineX2= (x2 * c - y2 * s)+boxCollider.x;
      boxCollider.aLine.get(i).lineY2= (x2 * s + y2 * c)+boxCollider.y;
    }


    // una vez vuelto en la posicion original rotamos
    this.angle= angle;
    s = sin(radians(this.angle));
    c = cos(radians(this.angle));

    for (int i=0; i<boxCollider.aLine.size (); i++) {
      // translate point back to origin:
      x1 = boxCollider.aLine.get(i).lineX1-boxCollider.x;
      y1 = boxCollider.aLine.get(i).lineY1-boxCollider.y;
      x2 = boxCollider.aLine.get(i).lineX2-boxCollider.x;
      y2 = boxCollider.aLine.get(i).lineY2-boxCollider.y;

      // rotate point and translate point back:
      boxCollider.aLine.get(i).lineX1= (x1 * c - y1 * s)+boxCollider.x;
      boxCollider.aLine.get(i).lineY1= (x1 * s + y1 * c)+boxCollider.y;
      boxCollider.aLine.get(i).lineX2= (x2 * c - y2 * s)+boxCollider.x;
      boxCollider.aLine.get(i).lineY2= (x2 * s + y2 * c)+boxCollider.y;
    }
  }




  void update() {
    translate(boxCollider.x, boxCollider.y);
    rotate(radians(angle));
    noFill();
    //rect(0-boxCollider.b_width/2, 0-boxCollider.b_height/2, boxCollider.b_width, boxCollider.b_height);
    rotate(radians(-angle));
    translate(-boxCollider.x, -boxCollider.y);
    //para pintar las lineas del collider
    for (int i=0; i<boxCollider.aLine.size (); i++) {
      Line line = boxCollider.aLine.get(i);
      //line(line.lineX1, line.lineY1, line.lineX2, line.lineY2);
    }
  }
}

class BoxCollider {

  float x, y;
  float b_height, b_width;
  float spring;
  ArrayList<Line> aLine;

  BoxCollider(float x, float y, float b_width, float b_height) {
    this.x = x;
    this.y = y;
    this.b_height = b_height;
    this.b_width = b_width;
    this.spring = spring;
    aLine = new ArrayList<Line>();
    //linea de arriba
    Line line = new Line(this.x-this.b_width/2, this.y -this.b_height/2, this.x+this.b_width/2, this.y -this.b_height/2);
    aLine.add(line);

    //linea de abajo
    line = new Line(this.x-this.b_width/2, this.y +this.b_height/2, this.x+this.b_width/2, this.y +this.b_height/2);
    aLine.add(line);

    //linea izq
    line = new Line(this.x-this.b_width/2, this.y -this.b_height/2, this.x-this.b_width/2, this.y +this.b_height/2);
    aLine.add(line);

    //linea der
    line = new Line(this.x+this.b_width/2, this.y -this.b_height/2, this.x+this.b_width/2, this.y +this.b_height/2);
    aLine.add(line);
  }

  void setPosition(float x, float y) {
    this.x = x;
    this.y = y;
    aLine.clear();
    //linea de arriba
    Line line = new Line(this.x-this.b_width/2, this.y -this.b_height/2, this.x+this.b_width/2, this.y -this.b_height/2);
    aLine.add(line);

    //linea de abajo
    line = new Line(this.x-this.b_width/2, this.y +this.b_height/2, this.x+this.b_width/2, this.y +this.b_height/2);
    aLine.add(line);

    //linea izq
    line = new Line(this.x-this.b_width/2, this.y -this.b_height/2, this.x-this.b_width/2, this.y +this.b_height/2);
    aLine.add(line);

    //linea der
    line = new Line(this.x+this.b_width/2, this.y -this.b_height/2, this.x+this.b_width/2, this.y +this.b_height/2);
    aLine.add(line);
  }

  void addLine(Line line) {
    aLine.add(line);
  }
}

class Ball {

  CircleCollider circleCollider;
  PVector vector;
  Timer timer;
  Animation gameBall;


  Ball(CircleCollider circleCollider, PVector vector) {
    this.circleCollider = circleCollider;
    this.gameBall = new Animation("brain_ball", 6);
    this.vector = vector;
    this.timer = new Timer(1);
    timer.start();
  }


  void update() {

    if (timer.isFinished()) {


      
      move();
      gravity();


      for (Ball ball : aBall) {
        if (ball.circleCollider.x != this.circleCollider.x && ball.circleCollider.y != this.circleCollider.y &&  circleCollider.hasCollidedWithBall(ball)) {

          bounceWithBall(ball);
        }
      }

      for (Plataform plataform : aPlataform) {
        for (Line line : plataform.box.boxCollider.aLine) {
          if (circleCollider.hasCollidedWithLine(line.lineX1, line.lineY1, line.lineX2, line.lineY2)) {
            // strokeWeight(10);
            bounceWithLine(line.lineX1, line.lineY1, line.lineX2, line.lineY2);

            gravity();
          }
        }
      }

      for (Line line : aLine) {
        if (circleCollider.hasCollidedWithLine(line.lineX1, line.lineY1, line.lineX2, line.lineY2)) {
          // strokeWeight(10);
          bounceWithLine(line.lineX1, line.lineY1, line.lineX2, line.lineY2);

          gravity();
        }
      }

      boolean destroyed=false;
      for (Line line : player.box.boxCollider.aLine) {
        if (circleCollider.hasCollidedWithLine(line.lineX1, line.lineY1, line.lineX2, line.lineY2) && !destroyed) {
          //background(255,0,0);
          zombieBite.play();
          zombieBite.rewind();
          aBallToDestroy.add(this);
          destroyed=true;
        }
      }




      timer.start();
    }
    gameBall.display(circleCollider.x-circleCollider.radius, circleCollider.y - circleCollider.radius);
    // image(gameBall, circleCollider.x-circleCollider.radius, circleCollider.y - circleCollider.radius);
    //ellipse(circleCollider.x, circleCollider.y, circleCollider.radius*2, circleCollider.radius*2);
  }

  void move() {
    circleCollider.x += vector.x;
    circleCollider.y += vector.y;
  }


  void bounceWithLine(float lineX1, float lineY1, float lineX2, float lineY2) {


    PVector vPlane = new PVector(lineX2-lineX1, lineY2-lineY1);
    float modRectaP1 = abs(sqrt(pow(lineX1-circleCollider.x, 2)+ pow(lineY1-circleCollider.y, 2)));
    float modRectaP2 = abs(sqrt(pow(lineX2-circleCollider.x, 2)+ pow(lineY2-circleCollider.y, 2)));
    if (modRectaP1<=circleCollider.radius || modRectaP2<=circleCollider.radius) {

      vPlane = new PVector(-vPlane.y, vPlane.x);
    }
    PVector vNormal = new PVector(0, 0);
    PVector vTangen = new PVector(0, 0);


    float lineVDotProduct = (vPlane.x*vector.x+vPlane.y*vector.y);
    float linelineDotProduct = (vPlane.x*vPlane.x + vPlane.y*vPlane.y);

    vTangen.x = (lineVDotProduct/linelineDotProduct)*vPlane.x;
    //  println("vTangen.x = " + vTangen.x);
    vTangen.y = (lineVDotProduct/linelineDotProduct)*vPlane.y;
    vNormal.x = vector.x-vTangen.x;
    vNormal.y = vector.y-vTangen.y;

    vector.x = 1*(1*(-1*vNormal.x+vTangen.x));
    vector.y = 1*(1*(-1*vNormal.y+vTangen.y));

    // println((lineY2-lineY1)/(lineX2-lineX1)+"//"+vector.y/vector.x);
    //  println("modulo"+abs(sqrt(pow(vector.x, 2)+ pow(vector.y, 2))));
  }

  void bounceWithBall(Ball otherBall) {
    float dx = otherBall.circleCollider.x - this.circleCollider.x;
    float dy = otherBall.circleCollider.y - this.circleCollider.y;
    float minDist = otherBall.circleCollider.radius + this.circleCollider.radius;
    float angle = atan2(dy, dx);
    float targetX = this.circleCollider.x + cos(angle) * minDist;
    float targetY = this.circleCollider.y + sin(angle) * minDist;
    float ax = (targetX -otherBall.circleCollider.x) * spring;
    float ay = (targetY - otherBall.circleCollider.y) * spring;
    this.vector.x -= ax;
    this.vector.y -= ay;
    otherBall.vector.x += ax;
    otherBall.vector.y += ay;
  }

  void gravity() {
   vector.y = vector.y + gravityConst;
   }
}

class CircleCollider {

  float x, y;
  float radius;
  float spring;

  CircleCollider(float x, float y, float radius, float spring) {
    this.x = x;
    this.y = y;
    this.radius = radius;
    this.spring = spring;
  }

  boolean hasCollidedWithLine(float rectaX1, float rectaY1, float rectaX2, float rectaY2) {

    float diffRectY = rectaY2-rectaY1;
    float diffRectX = rectaX2-rectaX1;
    float modulDiffRect = sqrt(pow(diffRectY, 2) + pow(diffRectX, 2));
    float distance = abs( diffRectY*this.x - diffRectX*this.y + rectaX2*rectaY1 - rectaY2*rectaX1 )/modulDiffRect;
    float modRectaP1 = abs(sqrt(pow(rectaX1-this.x, 2)+ pow(rectaY1-this.y, 2)));
    float modRectaP2 = abs(sqrt(pow(rectaX2-this.x, 2)+ pow(rectaY2-this.y, 2)));

    if (distance<=radius && (modRectaP1<modulDiffRect && modRectaP2<modulDiffRect || (modRectaP1<radius || modRectaP2<radius))) {
      // println("antes"+distance);


      return true;
    } else {
      return false;
    }
  }

  boolean hasCollidedWithBall(Ball otherBall) {
    float dx = otherBall.circleCollider.x - x;
    float dy = otherBall.circleCollider.y - y;
    float distance = sqrt(dx*dx + dy*dy);
    float minDist = otherBall.circleCollider.radius + radius;
    if (distance <= minDist) { 
      return true;
    } else {
      return false;
    }
  }
}



class Timer {

  int savedTime; // When Timer started
  int totalTime; // How long Timer should last

  Timer(int tempTotalTime) {
    totalTime = tempTotalTime;
  }

  // Starting the timer
  void start() {
    // When the timer starts it stores the current time in milliseconds.
    savedTime = millis();
  }

  // The function isFinished() returns true if 5,000 ms have passed. 
  // The work of the timer is farmed out to this method.
  boolean isFinished() { 
    // Check how much time has passed
    int passedTime = millis()- savedTime;
    if (passedTime > totalTime) {
      return true;
    } else {
      return false;
    }
  }
}

class Player {
  Box box;
  float speed;
  boolean isGrounded;
  PVector vector;
  Animation walkRight;
  Animation walkLeft;
  Animation jump;
  Animation idle;

  Player() {
    vector = new PVector(0, 0);
    BoxCollider boxCollider = new BoxCollider(width/2, height-400, 50, 100);
    box = new Box(boxCollider, vector, 0); 
    speed=2;
    isGrounded=false;
    vector=new PVector(0, 0);
    walkRight = new Animation("zombie_right", 7);
    walkLeft = new Animation("zombie_left", 7);
    jump = new Animation("zombie_jump", 4);
    idle = new Animation("zombie_idle", 2);
  }  

  void update() {

    if (box.boxCollider.y+box.boxCollider.b_height/2>=height-height/17) {
      isGrounded=true;
      vector.y = 0;
    } else {
      isGrounded=false;
    }



    // Animaciones segun movimiento
    if (rightSpeed == 1 && leftSpeed == 0 && isGrounded)
      walkRight.display(box.boxCollider.x-box.boxCollider.b_width, box.boxCollider.y-box.boxCollider.b_height/2);
    else if (rightSpeed == 0 && leftSpeed == 1 && isGrounded)
      walkLeft.display(box.boxCollider.x-box.boxCollider.b_width, box.boxCollider.y-box.boxCollider.b_height/2);
    else if (!isGrounded)
      jump.display(box.boxCollider.x-box.boxCollider.b_width, box.boxCollider.y-box.boxCollider.b_height/2);
    else
      idle.display(box.boxCollider.x-box.boxCollider.b_width, box.boxCollider.y-box.boxCollider.b_height/2);


    // Aplicamos movimiento izquierda-derecha
    box.boxCollider.setPosition(box.boxCollider.x + rightSpeed*speed, box.boxCollider.y);
    box.boxCollider.setPosition(box.boxCollider.x - leftSpeed*speed, box.boxCollider.y);

    // Salto
    if (keyPressed) {
      if (key == CODED) {
        if (keyCode == UP && isGrounded) {
          vector.y -= 4;
          box.boxCollider.setPosition(box.boxCollider.x, box.boxCollider.y - speed);
        }
      }
    }

    if (box.boxCollider.y<height && !isGrounded) {
      vector.y += +gravityConst;
      box.boxCollider.setPosition(box.boxCollider.x, box.boxCollider.y+vector.y);
    }

    if (box.boxCollider.x<0) {
      box.boxCollider.x = width;
    } else if (box.boxCollider.x>width) {
      box.boxCollider.x = 0;
    }



    box.update();
  }
}


class Line {
  float lineX1, lineY1, lineX2, lineY2;
  Line(float lineX1, float lineY1, float lineX2, float lineY2) {
    this.lineX1=lineX1;
    this.lineX2=lineX2;
    this.lineY1=lineY1;
    this.lineY2=lineY2;
  }
}

class ScoreLabel {
  int score;
  ScoreLabel(int score) {
    this.score = score;
  }

  void update() {
    fill(255);
    text("Score: "+score, 20, 35);
  }
}

class BallGenerator {
  Timer timer;
  int maxBalls;
  BallGenerator(int maxBalls) {
    timer = new Timer(1000);
    timer.start();
    this.maxBalls = maxBalls;
  }
  void update() {
    generate();
  }
  void generate() {
    if (timer.isFinished()) {
      if (aBall.size()<maxBalls) {
        PVector vector = new PVector(random(0, 5), random(1, 5));
        CircleCollider circleCollider = new CircleCollider(width/2, height/8, 25, spring);
        Ball ball = new Ball(circleCollider, vector);
        aBall.add(ball);
      }
      timer.start();
    }
  }
}

class GameTimer {
  boolean isFinished;
  int seconds;
  Timer timer;
  GameTimer() {
    isFinished=false;
    seconds=60;
    timer = new Timer(1000);
    timer.start();
  }

  void update() {
    if (timer.isFinished()) {
      seconds--;
      timer.start();
    }
    drawGameTimer();
    if (seconds<=0) {
      isFinished=true;
    }
  }

  void drawGameTimer() {
    fill(255);
    text("Time Left: "+seconds, 1065, 35);
  }
}

// Funciones predeterminades que puedes modificar
// Velocidad a 0 si no estás pulsando la tecla
void keyReleased()
{
  if (key == CODED)
  {
    if (keyCode == LEFT)
    {
      leftSpeed = 0;
    }
    if (keyCode == RIGHT)
    {
      rightSpeed = 0;
    }
  }
}

//Velocidad a 1 si se pulsa. Después se usa como factor, o sea que depende de la speed de la clase player.
// Basicamente para decidir si se mueve o no.
void keyPressed()
{
  if (key == CODED)
  {
    if (keyCode == LEFT)
    {
      leftSpeed = 1;
    }
    if (keyCode == RIGHT)
    {
      rightSpeed = 1;
    }
  }
}

// Class for animating a sequence of GIFs (la he cogido de internet y he añadido un timer de la 
// clase que usamos el otro dia para controlar el ritmo de los frames (que no vayan con el draw).


class Animation {
  PImage[] images;
  int imageCount;
  int frame;
  Timer frameTimer;

  Animation(String imagePrefix, int count) {
    imageCount = count;
    images = new PImage[imageCount];
    frameTimer = new Timer(100);
    frameTimer.start();

    for (int i = 0; i < imageCount; i++) {
      // Use nf() to number format 'i' into x digits
      String filename = imagePrefix + nf(i, 2) + ".gif";
      images[i] = loadImage(filename);
    }
  }

  void display(float xpos, float ypos) {

    if (frameTimer.isFinished()) {
      frame = (frame+1) % imageCount;
      frameTimer.start();
    }
    image(images[frame], xpos, ypos);
  }

  int getWidth() {
    return images[0].width;
  }
}


class Plataform {
  Box box;
  PImage image;

  Plataform(PImage image, Box box) {
    this.image = image;
    this.box = box;
  }

  void update() {
    translate(box.boxCollider.x, box.boxCollider.y);
    rotate(radians(box.angle));
    noFill();
    image(image, 0-box.boxCollider.b_width/2, 0-box.boxCollider.b_height/2, box.boxCollider.b_width, box.boxCollider.b_height);
    rotate(radians(-box.angle));
    translate(-box.boxCollider.x, -box.boxCollider.y);

    box.update();
  }
}

