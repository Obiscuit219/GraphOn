import g4p_controls.*;
// setup all variables
ArrayList<ArrayList<DataPoint>> lineData;
float minX = Float.MAX_VALUE, maxX = Float.MIN_VALUE;
float minY = Float.MAX_VALUE, maxY = Float.MIN_VALUE;
color[] lineColors;
ArrayList<String> seriesNames = new ArrayList<String>();
String[] lines;
// GUI variables
String graphType = "Line";
String graphTitle = "Graph";
String xTitle = "X-Axis";
String yTitle = "Y-Axis";
String file = "Line";
int selectedColorIndex = 0;
int screenshotNum = 1;
Boolean showGrid = true;
Boolean showLegend = true;
// margins from each side of the screen
int leftMargin = 80;
int bottomMargin = 70;
int topMargin = 40;
int rightMargin = 40;

void setup() {
  size(800, 700);
  createGUI(); // setup sliders, buttons, etc.
  loadData();  // load initial data from file
  
  if (lineColors.length > 0) { // give each dataset an assigned color
    slider1.setValue(red(lineColors[0]));
    slider2.setValue(green(lineColors[0]));
    slider3.setValue(blue(lineColors[0]));
    textfield4.setText("1");
  }
}

void draw() {
  background(255);
  stroke(0);
  fill(0);
  textAlign(CENTER); // original alignment for text
  textSize(16); // original size for text
  drawAxes(minX, maxX, minY, maxY); // draw the axes
  if (lineData.size() == 0) { // check if dataset is empty or didnt load
    fill(0);
    textAlign(CENTER, CENTER);
    text("No data loaded", width / 2, height / 2);
    return;
  }

  
  for (int i = 0; i < lineData.size(); i++) { // draw each dataset with their parameters
    ArrayList<DataPoint> currentLine = lineData.get(i);
    Graph g = new Graph(currentLine, graphType, graphType + " Graph", xTitle, yTitle, lineColors[i]);
    g.drawGraph(minX, maxX, minY, maxY);
  }
  
  if (showLegend) { // toggle legend control
    drawLegend();
  }
}
