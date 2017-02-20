import beads.*;
import java.util.Arrays; 

class Audio {
  AudioContext ac = new AudioContext();

  void init(String s) {
    fileSelected(s);
  }

  void fileSelected(String fileName) {
    println(fileName);
    String audioFileName = dataPath("audio/"+fileName);
    SamplePlayer player = new SamplePlayer(ac, SampleManager.sample(audioFileName));

    Gain g = new Gain(ac, 2, 0.2);
    g.addInput(player);
    ac.out.addInput(g);
    ac.start();
  }
}