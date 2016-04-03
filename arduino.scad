// Raspberry Pi connectors library
//
// Copyright (c) 2013 Kelly Egan
// Copyright (c) 2016 Alejandro Medrano
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
// and associated documentation files (the "Software"), to deal in the Software without restriction, 
// including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do 
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial
// portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
// NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


//Constructs a roughed out RasberryPi board
//Current only USB, power and headers
module raspberry(boardType = BPLUS) {
  //The PCB with holes
  difference() {
    color("DarkGreen") 
      boardShape( boardType );
    translate([0,0,-pcbHeight * 0.5]) holePlacement(boardType = boardType)
      color("SteelBlue") cylinder(r = mountingHoleRadius, h = pcbHeight * 2, $fn=32);
  }
  //Add all components to board
  components( boardType = boardType, component = ALL );
}

//Creates a bumper style enclosure that fits tightly around the edge of the PCB.
module bumper( boardType = BPLUS, mountingHoles = false ) {
  bumperBaseHeight = 2;
  bumperHeight = bumperBaseHeight + pcbHeight + 0.5;
  dimensions = boardDimensions(boardType);

  difference() {
    union() {
      //Outer rim of bumper
      difference() {
        boardShape(boardType = boardType, offset=1.4, height = bumperHeight);
        translate([0,0,-0.1])
          boardShape(boardType = boardType, height = bumperHeight + 0.2);
      }

      //Base of bumper  
      difference() {
        boardShape(boardType = boardType, offset=1, height = bumperBaseHeight);
        translate([0,0, -0.1])
          boardShape(boardType = boardType, offset=-2, height = bumperHeight + 0.2);
      }

      //Board mounting holes
      holePlacement(boardType=boardType)
        cylinder(r = mountingHoleRadius + 1.5, h = bumperBaseHeight, $fn = 32);

      //Bumper mounting holes (exterior)
      if( mountingHoles ) {
        difference() {  
          hull() {
            translate([-6, (dimensions[1] - 6) / 2, 0])
              cylinder( r = 6, h = pcbHeight + 2, $fn = 32 );
            translate([ -0.5, dimensions[0] / 2 - 9, 0]) 
              cube([0.5, 12, bumperHeight]);
          }
          translate([-6, (dimensions[0] - 6) / 2, 0])
            mountingHole(holeDepth = bumperHeight);
        }
        difference() {  
          hull() {
            translate([dimensions[0] + 6, (dimensions[1] - 6) / 2,0])
              cylinder( r = 6, h = pcbHeight + 2, $fn = 32 );
            translate([ dimensions[0], dimensions[1] / 2 - 9, 0]) 
              cube([0.5, 12, bumperHeight]);
          }
          translate([dimensions[0] + 6, (dimensions[1] - 6) / 2,0])
            mountingHole(holeDepth = bumperHeight);
        }
      }
    }
    translate([0,0,-0.5])
    holePlacement(boardType=boardType)
      cylinder(r = mountingHoleRadius, h = bumperHeight, $fn = 32);  
    translate([0, 0, bumperBaseHeight]) {
      components(boardType = boardType, component = ALL, offset = 1);
    }
    translate([4,(dimensions[1] - dimensions[1] * 0.4)/2,-1])
      cube([dimensions[0] -8,dimensions[1] * 0.4,bumperBaseHeight + 2]);
  }
}

//Setting for enclosure mounting holes (Not Arduino mounting)
NOMOUNTINGHOLES = 0;
INTERIORMOUNTINGHOLES = 1;
EXTERIORMOUNTINGHOLES = 2;

//Create a board enclosure
module enclosure(boardType = BPLUS, wall = 3, offset = 3, heightExtension = 10, cornerRadius = 3, mountType = TAPHOLE) {
  standOffHeight = 5;

  dimensions = boardDimensions(boardType);
  boardDim = boardDimensions(boardType);
  pcbDim = pcbDimensions(boardType);

  enclosureWidth = pcbDim[0] + (wall + offset) * 2;
  enclosureDepth = pcbDim[1] + (wall + offset) * 2;
  enclosureHeight = boardDim[2] + wall + standOffHeight + heightExtension;

  union() {
    difference() {
      //Main box shape
      boundingBox(boardType = boardType, height = enclosureHeight, offset = wall + offset, include=PCB, cornerRadius = wall);
  
      translate([ 0, 0, wall]) {
        //Interior of box
        boundingBox(boardType = boardType, height = enclosureHeight, offset = offset, include=PCB, cornerRadius = wall);
  
        //Punch outs for USB and POWER
        translate([0, 0, standOffHeight]) {
          components(boardType = boardType, offset = 1, extension = wall + offset + 10);
        }
      }
      
      //Holes for lid clips
      translate([0, enclosureDepth * 0.75 - (offset + wall), enclosureHeight]) {
        translate([-offset, 0, 0])
          rotate([0, 180, 90]) clipHole(clipHeight = 10, holeDepth = wall + 0.2);
        translate([offset + boardDim[0], 0, 0])
          rotate([0, 180, 270]) clipHole(clipHeight = 10, holeDepth = wall + 0.2);
      }
    
      translate([0, enclosureDepth * 0.25 - (offset + wall), enclosureHeight]) {
        translate([-offset, 0, 0])
          rotate([0, 180, 90]) clipHole(clipHeight = 10, holeDepth = wall + 0.2);
        translate([offset + dimensions[0], 0, 0])
          rotate([0, 180, 270]) clipHole(clipHeight = 10, holeDepth = wall + 0.2);
      }   
    }
    translate([0, 0, wall]) {
      standoffs(boardType = boardType, height = standOffHeight, mountType = mountType);
    }
  }
}

//Create a snap on lid for enclosure
module enclosureLid( boardType = BPLUS, wall = 3, offset = 3, cornerRadius = 3, ventHoles = false) {
  dimensions = boardDimensions(boardType);
  boardDim = boardDimensions(boardType);
  pcbDim = pcbDimensions(boardType);

  enclosureWidth = pcbDim[0] + (wall + offset) * 2;
  enclosureDepth = pcbDim[1] + (wall + offset) * 2;

  difference() {
    union() {
      boundingBox(boardType = boardType, height = wall, offset = wall + offset, include=PCB, cornerRadius = wall);

      translate([0, 0, -wall * 0.5])
        boundingBox(boardType = boardType, height = wall * 0.5, offset = offset - 0.5, include=PCB, cornerRadius = wall);
    
      //Lid clips
      translate([0, enclosureDepth * 0.75 - (offset + wall), 0]) {
        translate([-offset, 0, 0])
          rotate([0, 180, 90]) clip(clipHeight = 10);
        translate([offset + boardDim[0], 0, 0])
          rotate([0, 180, 270]) clip(clipHeight = 10);
      }
    
      translate([0, enclosureDepth * 0.25 - (offset + wall), 0]) {
        translate([-offset, 0, 0])
          rotate([0, 180, 90]) clip(clipHeight = 10);
        translate([offset + dimensions[0], 0, 0])
          rotate([0, 180, 270]) clip(clipHeight = 10);
      }

    }
  }
}

//Offset from board. Negative values are insets
module boardShape( boardType = BPLUS, offset = 0, height = pcbHeight ) {
  dimensions = boardDimensions(boardType);

  xScale = (dimensions[0] + offset * 2) / dimensions[0];
  yScale = (dimensions[1] + offset * 2) / dimensions[1];

  translate([-offset, -offset, 0])
    scale([xScale, yScale, 1.0])
      linear_extrude(height = height) 
        polygon(points = boardShapes[boardType]);
}

//Create a bounding box around the board
//Offset - will increase the size of the box on each side,
//Height - overides the boardHeight and offset in the z direction

BOARD = 0;        //Includes all components and PCB
PCB = 1;          //Just the PCB
COMPONENTS = 2;   //Just the components

module boundingBox(boardType = BPLUS, offset = 0, height = 0, cornerRadius = 0, include = BOARD) {
  //What parts are included? Entire board, pcb or just components.
  pos = ([boardPosition(boardType), pcbPosition(boardType), componentsPosition(boardType)])[include];
  dim = ([boardDimensions(boardType), pcbDimensions(boardType), componentsDimensions(boardType)])[include];

  //Depending on if height is set position and dimensions will change
  position = [
        pos[0] - offset, 
        pos[1] - offset, 
        (height == 0 ? pos[2] - offset : pos[2] )
        ];

  dimensions = [
        dim[0] + offset * 2, 
        dim[1] + offset * 2, 
        (height == 0 ? dim[2] + offset * 2 : height)
        ];

  translate( position ) {
    if( cornerRadius == 0 ) {
      cube( dimensions );
    } else {
      roundedCube( dimensions, cornerRadius=cornerRadius );
    }
  }
}

//Creates standoffs for different boards
TAPHOLE = 0;
PIN = 1;

module standoffs( 
  boardType = BPLUS, 
  height = 10, 
  topRadius = mountingHoleRadius + 1, 
  bottomRadius =  mountingHoleRadius + 2, 
  holeRadius = mountingHoleRadius,
  mountType = TAPHOLE
  ) {

  holePlacement(boardType = boardType)
    union() {
      difference() {
        cylinder(r1 = bottomRadius, r2 = topRadius, h = height, $fn=32);
        if( mountType == TAPHOLE ) {
          cylinder(r =  holeRadius, h = height * 4, center = true, $fn=32);
        }
      }
      if( mountType == PIN ) {
        translate([0, 0, height - 1])
        pintack( h=pcbHeight + 3, r = holeRadius, lh=3, lt=1, bh=1, br=topRadius );
      }
    }  
}

//This is used for placing the mounting holes and for making standoffs
//child elements will be centered on that chosen boards mounting hole centers
module holePlacement(boardType = BPLUS ) {
  for(i = boardHoles[boardType] ) {
    translate(i)
      children(0);
  }
}

//Places components on board
//  compenent - the data set with a particular component (like boardHeaders)
//  extend - the amount to extend the component in the direction of its socket
//  offset - the amount to increase the components other two boundaries

//Component IDs
ALL = -1;
HEADER_F = 0;
HEADER_M = 1;
USB = 2;
POWER = 3;
RJ45 = 4;

module components( boardType = BPLUS, component = ALL, extension = 0, offset = 0 ) {
  translate([0, 0, pcbHeight]) {
    for( i = [0:len(components[boardType]) - 1] ){
      if( components[boardType][i][3] == component || component == ALL) {
          //Calculates position + adjustment for offset and extention  
          position = components[boardType][i][0] 
            - (([1,1,1] - components[boardType][i][2]) * offset)
            + [  min(components[boardType][i][2][0],0), min(components[boardType][i][2][1],0), min(components[boardType][i][2][2],0) ] 
            * extension;
          //Calculates the full box size including offset and extention
          dimensions = components[boardType][i][1] 
            + ((components[boardType][i][2] * [1,1,1]) 
              * components[boardType][i][2]) * extension
            + ([1,1,1] - components[boardType][i][2]) * offset * 2;        
          translate( position ) color( components[boardType][i][4] ) 
            cube( dimensions );
      }
    }  
  }
}

module roundedCube( dimensions = [10,10,10], cornerRadius = 1, faces=32 ) {
  hull() cornerCylinders( dimensions = dimensions, cornerRadius = cornerRadius, faces=faces ); 
}

module cornerCylinders( dimensions = [10,10,10], cornerRadius = 1, faces=32 ) {
  translate([ cornerRadius, cornerRadius, 0]) {
    cylinder( r = cornerRadius, $fn = faces, h = dimensions[2] );
    translate([dimensions[0] - cornerRadius * 2, 0, 0]) cylinder( r = cornerRadius, $fn = faces, h = dimensions[2] );
    translate([0, dimensions[1] - cornerRadius * 2, 0]) {
      cylinder( r = cornerRadius, $fn = faces, h = dimensions[2] );
      translate([dimensions[0] - cornerRadius * 2, 0, 0]) cylinder( r = cornerRadius, $fn = faces, h = dimensions[2] );
    }
  }
}

//Create a clip that snapps into a clipHole
module clip(clipWidth = 5, clipDepth = 5, clipHeight = 5, lipDepth = 1.5, lipHeight = 3) {
  translate([-clipWidth/2,-(clipDepth-lipDepth),0]) rotate([90, 0, 90])
  linear_extrude(height = clipWidth, convexity = 10)
    polygon(  points=[  [0, 0], 
            [clipDepth - lipDepth, 0],
            [clipDepth - lipDepth, clipHeight - lipHeight],
            [clipDepth - 0.25, clipHeight - lipHeight],
            [clipDepth, clipHeight - lipHeight + 0.25],
            [clipDepth - lipDepth * 0.8, clipHeight],
            [(clipDepth - lipDepth) * 0.3, clipHeight] 
            ], 
        paths=[[0,1,2,3,4,5,6,7]]
      );
}

//Hole for clip
module clipHole(clipWidth = 5, clipDepth = 5, clipHeight = 5, lipDepth = 1.5, lipHeight = 3, holeDepth = 5) {
  offset = 0.1;
  translate([-clipWidth/2,-(clipDepth-lipDepth),0])
  translate([-offset, clipDepth - lipDepth-offset, clipHeight - lipHeight - offset])
    cube( [clipWidth + offset * 2, holeDepth, lipHeight + offset * 2] );
}

module mountingHole(screwHeadRad = woodscrewHeadRad, screwThreadRad = woodscrewThreadRad, screwHeadHeight = woodscrewHeadHeight, holeDepth = 10) {
  union() {
    translate([0, 0, -0.01])
      cylinder( r = screwThreadRad, h = 1.02, $fn = 32 );
    translate([0, 0, 1])
      cylinder( r1 = screwThreadRad, r2 = screwHeadRad, h = screwHeadHeight, $fn = 32 );
    translate([0, 0, screwHeadHeight - 0.01 + 1])
      cylinder( r = screwHeadRad, h = holeDepth - screwHeadHeight + 0.02, $fn = 32 );
  }
}

/******************************** UTILITY FUNCTIONS *******************************/

//Return the length side of a square given its diagonal
function sides( diagonal ) = sqrt(diagonal * diagonal  / 2);

//Return the minimum values between two vectors of either length 2 or 3. 2D Vectors are treated as 3D vectors who final value is 0.
function minVec( vector1, vector2 ) =
  [min(vector1[0], vector2[0]), min(vector1[1], vector2[1]), min((vector1[2] == undef ? 0 : vector1[2]), (vector2[2] == undef ? 0 : vector2[2]) )];

//Return the maximum values between two vectors of either length 2 or 3. 2D Vectors are treated as 3D vectors who final value is 0.
function maxVec( vector1, vector2 ) =
  [max(vector1[0], vector2[0]), max(vector1[1], vector2[1]), max((vector1[2] == undef ? 0 : vector1[2]), (vector2[2] == undef ? 0 : vector2[2]) )];

//Determine the minimum point on a component in a list of components
function minCompPoint( list, index = 0, minimum = [10000000, 10000000, 10000000] ) = 
  index >= len(list) ? minimum : minCompPoint( list, index + 1, minVec( minimum, list[index][0] ));

//Determine the maximum point on a component in a list of components
function maxCompPoint( list, index = 0, maximum = [-10000000, -10000000, -10000000] ) = 
  index >= len(list) ? maximum : maxCompPoint( list, index + 1, maxVec( maximum, list[index][0] + list[index][1]));

//Determine the minimum point in a list of points
function minPoint( list, index = 0, minimum = [10000000, 10000000, 10000000] ) = 
  index >= len(list) ? minimum : minPoint( list, index + 1, minVec( minimum, list[index] ));

//Determine the maximum point in a list of points
function maxPoint( list, index = 0, maximum = [-10000000, -10000000, -10000000] ) = 
  index >= len(list) ? maximum : maxPoint( list, index + 1, maxVec( maximum, list[index] ));

//Returns the pcb position and dimensions
function pcbPosition(boardType = BPLUS) = minPoint(boardShapes[boardType]);
function pcbDimensions(boardType = BPLUS) = maxPoint(boardShapes[boardType]) - minPoint(boardShapes[boardType]) + [0, 0, pcbHeight];

//Returns the position of the box containing all components and its dimensions
function componentsPosition(boardType = BPLUS) = minCompPoint(components[boardType]) + [0, 0, pcbHeight];
function componentsDimensions(boardType = BPLUS) = maxCompPoint(components[boardType]) - minCompPoint(components[boardType]);

//Returns the position and dimensions of the box containing the pcb board
function boardPosition(boardType = BPLUS) = 
  minCompPoint([[pcbPosition(boardType), pcbDimensions(boardType)], [componentsPosition(boardType), componentsDimensions(boardType)]]);
function boardDimensions(boardType = BPLUS) = 
  maxCompPoint([[pcbPosition(boardType), pcbDimensions(boardType)], [componentsPosition(boardType), componentsDimensions(boardType)]]) 
  - minCompPoint([[pcbPosition(boardType), pcbDimensions(boardType)], [componentsPosition(boardType), componentsDimensions(boardType)]]);

/******************************* BOARD SPECIFIC DATA ******************************/
//Board IDs
A = 0;
APLUS = 1;
B = 2;
BPLUS = 3;
ZERO = 4;

/********************************** MEASUREMENTS **********************************/
pcbHeight = 1.7;
headerWidth = 2.54;
headerHeight = 9;
mountingHoleRadius = 3.2 / 2;

/********************************* MOUNTING HOLES *********************************/

//BPLUS holes
BPLUSHoles = [
  [  3.5, 3.5 ],
  [  58 +3.5, 3.5 ],
  [  3.5, 49+3.5 ],
  [  58+3.5 , 49+3.5 ]
  ];

//Zero holes
ZEROHoles = [
  [  3.5, 3.5 ],
  [  58 , 3.5 ],
  [  3.5, 26.5 ],
  [  58 , 26.5 ]
  ];



boardHoles = [ 
  0,        //A
  0,        //APLUS
  0,        //B
  BPLUSHoles,     //BPLUS
  ZEROHoles,     //ZERO
  ];

/********************************** BOARD SHAPES **********************************/

BPLUSBoardShape= [
    [0,0],
    [85,0],
    [85,56],
    [0,56]
  ];
ZEROBoardShape= [
    [0,0],
    [65,0],
    [65,30],
    [0,30]
  ];

boardShapes = [ 
  0,        //A
  0,        //APLUS
  0,        //B
  BPLUSBoardShape,     //BPLUS
  ZEROBoardShape,     //ZERO
  ]; 

/*********************************** COMPONENTS ***********************************/

//Component data. 
//[position, dimensions, direction(which way would a cable attach), type(header, usb, etc.), color]
DoubleUSBComp = [17,13.20,16];

BPLUSComponents= [
[[7,-1,0],[8,5.7,3],[0,-1,0],POWER,"silver"],
[[25,-1.5,0],[15,11.6,6],[0,-1,0],USB,"silver"],
[[50,-2.5,0],[7,15,5],[0,-1,0],POWER,"black"],
[[66,2.5,0],[21.3,16,13.6],[1,0,0],RJ45,"silver"],
[[69,22.5,0],DoubleUSBComp,[1,0,0],USB,"silver"],
[[69,40,0],DoubleUSBComp,[1,0,0],USB,"silver"],
[[7,49.7,0],[50,5,7],[0,0,1],HEADER_M,"gold"],
[[-2,22.5,-2.7],[17,13.6,1],[-1,0,0],USB,"black"],
];
ZEROComponents = [
[],
];

components = [ 
  0,        //A
  0,        //APLUS
  0,        //B
  BPLUSComponents,     //BPLUS
  ZEROComponents,     //ZERO
  ]; 

/****************************** NON-BOARD PARAMETERS ******************************/

//Mounting holes
woodscrewHeadRad = 4.6228;  //Number 8 wood screw head radius
woodscrewThreadRad = 2.1336;    //Number 8 wood screw thread radius
woodscrewHeadHeight = 2.8448;  //Number 8 wood screw head height