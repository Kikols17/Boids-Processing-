class Label {
  Flock flock;
  
  PVector position = new PVector();
  
  PVector drawable_position = new PVector();
  PVector color_rgb;
  String text;
  int size;
  
  ArrayList<Scarer> scarers_list = new ArrayList<Scarer>();
  
  Label(Flock flock, float pos_x, float pos_y, int r, int g, int b, int label_size, String content) {  
    // Inits Label instance
    this.flock = flock;
    
    this.position = new PVector(pos_x, pos_y);
    
    this.color_rgb = new PVector(r, g, b);
    this.text = content;
    this.size = label_size;
    
    this.center_label(pos_x, pos_y);
  }
  
  void center_label(float pos_x, float pos_y) {
    // centers the text, on the given coords
    textSize(this.size);
    float w = textWidth(this.text);    // outputs the width of the text
    float h = textAscent();            // outputs the height of the text, from bottom to the top of the character 'd'
    
    this.drawable_position = new PVector(pos_x - w/2, pos_y + h/2);
    this.clear_scarers();
    this.place_scarers();
  }
  
  void place_scarers() {
    textSize(this.size);
    float w = textWidth(this.text);    // outputs the width of the text
    
    int amount = (int)w/30;
    
    for (int i=0; i<amount; i++) {
      this.flock.Add_Scarer(this.drawable_position.x+30*i, this.position.y, 5000, true, false, false);
      this.scarers_list.add(this.flock.scarers_list.get((int)this.flock.scarers_list.size()-1));
    }
    this.flock.Add_Scarer(this.drawable_position.x+w, this.position.y, 5000, true, false, false);
    this.scarers_list.add(this.flock.scarers_list.get((int)this.flock.scarers_list.size()-1));
  }
  void clear_scarers() {
    for (Scarer scarer : this.scarers_list) {
      this.flock.Remove_Scarer(scarer);
    }
    this.scarers_list = new ArrayList<Scarer>();
  }
  
  
  void change_text(char new_character, int code) {
    if (new_character==DELETE || new_character==BACKSPACE) {
      if (this.text.length()>0) {
        this.text = this.text.substring(0, this.text.length()-1);
      }
    } else if (code==UP) {
      this.size += 5;
    } else if (code==DOWN) {
      this.size -= 5;
    } else if (new_character>=32 && new_character<=127) {
      this.text += new_character;
    }
    center_label(this.position.x, this.position.y);
  }
  
  
  
  void move_to(float pos_x, float pos_y) {
    // Moves the text to the given coords
    this.position = new PVector(pos_x, pos_y);
    this.center_label(pos_x, pos_y);
  }
  
  
  
  void render() {
    // Renders the text
    if (this.text.length()!=0) {
      textSize(size);
      fill(this.color_rgb.x, this.color_rgb.y, this.color_rgb.z);
      text(this.text, this.drawable_position.x, this.drawable_position.y);
    } else {
      textSize(size);
      fill(255, 0, 255, 175);
      text("TEXT", this.drawable_position.x, this.drawable_position.y);
    }
  }
}
