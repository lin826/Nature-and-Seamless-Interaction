public class Node {
  OOCSI oocsi;
  String server_ip = "oocsi.id.tue.nl";
  String my_id="0";
  String MODE = "0";
  String STATUS = "0";

  String serverDir = "/home/pi/Documents/Nature-and-Seamless-Interaction";
  File workingDir = new File(serverDir);

  Node(String settingFile) {
    updateSetting(settingFile);
  }
  Node(String settingFile,String ip) {
    updateSetting(settingFile);
    my_id = ip;
  }

  void connectOOCSI(String ServerIP, int ServerPort) {
    // OOCSI channel connect
    server_ip = ServerIP;
    oocsi = new OOCSI(this, ServerIP, ServerIP, ServerPort);
    oocsi.subscribe(ServerIP);
  }
  void connectOOCSI(String ServerIP) {
    // OOCSI channel connect
    server_ip = ServerIP;
    oocsi = new OOCSI(this, my_id, ServerIP);
    oocsi.subscribe("Server");
  }
  void connectOOCSI() {
    // OOCSI channel connect
    oocsi = new OOCSI(this, my_id, server_ip);
    oocsi.subscribe("Server");
  }

  boolean sendMessage(String function_name, String msg) {
    try {
      oocsi.channel("Server")
        .data("sender_ip", my_id)
        .data("function", function_name)
        .data("io_msg", msg).send();
      return true;
    }
    catch(Exception e) {
      println("sendMessage Exception for '"+msg+"'");
      return false;
    }
  }
  private void setMode(String s) {
    MODE = s;
  }
  private void setStatus(String s) {
    STATUS = s;
  }

  private void updateSetting(String addr) {
    String setting_items[] = {"OOCSI_STATUS", "ID", "MODE"};
    String setting_data[]  = {"0", "0", "0"};
    String lines[] = loadStrings(addr);
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].length()==0)
        continue;
      if (lines[i].charAt(0)=='#')
        continue;
      for (int j = 0; j < setting_items.length; j++) {
        if (lines[i].length()<setting_items[j].length()) 
          continue;
        if (lines[i].substring(0, setting_items[j].length()).equals(setting_items[j]))
          setting_data[j] = lines[i].substring(setting_items[j].length()+1);
      }
    }
    my_id = setting_data[1];
    setStatus(setting_data[0]);
    setMode(setting_data[2]);
  }

  public void handleOOCSIEvent(OOCSIEvent msg) {
    boolean toHandle = false;
    if((msg.getString("sender_ip").equals("Hub")) && !my_id.equals("Hub")){
      toHandle = true;
    }else if(!(msg.getString("sender_ip").equals("Hub")) && my_id.equals("Hub")){
      toHandle = true;
    }
    
    if (!STATUS.equals("Unconnected") && toHandle) {
      try {
        Handler(msg.getString("function"), msg.getString("io_msg"));
      } 
      catch(Exception e) {
        println("Next stage error"+e);
      }
    }
  }
}