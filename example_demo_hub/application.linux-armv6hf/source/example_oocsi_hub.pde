import nl.tue.id.oocsi.*;
import java.io.*;

Node node = new Node("../setting","Hub");

void setup() {
  node.connectOOCSI();
}

void draw() {
  node.sendMessage("functionName", "forExample");
}

void Handler(String function, String input) {
  println("function: ", function);
  println("io_msg: ", input);
}