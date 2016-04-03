include <raspberry.scad>

//Raspberry Pi boards
//You can create a boxed out version of a variety of boards by calling the arduino() module
//The default board for all functions is the Uno

ZDim = boardDimensions( ZERO );
BPDim = boardDimensions( BPLUS );

//Board mockups
raspberry();
/*
translate( [BPDim[0] + 50, 0, 0] )
	raspberry(ZERO);

translate( [-(BPDim[0] + 50), 0, 0] )
	arduino(LEONARDO);

translate([0, 0, -75]) {
	enclosure();

	translate( [BPDim[0] + 50, 0, 0] )
		bumper(DUE);

	translate( [-(BPDim[0] + 50), 0, 0] ) union() {
		standoffs(LEONARDO, mountType=PIN);
		boardShape(LEONARDO, offset = 3);
	}
}

translate([0, 0, 75]) {
	enclosureLid();
}
*/
