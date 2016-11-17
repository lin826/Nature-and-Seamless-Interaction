
int MODE = 0;
ArrayList<Audio> adio_list = new ArrayList<Audio>();

void setup(){
  for(int i=1;i<5;i++){
    adio_list.add(new Audio());
    adio_list.get(i-1).init("install/install_"+i+".wav");
    delay(1000);
  }
  adio_list.add(new Audio());
  adio_list.get(4).init("install/install_finish.wav");
}

void draw(){
  for(Audio a: adio_list){
    //a.play();
    delay(1000);
    print("Play!");
  }
}