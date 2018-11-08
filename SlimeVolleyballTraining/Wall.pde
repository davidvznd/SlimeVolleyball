//Wall class, there will only be one!
class Wall {
  PVector position;
  float sizeX;
  float sizeY;
  
  Wall(){
    position = new PVector(width/2-10, height-100);
    sizeX = 20;
    sizeY = 100;
  }
  
  void display()
  {
    rect(position.x,position.y, sizeX, sizeY);
  }
}