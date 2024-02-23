class Flock {
  ArrayList<Boid> boids_list;
  ArrayList<Scarer> scarers_list;
  ArrayList<Label> labels_list;
  boolean pause = true;
  boolean spawning = false;
  
  float vision_range = 50;
  ArrayList<ArrayList<Boid>> quadrants_list = new ArrayList<ArrayList<Boid>>();
  int quadrant_w, quadrant_h;
  int quadrant_x, quadrant_y;
  
  
  Flock() {
    // Innits Flock instance
    this.boids_list = new ArrayList<Boid>();
    this.scarers_list = new ArrayList<Scarer>();
    this.labels_list = new ArrayList<Label>();
    this.Add_Scarer(0, 0, 10000, false, false, true);
    
    // Create "quadrant_list" matrix
    this.Calculate_quadrants();
    for (int i=0; i<this.quadrant_y*quadrant_x; i++) {
      this.quadrants_list.add( new ArrayList<Boid>() );
    }
  }
  
  
  
  
  void Calculate_quadrants() {
    // Based on size of the window, and on the "vision_range" of the Boids, calculate the optimal amount of quadrants' height, width an couts
    int qw = width; int qh = height;
    
    while(qw>=(int)vision_range) {
      if (width%qw == 0) { quadrant_w = qw; }
      qw--;
    }
    while(qh>=(int)vision_range) {
      if (height%qh == 0) { quadrant_h = qh; }
      qh--;
    }
    this.quadrant_x = width/this.quadrant_w + 4;
    this.quadrant_y = height/this.quadrant_h + 4;
    
    println("quadrant x: " + this.quadrant_x + "   quadrant y: " + this.quadrant_y);
    println("quadrant width: " + this.quadrant_w + "   quadrant height: " + this.quadrant_h);
  }
  
  
  
  void Clear() {
    // Deletes all the Boids and Scarers on this Flock
    // It adds back the first Scarer, because the first one is reserved for the "Mouse Scarer" that follows the mouse around
    
    // Remove the Boids from "boids_list"
    Boid boid;
    int n = (int)boids_list.size();
    for (int i=0; i<n; i++) {
      boid = boids_list.get(0);
      Remove_Boid(boid);
    }
    
    // Remove the Scarers from "scarers_list"
    this.scarers_list.removeAll(this.scarers_list);
    this.scarers_list.add( new Scarer(this, 0, 0, 4800, false, false, true) );    // add "Mouse Scarer"
    
    // Remove the Labels from "labels_list"
    this.labels_list.removeAll(this.labels_list);
  }
  
  
  
  void Add_Boid(float posx, float posy) {
    // Adds one Boid to this Flock, with given coords, and random angle
    this.boids_list.add( new Boid(this, posx, posy) );
  }
  void Remove_Boid(Boid boid) {
    // Removes the Boid from "boids_list" (but before removes its entry on the quadrants_list)
    if (boid.quadrant.x!=-1 && boid.quadrant.y!=-1) {
      this.quadrants_list.get((int)boid.quadrant.y*quadrant_x + (int)boid.quadrant.x).remove(boid);
    }
    this.boids_list.remove(boid);
  }
  void Delete_Boids(float posx, float posy) {
    // Deletes Boids within a range
    // default range is 100 pxs
    float dist;
    Boid boid;
    for (int i=0; i<(int)this.boids_list.size(); i++) {
      boid = boids_list.get(i);
      dist = sqrt( pow(boid.position.x-posx, 2) + pow(boid.position.y-posy, 2) );
      if (dist<100.0) {
        this.Remove_Boid(boid);
        i--;
      }
    }
  }
  
  
  
  void Add_Scarer(float posx, float posy, float pot, boolean str_state, boolean str_visible, boolean str_foll) {
    // Adds one Scarer to the Flock, given coords, potency, state(ON or OFF), visibility(ON or OFF) and follow_mouse(ON or OFF)
    this.scarers_list.add( new Scarer(this, posx, posy, pot, str_state, str_visible, str_foll) );
  }
  void Remove_Scarer(Scarer scarer) {
    // Removes the Scarer from "scarer_list"
    this.scarers_list.remove(scarer);
  }
  void Delete_Scarers(float posx, float posy) {
    // Deletes Scarers within a range
    // default range is 100 pxs
    float dist;
    Scarer scarer;
    for (int i=0; i<(int)this.scarers_list.size(); i++) {
      scarer = this.scarers_list.get(i);
      dist = sqrt( pow(scarer.position.x-posx, 2) + pow(scarer.position.y-posy, 2) );
      if (dist<100.0) {
        this.Remove_Scarer(scarer);
        i--;
      }
    }
  }
  
  
  
  void Add_Label(float x_pos, float y_pos, int r, int g, int b, int size, String content) {
    // Adds one label to "labels_list" with given position, color, size and text (content)
    this.labels_list.add( new Label(this, x_pos, y_pos, r, g, b, size, content) );
  }
  void Remove_Label(Label label) {
    // Removes the Label from "labels_list" (but before the label's scarers ("label_list") from the flock)
    this.scarers_list.removeAll(label.scarers_list);
    this.labels_list.remove(label);
  }
  void Delete_Labels(float posx, float posy) {
    // Deletes Labels within a range
    // default range is 100 pxs
    float dist;
    Label label;
    for (int i=0; i<(int)this.labels_list.size(); i++) {
      label = this.labels_list.get(i);
      dist = sqrt( pow(label.position.x-posx, 2) + pow(label.position.y-posy, 2) );
      if (dist<100.0) {
        this.Remove_Label(label);
        i--;
      }
    }
  }
  
  
  
  void TogglePause() {
    // Toggle pause on the Flock Sim
    if ( pause==false ) { pause = true; println("Paused"); }
    else { pause = false; println("Unpaused"); }
  }
  
  
  
  void run(){
    background(0,0,0);    // Clear the screen
    // Run this to run the properties of the Flock
    // This function should be called every frame
    /* STEPS:
          1. Spawn boids, if in "spawning" state
          2. If NOT "paused":
              2.1. Run all Boids (calculate their next positions and states)
              2.2. Move all Boids (and check for window borders to wrap-around)
          3. Render all objects:
              3.1. Render all Boids
              3.2. Render all Scarers
              3.3. Render all Labels
    */
    
    if (spawning) {
      Add_Boid(mouseX, mouseY);
    }
    
    // float time_s = 60*60*1000*hour() + 60000*minute() + 1000*second() + millis();
    if (pause == false) {
      // The Boids are only updated and moved if the Sim is unpaused
      for (Boid boid : boids_list) {
        boid.run();
      }
      for (Boid boid : boids_list) {
        boid.Move();
        boid.Check_Borders();
      }
    }
    
    // fill(0,0,0,20);
    // rect(-1, -1, width+1, height+1);
    //background(0,0,0);    // Clear the screen
    // Render all the Boids, always, independently of state of Pause
    for (Boid boid : boids_list) {
      boid.render();
    }
    // Run all the Scarers, they are run because they can be moving around the screen (moving after the mouse for example)
    for (Scarer scarer : scarers_list) {
      scarer.run();
    }
    // Render all Text
    for (Label label : labels_list) {
      label.render();
    }
  }
  
}
