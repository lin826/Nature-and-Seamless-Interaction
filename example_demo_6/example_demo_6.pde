import nl.tue.id.oocsi.*;
import java.io.*;
import processing.io.*;

ArrayList<ArrayList<Integer>> channels = new ArrayList<ArrayList<Integer>>(); 
ArrayList<ArrayList<Integer>> ports = new ArrayList<ArrayList<Integer>>();

//m is class where different light behaviours are, behaviours can be combined to form desired patterns 
Methods m =  new Methods();
Node node;
Audio audio = new Audio();

void setup() {
  setChennals();
  node = new Node("../setting");
  node.connectOOCSI();
}

void draw() {
}

void setChennals() {
  //an arraylist of all lights | channels has been set as the default arraylist, where if all lights are used, it can be used 
  //if there are any change in number if lights used, i < 42 will be changed to i < ?, where ? is the desired 4th address of the last channel used | more information can be found at the bottom of the page 
  for (int i=6; i<42; i+=4) {
    ArrayList<Integer> temp = new ArrayList<Integer> ();
    temp.add(i); 
    temp.add(i+1);
    temp.add(i+2);
    temp.add(i+3);
    channels.add(temp);
  }
}
// if not all lights are to be used, this method can be called to create an arraylist of lights involved 
void setPorts(int[] pins) {
  ports.clear();
  for (int i : pins) {
    ArrayList<Integer> temp  = new ArrayList<Integer> (); 
    for (int  j=0; j<channels.get(i).size(); j++) {
      temp.add(channels.get(i).get(j));
    }
    ports.add(temp);
  }
}

void Handler(String function, String input) {
  println("function: ", function);
  println("io_msg: ", input);
  switch(function) {
  case "execute_1":
    switch(input) {
    case "1":
      if (node.my_id.equals("3")) {
        audio.init("turnon/turnon_start.wav");
        oneFadeIn();
      }
      finishReport();
      break;
    case "2":
      audio.init("turnon/turnon_"+node.my_id+".wav");
      oneFadeIn();
      finishReport();
      break;
    default:
      println("No input: ", input); 
      m.alloff();
    }
    break;
  case "execute_2":
    switch(input) {
    case "1":
    case "2":
    case "3":
    case "4":
    case "5":
      if (node.my_id.equals(input)) {
        audio.init("install/install_"+input+".wav");
        oneFadeIn();
      }
      finishReport();
      break;
    case "6":
      audio.init("install/install_finish.wav");
      oneFadeIn();
      finishReport();
      break;
    default:
      println("No input: ", input); 
      m.alloff();
    }
    break;
  case "execute_3":
    switch(input) {
    case "1":
      if (node.my_id.equals("3")) insideOut();
      finishReport();
      break;
    case "2":
      if (!node.my_id.equals("3")) OutsideIn();
      finishReport();
      break;
    case "3":
      if (node.my_id.equals("1")) CrossBlink();
      else if (node.my_id.equals("2")) CircleBlink();
      else if (node.my_id.equals("4")) CircleBlink();
      else if (node.my_id.equals("5")) Swing();
      finishReport();
      break;
    default:
      println("No input: ", input); 
      m.alloff();
    }
    break;
  case "execute_4":
    switch(input) {
    case "1":
      if (node.my_id.equals("3")) insideOut();
      finishReport();
      break;
    case "2":
      if (!node.my_id.equals("3")) OutsideIn();
      finishReport();
      break;
    case "3":
      Sync();
      finishReport();
      break;
    case "4":
      CircleBlink();
      finishReport();
      break;
    default:
      println("No input: ", input); 
      m.alloff();
    }
    break;
  case "execute_5":
    switch(input) {
    case "1":
      CircleOn(); 
      finishReport();
      break;
    case "2":
      if (node.my_id.equals("3")) Quit();
      else m.allon(4000);
      finishReport();
      break;
    default:
      println("No input: ", input); 
      m.alloff();
    }
    break;
  default: 
    println("No function: ", function);
    m.alloff();
  }
}

void finishReport() {
  node.sendMessage("finishReport", node.my_id);
}
void oneFadeIn() {
  int[] p = {0};
  setPorts(p);
  m.fadein(ports, 4000);
}
void insideOut() {
  int[] p_1 = {0};
  setPorts(p_1);
  m.fade(1, ports, 1800);
  int[] p_2 = {1, 2, 3, 4, 5, 6, 7, 8};
  setPorts(p_2);
  m.fade(1, ports, 1200);
}
void OutsideIn() {
  int[] p_1 = {1, 2, 3, 4, 5, 6, 7, 8};
  int[] p_2 = {0};
  setPorts(p_1);
  m.fade(1, ports, 1200);
  setPorts(p_2);
  m.fade(1, ports, 1800);
}
void CrossBlink() {
  int[] p = {0, 2, 4, 6, 8};
  setPorts(p);
  m.blink_more(ports, 2, 200, 4000);
}
void CircleBlink() {
  int[] p = {1, 2, 3, 4, 5, 6, 7, 8};
  setPorts(p);
  m.blink_more(ports, 2, 200, 4000);
}
void Swing() {
  int start = 3;
  int[][] p={{start+2, start+1, start, start+4, start+3}, 
    {start+3, start+2, start+1, start, start+4}, {start+4, start+3, start+2, start+1, start}, 
    {start+3, start+4, start+2, start+1, start}, {start+2, start+3, start+4, start+1, start}, {start+1, start+2, start+3, start, start+4}, 
    {start, start+1, start+2, start+4, start+3}, {start+1, start, start+2, start+4, start+3}, {start+2, start+1, start, start+4, start+3}};
  for (int i=0; i<3; i++) { // Come and go twice
    for (int j=0; j<p.length; j++) {
      setPorts(p[j]);
      m.switchon(ports, 3, 4000);
      delay(200);
    }
  }
  m.alloff();
}
void Sync() {
  int[] p_1 = {1, 3, 5, 7};
  int[] p_2 = {2, 4, 6, 8};
  setPorts(p_1);
  m.alloff();
  m.on(ports, 4000);
  delay(300);
  setPorts(p_2);
  m.alloff();
  m.on(ports, 4000);
  delay(300);
  setPorts(p_1);
  m.alloff();
  m.on(ports, 4000);
  delay(300);
  m.alloff();
}
void Quit() {
  int[][] p = {{5}, {4, 5, 6}, {0, 3, 4, 5, 6, 7}, 
    {0, 2, 3, 4, 5, 6, 7, 8}, {0, 1, 2, 3, 4, 5, 6, 7, 8}};
  for (int i=0; i<p.length; i++) {
    setPorts(p[i]);
    m.on(ports, 4000);
    delay(400);
  }
  m.alloff();
}
void CircleOn() {
  int[] p_1 = {8};
  setPorts(p_1);
  m.fadein(ports, 2000);
  int[] p = {8, 7, 6, 5, 4, 3, 2, 1};
  for (int i=0; i<=p.length; i++) {
    setPorts(p);
    m.switchon(ports, 3, 4000);
    delay(200);
    for (int j=0; j<p.length; j++) {
      p[j] = p[j]%p.length+1;
    }
  }
  m.alloff();
}