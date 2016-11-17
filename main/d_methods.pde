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
  void alloff(){
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
  void allon(int brightness){
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
  
  void fade1(int times, ArrayList portList,int max_brightness){
    
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
  void fadein1(ArrayList portList, int waiting, int max_brightness){
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
  
  void fadeout1(ArrayList portList, int waiting, int max_brightness){
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
  void fade(int times, ArrayList portList,int max_brightness){
    
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
  
  void fadein(ArrayList portList, int max_brightness){
    
   this.portList = portList;
   
   
   this.max_brightness = max_brightness; 
   type(4);
    
  }
  
  
  //method: lights fade out together
  //portlist= the lights involved 
  //max_brightness = how bright the light should be ; can range from 0 to 4095, with 0 being no light and 4095 being the brightest
  
  void fadeout(ArrayList portList, int max_brightness){    
   this.portList = portList; 
   this.max_brightness = max_brightness; 
   type(5);
  }
  
  
  
  
  //method: switch off selected lights 
  //paused: duration of wait between two lights switching off, if any
  void off(ArrayList portList, int paused){
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
  void on1(ArrayList portList, int paused,int brightness){
    
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
   void on(ArrayList portList,int brightness){
    this.portList = portList; 
   
     for(int i=0;i<portList.size();i++){
       p= (ArrayList) portList.get(i);
       this.brightness = brightness; 
       type(0);
     }
   }
   //method: switch on selected lights 
   //brightness: how bright the light is when turned on, with 0 being no light and 4095 being the brightest 
   void gradienton(ArrayList portList,int brightness){
    this.portList = portList; 
     for(int i=0;i<portList.size();i++){
       p= (ArrayList) portList.get(i);
       this.brightness = brightness/portList.size()*(i+1); 
       type(0);
     }
   }
  
  
  
  // method: lights blink one by one
  //waiting: duration of pause in between two lights blinking, if any
  //portlist= the lights involved 
  //blink = number of times of blinking 
  //max_brightness = how bright the light should be ; can range from 0 to 4095, with 0 being no light and 4095 being the brightest
  
  void blink(ArrayList portList, int blink, int waiting, int brightness){
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
  
  void blink_more(ArrayList portList, int blink, int waiting,int brightness){
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
  

  
  
  void type(int method){ 
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
    
    
    void basics(int temp, int port1 ){
      
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