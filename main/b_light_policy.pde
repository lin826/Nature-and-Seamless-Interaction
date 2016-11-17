import processing.io.*;

class Policy{
ArrayList<ArrayList<Integer>> channels = new ArrayList<ArrayList<Integer>>(); 
ArrayList <ArrayList<Integer>> ports = new ArrayList<ArrayList<Integer>>();

Methods m;
Audio audio = new Audio();

void m_setup(){
  //m is class where different light behaviours are, behaviours can be combined to form desired patterns 
  m =  new Methods();
  
  //an arraylist of all lights | channels has been set as the default arraylist, where if all lights are used, it can be used 
  //if there are any change in number if lights used, i < 42 will be changed to i < ?, where ? is the desired 4th address of the last channel used | more information can be found at the bottom of the page 
  for (int i=6; i<42; i+=4){
    ArrayList<Integer> temp = new ArrayList<Integer> ();
    temp.add(i); 
    temp.add(i+1);
    temp.add(i+2);
    temp.add(i+3);
    channels.add(temp); 
  }
  m.alloff();
}

void m_draw(String mode){
  if(mode.equals("1") && setting_data[1].equals("3")){
    audio.init("turnon/turnon_start.wav");
    oneFadeIn();
  } else if(mode.equals("-1")){
    audio.init("turnon/turnon_"+setting_data[1]+".wav");
    oneFadeIn();
  } else if(mode.equals("2_"+setting_data[1])){
    audio.init("install/install_"+setting_data[1]+".wav");
    oneFadeIn();
  } else if(mode.equals("2")){
    audio.init("install/install_finish.wav");
    oneFadeIn();
  } else if(mode.equals("3")  && setting_data[1].equals("3")){
    insideOut();
  } else if(mode.equals("-3")  && !setting_data[1].equals("3")){
    OutsideIn();
  } else if(mode.equals("3_2")  && setting_data[1].equals("1")){
    CrossBlink(); // Task reject
  } else if(mode.equals("3_2")  && setting_data[1].equals("2")){
    CircleBlink(); // Task agree
  } else if(mode.equals("3_2")  && setting_data[1].equals("4")){
    CircleBlink(); // Task agree
  } else if(mode.equals("3_2")  && setting_data[1].equals("5")){
    CircleBlink(); // Task unknown
    // Task unknown// Task unknown// Task unknown// Task unknown!!!!!
  } else if(mode.equals("4")  && setting_data[1].equals("3")){
    insideOut();
  } else if(mode.equals("-4")  && !setting_data[1].equals("3")){
    allFade(); // others also wake up 
  } else if(mode.equals("4_2")){
    Sync(); // Sync success that adjust by user
  }
}
void oneFadeIn(){
  int[] p = {0};
  setPorts(p);
  m.fadein(ports,4000);
}
void allFade(){
 int[] p = {0,1,2,3,4,5,6,7,8};
 setPorts(p);
 m.fade(3,ports,4000);
}
void insideOut(){
  int[] p_1 = {0};
  setPorts(p_1);
  int[] p_2 = {1,2,3,4,5,6,7,8};
  setPorts(p_2);
  m.fade(1,ports,4000);
}
void OutsideIn(){
  int[] p_1 = {1,2,3,4,5,6,7,8};
  int[] p_2 = {0};
  setPorts(p_1);
  setPorts(p_2);
  m.fade(1,ports,4000);
}
void CrossBlink(){
  int[] p = {0,1,3,5,7};
  setPorts(p);
  m.blink_more(ports,2,1,4000);
}
void CircleBlink(){
  int[] p = {1,2,3,4,5,6,7,8};
  setPorts(p);
  m.blink_more(ports,2,1000,4000);
}
void Sync(){
  int[] p_1 = {1,3,5,7};
  int[] p_2 = {2,4,6,8};
  for(int i=0;i<3;i++){
    setPorts(p_1);
    m.on(ports,1,4000);
    setPorts(p_2);
    m.on(ports,1,4000);
  }
}
// if not all lights are to be used, this method can be called to create an arraylist of lights involved 
void setPorts(int[] pins){
  ports.clear();
  for(int i: pins){
     ArrayList<Integer> temp  = new ArrayList<Integer> (); 
     for(int  j=0;  j<channels.get(i).size(); j++){
       temp.add(channels.get(i).get(j));
     }
     ports.add(temp);
  }
  /*for(ArrayList<Integer> list: ports){
    for(int i: list){
      print(i+" ");
    }
    println();
  }*/
}
/*for(int i=1;i<5;i++){
    adio_list.add(new Audio());
    adio_list.get(i-1).init("install/install_"+i+".wav");
    delay(1000);
  }
  adio_list.add(new Audio());
  adio_list.get(4).init("install/install_finish.wav");*/


/*

datasheet of pwm pca9685 is found at this link https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf
For every channel, there are 4 addresses. One channel represents one light. 
channel 0: 6,7,8,9
channel 1: 10,11,12,13
channel 2: 14,15,16,17
channel 3: 18,19,20,21
channel 4: 22,23,24,25
channel 5: 26,27,28,29
channel 6: 30,31,32,33
channel 7: 34,35,36,37
channel 8: 38,39,40,41
channel 9: 42,43,44,45
channel 10: 46,47,48,49
channel 11: 50,51,52,53
channel 12: 54,55,56,57
channel 13: 58,59,60,61
channel 14: 62,63,64,65
channel 15: 66,67,68,69


right: channel 0
right_down: channel 1
bottom: channel 2
left_down: channel 3
left: channel 4
left_up: channel 5
up: channel 6
right_up: channel 7
centre: channel 8




*/
}