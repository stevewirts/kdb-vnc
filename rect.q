.rect.toString:{[aRect]
	aString:"aRect(",(string aRect 0),",",(string aRect 1),",",(string aRect 2),",",(string aRect 3),")";
	aString};	

.rect.ex:{[rect](rect 2)+(rect 0)};

.rect.ey:{[rect](rect 3)+(rect 1)};

.rect.area:{[rect](rect 2)*(rect 3)};

.rect.contains:{[rect;aPoint]
	x:aPoint 0;
	y:aPoint 1;
	if[(rect 0) > x;:0b];
	if[(rect 1) > y;:0b];
	if[x > .rect.ex[rect];:0b];
	if[y > .rect.ey[rect];:0b];
	1b};

.rect.intersects:{[rect1;rect2]
	x:rect2 0;
	y:rect2 1;
	width:rect2 2;
	height:rect2 3;
	if[.rect.contains[rect1;(x;y)];:1b];
	if[.rect.contains[rect1;(x+width;y)];:1b];
	if[.rect.contains[rect1;(x;y+height)];:1b];
	if[.rect.contains[rect1;(x+width;y+height)];:1b];
	// only one last possibility, the rectangle completely sits around this one
	if[.rect.contains[rect2;(rect1 0;rect1 1)];:1b];	
	0b};

.rect.intersect:{[rect1;rect2]
	if[not .rect.intersects[rect1;rect2];:4#0];
	x_s:(rect1 0;rect2 0;.rect.ex[rect1];.rect.ex[rect2]);
	x_s:x_s[iasc x_s];
	y_s:(rect1 1;rect2 1;.rect.ey[rect1];.rect.ey[rect2]);
	y_s:y_s[iasc y_s];
	nX:x_s 1;
	nY:y_s 1;
	nWidth:(x_s 2) - nX;
	nHeight:(y_s 2) - nY;
	(nX;nY;nWidth;nHeight)};

.rect.union:{[rect1;rect2]
	x_s:(rect1 0;rect2 0;.rect.ex[rect1];.rect.ex[rect2]);
	x_s:x_s[iasc x_s];
	y_s:(rect1 1;rect2 1;.rect.ey[rect1];.rect.ey[rect2]);
	y_s:y_s[iasc y_s];
	nX:x_s 0;
	nY:y_s 0;
	nWidth:(x_s 3) - nX;
	nHeight:(y_s 3) - nY;
	(nX;nY;nWidth;nHeight)};
	
.rect.indexes:{[rect1;rect2]	// rect1 - coordinate system to find indexes in, rect2 the rectangle
	rect2:.rect.intersect[rect1;rect2]; // perfrom a clipping to stay within the bounds.
	indexes:raze {(y + key x 2)}[rect2] each (((rect2 0)+(rect2 1)*rect1 2) + ((rect1 2) * key (rect2 3)));
	indexes};

.rect.centered:{[aRect1;aRect2] `Rectangle`centered;
	centerWidth1:"i"$(aRect1 0) + ((aRect1 2) % 2);
	centerHeight1:"i"$(aRect1 1) + ((aRect1 3) % 2);
	centerWidth2:"i"$(aRect2 0) + ((aRect2 2) % 2);
	centerHeight2:"i"$(aRect2 1) + ((aRect2 3) % 2);
	transWidth:centerWidth2 - centerWidth1;	
	transHeight:centerHeight2 - centerHeight1;
	aResult:((transWidth + aRect1 0);(transHeight + aRect1 1);(aRect1 2);(aRect1 3));	
	aResult};







