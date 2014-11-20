//***********************************************************************************************
// utilitiy functions

// use these for clarity in coding.
exitHere:();

power:{t:1;do[y;t:t*x];t};

.vnc.encodeAsTwoBytes:{
	//tmp:("x"$x % 256);
	//tmp,:("x"$x mod 256);
	tmp:("x"$floor x % 256),("x"$x mod 256);
	tmp}

.vnc.decodeFromTwoBytes:{
	aValue:256 * "i"$x;
	$[y<0x00;aValue:aValue + 256 + "i"$y;aValue:aValue+"i"$y];
	aValue}

.vnc.bytesToInteger:{
	// ignore the 1st byte for now/too big for a font bitmap
	result:(65536 * (x 1)) + (256 * (x 2)) + (1 * (x 3));
	result}

.vnc.intToBits:{[anInt]
	r:0b vs'0x0 vs "i"$anInt;
	last r}

.vnc.pointsInLine:{[sx;sy;ex;ey]
	xs:(sx;ex)iasc(sx;ex);
	ys:(sy;ey)iasc(sy;ey);
	xSize:(last xs)-first xs;
	ySize:(last ys)-first ys;
	nop:1 + max (xSize;ySize);
	x_s:"i"$(first xs)+((1%(nop-1))*(key nop))*xSize;
	y_s:"i"$(first ys)+((1%(nop-1))*(key nop))*ySize;
	if[(x_s;y_s)~(enlist 0N;enlist 0N);(x_s:xs[0 1];y_s:ys[0 1])];
	if[(ys 0) = sy;y_s:reverse y_s];
	if[(xs 0) = sx;x_s:reverse x_s];
	y_s:(.vnc.bounds 2) * y_s;
	indexes: "i"${(x 0)+(x 1)} each flip (x_s;y_s);
	indexes};

.point.distance:{[pointA;pointB]
	distance:sqrt {(x 0) + (x 1)} power[;2]{(x 0)-(x 1)} each flip (pointA;pointB);
	distance};
// end utility functions
//************************************************************************************************