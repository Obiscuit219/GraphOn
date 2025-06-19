class Graph { // setup variables
  ArrayList<DataPoint> data;
  String graphType;
  String title;
  String xAxisLabel;
  String yAxisLabel;
  color lineColor;

  Graph(ArrayList<DataPoint> data, String graphType, String title, String xAxisLabel, String yAxisLabel, color lineColor) {
    this.data = data;
    this.graphType = graphType;
    this.title = title;
    this.xAxisLabel = xAxisLabel;
    this.yAxisLabel = yAxisLabel;
    this.lineColor = lineColor;
  }

  void drawGraph(float minX, float maxX, float minY, float maxY) { // draws graph depending on graph type
    if (graphType.equals("Line")) {
      drawLine(minX, maxX, minY, maxY);
    } else if (graphType.equals("Bar")) {
      drawGroupedBar(minX, maxX, minY, maxY);
    } else if (graphType.equals("Scatter")) {
      drawScatter(minX, maxX, minY, maxY);
    }
  }

  void drawLine(float minX, float maxX, float minY, float maxY) {
    // draws a continuous line graph by connecting points
    stroke(lineColor);
    strokeWeight(2);
    noFill();
    beginShape(); // used to draw abnormal shapes
    for (DataPoint p : data) {
      float x = map(p.x, minX, maxX, leftMargin, width - rightMargin);
      float y = map(p.y, minY, maxY, height - bottomMargin, topMargin);
      vertex(x, y);
    }
    endShape();
    strokeWeight(1);
  }

  void drawGroupedBar(float minX, float maxX, float minY, float maxY) {
    // calculates spacing and bar width for grouped bar display
    int numSeries = lineData.size();
    int numBars = data.size();
    float totalWidth = width - leftMargin - rightMargin;
    
    float groupSpacing = max(10, 50 - numBars); 
    float groupWidth = (totalWidth - (numBars-1)*groupSpacing) / numBars;
    float barWidth = groupWidth * 0.8f / numSeries;
    // draw each bar at its calculated position
    for (int i = 0; i < numBars; i++) {
      DataPoint p = data.get(i);
      float groupStartX = leftMargin + i*(groupWidth + groupSpacing);
      float x = groupStartX + (groupWidth * 0.1f) + (getSeriesIndex() * barWidth);
      // y and zeroY are needed in case bars go below 0
      float y = constrain(map(p.y, minY, maxY, height - bottomMargin, topMargin), 
                topMargin, height - bottomMargin);
      float zeroY = constrain(map(0, minY, maxY, height - bottomMargin, topMargin), 
                topMargin, height - bottomMargin);
      
      fill(lineColors[getSeriesIndex()]);
      rect(x, min(y, zeroY), barWidth, abs(zeroY - y)); // draw bar
    }
  }

  void drawScatter(float minX, float maxX, float minY, float maxY) {
    // draws a small dot for each data point
    fill(lineColor);
    noStroke();
    for (DataPoint p : data) { // look at each datapoint
      float x = map(p.x, minX, maxX, leftMargin, width - rightMargin);
      float y = map(p.y, minY, maxY, height - bottomMargin, topMargin);
      ellipse(x, y, 8, 8); // draw dot at x,y coordinates
    }
  }

  int getSeriesIndex() {
    // returns this dataset's index by matching reference to global lineData
    for (int i = 0; i < lineData.size(); i++) {
      if (lineData.get(i) == data) return i;
    }
    return 0;
  }
}
