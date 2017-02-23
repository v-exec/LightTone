import themidibus.*;
import KinectPV2.KJoint;
import KinectPV2.*;
//requires midi rewiring tool. I used loopMIDI for this project

//myBus and Kinect controllers
MidiBus myBus;
KinectPV2 kinect;

//distance thresholds
int maxD = 2000; // 4.5mx ~100 grey usually 2000
int minD = 0;  //  50cm ~30 grey

//array of currently playing notes (set up to work with 2 octaves - 24 notes)
boolean[] playing = new boolean [24];

//setup kinect and midi controllers
void setup() {
  size(512, 424, P3D);
  frameRate(30);

  //list all available midi inputs and ouputs for reference
  MidiBus.list();

  //initialize MidiBus channel
  myBus = new MidiBus(this, "", "loopMIDI Port");

  //initialize kinect controller and enable depth and point cloud images
  kinect = new KinectPV2(this);
  kinect.enableDepthImg(true);
  kinect.enablePointCloud(true);

  kinect.init();
}
//kinect data gathering
void draw() {
  background(0);

  //get depth image which won't be visible, but is used for point cloud
  image(kinect.getDepthImage(), 512, 0);
  //get and display point cloud depth image
  image(kinect.getPointCloudDepthImage(), 0, 0);

  //get raw depth data from [0 - 4500]
  int [] rawData = kinect.getRawDepthData();

  //set point cloud thresholds
  kinect.setLowThresholdPC(minD);
  kinect.setHighThresholdPC(maxD);

  //load pixel[] array
  loadPixels();

  //start and end denote limits of 'input body' (element), hit denotes middle point between start and end
  int start = 0;
  int end = 0;
  int hit = 0;

  //'pointer' goes through every scanned element. once an element is found, 'pointer' turns off all notes between it and the last element, and turns on the current element's note
  int pointer = 0;

  for (int i=1; i<width; i++) {

    //loop goes through each horizontal pixel in center of screen, checking whether they're sufficiently bright to be considered the 'start' point of an element
    if (grayify(i) > 0 && grayify(i-1) == 0) start = i;
    else if ((grayify(i) > 0 && i == width-1) || (grayify(i) == 0 && grayify(i-1) > 0)) {
      if (i == width-1) end = width-1;
      else end = i-1;
      hit = (start + end)/2;
      int nota = noteify(hit) -60;

      //pointer travels from current note to the next, turning off all notes in between them
      for (; pointer < nota; pointer++) {
        if (playing[pointer]) {
          myBus.sendNoteOff(0, pointer+60, 74);
          playing[pointer] = false;
        }
      }

      //upon arriving to the appropriate note, if it isn't already playing, then send a play alert
      if (!playing[nota]) {
        myBus.sendNoteOn(0, nota+60, velocify(hit));
        playing[nota] = true;
      }

      //offset pointer by one to avoid having it turn off the currently playing note
      pointer++;
    }
  }

  //turn off all remaining notes after most recently played note
  for (; pointer < 24; pointer++) {
    if (playing[pointer]) {
      myBus.sendNoteOff(0, pointer+60, 74);
      playing[pointer] = false;
    }
  }

  //tiny delay to keep input consistent
  delay(1);
}