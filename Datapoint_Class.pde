class DataPoint {
  float x, y; // each point has a x and y coordinate
  
  DataPoint(float x, float y) {
    this.x = x; // set x value
    this.y = y; // set y value
  }
  
  void display(float xOffset, float yOffset, float xScale, float yScale) { // draw point required
    float plotX = xOffset + x * xScale;
    float plotY = yOffset - y * yScale;
    circle(plotX, plotY, 5); // draw dot
  }
}
