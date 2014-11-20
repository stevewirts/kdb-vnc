.vnc.fonts:(enlist `null)!enlist (();();();());

.vnc.font.getFont:{[fontName]
	//fontName:`$fontName;
	
	// let's check to see if it's cached, if so return that;
	if[fontName in key .vnc.fonts;:.vnc.fonts[fontName]];
	//aFont:.vnc.fonts[fontName];
	//if[not 0 = count aFont;:aFont];
	//if[not (();();();())~aFont;aFont];

	// load the font from disk
	filename:`$(":fonts/", (string fontName),".bmp");
	fileContents:raze "x"$read0 filename;
	fd:raze raze fileContents;
	d:{x y reverse (-1 + z +(key 4))}[.vnc.bytesToInteger;fd];
	width:d 19;
	height:d 23;
	imageSizeInBytes:d 35;
	dataStart:d 11;
	charWidth:"i"$ width % 16;
	charHeight:"i"$ height % 14;
	rowSize:"i"$((imageSizeInBytes*8)% height);
	padding:rowSize - width;
	bits:{t:(neg x) _ y;t}[padding] each reverse rowSize cut raze .vnc.intToBits each "i"$fileContents[(d 11) + (key d 35)];
	chars:raze flip {x cut y}[charHeight] each flip {x cut y}[charWidth] each bits;
	
	// to see the chars uncomment this
	//{{1 (ssr[raze string x;"1";" "]);-1""} each x} each chars;
	//theFontData:.vnc.font.prepChar[width;height] each not ("c"$(32 + key (count chars)))!chars;
	
	aPF:.vnc.font.prepChar[charWidth;charHeight];
	theCharMap:("c"$(32 + key (count chars)))!aPF each not chars;
	aFont:(fontName;charWidth;charHeight;theCharMap);
	.vnc.fonts[fontName]::aFont;
	aFont};

.vnc.font.prepChar:{[w;h;aChar] `.vnc.g.prepChar;
	expand:{y,x}["b"$(.vnc.bounds[2]-w)#0];
	theEChar:raze expand each aChar;
	theIndexes:where theEChar = 1b;
	theIndexes};


.vnc.font.bounds:{[aFont;aText]
	w:aFont[1];
	h:aFont[2];
	aRect:(0;0;(w * count aText);(h));
	aRect}

.vnc.font.asMask:{{$[x;0xff;.vnc.transparentColor]} each (not raze x)}