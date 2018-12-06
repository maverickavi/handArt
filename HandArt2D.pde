/* --------------------------------------------------------------------------
 * SimpleOpenNI  
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 * This demos shows how to use the gesture/hand generator.
 * It's not the most reliable yet, a two hands example will follow
 * ----------------------------------------------------------------------------
 */
 /*
 Art through different interactions in 3D space. Digital canvas board for easy drawing. 
 Drawing from a distance on large screen  
 */
 
 //implement (580 , 452) threshold on interaction
 
 
import java.util.Map;
import java.util.Iterator;

import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;

import SimpleOpenNI.*;

Robot robot;

SimpleOpenNI context;
int handVecListSize = 3;
int a = 128;
Map<Integer,ArrayList<PVector>>  handPathList = new HashMap<Integer,ArrayList<PVector>>();
color[]       userClr = new color[]{ color(204,51,0,a),
                                     color(0,153,153,a),
                                     color(204,0,255,a),
                                     color(204,255,102,a),
                                     color(51,102,153,a),
                                     color(255)
                                   };

color col;
float x = 0, y = 0;
//float newX = 0, newY = 0;
PVector pt, crsr, diff;
PGraphics pg;

float stepSize = 2.0;
float lineLength = 15;

int clr = 0;
int btn = 0;

float depth;

int click = 0;
int handTracked = 0;

int drawMode = 0;

String[] s = {"POINT", "LINE", "SQUARE", "CIRCLE", "CUBE", "SPHERE"};

void setup()
{
//  frameRate(200);
  size(displayWidth, displayHeight, P2D);
  pg = createGraphics(600, 600,P3D);
  
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }   

  // enable depthMap generation 
  context.enableDepth();
  
  // disable mirror
  context.setMirror(true);

  // enable hands + gesture generation
  //context.enableGesture();
  context.enableHand();
  context.startGesture(SimpleOpenNI.GESTURE_WAVE);
  context.startGesture(SimpleOpenNI.GESTURE_CLICK);
  //context.startGesture(SimpleOpenNI.GESTURE_HAND_RAISE);
  
  // set how smooth the hand capturing should be
  context.setSmoothingHand(.5);
  
  background(255);
  smooth();
  pt = new PVector(0,0);
  
  cursor(ARROW);
  
  try { 
    robot = new Robot();
  } 
  catch (AWTException e) {
    e.printStackTrace();
    exit();
  }
  frameRate(200);
  col = userClr[0];
  
  
  
}

void draw()
{
  //UI elements
  pushMatrix();
  translate(0,0);
  noStroke();
  fill(255);
  rect(width-50,0,50,280);
  for(int i = 0; i < 6; i++){
    noStroke();
    fill(userClr[i]);
    if(i == 5){ 
      stroke(0);
      strokeWeight(0.5);
    }
    ellipse(width-30,30 + i*45, 15 ,15);
    if(i == clr){
      if(clr == 5){
        stroke(0);
        strokeWeight(0.5);
      }
      ellipse(width-30,30 + i*45, 20 ,20);
    }
    
    //Bounding box
    stroke(255);
    strokeWeight(2);
    noFill();
    rect(width/2 - 300, height/2 - 225, 599,450);
    stroke(0,100);
    strokeWeight(0.25);
    noFill();
    rect(width/2 - 300, height/2 - 225, 600,450);
  }
  noStroke();
  fill(255);
  rect(0,0,100,50);
  
  textSize(20);
  fill(0);
  text(s[btn], 10,30);
  
  popMatrix();
  
  // update the cam
  context.update();
  translate(width/2-320,height/2-240);

  //image(context.depthImage(),0,0);
   
  // draw the tracked hands

  if(handPathList.size() > 0)  
  {    
    Iterator itr = handPathList.entrySet().iterator();     
    while(itr.hasNext())
    {
      Map.Entry mapEntry = (Map.Entry)itr.next(); 
      int handId =  (Integer)mapEntry.getKey();
      ArrayList<PVector> vecList = (ArrayList<PVector>)mapEntry.getValue();
      PVector p,p1;
      PVector p2d = new PVector();
          
      p = vecList.get(0);
      p1 = vecList.get(1);
      diff = (PVector.sub(p,p1)).normalize();
      context.convertRealWorldToProjective(p,p2d);
      //point((int)p2d.x,(int)p2d.y);
      robot.mouseMove((int)p2d.x+width/2-320,(int)p2d.y+height/2-240);
      robot.mouseMove((int)p2d.x+width/2-320,(int)p2d.y+height/2-240+45);
      //println(mouseX + "," + mouseY);
      ////println(p2d.x+ ","+p2d.y);
      //println(Integer.toString((int)p2d.x+width/2-320) + "," +Integer.toString((int)p2d.y+height/2-240+45));
      //println(" ");
      
      pt = p2d.copy();
      depth = p.z;
 
    }        
  }
  println(btn, clr);
  if (click == 1 && clr != 5) {
      
    float d = dist(x,y, pt.x,pt.y);

    if (d > stepSize) {
      float angle = atan2(pt.y-y, pt.x-x); 

      pushMatrix();
      translate(x,y);
      rotate(angle);
      stroke(col);
      pg.stroke(col);
      strokeWeight(2);
      //println(depth);
      if (frameCount % 2 == 0){
        stroke(150);
        pg.stroke(150);
      }
      float l1 = lineLength*d/10;
      float l2 = lineLength*map(depth,500,2000,20,0);
      float l;
      if(drawMode == 0){
        l = l1; 
      }
      else 
        l = l2;
      switch(btn){
        case 0:
          strokeWeight(l/10);
          point(0,0);
          break;
        case 1:
          line(0,0,0,l);
          break;
        case 2:
          noFill();
          rect(0,0,l,l);
          break;
        case 3:
          noFill();
          ellipse(0,0,l/2,l/2);
          break;
        case 4:
          pg.beginDraw();
          pg.background(255,0);
          pg.translate(l/3,l/3,-l);
          pg.rotateZ(diff.z);
          pg.noFill();
          pg.box(l);
          pg.endDraw();
          
          image(pg, 0, 0);
          break;
        case 5:
          pg.beginDraw();
          pg.background(255,0);
          pg.translate(l/3,l/3,-l);
          pg.rotateZ(diff.z);
          pg.noFill();
          pg.sphere(l/2);
          pg.endDraw();
          
          image(pg, 0, 0);
          break;
      }
      
      popMatrix();

      if(drawMode == 0) stepSize = map(depth,500,2000,1,10);
      else stepSize = map(d,0,300,1,10);
      
      x = x + cos(angle) * stepSize;
      y = y + sin(angle) * stepSize; 
      
      
    }
  }
  else if(click == 1 && clr == 5){
    noStroke();
    fill(col);
    ellipse(pt.x,pt.y,map(depth,500,2000,50,2),map(depth,500,2000,50,2));
  }
  
}


// -----------------------------------------------------------------
// hand events

void onNewHand(SimpleOpenNI curContext,int handId,PVector pos)
{
  println("onNewHand - handId: " + handId + ", pos: " + pos);
 
  ArrayList<PVector> vecList = new ArrayList<PVector>();
  vecList.add(pos);

  
  handPathList.put(handId,vecList);
  
}

void onTrackedHand(SimpleOpenNI curContext,int handId,PVector pos)
{
  //println("onTrackedHand - handId: " + handId + ", pos: " + pos );
  
  ArrayList<PVector> vecList = handPathList.get(handId);

  if(vecList != null)
  {
    vecList.add(0,pos);

    
    if(vecList.size() >= handVecListSize)
      // remove the last point 
      vecList.remove(vecList.size()-1);
      
  }
  if (click == 0){
    PVector temp_p = new PVector(0,0);
    context.convertRealWorldToProjective(pos,temp_p);
    x = temp_p.x;
    y = temp_p.y;
  }
}

void onLostHand(SimpleOpenNI curContext,int handId)
{
  println("onLostHand - handId: " + handId);
  handPathList.remove(handId);
  //click = 0;
  Iterator itr = handPathList.entrySet().iterator();     
  if(!itr.hasNext()){
    handTracked = 0;
    click = 0;
    cursor(ARROW);
  }
  
}

// -----------------------------------------------------------------
// gesture events

void onCompletedGesture(SimpleOpenNI curContext,int gestureType, PVector pos)
{
  println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);
  //println(handTracked + "," +click);
  if(handTracked == 1 && gestureType == 1 ){
    if(click == 0){      
      click = 1;
      cursor(CROSS);
    }
    else{
      click = 0;
      cursor(HAND);
      }
  }
  
  if(gestureType == 0){
    if(handTracked == 0){
      handTracked = 1;
      cursor(HAND);
      context.startTrackingHand(pos);
      int handId = context.startTrackingHand(pos);
      println("hands tracked: " + handId);
    }
    else{
      PVector temp = pos.copy();
      //cursor(ARROW);
      PVector temp2D= new PVector(0,0);
      context.convertRealWorldToProjective(temp,temp2D);
      if(temp2D.x > 320){
        println(temp2D.x);
        if(clr<5){
          clr++;
          col = userClr[clr];
        
         }
      
        else{
          clr = 0;
          col = userClr[clr];
        }
      }
      else {
        if(btn < 5) btn++;
        else btn = 0;
        
      }
      
    }
    
    
  }
  
}

// -----------------------------------------------------------------
// Keyboard event
void keyPressed()
{

  switch(key)
  {
  case ' ':
    if(clr<5){
      clr++;
      col = userClr[clr];
      
    }
    
    else{
      clr = 0;
      col = userClr[clr];
    }
    
    break;
  case BACKSPACE:
    background(255);
    break;
  case '1':
    drawMode = 0;
    break;
  case '2':
    drawMode = 1;
    break;  
  case 's':
    saveFrame("sketch.png");
    break;
  case 'p':
    if(btn < 5) btn++;
    else btn = 0;
    break;
    
  

  }
}
