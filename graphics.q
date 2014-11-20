\l rect.q
\l fonts.q

// testing function
g:{
	.vnc.g.drawOval[0;(100;100;200;150);`Yellow];
	
	.vnc.g.drawRect[0;(100;100;200;150);`LightBlue];
	
	.vnc.g.drawOval[0;(50;50;50;100);`LightBlue];
	
	.vnc.g.drawRect[0;(50;50;50;100);`Yellow];
	
	polyLinePoints:flip (50 100 200 300 600;400 500 600 500 50);
	
	.vnc.g.drawPolyline[0;polyLinePoints;`Violet];
	
	polyLinePoints:10 + flip (50 100 200 300 600;400 500 600 500 50);
	
	.vnc.g.drawPolygon[0;polyLinePoints;`LightGreen];
	
	.vnc.addToDamageRegions[(0;0;1024;768)];
	
	.vnc.pushUpdates();	
	
	};

// the knowledge of the size of the screen needs to
// not be in these functions

.point.toString:{[aPoint]
	aString:"aPoint(",(string aPoint 0),",",(string aPoint 1),")";
	aString};

.vnc.g.borderIndexes:{[rect]
	// let's make sure it doesn't give back
	// overflown indexes outside the bounds
	// of the screen
	rect:.rect.intersect[.vnc.bounds;rect];

	left:(rect 0)+((rect 1) + key rect 3)*(.vnc.bounds 2);
	right:-1 + left + (rect 2);
	bottom:(last left) + (key rect 2);
	top:(first left) + (key rect 2);
	indexes: raze top, bottom, left, right;
	indexes};

.vnc.g.pointsInLine:{[sx;sy;ex;ey]
	xs:(sx;ex)iasc(sx;ex);
	ys:(sy;ey)iasc(sy;ey);
	xSize:(last xs)-first xs;
	ySize:(last ys)-first ys;
	nop:1 + max (xSize;ySize);
	x_s:"i"$floor each (first xs)+((1%(nop-1))*(key nop))*xSize;
	y_s:"i"$floor each (first ys)+((1%(nop-1))*(key nop))*ySize;
	
	// xMax is the number of points that are "inside" the bounds
	// any point at index larger than xMax is outside and needs to be
	// ignored
	xMax:(count where y_s < .vnc.bounds 3) & (count where x_s < .vnc.bounds 2);	
	x_s:x_s[key xMax];	
	y_s:y_s[key xMax];

	if[(x_s;y_s)~(enlist 0N;enlist 0N);(x_s:xs[0 1];y_s:ys[0 1])];
	if[(ys 0) = sy;y_s:reverse y_s];
	if[(xs 0) = sx;x_s:reverse x_s];
	y_s:(.vnc.bounds 2) * y_s;
	indexes:("i"${(x 0)+(x 1)} each flip (x_s;y_s));
	indexes};
	
.vnc.g.drawString:{[gcId;aFont;aColor;aText;anX;aY] `.vnc.g.drawString;
	//if[1;:()];
	w:aFont[1];
	h:aFont[2];
	aRect:(anX;aY;(w * count aText);(h));
	indexes:.vnc.g.borderIndexes[aRect];
	indexes:indexes where indexes < count .vnc.background;
	renderMe:flip (anX + (w * key count aText);aText);
	{[g;f;c;y;r] .vnc.g.drawChar[g;f;c;(r 1);(r 0);y]}[gcId;aFont;aColor;aY] each renderMe;
	//.vnc.addToDamageRegions[aRect];	
	};

// this function is the character repeat speed test
.vnc.g.crt:{[x] c:0; while[c<x;.vnc.g.drawChar[0;.vnc.font.getFont`courier_11;`Black;"H";100;100];c:c+1]}	
// \t .vnc.g.crt[100]; /time the renedering of a hundred chars

.vnc.g.drawChar:{[gcId;aFont;aColor;aCharString;anX;aY]
	// if the starting point for rendering the 
	// char is off the screen don't bother
	if[anX>.vnc.bounds 2;:()];
	if[aY>.vnc.bounds 3;:()];

	aChar:aFont[3][aCharString];
	aPF:.vnc.font.prepChar[aFont[1];aFont[2]];	

	anOffset:(aY*.vnc.bounds 2) + anX;
	theIndexes:anOffset + aChar;
	theIndexes:theIndexes where theIndexes > 0;
	theIndexes:theIndexes where theIndexes < count .vnc.screenBuffer;
	@[`.vnc.screenBuffer;theIndexes;:;.vnc.colors[aColor][0]];
	};

.vnc.g.drawRect:{[gcId;rect;aColor] `.vnc.g.fillRect;
	theColorValue:.vnc.colors[aColor][0];
	theIndexes:.vnc.g.borderIndexes[rect];
	theIndexes:theIndexes where theIndexes > 0;
	@[`.vnc.screenBuffer;theIndexes;:;theColorValue];
	};

.vnc.g.draw3DRect:{[gcId;rect;aColor1;aColor2]
	//if[1;:()];
	.vnc.g.drawRect[gcId;rect;aColor1];
	leftX:rect 0;
	rightX:-1 + leftX + rect 2;
	topY:rect 1;
	bottomY:-1 + topY + rect 3;
	.vnc.g.drawLine[gcId;leftX;bottomY;rightX;bottomY;aColor2];
	.vnc.g.drawLine[gcId;rightX;topY;rightX;bottomY;aColor2];
	};	

.vnc.g.pointsToIndexes:{[theRect;thePoints]
	w:theRect 2;
	h:theRect 3;
	translated:{[w;h;point](point 0)+((point 1)*w)}[w;h] each thePoints;
	translated};

.vnc.g.drawArc:{[gcId;aRect;aColor;aStartAngle;anArcAngle]
	//startAngle:aStartAngle mod 360;
	//arcAngle:anArcAngle mod 360;

	startAngle:aStartAngle;
	arcAngle:anArcAngle;

	oX:aRect 0;
	oY:aRect 1;
	w:aRect 2;
	h:aRect 3;
	r:"i"$(w%2);
	if[w>h;:.vnc.g.drawHorizontalArc[gcId;aRect;aColor;startAngle;arcAngle]];
	if[w<h;:.vnc.g.drawVerticalArc[gcId;aRect;aColor;startAngle;arcAngle]];
	.vnc.g.drawCircle[gcId;oX;oY;r;aColor;startAngle;arcAngle];
	};

.vnc.g.drawHorizontalArc:{[gcId;aRect;aColor;startAngle;arcAngle]
	oX:aRect 0;
	oY:aRect 1;
	w:aRect 2;
	h:aRect 3;
	r:"i"$(h%2);
	lx:oX + r;
	ly:oY + r;
	rx:oX + w - r;
	ry:oY + r;
	// let's do polar coordinates first
	//x(t) = r cos(t) + j;
	//y(t) = r sin(t) + k;
	numberOfRadians:"i"$(50%7)*r;
	theta:(((44%7)%(numberOfRadians - 1))*key numberOfRadians);
	start:"i"$(startAngle%360)*(count theta);
	stop:"i"$((startAngle + arcAngle)%360)*(count theta);
	range:start + key (stop - start);
	x_s:(reverse (r * cos theta) + lx)[range];
	y_s:(reverse (r * sin theta) + ly)[range];
	points:distinct "i"$flip (x_s;y_s);
	points:points where not (points[;0] < 0) or (points[;0] > (.vnc.bounds 2)) or (points[;1] < 0) or (points[;1] > (.vnc.bounds 3));	
	leftPoints:points where points[;0] < lx;
	leftPoints:leftPoints[iasc reverse each leftPoints];
	rightPoints: {((x - (2*y)) + z 0;z 1)}[w;r] each (points where points[;0] > lx);
	rightPoints:rightPoints[iasc reverse each rightPoints];

	.vnc.g.plot[gcId;leftPoints;aColor];
	.vnc.g.plot[gcId;rightPoints;aColor];

	if[((count leftPoints) < 1) or (((count rightPoints) < 1));:()];
	tl:first leftPoints;
	tr:first rightPoints;
	if[1 > abs (tl[1]-tr[1]);.vnc.g.drawLine[gcId;tl 0;tl 1;tr 0;tr 1;aColor]];		

	bl:last leftPoints;
	br:last rightPoints;
	if[1 > abs (bl[1]-br[1]);.vnc.g.drawLine[gcId;bl 0;bl 1;br 0;br 1;aColor]];
	};

.vnc.g.drawVerticalArc:{[gcId;aRect;aColor;startAngle;arcAngle]
	oX:aRect 0;
	oY:aRect 1;
	w:aRect 2;
	h:aRect 3;
	r:"i"$(w%2);
	tx:oX + r;
	ty:oY + r;
	bx:oX + r;
	by:oY + (h - (2*r));
	// let's do polar coordinates first
	//x(t) = r cos(t) + j;
	//y(t) = r sin(t) + k;
	numberOfRadians:"i"$(50%7)*r;
	theta:(((44%7)%(numberOfRadians - 1))*key numberOfRadians);
	start:"i"$(startAngle%360)*(count theta);
	stop:"i"$((startAngle + arcAngle)%360)*(count theta);
	range:start + key (stop - start);
	x_s:(reverse (r * cos theta) + tx)[range];
	y_s:(reverse (r * sin theta) + ty)[range];
	points:distinct "i"$flip (x_s;y_s);
	points:points where not (points[;0] < 0) or (points[;0] > (.vnc.bounds 2)) or (points[;1] < 0) or (points[;1] > (.vnc.bounds 3));	
	topPoints:points where points[;1] < ty;
	topPoints:topPoints[iasc topPoints];
	bottomPoints: {(z 0;(x - (2*y)) + z 1)}[h;r] each (points where points[;1] > ty);
	bottomPoints:bottomPoints[iasc bottomPoints];

	.vnc.g.plot[gcId;topPoints;aColor];
	.vnc.g.plot[gcId;bottomPoints;aColor];

	if[((count topPoints) < 1) or (((count bottomPoints) < 1));:()];
	tl:first topPoints;
	bl:first bottomPoints;
	if[1 > abs (bl[0] - tl[0]);.vnc.g.drawLine[gcId;tl 0;tl 1;bl 0;bl 1;aColor]];		

	tr:last topPoints;
	br:last bottomPoints;
	if[1 > abs (br[0]-tr[0]);.vnc.g.drawLine[gcId;tr 0;tr 1;br 0;br 1;aColor]];
	};

.vnc.g.drawCircle:{[gcId;oX;oY;aRadius;aColor;startAngle;arcAngle]
	// let's do polar coordinates first
	//x(t) = r cos(t) + j;
	//y(t) = r sin(t) + k;
	j:oX;
	k:oY;
	r:aRadius;
	numberOfRadians:"i"$(50%7)*r;
	theta:(((44%7)%(numberOfRadians - 1))*key numberOfRadians);
	start:"i"$(startAngle%360)*(count theta);
	stop:"i"$((startAngle + arcAngle)%360)*(count theta);
	range:start + key (stop - start);
	x_s:(reverse (r * cos theta) + j)[range];
	y_s:(reverse (r * sin theta) + k)[range];
	points:distinct "i"$flip (x_s;y_s);
	points:points where not (points[;0] < 0) or (points[;0] > (.vnc.bounds 2)) or (points[;1] < 0) or (points[;1] > (.vnc.bounds 3));	
	indexes:.vnc.g.pointsToIndexes[.vnc.bounds;points];
	indexes:indexes where indexes < ((.vnc.bounds 2) * (.vnc.bounds 3));
	//.vnc.screenBuffer[indexes]:.vnc.colors[aColor][0];	
	theColorValue:.vnc.colors[aColor][0];
	@[`.vnc.screenBuffer;indexes;:;theColorValue];
	};

.vnc.g.drawLine:{[gcId;sx;sy;ex;ey;aColor]
	//-1 "points (",(string sx),",",(string sy),") to (",(string ex),",",(string ey),")";
	indexes:.vnc.g.pointsInLine[sx;sy;ex;ey];
	indexes:indexes where indexes < count .vnc.background;
	indexes:indexes where indexes > 0;
	/.vnc.screenBuffer[indexes]:.vnc.colors[aColor][0];

	theColorValue:.vnc.colors[aColor][0];
	@[`.vnc.screenBuffer;indexes;:;theColorValue];

	/xs:(sx;ex)iasc(sx;ex);
	/ys:(sy;ey)iasc(sy;ey);
	/xSize:(last xs)-first xs;
	/ySize:(last ys)-first ys;
	/rect:(-1 + first xs;-1 + first ys;xSize + 3;ySize + 3);
	//.vnc.addToDamageRegions[rect];
	};

.vnc.g.plot:{[gcId;thePoints;aColor]
	indexes:.vnc.g.pointsToIndexes[.vnc.bounds;thePoints];
	indexes:indexes where indexes < ((.vnc.bounds 2) * (.vnc.bounds 3));
	.vnc.screenBuffer[indexes]:.vnc.colors[aColor][0];	
	};

.vnc.g.fill3DRect:{[gcId;aRect;color1;color2;color3]
	.vnc.g.fillRect[gcId;aRect;color1];
	.vnc.g.draw3DRect[gcId;aRect;color2;color3];
	};

.vnc.g.drawOval:{[gcId;aRect;aColor]
	.vnc.g.drawArc[gcId;aRect;aColor;0;360];
	};
	
.vnc.g.fillRect:{[gcId;rect;aColor] `.vnc.g.fillRect;
	theColorValue:.vnc.colors[aColor][0];
	theClip:.rect.intersect[.vnc.bounds;rect];
	theY:theClip 1;
	theYStop:((theClip 3) + theY);
	aRowXs:(theClip 0)+ til (theClip 2);
	while[theY<theYStop;
		aP:theY*(.vnc.bounds 2);
		theRowIndexes:aP+aRowXs;
		@[`.vnc.screenBuffer;theRowIndexes;:;theColorValue];
		theY:theY+1];
	};

.vnc.g.drawPolygon:{[gcId;thePoints;aColor]
	thePoints,:enlist (first thePoints);
	//thePoints:thePoints,(first thePoints);
	.vnc.g.drawPolyline[gcId;thePoints;aColor];
	};

.vnc.g.drawPolyline:{[gcId;thePoints;aColor]
	allThePairs:flip (-1 _ thePoints;(1 _ (count thePoints) # thePoints));
	{[x;y;pair].vnc.g.drawLine[x;pair[0][0];pair[0][1];pair[1][0];pair[1][1];y]}[gcId;aColor] each allThePairs;
	};

.vnc.g.fillArc:{[gcId;rect;color]
	};

.vnc.g.fillOval:{[gcId;aRect;aColor]
	$[(aRect 2) > (aRect 3);.vnc.g.fillHorizontalOval[gcId;aRect;aColor];.vnc.g.fillVerticalOval[gcId;aRect;aColor]];
	};


.vnc.g.drawOval:{[gcId;aRect;aColor]
	$[(aRect 2) > (aRect 3);.vnc.g.drawHorizontalOval[gcId;aRect;aColor];.vnc.g.drawVerticalOval[gcId;aRect;aColor]];
	};

.vnc.g.drawHorizontalOval:{[gcId;aRect;aColor]
	x:aRect 0;
	y:aRect 1;
	w:aRect 2;
	h:aRect 3;
	r:"i"$(h%2);
	numberOfRadians:"i"$(50%7)*r;
	yMiddle:y + r;
	y_s:"i"${(x-y;x+y)}[yMiddle] each sqrt (r*r) * abs sin(22%7)*(1%(2*w))*key (2*w);
	x_s:x+"i"$(w%(count y_s))*key count y_s;
	//x_s:x + (1%(2*w)) * key (2*w);
	points:"i"$flip (x_s;y_s);	
	{z:raze z;.vnc.g.plot[x;(((z 0);(z 1));((z 0);(z 2)));y]}[gcId;aColor] each points;
	}

.vnc.g.drawVerticalOval:{[gcId;aRect;aColor]
	x:aRect 0;
	y:aRect 1;
	w:aRect 2;
	h:aRect 3;
	r:"i"$(w%2);
	numberOfRadians:"i"$(50%7)*r;
	xMiddle:x + r;
	x_s:"i"${(x-y;x+y)}[xMiddle] each sqrt (r*r) * abs sin(22%7)*(1%(2*h))*key (2*h);
	y_s:y+"i"$(h%(count x_s))*key count x_s;
	//y_s:y + (1%(2*h)) * key (2*h);
	points:"i"$flip (x_s;y_s);	
	{z:raze z;.vnc.g.plot[x;(((z 0);(z 2));((z 1);(z 2)));y]}[gcId;aColor] each points;
	}

.vnc.g.fillHorizontalOval:{[gcId;aRect;aColor]
	x:aRect 0;
	y:aRect 1;
	w:aRect 2;
	h:aRect 3;
	r:"i"$(h%2);
	yMiddle:y + r;
	y_s:"i"${(x-y;x+y)}[yMiddle] each sqrt (r*r) * abs sin(22%7)*(1%w)*key w;
	x_s:x + key w;
	points:flip (x_s;y_s);	
	{z:raze z;.vnc.g.drawLine[x;(z 0);(z 1);(z 0);(z 2);y]}[gcId;aColor] each points;
	}

.vnc.g.fillVerticalOval:{[gcId;aRect;aColor]
	x:aRect 0;
	y:aRect 1;
	w:aRect 2;
	h:aRect 3;
	r:"i"$(w%2);
	xMiddle:x + r;
	x_s:"i"${(x-y;x+y)}[xMiddle] each sqrt (r*r) * abs sin(22%7)*(1%h)*key h;
	y_s:y + key h;
	points:flip (x_s;y_s);	
	{z:raze z;.vnc.g.drawLine[x;(z 0);(z 2);(z 1);(z 2);y]}[gcId;aColor] each points;
	}


.vnc.g.fillPolygon:{[gcId;rect;color]
	};	

.vnc.g.drawImage:{[gcId;rect;color]
	};