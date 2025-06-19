void loadData() { // read the loaded dataset in the way that is necessary
  // reset min/max tracking
  minX = Float.MAX_VALUE;
  maxX = Float.MIN_VALUE;
  minY = Float.MAX_VALUE;
  maxY = Float.MIN_VALUE;
  // arrays for easy control and organization
  lineData = new ArrayList<ArrayList<DataPoint>>();
  seriesNames = new ArrayList<String>();
  // try loading file if the name exists
  try {
    String[] lines = loadStrings(file + ".txt");
    for (String line : lines) { // load each line of data
      ArrayList<DataPoint> currentLine = new ArrayList<DataPoint>();
      String[] values = split(line, " ");
      if (values.length < 2) continue;
      // store series name
      String name = values[0];
      seriesNames.add(name);
      // load data in a format that fits scatterplots
      if (graphType.equals("Scatter")) {
        for (int i = 1; i < values.length - 1; i += 2) {
          try {
            float x = float(values[i]);
            float y = float(values[i+1]);
            DataPoint point = new DataPoint(x, y);
            currentLine.add(point);
            // update bounds
            if (x < minX) minX = x;
            if (x > maxX) maxX = x;
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
          } catch (NumberFormatException e) {
            println("Skipping invalid number pair at line " + line);
          }
        }
      } 
      else { // load data in a format that fits bar and line graphs
        for (int i = 1; i < values.length; i++) {
          float num = float(values[i]);
          DataPoint point = new DataPoint(i - 1, num);
          currentLine.add(point);
          // update bounds
          if (point.x < minX) minX = point.x;
          if (point.x > maxX) maxX = point.x;
          if (num < minY) minY = num;
          if (num > maxY) maxY = num;
        }
      }
      // add to full dataset if not empty
      if (currentLine.size() > 0) {
        lineData.add(currentLine);
      }
    }
    // set minimum Y value at 0 if all values are positive
    if (minY > 0) {
      minY = 0;
    }
    // generate random colors if the colors arent already assigned
    if (lineColors == null || lineColors.length != lineData.size()) {
      lineColors = new color[lineData.size()];
      for (int i = 0; i < lineColors.length; i++) {
        lineColors[i] = color(random(255), random(255), random(255));
      }
    }
    // add padding below and above y-axis for spacing
    float yPadding = (maxY - minY) * 0.1;
    maxY += yPadding;
    if (minY != 0) {
      minY -= yPadding;
    }
  } 
  catch (Exception e) {
    println("Error loading file: " + e);
    lineData = new ArrayList<ArrayList<DataPoint>>();
    seriesNames = new ArrayList<String>();
  }

  redraw(); // force refresh
}

void drawLegend() { // draw the legend
  int boxSize = 12;
  int padding = 5;
  int startX = width - 150;
  int startY = 10;
  // background box setup
  fill(255);
  stroke(0);
  rect(startX - padding, startY - padding, 130, seriesNames.size() * (boxSize + padding) + padding);
  
  for (int i = 0; i < seriesNames.size(); i++) { // loop through all datasets
    stroke(0);
    fill(lineColors[i]);
    rect(startX, startY + i * (boxSize + padding), boxSize, boxSize);
    // highlight selected dataset
    if (i == selectedColorIndex) {
      noFill();
      stroke(0);
      strokeWeight(2);
      rect(startX-1, startY + i * (boxSize + padding)-1, boxSize+2, boxSize+2);
      strokeWeight(1);
    }
    // draw series name
    fill(0);
    noStroke();
    textAlign(LEFT, CENTER);
    textSize(14);
    text(seriesNames.get(i), startX + boxSize + 10, startY + i * (boxSize + padding) + boxSize/2);
  }
}

void drawAxes(float minX, float maxX, float minY, float maxY) { // draw axes
  stroke(0);
  fill(0);
  textSize(16);
  textAlign(CENTER, CENTER);
  // draw axis lines
  line(leftMargin, height - bottomMargin, leftMargin, topMargin);
  line(leftMargin, height - bottomMargin, width - rightMargin, height - bottomMargin);

  if (showGrid) { // control grid togglability
    stroke(220);
    if (!graphType.equals("Bar")) { // skip x ticks if bar graph
      int numXTicks = calculateTicks(minX, maxX);
      float xStep = (maxX - minX)/numXTicks;
      for (int i = 0; i <= numXTicks; i++) {
        float xPos = map(minX + i*xStep, minX, maxX, leftMargin, width - rightMargin);
        line(xPos, height - bottomMargin, xPos, topMargin);
      }
    }

    int numYTicks = 10; // number of y ticks
    for (int i = 0; i <= numYTicks; i++) { // draw y ticks
      float yPos = map(i, 0, numYTicks, height - bottomMargin, topMargin);
      line(leftMargin, yPos, width - rightMargin, yPos);
    }
  }

  stroke(0);
  if (!graphType.equals("Bar")) { // skip x tick numbers if bar graph
    int numXTicks = calculateTicks(minX, maxX);
    float xStep = (maxX - minX)/numXTicks;
    for (int i = 0; i <= numXTicks; i++) {
      float xVal = minX + i*xStep;
      float xPos = map(xVal, minX, maxX, leftMargin, width - rightMargin);
      line(xPos, height - bottomMargin, xPos, height - bottomMargin + 5);
      text(nf(xVal, 0, (xStep < 1) ? 2 : 1), xPos, height - bottomMargin + 20);
    }
  }

  textAlign(RIGHT, CENTER);
  int numYTicks = 10;
  for (int i = 0; i <= numYTicks; i++) { // y-axis numbers
    float yPos = map(i, 0, numYTicks, height - bottomMargin, topMargin);
    float val = lerp(minY, maxY, i/float(numYTicks));
    line(leftMargin - 5, yPos, leftMargin, yPos);
    text(nf(val, 0, 1), leftMargin - 10, yPos);
  }
  // draw axis and graph titles
  textAlign(CENTER, CENTER);
  textSize(25);
  text(graphTitle, width / 2, topMargin / 2); // graph title
  text(xTitle, (width + leftMargin - rightMargin) / 2, height - bottomMargin + 40); // x axis title

  pushMatrix(); // rotate the text for y-axis
  translate(leftMargin - 55, (height + topMargin - bottomMargin) / 2);
  rotate(-HALF_PI);
  text(yTitle, 0, 0); // x-axis title
  popMatrix();
}

int calculateTicks(float min, float max) { // caluculate required ticks using min and max values given
  float range = max - min;
  if (range <= 10) return (int)range;
  if (range <= 50) return 10;
  return (int)(range/10);
}

void updateSelectedColor() { // update color selected for specific line
  if (selectedColorIndex >= 0 && selectedColorIndex < lineColors.length) {
    // set colors selected
    lineColors[selectedColorIndex] = color(
      slider1.getValueF(), 
      slider2.getValueF(), 
      slider3.getValueF()
    );
    redraw(); // refresh drawing
  }
}
