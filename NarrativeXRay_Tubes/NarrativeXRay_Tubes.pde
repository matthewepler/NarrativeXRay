/*  Narrative X-Ray
    Matthew Epler, 2011
*/

import processing.opengl.*;  // using Processing v.1.5.1 for superCAD library compatibility

import superCAD.*;              // allows for export of OBJ file. only runs in Processing 1.5
boolean record = false;
String cadSoftware, ext;

import peasy.*;
PeasyCam camera;

ArrayList tubeLines = new ArrayList();

String[] doc;  // holds all lines of text in the document to be analyzed
String[] s;    // used to hold one word at a time


int x, y, z;
int lineCounter = 0;     // for each line in the txt file
int linesPerPage = 36;   // average # of lines per page in this version of the book
int wordsPerLine = 13;   // average number of words per line in this version of the book
int pageNum = 1;         // start on page 1!
int totalPages = 308;    // total # of pages in printed book
int occurance = 0;       /* keeps track of which occurance of the search term is currently 
                          being calculated. Should match totalOccurances */
int totalOccurances = 580;                              
int totalLines = totalOccurances-1;   /* totalOccurances is the total number of times the target String appears 
                                       in the text. Calculated by simple "Find" search on the document in a program
                                       like TextEdit. Confirms how large my array of coordinates should be. There
                                       is one less tube than there are points because the first and last points are
                                       not connected. There's a more elegant solution, I'm sure. But I'm a noob.   */
                                       
int[] Xs;                // Array of x-coordinates
int[] Ys;                // Array of y-coordinates
int[] Zs;                // Array of z-coordinates

float oneThick = 1;      // determines overall thickness of tubes/lines.

// Book Dimensions converted from inches to pixels (72 px = 1.0 in)
// Exterior
int bookHeight = 629;
int bookWidth = 410;
int bookDepth = 86;
// Page Layout
int printHeight = 527;
int printWidth = 291;
int rightMargin = 68;
int leftMargin = 51;
int topMargin = 51;
int bottomMargin = 51;



void setup() {
  size(600, 700, OPENGL);
  frameRate(30);
  camera = new PeasyCam(this, 0, 0, 0, 800);
  noStroke();
  smooth();
  
  doc = loadStrings("Od.txt");

  Xs = new int[totalOccurances];
  Ys = new int[totalOccurances];
  Zs = new int[totalOccurances];

  for (int j=0; j<doc.length; j++) {               // for every line in the document...
    lineCounter++;                                 // keep track of the line we're on. 
    if (lineCounter == linesPerPage+1) {
      lineCounter = 0;                             // 1 page = 36 lines
      pageNum++;
    } 
    y = lineCounter;   
    // printed object should be as close to original book as possible    
    y = int(map(y, 0, linesPerPage, 0, printHeight-topMargin-bottomMargin));  
    z = pageNum;
    z = int(map(z, 0, totalPages, 0+oneThick, bookDepth+oneThick));

    s = splitTokens(doc[j]);            // create an array of all words in one line.
    for (int i=0; i<s.length; i++) {
      String temp_s = trim(s[i]);       // eliminate any whitespace in prep for match test
      if (temp_s.contains("Ulysses")) {  // each word tested for matches with search term.
        x = (temp_s.length())*(i+1);     // approximate position in line as it appears on the page
        x = int(map(x, 0, doc[j].length(), 0, printWidth-leftMargin-rightMargin));     
        Xs[occurance] = x;
        Ys[occurance] = y;
        Zs[occurance] = z;
        //println("Ulysses# " + occurance + " = " + Xs[occurance] + " : " +  Ys[occurance] + " : "+ Zs[occurance]);
        occurance++;                    // Useful for printing
      }
    }
  }

  // start an arraylist with a single tube
  Tube tube1 = new Tube(Xs[1], Ys[1], Zs[1], Xs[0], Ys[0], Zs[0]);  // xyz coordinates for point [0] and [1]
  tube1.setThickness(oneThick);
  tubeLines.add(tube1);
  //fill up arraylist with random lines
  for (int i = 1; i < totalLines; i++) {
    //Tube lastTube = (Tube)tubeLines.get(tubeLines.size()-1);
    Tube tube = new Tube(Xs[i-1], Ys[i-1], Zs[i-1], Xs[i], Ys[i], Zs[i]);  // * see Note 1 at end of file
    tube.setThickness(oneThick);
    tubeLines.add(tube);
  }
}

void draw() {
  background(0);
  // directionalLight(0, 120, 255, 0, 0, -1);

  if (record) {
    beginRaw("superCAD."+cadSoftware, "Odyssey."+ext);
  }

  translate(-width/2+100, -height/2+100); // lining up camera with structure
  pushMatrix();
  for (int i = 0; i < totalLines; i++) {
    fill(255, i*2, i);
    //draw tube from a  x,y,z coordinate to the previous coordinate in the arrays 
    Tube tube = (Tube)tubeLines.get(i);
    tube.render();
  }
  popMatrix();
  if (record) {
    endRaw();
    record = false;
  }
}

/* save OBJ file. Later this file is imported into Vectorworks and the "Conform" command
is performed to merge all the individual tubes into a single shape. The staff at NYU's 
Advanced Media Studio also made the shape manifold in Maya by unifying all vertices.
*/
void keyPressed() {

  switch(key) {
  case 'r': 
    cadSoftware = "Rhino"; 
    ext = "rvb"; 
    break;
  case 's': 
    cadSoftware = "SketchUP"; 
    ext = "rb";
    break;
  case 'a': 
    cadSoftware = "AutoLISP"; 
    ext = "lsp";
    break;
  case 'p': 
    cadSoftware = "PovRAY"; 
    ext = "pov";
    break;
  case 'm': 
    cadSoftware = "Maya"; 
    ext = "mel";
    break; 
  case 'o': 
    cadSoftware = "ObjFile"; 
    ext = "obj";
    break;       
  case 'c': 
    cadSoftware = "ArchiCAD"; 
    ext = "gdl";
    break;
  }
  record = true;
}


/*
NOTE 1: The staff at NYU's Advanced Media Studio believed that mapping my coordinates inside of Processing could have something 
to do with the errors we were getting in the 3D Printer's software ("ask what these were"). Their solution was
to divide all Z-coordinates by 32 so that the shape could be re-stretched in Maya to its original shape. Looking back,
I can't see why this made any difference, but at the time it seemed to help. If you can shed any light on this,
it'd be very helpful!

NOTE 2: The final object needed structural support to stay together. Before being sent to the printer, a solid frame
structure was added around the edges of the structure. This was done in Maya by the staff at AMS, to whom I owe
a lot of thanks. Now that I think about it, I should probably get them a gift. 
*/
