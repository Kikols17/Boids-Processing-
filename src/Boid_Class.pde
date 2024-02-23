class Boid
{
  /*                                Boid Class
  *    A Boid is an entity, defined primarily by a position PVector and a facing PVector
  *
  *    
  *
  *
  *
  */
  Flock flock;
  
  PVector position;
  PVector facing;
  PVector new_facing;
  PVector quadrant = new PVector(-1, -1);
  
  
  // positions of the points of the shape of the Boid
  PVector point1 = new PVector(9,0);
  PVector point2 = new PVector(-9,-6);
  PVector point3 = new PVector(-9,6);
  
  
  float cohes_fac = 1;
  float separ_fac = 1;
  float align_fac = 1;
  
  float fleee_fac = 1;
  float randm_fac = 1;
  
  
  float min_speed = 1;
  float max_speed = 4;
  
  ArrayList<Boid> neighbours;              // Indexes of the Boids that are inside of the vision range of this Boid
  ArrayList<Scarer> predators;             // Indexes of the Scarers that are inside of the vision range of this Boid
  
  
  Boid(Flock flock, float posx, float posy) {
    // Innits Boid instance
    this.flock = flock;
    this.position = new PVector(posx, posy);
    
    float angle = random(TWO_PI);
    this.facing = new PVector(cos(angle), sin(angle));
    this.new_facing = facing;
  }
  
  
  
  void run(){
    // Run this to update the Boid
    this.Self_identify_quadrant();
    
    this.Find_neighbours();
    this.Find_nearby_scarers();
    
    this.Calc_facing(this.Cohesion(), this.Separation(), this.Alignment(), this.Flee(), this.Wander());
  }
  
  
  
  
  // Finds the Boids within the vision range of this Boid
  // returns a list of indexes of the neighbours' Boids
  void Find_neighbours() {
    this.neighbours = new ArrayList<Boid>();
    
    // The nearby_boids are the boids that are inside and directly around the quadrant of this boid
    ArrayList<Boid> nearby_boids = new ArrayList<Boid>();
    
    
    nearby_boids.addAll(this.flock.quadrants_list.get(((int)this.quadrant.y+1)*this.flock.quadrant_x+(int)this.quadrant.x+1));
    nearby_boids.addAll(this.flock.quadrants_list.get(((int)this.quadrant.y+1)*this.flock.quadrant_x+(int)this.quadrant.x));
    nearby_boids.addAll(this.flock.quadrants_list.get(((int)this.quadrant.y+1)*this.flock.quadrant_x+(int)this.quadrant.x-1));
    nearby_boids.addAll(this.flock.quadrants_list.get((int)this.quadrant.y*this.flock.quadrant_x+(int)this.quadrant.x+1));
    nearby_boids.addAll(this.flock.quadrants_list.get((int)this.quadrant.y*this.flock.quadrant_x+(int)this.quadrant.x));
    nearby_boids.addAll(this.flock.quadrants_list.get((int)this.quadrant.y*this.flock.quadrant_x+(int)this.quadrant.x-1));
    nearby_boids.addAll(this.flock.quadrants_list.get(((int)this.quadrant.y-1)*this.flock.quadrant_x+(int)this.quadrant.x+1));
    nearby_boids.addAll(this.flock.quadrants_list.get(((int)this.quadrant.y-1)*this.flock.quadrant_x+(int)this.quadrant.x));
    nearby_boids.addAll(this.flock.quadrants_list.get(((int)this.quadrant.y-1)*this.flock.quadrant_x+(int)this.quadrant.x-1));
    
    
    float x1 = this.position.x;
    float y1 = this.position.y;
    
    // Loop thru all the nearby_boids, and find those who are inside the vision range (stores them in ArrayList<Integer> "neighbours")
    float x2, y2;
    float distance;
    for (Boid boid : nearby_boids){
      x2 = boid.position.x;
      y2 = boid.position.y;
      distance = sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
      if ((distance<this.flock.vision_range) && (distance!=0.0)) {
        this.neighbours.add(boid);
      }
    }
  }
  
  // Finds the Scarers within the vision range of this Boid
  // returns a list of indexes of the neighbours' Boids
  void Find_nearby_scarers(){
    this.predators = new ArrayList<Scarer>();
    
    float x1 = this.position.x;
    float y1 = this.position.y;
    // Loop thru all the scarers, and find those who are inside the vision range
    for (Scarer scarer : this.flock.scarers_list) {
      float x2 = scarer.position.x;
      float y2 = scarer.position.y;
      float distance = sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
      if (( distance < scarer.range_of_effect ) && ( scarer.state==true )) {
        this.predators.add(scarer);
      }
    }
  }
  
  
  
  
  PVector Cohesion() {
    // Calculates the Cohesion Vector
    int n_neighbours = this.neighbours.size();
    PVector coh_vec = new PVector(0,0);
    PVector center = new PVector(this.position.x/(n_neighbours+1), this.position.y/(n_neighbours+1));
    
    for (Boid boid : this.neighbours) {
      center.x += ( boid.position.x/(n_neighbours+1) );
      center.y += ( boid.position.y/(n_neighbours+1) );
    }
    coh_vec.x = (center.x-this.position.x) * this.cohes_fac;
    coh_vec.y = (center.y-this.position.y) * this.cohes_fac;
    
    println("Cohesion " + coh_vec.x + ", " + coh_vec.y);
    
    stroke(250,0,0);
    line(this.position.x, this.position.y, this.position.x+coh_vec.x, this.position.y+coh_vec.y);
    return coh_vec;
  }
  
  
  PVector Separation() {
    // Calculates the Separation Vector
    PVector sep_vec = new PVector(0,0);
    PVector vec = new PVector(0,0);
    float sep_value;
    float dist;
    
    for (Boid boid : this.neighbours) {
      vec.x = this.position.x-boid.position.x; vec.y = this.position.y-boid.position.y;
      dist = vec.mag();
      
      if (dist<0.01) {
        this.position.x += 0.01;
        this.position.y += 0.01;
        vec.x = boid.position.x-this.position.x; vec.y = boid.position.y-this.position.y;
        dist = vec.mag();
      } 
      //vec.x = vec.x/dist; vec.y = vec.y/dist;
      
      sep_value = ( pow(this.flock.vision_range,6) / pow(dist,6) - 1 );
      
      sep_vec.x += (vec.x*sep_value) * this.separ_fac;
      sep_vec.y += (vec.y*sep_value) * this.separ_fac;
    }
    
    println("Separation " + sep_vec.x + ", " + sep_vec.y);
    stroke(0,255,0);
    line(this.position.x, this.position.y, this.position.x+sep_vec.x, this.position.y+sep_vec.y);
    return sep_vec;
  }
  
  
  PVector Alignment() {
    // Calculates the Alignment Vector
    PVector ali_vec = new PVector(0,0);
    int n_neighbours = neighbours.size();
    
    for (Boid boid : neighbours) {
      PVector vec = boid.facing;
      ali_vec.x = ( ali_vec.x + ( vec.x/n_neighbours ) ) * align_fac;
      ali_vec.y = ( ali_vec.y + ( vec.y/n_neighbours ) ) * align_fac;
    }
    return ali_vec;
  }
  
  PVector Flee() {
    // Calculates the Fleeing Vector
    PVector flee_vec = new PVector(0,0);
    
    if (predators==null) {
      return flee_vec;
    }
    for (Scarer scarer : predators) {
      PVector vec = new PVector(position.x-scarer.position.x, position.y-scarer.position.y);
      if (vec.x+vec.y == 0){
        vec.x = vec.x+0.001;
      }
      if (Math.sqrt( Math.pow(scarer.position.x-position.x, 2) + Math.pow(scarer.position.y-position.y, 2) )<0.1) {
        position.x = position.x + 0.01;
        position.y = position.y + 0.01;
      }
      float k =  (float)Math.sqrt( (( scarer.potency / 
                        Math.sqrt( Math.pow(scarer.position.x-position.x, 2) + Math.pow(scarer.position.y-position.y, 2) )
                                  )) / ((Math.pow(vec.x, 2)+Math.pow(vec.y, 2))*2) );
      flee_vec.x = flee_vec.x + vec.x*k * fleee_fac;
      flee_vec.y = flee_vec.y + vec.y*k * fleee_fac;
    }
    return flee_vec;
  }
  
  PVector Wander() {
    // Calculates the Wander Vector
    float angle = random(TWO_PI);
    PVector wand_vec = new PVector( cos(angle)*0.3*randm_fac, sin(angle)*0.3*randm_fac );
    
    return wand_vec;
  }
  
  
  
  
  // Adds all the vectors, to create the next facing vector
  void Calc_facing(PVector coh_vec, PVector sep_vec, PVector ali_vec, PVector flee_vec, PVector wand_vec) {
    PVector force = new PVector(coh_vec.x+sep_vec.x+ali_vec.x+flee_vec.x+wand_vec.x, coh_vec.y+sep_vec.y+ali_vec.y+flee_vec.y+wand_vec.y);
    new_facing = new PVector( facing.x+force.x, facing.y+force.y);
  }
  
  // Move the Boid Forward
  void Move() {
    facing = new PVector(new_facing.x, new_facing.y);
    
    if (Math.sqrt( ((facing.x*facing.x)+(facing.y*facing.y)) ) < min_speed ) {
      float k = (float)Math.sqrt( Math.pow(min_speed, 2)/(( (facing.x*facing.x)+(facing.y*facing.y) )*2) );
      facing.x = facing.x*k;
      facing.y = facing.y*k;
    }
    if (Math.sqrt( ((this.facing.x*this.facing.x)+(this.facing.y*this.facing.y)) ) > this.max_speed ) {
      float k = (float)Math.sqrt( Math.pow(this.max_speed, 2)/(( (this.facing.x*this.facing.x)+(this.facing.y*this.facing.y) )*2) );
      this.facing.x = this.facing.x*k;
      this.facing.y = this.facing.y*k;
    }
    
    this.position = new PVector( this.position.x + this.facing.x, this.position.y + this.facing.y );
    // println("id :" + ID);
    // print(this.position.x + ", " +this.position.y);
  }
  
  // Check if the Boid is not off-bounds
  void Check_Borders() {
    if (this.position.x < 0) { this.position.x += width; }
    else if (this.position.x > width) { this.position.x -= width; }
    if (this.position.y < 0) { this.position.y += height; }
    else if (this.position.y > height) { this.position.y -= height; }
  }
  
  
  
  
  // The Boid updates his quadrant internally, and changes his own place in the leasure of quadrants the ArrayList<Integer> "quadrants_list"
  void Self_identify_quadrant() {
    if (!(this.quadrant.x==-1 || this.quadrant.y==-1)) {
      this.flock.quadrants_list.get((int)this.quadrant.y*this.flock.quadrant_x + (int)this.quadrant.x).remove(this);
    }
    
    quadrant.x = (int)this.position.x/this.flock.quadrant_w+2;
    quadrant.y = (int)this.position.y/this.flock.quadrant_h+2;
    
    this.flock.quadrants_list.get((int)this.quadrant.y*this.flock.quadrant_x + (int)this.quadrant.x).add(this);
  }
  
  

  
  
  // Draw the Boid on the Screen
  void render() {
    
    if (facing.x == 0){
      facing.x = facing.x + 1;
    }
    float angle = atan(facing.y/facing.x);
    if (facing.x < 0) {
      if (facing.y > 0) { angle = angle+PI; }
      else { angle = angle-PI; }
    }
    
    class Local {
      PVector rotate_points(PVector point, float angle) {
        // Real simple rotation matrix around (0,0)
        PVector new_point = new PVector(0,0);
        new_point.x = point.x*cos(angle) - point.y*sin(angle);
        new_point.y = point.x*sin(angle) + point.y*cos(angle);
        return new_point;
      }
      PVector position_points(PVector point, PVector center) {
        // Slides the point to its real position
        PVector new_point = new PVector(0,0);
        new_point.x = point.x + center.x;
        new_point.y = point.y + center.y;
        return new_point;
      }
    }
    
    Local local;
    local = new Local();
    
    PVector draw_point1 = local.position_points(local.rotate_points(point1, angle), position);
    PVector draw_point2 = local.position_points(local.rotate_points(point2, angle), position);
    PVector draw_point3 = local.position_points(local.rotate_points(point3, angle), position);
    
    noStroke();
    fill(0, int(abs( (255*angle)/PI) ), 255, 255);    // (Blue-Cyan)
    // fill(255, int(abs( (255*angle)/PI) ), 0, 255);    // (Yellow-Red)
    // fill(int(abs( (255*angle)/PI) ), 0, 255, 255);    // (Blue-Magenta)  My favourite pallete
    // fill(int(abs( (255*angle)/PI) ), 255, 0, 255);    // (Green-Yellow)
    // fill(0, 255, int(abs( (255*angle)/PI) ), 255);    // (Green-Cyan)
    // fill(255, 0, int(abs( (255*angle)/PI) ), 255);    // (Pink-Red)
    triangle(draw_point1.x, draw_point1.y, draw_point2.x, draw_point2.y, draw_point3.x, draw_point3.y);
  }
}
