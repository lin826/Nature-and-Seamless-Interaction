import beads.*;
import java.util.Arrays; 

class Audio{
  AudioContext ac;
  
  void init(String s) {
    ac = new AudioContext();
    fileSelected(s);
    ac.start();
  }

  void fileSelected(String fileName) {
  /*
   * Here's how to play back a sample.
   * 
   * The first line gives you a way to choose the audio file.
   * The (commented, optional) second line allows you to stream the audio rather than loading it all at once.
   * The third line creates a sample player and loads in the Sample.
   * SampleManager is a utility which keeps track of loaded audio
   * files according to their file names, so you don't have to load them again.
   */
  String audioFileName = dataPath("audio/"+fileName);
  SamplePlayer player = new SamplePlayer(ac, SampleManager.sample(audioFileName));
  
  Gain g = new Gain(ac, 2, 0.2);
  g.addInput(player);
  ac.out.addInput(g);
  }
  
  void play(){
    ac.start();
  }
}