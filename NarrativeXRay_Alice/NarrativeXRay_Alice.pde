/*  Narrative X-Ray - Alice in Wonderland Example
    Matthew Epler, 2011

    This example uses a copy of "Alice and Wonderland" published in 1897
    by The MacMillan Company. 
    Source: http://books.google.com/books?id=XlsVAQAAIAAJ&dq=alice%20in%20wonderland&pg=PP7#v=onepage&q=alice%20in%20wonderland&f=false

    More books are in the data folder. Change the txt String to load a different one.
*/

import processing.opengl.*;

import peasy.*;
PeasyCam camera;

PFont f;  

ArrayList tubeLines = new ArrayList();
ArrayList tubeLines2 = new ArrayList();

String[] doc;  // holds all lines of text in the doc
String[] s;    // used to hold one word at a time
String[] s2;

int x, y, z;
int x2, y2, z2;

int lineCounter = 0;     // for each line in the txt file
int linesPerPage = 22;   // average # of lines per page in this version of the book
int wordsPerLine = 8;   // average number of words per line in this version of the book
int pageNum = 1;         // start on page 1! 
int pageNum2 = 1;        
int totalPages = 224;    // in this printed edition
int occurance = 0;       // keeps track of which occurance of the search term is currenlty being calculated. Should match totalOccurances 
int occurance2 = 0;      
int totalOccurances = 398;  // total number of times the target String appears in the text
int totalOccurances2 = 75;   // total number of times the target String appears in the text
int totalLines = totalOccurances-1;
int totalLines2 = totalOccurances2-1;

int[] Xs;                // Array of x-coordinates
int[] Ys;                // Array of y-coordinates
int[] Zs;                // Array of z-coordinates
int[] Xs2;                // Array of x-coordinates
int[] Ys2;                // Array of y-coordinates
int[] Zs2;                // Array of z-coordinates

float thickness = 1.5;  // thickness of lines

// Book Dimensions !!! coverted from inches to pixels (72 px = 1.0 in)
// Exterior
int bookHeight = 629; // !!!
int bookWidth = 410;
int bookDepth = 86;
// Page Layout
int printHeight = 527;
int printWidth = 291;
int rightMargin = 68;
int leftMargin = 51;
int topMargin = 51;
int bottomMargin = 51;

// user input 
String userTitle;
String userWord;
String userWord2;
color userColor;
color userColor2;
boolean tagsOn = false;  // places the search term as text at each occurance 
boolean tubesOn = false; // tubes on/off, spheres will always appear
float alpha1, alpha2;    // used to dramatize depth of shape

int zSpace;  // how stretched should it appear?




void setup() {
  size(2600, 1400, OPENGL);
  frameRate(30);
  camera = new PeasyCam(this, 100, -100, -100, 800);
  noStroke();
  sphereDetail(4);
  smooth();


  doc = loadStrings("alice.txt");
  userTitle = "Alice in Wonderland";
  userWord = "Alice";          // search term #1
  userColor = color(#1FDED2);
  userWord2 = "Queen";         // search term #2
  userColor2 = color(#CE06C1);
  tagsOn = false;
  tubesOn = true;
  zSpace = 800;

  alpha1 = 255;  // starting alpha values, to be decreased incrementally
  alpha2 = 255;


  Xs = new int[totalOccurances];
  Ys = new int[totalOccurances];
  Zs = new int[totalOccurances];

  for (int j=0; j<doc.length; j++) {               // for every line in the document...
    lineCounter++;                                 // keep track of the line we're on. 
    if (lineCounter == linesPerPage+1) {
      lineCounter = 0;                             
      pageNum++;
    } 
    y = lineCounter;
    y = int(map(y, 0, linesPerPage, 0, 600));  
    z = pageNum;
    z = int(map(z, 0, totalPages, 0, zSpace*-1));

    s = splitTokens(doc[j]);            // create array of words for each line
    for (int i=0; i<s.length; i++) {
      String temp_s = trim(s[i]);       // eliminate whitespace
      if (temp_s.contains(userWord)) {  // look for match
        x = (temp_s.length())*(i+1); 
        x = int(map(x, 0, doc[j].length(), 0, 300));     
        Xs[occurance] = x;
        Ys[occurance] = y;
        Zs[occurance] = z;
        println(userWord + "# " + occurance + " = " + Xs[occurance] + " : " +  Ys[occurance] + " : "+ Zs[occurance]);
        occurance++;
      }
    }
  }

  Xs2 = new int[totalOccurances2];
  Ys2 = new int[totalOccurances2];
  Zs2 = new int[totalOccurances2];

  for (int j=0; j<doc.length; j++) {               // for every line in the document...
    lineCounter++;                                 // keep track of the line we're on. 
    if (lineCounter == linesPerPage+1) {
      lineCounter = 0;                             // 1 page = 36 lines
      pageNum2++;
    } 
    y2 = lineCounter;
    y2 = int(map(y2, 0, linesPerPage, 0, 600));  // all mapped figures are arbitrary. Can be changed.
    z2 = pageNum2;
    z2 = int(map(z2, 0, totalPages, 0, zSpace*-1));

    s2 = splitTokens(doc[j]);
    for (int i=0; i<s2.length; i++) {
      String temp_s2 = trim(s2[i]);
      if (temp_s2.contains(userWord2)) {
        x2 = (temp_s2.length())*(i+1); 
        x2 = int(map(x2, 0, doc[j].length(), 0, 300));     // arbitray limits to make sure Processing displays all values in canvas
        Xs2[occurance2] = x2;
        Ys2[occurance2] = y2;
        Zs2[occurance2] = z2;
        println(userWord2 + "# " + occurance2 + " = " + Xs2[occurance2] + " : " +  Ys2[occurance2] + " : "+ Zs2[occurance2]);
        occurance2++;
      }
    }
  }

  if (tubesOn == true) {
    Tube tube1 = new Tube(Xs[1], Ys[1], Zs[1], Xs[0], Ys[0], Zs[0]);  // xyz coordinates for point [0] and [1]
    tube1.setThickness(thickness);
    tubeLines.add(tube1);
    for (int i = 1; i < totalOccurances; i++) {
      //Tube lastTube = (Tube)tubeLines.get(tubeLines.size()-1);
      Tube tube = new Tube(Xs[i], Ys[i], Zs[i], Xs[i-1], Ys[i-1], Zs[i-1]);
      tube.setThickness(1);
      tubeLines.add(tube);
    }
    println(tubeLines.size());

    Tube tube2 = new Tube(Xs2[1], Ys2[1], Zs2[1], Xs2[0], Ys2[0], Zs2[0]);  // xyz coordinates for point [0] and [1]
    tube2.setThickness(thickness);
    tubeLines2.add(tube2);
    for (int i = 1; i < totalOccurances2; i++) {
      //Tube lastTube = (Tube)tubeLines.get(tubeLines.size()-1);
      Tube tube = new Tube(Xs2[i], Ys2[i], Zs2[i], Xs2[i-1], Ys2[i-1], Zs2[i-1]);
      tube.setThickness(1);
      tubeLines2.add(tube);
    }
    println(tubeLines2.size());
  }

  f = createFont("tall.ttf", 98);
  textFont(f);
}


void draw() {
  background(0);

  fill(155);
  textFont(f, 98);
  text(userTitle, 175, 100);

  fill(userColor);
  rect(175, 115, 20, 20);
  fill(userColor2);
  rect(175, 160, 20, 20);

  fill(255);
  textFont(f, 48);
  text("'" + userWord + "'", 200, 140);
  text("'" + userWord2 + "'", 200, 185);
  pushMatrix();
  translate(-300, -400);

  for (int i = 0; i < tubeLines.size()-1; i++) {
    fill(red(userColor), green(userColor), blue(userColor), alpha1);
    if (tubesOn == true) {
      Tube tube = (Tube)tubeLines.get(i);
      tube.render();
    }
    setSphere(Xs[i], Ys[i], Zs[i]);

    if (tagsOn == true) {
      fill(userColor);
      text(userWord, Xs[i], Ys[i], Zs[i]);
    }
    alpha1 -= .45;
  }
  for (int i = 0; i < tubeLines2.size()-1; i++) {
    fill(red(userColor2), green(userColor2), blue(userColor2), alpha2);
    if (tubesOn == true) {
      Tube tube2 = (Tube)tubeLines2.get(i);
      tube2.render();
    }
    setSphere(Xs2[i], Ys2[i], Zs2[i]);

    if (tagsOn == true) {
      fill(userColor2);
      text(userWord2, Xs2[i], Ys2[i], Zs2[i]);
    }
    alpha2 -= .45;
  }
  popMatrix();
  alpha1 = 255;
  alpha2 = 255;
}

void setSphere(float x, float y, float z) {
  pushMatrix();
  translate(x, y, z);
  sphere(thickness*2.5);
  popMatrix();
}

