
public class Node{
  OOCSI oocsi;
  String server_ip = "oocsi.id.tue.nl";
  String my_ip="0";
  String MODE = "0";
  String STATUS = "0";
  Policy policy = new Policy();
 
  String serverDir = "/home/pi/Documents/Nature-and-Seamless-Interaction";
  File workingDir = new File(serverDir);
  
 Node(){
   my_ip = getIP();
   policy.m_setup();
 }
 
 void connectOOCSI(String ServerIP,int ServerPort){
    // OOCSI channel connect
    server_ip = ServerIP;
    oocsi = new OOCSI(this,ServerIP, ServerIP,ServerPort);
    oocsi.subscribe(ServerIP);
  }
  void connectOOCSI(){
    // OOCSI channel connect
    oocsi = new OOCSI(this,my_ip, server_ip);
    oocsi.subscribe("Server");
    oocsi.subscribe(server_ip);
  }
  
 boolean sendMessage(String function_name , String msg){
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