import nl.tue.id.oocsi.*;
import java.io.*;

Node node;

int numItems = 3;
int mode, numFinish;
String command = "execute_3";

void setup() {
  node = new Node("../setting", "Hub");
  node.connectOOCSI();
  mode = 1;
  node.sendMessage(command, "1");
}

void draw() {
  if (numFinish==numItems) {
    switch(mode) {
    case 1:
    case 2:
    case 3:
    case 4:
      mode += 1;
      node.sendMessage(command, str(mode));
      break;
    default:
      println("Run into wrong mode: ", mode);
      mode = 0;
    }
    // Reset the number of Items finished the command
    numFinish = 0;
  }
}

void Handler(String function, String input) {
  switch(function) {
  case "finishReport":
    numFinish += 1;
    println("finishReport: ", input);
    break;
  default:
    println("No function: ", function);
  }
}