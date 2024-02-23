 Flock flock;

int frames = 0;
int time_s = 60*60*hour() + 60*minute() + second() + millis()/1000;
boolean writing = false;

void settings() {
  fullScreen();
}

void setup() {
  background(0,0,0);
  frameRate(60);
  flock = new Flock();
  /*
  for (int i=0; i<1000; i++) {
    flock.Add_Boid(width/2, height/2);
  }
  */
  flock.Add_Boid(width/2+25, height/2);
  flock.Add_Boid(width/2-25, height/2);
  flock.Add_Label(width*0.9, height*0.9, 240, 240, 240, 30, "Boids - by Kiko");
  println("window width: " + width + "   window height: " + height);
}

void draw() {
  flock.run();
  
  // Every second, the console displays the fps of the last second
  frames++;
  if ((60*60*hour() + 60*minute() + second() + millis()/1000)-time_s > 1){
    print("fps: ");
    println(frames);
    time_s = 60*60*hour() + 60*minute() + second() + millis()/1000;
    frames = 0;
  }
}

void mousePressed() {
  if (mouseButton==LEFT) {
    // Start spawning Boids on mouse location's
    flock.spawning = true;
  } else if (mouseButton==CENTER) {
    // Create a Scarer on the current location of the cursor
    flock.Add_Scarer(mouseX, mouseY, 3200, true, true, false);
  } else if (mouseButton==RIGHT) {
    // Move the Scarer ("Mouse Scarer") to the cursor position, and turn it on, until the mouse button is released
    flock.scarers_list.get(0).Go_To(mouseX, mouseY); 
    flock.scarers_list.get(0).Scarer_On();
  }
}

void mouseReleased(){
  if (mouseButton==LEFT) {
    // Stop spawning Boids
    flock.spawning = false;
  } else if (mouseButton==CENTER) {
  } else if (mouseButton==RIGHT) {
    // Deactivate the "Mouse Scarer"
    flock.scarers_list.get(0).Scarer_Off();
  }
}

void keyPressed() {
  // If Sim is not in "writing" state, take in keyboard input as normal
  if (writing == false) {
    
    if (key==DELETE) {
      // Clear the Screen, and empty all the arrays that contain the Boids and Scarers
      flock.Clear();
    }
    if (key==BACKSPACE) {
      // Remove all Boids around a certain aread around the cursor
      flock.Delete_Boids(mouseX, mouseY);
      flock.Delete_Scarers(mouseX, mouseY);
      flock.Delete_Labels(mouseX, mouseY);
    }
    if (key==' ') {
      // Pause and Unpause
      flock.TogglePause();
    }
    if (key=='s') {
      flock.Add_Scarer(mouseX, mouseY, 3200, true, true, false);
    }
    if (key=='l') {
      flock.Add_Label(mouseX, mouseY, 240, 240, 240, 50, "Boids - by Kiko");
      writing = true;
    }
    
  } else {
    // If Sim is in "writin" state, edit the text from last Label object
    if (key == ENTER) {
      // Exit "writing" state
      writing = false;
    }
    // Write
    flock.labels_list.get((int)flock.labels_list.size()-1).change_text(key, keyCode);
  }
}
