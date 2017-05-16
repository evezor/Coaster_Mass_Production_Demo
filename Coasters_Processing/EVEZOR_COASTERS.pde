import controlP5.*;
import processing.serial.*;

ControlP5 cp5;

boolean LOAD_TEST = true;  // mark true to skip all the laser routines
boolean LASER_TEST = true;  // mark true to skip all the loading routines

int NUM_PILES = 5;
int STACK_HEIGHT = 40;
int PILE_NUM;
String RAPID = " F10000";
String SLIDER_RAPID = " F1200";

int COUNTER = 0;  //make this one less than what the first number will be
int NUM_COASTERS = 200;
int[] SERIAL = {0, 0, 1};

float[] SLIDER_LENGTH = {1500, 53.1};   //THE EXTENTS OF THE CAMERA SLIDER MOVEMENT FROM 0,0


float[] FIXTURE_CENTER= {-6.79, 138.52, 100};


float[] [] PILE_PICK = { {133.09, 95.68, 64},  // these are X, Y, E coordinates of pile locations
  {146.39, 106.18, 90},
  {175.99, 28.18, 40},
  {174.59, 54.38, 66},
  {190.89, 55.98, 84}  };


float[] [] PILE_DROP = {  {-10.89, -55.98, -153}, // these are X, Y, E coordinates of pile locations
  {4.61, -54.38, -135}, 
  {2.81, -27.18, -110}, 
  {33.61, -107.18, -157}, 
  {47.61, -96.98, -134.0}   };




boolean DONE = false;

PImage bg; 
PFont f;
PFont f2;


//SET UP SERIAL COMMUNICATIONS
Serial armPort;                       
Serial shutterPort;
Serial sliderPort;

String ArmString;
String ShutterString;
String SliderString;



void setup() {
  //frameRate(4);
  size(700, 400);
  bg = loadImage("HD_BG.jpg");
  noStroke();
  f = createFont("OCR A Extended", 150, true); 
  f2 = createFont("Arial Rounded MT Bold", 150, true);
  // Print a list of the serial ports, for debugging purposes:
  printArray(Serial.list());
  //  String[] fontList = PFont.list();
  //  printArray(fontList);

  //SET UP SERIAL 
  String portARM = Serial.list()[1];
  String portSHUTTER = Serial.list()[0];
  String portSLIDER = Serial.list()[2];

  armPort = new Serial(this, portARM, 250000);
  shutterPort = new Serial(this, portSHUTTER, 115200);
  sliderPort = new Serial(this, portSLIDER, 250000);

  armPort.bufferUntil('\n');
  shutterPort.bufferUntil('\n');
  sliderPort.bufferUntil('\n');

  //CREATE BUTTONS
  cp5 = new ControlP5(this);

  cp5.addButton("START")
    .setBroadcast(false)
    .setPosition(15, 335)
    .setSize(100, 50)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("SETUP")
    .setBroadcast(false)
    .setPosition(125, 360)
    .setSize(50, 25)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;

  cp5.addButton("STOP")
    .setBroadcast(false)
    .setPosition(185, 360)
    .setSize(50, 25)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
    
  cp5.addButton("DLY_PIC")
    .setBroadcast(false)
    .setPosition(245, 360)
    .setSize(50, 25)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
    
  cp5.addButton("RST_CTR")
    .setBroadcast(false)
    .setPosition(305, 360)
    .setSize(50, 25)
    .setValue(1)
    .setBroadcast(true)
    .getCaptionLabel().align(CENTER, CENTER)
    ;
}


void draw() {
  background(bg);
  stroke(226, 204, 0);
  if (DONE == false && COUNTER < 1) { 
    textFont(f2, 180);  
    fill(255);
    text("Press", 40, 155);
    text("Start", 65, 305);
  } else if (DONE == false) {  
    textFont(f, 390);  
    fill(255);
    text(COUNTER, 0, 305);
  } else {
    textFont(f2, 230);  
    fill(255);
    text("DONE", 5, 266);
  }
}


void serialEvent( Serial thisPort) {
  String inString = thisPort.readStringUntil('\n');
  if (inString != null) {
    inString = trim(inString);

    if (thisPort == armPort) {
      //println("ARM SRL:"+inString);
      if (inString.equals("PART PICKED")) {
        //println("Part has been grabbed");
        cameraLoadRoutine();
      } else if (inString.equals("CAMERA LOAD DONE")) {
        //println("LOAD DONE");
        laserOnes();
      } else if (inString.equals("ONES DONE")) {
        //println("ONES LAZED");
        laserTens();
      } else if (inString.equals("TENS DONE")) {
        //println("TENS LAZED");
        laserHundreds();
      } else if (inString.equals("HUNDREDS DONE")) {
        //println("HUNDREDS LAZED");
        laserRoutine();
      } else if (inString.equals("LASER DONE")) {
        //println("LASER DONE");
        cameraUnloadRoutine();
      } else if (inString.equals("CAMERA UNLOAD DONE")) {
        //println("UNLOAD DONE");
        stackDoneRoutine();
      } else if (inString.equals("ROUTINE FINISHED")) {
        //delay(400);
        INCREMENT();
        println("ROUTINE FINISHED - INCREMENT: "+COUNTER);
        if (COUNTER <= NUM_COASTERS) {
          moveSlider();
          getNewPart();
        } else {
          println("MAKE A ROUTINE HERE FOR THE ARM TO GO HOME NOW");
          DONE();
          armPort.write("G1 X-45 Y140 F700\nM84\n");
          delay(500);
          Camera1TakePic();
        }
      } else if (inString.equals("ok")) {
      } else { 
        println("ARM SRL: "+inString);  //if we've already established contact, keep getting and parsing data
      }
    }

    if (thisPort == shutterPort) {
      //println("SHTR SRL: "+inString);
      if (inString.equals("BLOW IS DONE")) {
        println("STARTING PROGRAM");
        armPort.write("L"); //load new part
      } else {
        println("SHTR SRL:"+inString);
      }
    }
    
    if (thisPort == sliderPort) {
      //println("SHTR SRL: "+inString);
      if (inString.equals("BLOW IS DONE")) {
        println("STARTING PROGRAM");
        armPort.write("L"); //load new part
      } else {
        println("SLIDER SRL:"+inString);
      }
    }
  }
}


void getNewPart() {  //M43 ends this routine
  getSerial();
  PILE_NUM = (COUNTER-1)/STACK_HEIGHT;
  //println("PICKING FROM PILE NUM " + PILE_NUM);
  String pickLocation = ("G1 X" + PILE_PICK[PILE_NUM][0] + " Y" + PILE_PICK[PILE_NUM][1] + " E" + PILE_PICK[PILE_NUM][2]+ RAPID +"\n");
  //println(pickLocation);
  if  (LASER_TEST == false) {
    armPort.write(pickLocation);  //move over correct pile
    enableEndstops();
    armPort.write("G1 Z0 F720\n");
  }
  armPort.write("M43\n");  //part is ready to get sucked and take picture
}

void cameraLoadRoutine() {   //M44 ends this routine
  Camera1TakePic();
  if (LASER_TEST == false) {
    disableEndstops();
    enableSucker();
    armPort.write("G28 Z0\n");
    String loadLocation = ("G1 X" + FIXTURE_CENTER[0] + " Y" + FIXTURE_CENTER[1] + " E" + FIXTURE_CENTER[2] + RAPID + "\n");
    //println("moving to suck part" + loadLocation);
    armPort.write(loadLocation);
    enableEndstops();
    armPort.write("G1 Z150 F720\n");
    disableSucker();
    armPort.write("G1 Z111 F720\n");
    disableEndstops();
    armPort.write("G28 Z0\n");
  }
  armPort.write("M44\n");  //M44: CAMERA LOAD DONE
}

void laserOnes() {
  String sdFile = (SERIAL[2] + "_O~1.gco");
  print(sdFile);
  String sdRun = ("M23 " + sdFile + "\nM24\n");
  if (LOAD_TEST == false) {
    //println("lasering ones");
    armPort.write(sdRun); //M49: ONES DONE
  } else {
    armPort.write("M49\n");
  }
}

void laserTens() {
  String sdFile = (SERIAL[1] + "_T~1.gco");
  print(sdFile);
  String sdRun = ("M23 " + sdFile + "\nM24\n");
  if (LOAD_TEST == false) {
    //println("lasering tens");
    armPort.write(sdRun);  //M50: TENS DONE
  } else {
    armPort.write("M50\n");
  }
}

void laserHundreds() {
  String sdFile = (SERIAL[0] + "_H~1.gco");
  println(sdFile);
  String sdRun = ("M23 " + sdFile + "\nM24\n");
  if (LOAD_TEST == false) {
    //println("lasering hundreds");
    armPort.write("M51\n");  //M51: HUNDREDS DONE
  } else {
    armPort.write("M51\n");
    //  armPort.write(sdFile);
  }
}

void laserRoutine() {
  startTimedPic();
  if (LOAD_TEST == false) {
    String mainFile = "M_A~1.gco";
    String sdRun = ("M23 " + mainFile + "\nM24\n");
    armPort.write(sdRun);
  } else {
    armPort.write("M45\n");  //M45: LASER DONE
  }
}

void cameraUnloadRoutine() {
  String loadLocation = ("G1 X" + FIXTURE_CENTER[0] + " Y" + FIXTURE_CENTER[1] + " E" + FIXTURE_CENTER[2] + RAPID + "\n");
  if (LASER_TEST == false) {
    armPort.write(loadLocation);
    enableEndstops();
    armPort.write("G1 Z100 F720\n");
    enableSucker();
    disableEndstops();
    armPort.write("G28 Z0\n");
    PILE_NUM = (COUNTER-1)/STACK_HEIGHT;
    println("PLACING ON PILE NUM " + PILE_NUM);
    String dropLocation = ("G1 X" + PILE_DROP[PILE_NUM][0] + " Y" + PILE_DROP[PILE_NUM][1] + " E" + PILE_DROP[PILE_NUM][2]+ RAPID + "\n");
    //println(dropLocation);
    armPort.write(dropLocation);  //move over correct pile
    enableEndstops();
    armPort.write("G1 Z0 F720\n");
  } else{}
  armPort.write("M46\n");
}

void stackDoneRoutine() {
  Camera1TakePic();
  if (LASER_TEST == false) {
    disableSucker();
    disableEndstops();
    armPort.write("G28 Z0\n");
  } else{}
  armPort.write("M47\n");  
}

void moveSlider(){
  float x = SLIDER_LENGTH[0]/NUM_COASTERS*COUNTER;
  float y = SLIDER_LENGTH[1]/NUM_COASTERS*COUNTER;
  String sx = String.format("%.2f",x); 
  String sy = String.format("%.2f",y); 
  String sliderPosition = ("G1 X" + sx + " Y" + sy + SLIDER_RAPID + "\nG04 P1000\nM84\n");
  print(sliderPosition);
  sliderPort.write(sliderPosition);
}


//THIS IS THE END OF THE ROUTINES BELOW IS CALLS 


void enableSucker() {
  armPort.write("M400\n");
  armPort.write("M42 P10 S255\n");
}

void disableSucker() {
  armPort.write("M400\n");
  armPort.write("M42 P10 S0\n");
}

void Camera1TakePic() {
  //println("take pic with cam 1");
  shutterPort.write("A");
}

void startTimedPic(){
  println("take timed pic");
  shutterPort.write("D");
}

void   enableEndstops() {
  armPort.write("M120\n");
}

void   disableEndstops() {
  armPort.write("M400\n");
  armPort.write("M121\n");
}

int[] getSerial() {
  SERIAL[0] = COUNTER%1000/100;
  SERIAL[1] = COUNTER%100/10;
  SERIAL[2] = COUNTER%10;
  //println("hundreds: "+SERIAL[0]+" tens: "+SERIAL[1]+" ONES: "+SERIAL[2]);
  return (SERIAL);
}

boolean DONE() {
  DONE = true;
  return(DONE);
}

int INCREMENT() {
  COUNTER = COUNTER+1;
  //println("up the counter by 1");
  return(COUNTER);
}

//  Create buttons

public void START(int theValue) {
  println("a button event from THE START BUTTON: "+theValue);
  armPort.write("M302\n");
  INCREMENT();
  moveSlider();
  getNewPart();
}

public void SETUP(int theValue) {
  println("a button event from THE SETUP BUTTON: "+theValue);
  armPort.write("G92 X-50.6 Y144.3 E0\nM302\nG28 Z0\nG1 X-45 Y140 F250\nG04 P500\nG1 X0 YO F1200\nM120\nG1 Z10\nG04 P10000\nG1 X-45 Y140 Z0");
}

public void STOP(int theValue) {
  println("ESTOP HIT: "+theValue);
  armPort.write("M112\n");
}

public void DLY_PIC(int theValue) {
  println("TAKE A DELAYED PIC");
  startTimedPic();
}

public void RST_CTR(int theValue) {
  println("RESET SHUTTER COUNTER");
  shutterPort.write('R');
}