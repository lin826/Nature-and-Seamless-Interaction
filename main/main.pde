import ddf.minim.*;

Minim minim;
AudioPlayer player;
 
void setup()
{
  size(100, 100);
 
  minim = new Minim(this);
  player = minim.loadFile("song.mp3");
  player.play();
}
 
void draw()
{
  // do what you do
}  
