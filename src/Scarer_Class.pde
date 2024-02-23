class Scarer{
  Flock flock;
  PVector position;
  float potency;
  float range_of_effect;
  boolean state;
  boolean visible;
  boolean follow_mouse;
  
  
  Scarer(Flock flock, float pos_x, float pos_y, float pot, boolean str_state, boolean str_visible, boolean foll){
    // Innits scarer instance
    this.flock = flock;
    this.position = new PVector(pos_x, pos_y);
    this.potency = pot;
    this.Calc_range();
    this.state = str_state;
    this.visible = str_visible;
    this.follow_mouse = foll;
  }
  
  
  void Go_To(float pos_x, float pos_y){
    // Moves Scarer to coords
    this.position = new PVector(pos_x, pos_y);
  }
  
  
  
  // Calculates the range of effect of the Scarer
  void Calc_range(){
    // Solve (y = (potency)/x^2) for x, given  y=1
    // x = sqrt(potency/y)
    this.range_of_effect = sqrt(potency/1);
  }
  
  
  void Scarer_On(){
    // Activates Scarer
    this.state = true;
    print("Scarer is now ON at x=");
    print(this.position.x);
    print(" y=");
    println(this.position.y);
  }
  void Scarer_Off(){
    // Deactivates Scarer
    this.state = false;
    print("Scarer is now OFF at x=");
    print(this.position.x);
    print(" y=");
    println(this.position.y);
  }
  
  
  
  
  void run() {
    if (follow_mouse && state) {
      // Follow the mouse around, if follow_mouse is ON AND the scarer is ON
      this.position.x = mouseX;
      this.position.y = mouseY;
    }
    if (this.visible && this.state) {
      // If the Scarer is renderable and is ON, render it  
      this.render();
    }
  }
  
  
  void render() {
    // Render a little point, to show where the Scarer is
    fill(0, 0, 0, 0);
    stroke(255, 0, 0, 255);
    circle(this.position.x, this.position.y, 10);
  }
  
}
