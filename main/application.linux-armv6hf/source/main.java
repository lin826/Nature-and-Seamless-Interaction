import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import nl.tue.id.oocsi.*; 
import java.io.*; 
import processing.io.*; 
import beads.*; 
import java.util.Arrays; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class main extends PApplet {






String setting_items[] = {"OOCSI_STATUS","ID","MODE"};
String setting_data[]  = {"0","0","0"};
// OOCSI_STATUS: Control the connecting status
//   Unconnected: Don't react to any OOCSI message.
// ID: Control the sound to use
// Mode: Control the task to demo

Node node;

public void setup(){
  updateSetting();
  printSetting();
  
  node = new Node(setting_data[1]);
  node.connectOOCSI();
  node.setStatus(setting_data[0]);
  node.setMode(setting_data[2]);
}

public void draw(){
  setting_data[2] = node.MODE;
  updateSetting();
}

public void updateSetting(){
  String lines[] = loadStrings("/home/pi/Documents/setting");
  for (int i = 0 ; i < lines.length; i++) {
    for (int j = 0 ; j < setting_items.length ; j++){
      if(lines[i].length()<setting_items[j].length()) 
        continue;
      if(lines[i].substring(0, setting_items[j].length()).equals(setting_items[j]))
        setting_data[j] = lines[i].substring(setting_items[j].length()+1);
    }
  }
}

public void printSetting(){
  for (int j = 0 ; j < setting_items.length; j++){
    println(setting_items[j],": ",setting_data[j]);
  }
}

public class Node{
  OOCSI oocsi;
  String server_ip = "oocsi.id.tue.nl";
  String my_ip="0";
  String MODE = "0";
  String STATUS = "0";
  Policy policy = new Policy();
 
  String serverDir = "/home/pi/Documents/Nature-and-Seamless-Interaction";
  File workingDir = new File(serverDir);
  
 Node(String id){
   my_ip = id;
   policy.m_setup();
 }
 
 public void connectOOCSI(String ServerIP,int ServerPort){
    // OOCSI channel connect
    server_ip = ServerIP;
    oocsi = new OOCSI(this,ServerIP, ServerIP,ServerPort);
    oocsi.subscribe(ServerIP);
  }
  public void connectOOCSI(){
    // OOCSI channel connect
    oocsi = new OOCSI(this,my_ip, server_ip);
    oocsi.subscribe("Server");
    oocsi.subscribe(server_ip);
  }
  
 public boolean sendMessage(String function_name , String msg){
    try{
      oocsi.channel("Server")
        .data("sender_ip", my_ip)
        .data("function",function_name)
        .data("io_msg",msg).send();
      return true;
    }catch(Exception e){
      println("sendMessage Exception for '"+msg+"'");
      return false;
    }
  }
  private BufferedReader commandLine(String s){
    try{
      Process p = Runtime.getRuntime().exec(s, null, workingDir);
      return new BufferedReader(new InputStreamReader(p.getInputStream()));
    } catch(Exception e){
      println("Error running command!");  
      println(e);
    }
    return null;
  }
  private String getIP(){
  String prefex = "    inet "; 
  String suffix = " brd";
  String except = "127.0.0.1";
  try{
    BufferedReader stdInput = commandLine("sudo ip addr show");
    String returnedValues; 
    while ( (returnedValues = stdInput.readLine ()) != null) {
        if(returnedValues.contains(prefex) && !returnedValues.contains(except)){
          String mIP = returnedValues.substring(prefex.length(),returnedValues.indexOf(suffix));
          println("Host IP: "+ mIP);
          return mIP;
        }
      }
  } catch(Exception e) {
    println("Error running command!");  
    println(e);
  }
  return "false";
}
  private void setMode(String s){
    MODE = s;
  }
  private void setStatus(String s){
    STATUS = s;
  }
  private void setSetting(String s){
    if(s.substring(0,my_ip.length()).equals(my_ip)){
    try {
      FileWriter output = new FileWriter("/home/pi/Documents/setting", true);
      output.write(s.substring(my_ip.length()+2));
      output.flush();
      output.close();
    }
    catch(IOException e) {
      println("setting is unable to write!");
      e.printStackTrace();
    }
        }
  }
  
  public void handleOOCSIEvent(OOCSIEvent msg){
    if (!STATUS.equals("Unconnected") && (msg.getString("sender_ip").equals("Server"))){
    try{
      print(msg.getString("sender_ip")+": ");
      print(msg.getString("function")+"(");
      println(msg.getString("io_msg")+")");
      if(msg.getString("function").equals("setMode")){
        setMode(msg.getString("io_msg"));
        policy.m_draw(msg.getString("io_msg"));
        sendMessage("reportFinish",my_ip);
      }
      else if(msg.getString("function").equals("setSetting")){
        setSetting(msg.getString("io_msg"));
      }
      else{
        commandLine(msg.getString("function"));
      }
    } catch(Exception e){
      println("Next stage error");
    }
  }
  
}


class Policy{
ArrayList<ArrayList<Integer>> channels = new ArrayList<ArrayList<Integer>>(); 
ArrayList <ArrayList<Integer>> ports = new ArrayList<ArrayList<Integer>>();

Methods m;
Audio audio = new Audio();

public void m_setup(){
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

public void m_draw(String mode){
  try{
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
    Swing(); // Task unknown
  } else if(mode.equals("4")  && setting_data[1].equals("3")){
    insideOut();
  } else if(mode.equals("-4")  && !setting_data[1].equals("3")){
    allFade(); // others also wake up 
  } else if(mode.equals("4_2")){
    Sync(); // Sync success that adjust by user
  } else if(mode.equals("5")){
    CircleOn(); // Sync success that adjust by user
  } else if(mode.equals("-5") && !setting_data[1].equals("1")){
    m.allon(4000); // Sync success that adjust by user
  } else if(mode.equals("-5") && setting_data[1].equals("1")){
    Quit(); // Sync success that adjust by user
  }
  } catch (Exception e){
    println("Error in m_draw(): ",e);
  }
}
public void oneFadeIn(){
  int[] p = {0};
  setPorts(p);
  m.fadein(ports,4000);
}
public void allFade(){
 int[] p = {0,1,2,3,4,5,6,7,8};
 setPorts(p);
 m.fade(3,ports,4000);
}
public void insideOut(){
  int[] p_1 = {0};
  setPorts(p_1);
  m.fade(1,ports,1800);
  int[] p_2 = {1,2,3,4,5,6,7,8};
  setPorts(p_2);
  m.fade(1,ports,1200);
}
public void OutsideIn(){
  int[] p_1 = {1,2,3,4,5,6,7,8};
  int[] p_2 = {0};
  setPorts(p_1);
  m.fade(1,ports,1200);
  setPorts(p_2);
  m.fade(1,ports,1800);
}
public void CrossBlink(){
  int[] p = {0,2,4,6,8};
  setPorts(p);
  m.blink_more(ports,2,200,4000);
}
public void CircleBlink(){
  int[] p = {1,2,3,4,5,6,7,8};
  setPorts(p);
  m.blink_more(ports,2,200,4000);
}
public void Swing(){
  int start = 3;
  int[][] p={{start+2,start+1,start,start+4,start+3},
    {start+3,start+2,start+1,start,start+4},{start+4,start+3,start+2,start+1,start},
    {start+3,start+4,start+2,start+1,start},{start+2,start+3,start+4,start+1,start},{start+1,start+2,start+3,start,start+4},
    {start,start+1,start+2,start+4,start+3},{start+1,start,start+2,start+4,start+3},{start+2,start+1,start,start+4,start+3}};
  for(int i=0;i<3;i++){ // Come and go twice
    for(int j=0;j<p.length;j++){
      setPorts(p[j]);
      m.switchon(ports,3,4000);
      delay(200);
    }
  }
  m.alloff();
}
public void Quit(){
  int[][] p = {{5},{4,5,6},{0,3,4,5,6,7},
      {0,2,3,4,5,6,7,8},{0,1,2,3,4,5,6,7,8}};
  for(int i=0;i<p.length;i++){
    setPorts(p[i]);
    m.on(ports,4000);
    delay(400);
  }
  m.alloff();
}
public void CircleOn(){
  int[] p_1 = {8};
  setPorts(p_1);
  m.fadein(ports,2000);
  int[] p = {8,7,6,5,4,3,2,1};
  for(int i=0;i<=p.length;i++){
    setPorts(p);
    m.switchon(ports,3,4000);
    delay(200);
    for(int j=0;j<p.length;j++){
      p[j] = p[j]%p.length+1;
    }
  }
  m.alloff();
}
public void Sync(){
  int[] p_1 = {1,3,5,7};
  int[] p_2 = {2,4,6,8};
    setPorts(p_1);
    m.alloff();
    m.on(ports,4000);
    delay(300);
    setPorts(p_2);
    m.alloff();
    m.on(ports,4000);
    delay(300);
    setPorts(p_1);
    m.alloff();
    m.on(ports,4000);
    delay(300);
    m.alloff();
}
// if not all lights are to be used, this method can be called to create an arraylist of lights involved 
public void setPorts(int[] pins){
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

 

class Audio{
  AudioContext ac;
  
  public void init(String s) {
    ac = new AudioContext();
    fileSelected(s);
  }

  public void fileSelected(String fileName) {
  /*
   * Here's how to play back a sample.
   * 
   * The first line gives you a way to choose the audio file.
   * The (commented, optional) second line allows you to stream the audio rather than loading it all at once.
   * The third line creates a sample player and loads in the Sample.
   * SampleManager is a utility which keeps track of loaded audio
   * files according to their file names, so you don't have to load them again.
   */
  println(fileName);
  String audioFileName = dataPath("audio/"+fileName);
  SamplePlayer player = new SamplePlayer(ac, SampleManager.sample(audioFileName));
  
  Gain g = new Gain(ac, 2, 0.2f);
  g.addInput(player);
  ac.out.addInput(g);
  ac.start();
  }
  
}
class Methods {

  ArrayList<ArrayList<Integer>> portList = new ArrayList<ArrayList<Integer>>();
  ArrayList <Integer> p = new ArrayList<Integer>(); 
  
  int PWMport = 0x40;
  int brightness =0; 
  int max_brightness = 0;
  int paused= 0;
  I2C i2c; 
  
  
  Methods(){
    
    //initialise I2C
    this.i2c = new I2C(I2C.list()[0]);    
    
    //ensure I2C channels are available for writing 
    i2c.beginTransmission(0x40);
    i2c.write(0);
    i2c.write(100);
    i2c.endTransmission();
  }
  
  
  
  //switch all lights off 
  public void alloff(){
    IntList p = new IntList();
    
    for (int i =9; i<42; i+=4){
     p.append(i); 
    }
    
    for(int i=0;i<p.size(); i++){
      brightness = 0x10;
      basics(0,p.get(i));
    }
  }
  
  
  
  
  //switch all lights on
  public void allon(int brightness){
    IntList p = new IntList();
    
    for (int i =6; i<42; i++){
     p.append(i); 
    }
    
    for(int i=0;i<p.size(); i++){
      this.brightness = brightness;
      basics(1,p.get(i));
    }
  }

   
  //method: fade in AND out (breathing lights), the lights fade one by one
  //times: how many times of breathing cycle
  //1 cycle = fade in and fade out 
  //portlist= the lights involved 
  //max_brightness = how bright the light should be ; can range from 0 to 4095, with 0 being no light and 4095 being the brightest
  
  public void fade1(int times, ArrayList portList,int max_brightness){
    
    this.portList= portList; 
    
    int flag8 = 0; 
    while(flag8< times){
      
      for (int i=0; i<portList.size(); i++){
        p = (ArrayList) portList.get(i);
        this.max_brightness= max_brightness;
        type(2);       
      }
      
       for (int i=0; i<portList.size(); i++){
        p = (ArrayList) portList.get(i);
        this.max_brightness = max_brightness;
        type(3);       
      }
      flag8++;
    }
  }
  
  //method: lights fade in one by one 
  //waiting: duration of pause in between two lights fading in, if any
  //portlist= the lights involved 
  //max_brightness = how bright the light should be ; can range from 0 to 4095, with 0 being no light and 4095 being the brightest
  public void fadein1(ArrayList portList, int waiting, int max_brightness){
   this.portList  = portList; 
   for(int i=0; i<portList.size(); i++){
    p = (ArrayList) portList.get(i);
    this.max_brightness= max_brightness;
    
    type(2);
    delay(waiting);
     
   }
  }
  
  //method: lights fade out one by one 
  //waiting: duration of pause in between two lights fading out, if any
  //portlist= the lights involved 
  //max_brightness = how bright the light should be ; can range from 0 to 4095, with 0 being no light and 4095 being the brightest
  
  public void fadeout1(ArrayList portList, int waiting, int max_brightness){
   this.portList = portList; 
   for(int i=0; i<portList.size(); i++){
    p =(ArrayList)portList.get(i);
    this.max_brightness = max_brightness;
    
    type(3);
    delay(waiting);     
   }
    
  }
  
  
  
  
  
  
  //method: fade in AND out (breathing lights), the lights fade together
  //times: how many times of breathing cycle
  //1 cycle = fade in and fade out 
  //portlist= the lights involved 
  //max_brightness = how bright the light should be ; can range from 0 to 4095, with 0 being no light and 4095 being the brightest  
  public void fade(int times, ArrayList portList,int max_brightness){
    
    this.portList= portList; 
    
    int flag2 = 0; 
    while(flag2< times){   
      this.max_brightness= max_brightness;
      type(4);  
      type(5); 
      flag2++;      
    }     
  }
  
  
  
  //method: lights fade in together
  //portlist= the lights involved 
  //max_brightness = how bright the light should be ; can range from 0 to 4095, with 0 being no light and 4095 being the brightest
  
  public void fadein(ArrayList portList, int max_brightness){
    
   this.portList = portList;
   
   
   this.max_brightness = max_brightness; 
   type(4);
    
  }
  
  
  //method: lights fade out together
  //portlist= the lights involved 
  //max_brightness = how bright the light should be ; can range from 0 to 4095, with 0 being no light and 4095 being the brightest
  
  public void fadeout(ArrayList portList, int max_brightness){    
   this.portList = portList; 
   this.max_brightness = max_brightness; 
   type(5);
  }
  
  
  
  
  //method: switch off selected lights 
  //paused: duration of wait between two lights switching off, if any
  public void off(ArrayList portList, int paused){
    this.portList =portList;
    
    if(paused ==0){
      for(int i=0; i<portList.size(); i++){
        p =  (ArrayList)portList.get(i);
        type(1);
      }
    }
    else{
      
      for(int i=0; i<portList.size(); i++){
        p =  (ArrayList)portList.get(i);
        type(1);
        delay(paused);
      }     
    }  
  }



  
  //method: switch on selected lights  one by one
  //paused: duration of wait between two lights switching on, if any
  //brightness: how bright the light is when turned on, with 0 being no light and 4095 being the brightest 
  public void on1(ArrayList portList, int paused,int brightness){
    
    this.portList = portList; 
    this.brightness= brightness;
    if (paused==0){
      
     for(int i=0; i<portList.size(); i++){
        p =  (ArrayList)portList.get(i);
        type(0);
      }
    }
    else{     
      for(int i=0; i<portList.size(); i++){
        p =  (ArrayList)portList.get(i);
        type(0);
        delay(paused);
      }
    }      
   }
   
   //method: switch on selected lights 
   //brightness: how bright the light is when turned on, with 0 being no light and 4095 being the brightest 
   public void on(ArrayList portList,int brightness){
    this.portList = portList; 
   
     for(int i=0;i<portList.size();i++){
       p= (ArrayList) portList.get(i);
       this.brightness = brightness; 
       type(0);
     }
   }
   
   public void switchon(ArrayList portList,int firstNum,int brightness){
    this.portList = portList; 
   
     for(int i=0;i<portList.size();i++){
       p= (ArrayList) portList.get(i);
       if(i>=firstNum)
         type(1);
       else {
         this.brightness = brightness/(i+1); 
         type(0);
       }
     }
   }
  
  
  
  // method: lights blink one by one
  //waiting: duration of pause in between two lights blinking, if any
  //portlist= the lights involved 
  //blink = number of times of blinking 
  //max_brightness = how bright the light should be ; can range from 0 to 4095, with 0 being no light and 4095 being the brightest
  
  public void blink(ArrayList portList, int blink, int waiting, int brightness){
   this.portList = portList; 
   int flag=0; 
   
   while(flag<blink){
     
     for(int i=0;i<portList.size();i++){
       p= (ArrayList) portList.get(i);
       this.brightness = brightness; 
       type(0);
       delay(waiting);
       type(1); 
       delay(waiting);
     }
     
     flag++;

   }    
  }
  
  
  
  // method: lights blink all at once 
  //waiting: duration of pause in between two lights blinking, if any
  //portlist= the lights involved 
  //blink = number of times of blinking 
  //max_brightness = how bright the light should be ; can range from 0 to 4095, with 0 being no light and 4095 being the brightest
  
  public void blink_more(ArrayList portList, int blink, int waiting,int brightness){
   this.portList = portList; 
   int flag7 =0; 
   
   while(flag7<blink){
        this.brightness = brightness;

     type(6);
     delay(waiting);
     type(7);
     flag7++;   
     delay(waiting);
   }    
  }
  

  
  
  public void type(int method){ 
    int num = method;     
    switch(num) {
      
      //on
     
      case 0: 

        
       for(int i=0; i<p.size(); i++){
           
           basics(1,p.get(i));
        }
        break;

      // off 
      
      case 1:
        this.brightness = 0x10; 
        basics(0,p.get(3));   
        

        break;

      
      //fading  in  
      case 2: 
       
       brightness=0;
       int fadeAmount = 135;
       boolean flag = true;

       while(flag){
              

        brightness = brightness + fadeAmount; 
        
        if (brightness >= max_brightness){
          brightness = max_brightness;
          flag= false;
        }


        for (int i=0;  i<p.size(); i++){
             basics(1,p.get(i));
          
        }        
        delay(100);  
       }
       break;
       
       
       
      //fading out 
       case 3: 
       
       int fadeAmount1 =  -135; 
       brightness = max_brightness; 
       boolean flag1 = true; 
       
       while(flag1){
              

        brightness = brightness + fadeAmount1; 

        if (brightness <= 0){
          brightness = 0;
          flag1 = false;
        }
          
        for (int i=0;  i<p.size(); i++){
           basics(1,p.get(i));
          
        }        
        delay(100);
       }
      break;
      
      
      //fade in all
      case 4: 
       
       brightness=0;
       int fadeAmount3 = 135;
       boolean flag3 = true;

       while(flag3){
              

        brightness = brightness + fadeAmount3; 
        
        if (brightness >= max_brightness){
          brightness = max_brightness;
          flag3= false;
        }


        for (int i=0;  i<portList.size(); i++){
          for(int j=0; j<portList.get(i).size(); j++){
             basics(1,portList.get(i).get(j));;
          }
        }        
        delay(100);  
       }
       break;
     
     
      // fadeout_all
     case 5:
       int fadeAmount5 =  -135; 
       brightness = max_brightness; 
       boolean flag5 = true; 
       
       while(flag5){
              

        brightness = brightness + fadeAmount5; 

        if (brightness <= 0){
          brightness = 0;
          flag5 = false;
        }
          
        for (int i=0;  i<portList.size(); i++){
          for(int j=0; j<portList.get(i).size(); j++){
           basics(1,portList.get(i).get(j));
           
          }
        }        
        delay(100);  
       }
      break;
      
      //all on
       case 6: 
        for(int i=0; i<portList.size(); i++){
           for(int j=0; j<portList.get(i).size(); j++){         
             basics(1,portList.get(i).get(j));
           }
                       
        }
        break;
        
        
       //all off
       case 7:
       
       for(int i=0; i<portList.size(); i++){
         for(int j=0; j<portList.get(i).size(); j++){
           brightness = 0x10; 
           basics(0,portList.get(i).get(j));
          }
        }
        break;
      } 
    }
    
    
    public void basics(int temp, int port1 ){
      
     int num = temp; 
     
     int port = port1;
      
     switch(num){
      
      //case 0: normal transmission 
      case 0: 
 
        
        i2c.beginTransmission(PWMport);
        i2c.write(port); 
        i2c.write(brightness);
        i2c.endTransmission();
        break;
        
      
      // case 1: fading 
      case 1:
          
          i2c.beginTransmission(PWMport);
          i2c.write(port);
      
          if(port%4==2) i2c.write(0);
          if(port%4==3) i2c.write(0);
          if(port%4==0) i2c.write(brightness & 0xf);
          if(port%4==1) i2c.write(((brightness & 0x0F00) >> 8)& 0xf);
          i2c.endTransmission();
          break;
      } 
    }
}
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "main" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
