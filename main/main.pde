<<<<<<< HEAD
import beads.*;
import java.util.Arrays; 

=======

import beads.*;
import java.util.Arrays; 

>>>>>>> af1872f56a1c233d87df5731568d9b61a97685ed
AudioContext ac;

void setup() {
  ac = new AudioContext();
  fileSelected();
}

void fileSelected() {
  /*
   * Here's how to play back a sample.
   * 
   * The first line gives you a way to choose the audio file.
   * The (commented, optional) second line allows you to stream the audio rather than loading it all at once.
   * The third line creates a sample player and loads in the Sample.
   * SampleManager is a utility which keeps track of loaded audio
   * files according to their file names, so you don't have to load them again.
   */
  String audioFileName = dataPath("test.mp3");
  SamplePlayer player = new SamplePlayer(ac, SampleManager.sample(audioFileName));
  
  Gain g = new Gain(ac, 2, 0.2);
  g.addInput(player);
  ac.out.addInput(g);
  ac.start();
  
}


void draw() {
}
