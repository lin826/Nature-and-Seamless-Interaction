import processing.serial.*;
import nl.tue.id.oocsi.*;
import java.io.*;


String setting_items[] = {"OOCSI_STATUS","ID","MODE"};
String setting_data[]  = {"0","0","0"};
// OOCSI_STATUS: Control the connecting status
//   Unconnected: Don't react to any OOCSI message.
// ID: Control the sound to use
// Mode: Control the task to demo

String ID = "00000";
Node node;

void setup(){
  updateSetting();
  printSetting();
  
  //m_setup();
  
  node = new Node();
  node.connectOOCSI();
  node.setStatus(setting_data[0]);
  node.setMode(setting_data[2]);
}

void draw(){
  setting_data[2] = node.MODE;
  updateSetting();
}

void updateSetting(){
  String lines[] = loadStrings("../../setting");
  for (int i = 0 ; i < lines.length; i++) {
    for (int j = 0 ; j < setting_items.length ; j++){
      if(lines[i].length()<setting_items[j].length()) 
        continue;
      if(lines[i].substring(0, setting_items[j].length()).equals(setting_items[j]))
        setting_data[j] = lines[i].substring(setting_items[j].length()+1);
    }
  }
}

void printSetting(){
  for (int j = 0 ; j < setting_items.length; j++){
    println(setting_items[j],": ",setting_data[j]);
  }
}