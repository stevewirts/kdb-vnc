// this file provides the handling of events
// that are sent from the vnc client
//see https://www.hep.phy.cam.ac.uk/vnc_docs/rfbproto.pdf

.event.toString:{[anEvent] aString: raze "anEvent(",(string anEvent `type),", ",(string anEvent `button),", ",(.point.toString[anEvent `location]),", ",(string anEvent `time),")";aString};

.vnc.events.handleEvent:{[x]
	l:count x;
	if[l<1;return 0N];
	mtype:x 0;
	//-1 string mtype;
	if[mtype~0x03;:.vnc.events.screenRefresh[x]];
	if[mtype~0x04;:.vnc.events.key[x]];
	if[mtype~0x05;:.vnc.events.mouse[x]];
	};
	
.vnc.events.screenRefresh:{[x]
	//-1 "screen refresh request";
	};

.vnc.events.key:{[x]
 	charKey:"c"$x 7;
 	// we really need a proper table here
 	if[0xff~x 6;if[0xe1~x 7;charKey:"shift"]];
 	if[0xff~x 6;if[0xe3~x 7;charKey:"control"]];
 	if[0xff~x 6;if[0x0d~x 7;charKey:"enter"]];
 	if[0xff~x 6;if[0x51~x 7;charKey:"arrow_left"]];
 	if[0xff~x 6;if[0x53~x 7;charKey:"arrow_right"]];
 	if[0xff~x 6;if[0x52~x 7;charKey:"arrow_up"]];
 	if[0xff~x 6;if[0x54~x 7;charKey:"arrow_down"]];
 	if[0xff~x 6;if[0x08~x 7;charKey:"backspace"]];
 	if[0xff~x 6;if[0x09~x 7;charKey:"tab"]];
 	m:charKey,(" ",$[0x01~x 1;"down, ";"up\n"]);
 	1 m};

// mouse double click detection stuff ----------------------------------------------------------------------	
.vnc.event.mouseOrientation:`primary`tertiary;
.vnc.event.null:(`type`button`location`time!(`null;`null;0 0;.z.Z))
.vnc.events.mouseDoubleClickTime:250; // this is milliseconds
.vnc.events.recentEvents:3 # enlist .vnc.event.null;
.vnc.events.addToMouseHistory:{[anEvent]
	.vnc.events.recentEvents:: -3 # .vnc.events.recentEvents,enlist anEvent;
	.vnc.events.recentEvents};

.vnc.events.mouse:{[x]
	theEvents:.vnc.events.decodeMouseEvents[x];
	.vnc.events.notifyMouseListeners each theEvents;	
	.vnc.events.updateCursorPosition[first theEvents];	
	};

.vnc.events.notifyMouseListeners:{[anEvent]
	//-1 .event.toString anEvent;	
	aType:anEvent`type;
	aComp:screen;
	aFunc:aComp[aType];
	aFunc[aComp;anEvent];
	//if[aType~`mouseDown;(aComp`mouseDown)[aComp;anEvent]];	
	//if[aType~`mouseUp;(aComp`mouseUp)[aComp;anEvent]];	
	//if[aType~`mouseMove;(aComp`mouseMove)[aComp;anEvent]];	
	//if[aType~`doubleClick;(aComp`doubleClick)[aComp;anEvent]];	
	//if[aType~`mouseDrag;(aComp`mouseDrag)[aComp;anEvent]];	
	//if[aType~`mouseDrop;(aComp`mouseDrop)[aComp;anEvent]];	
	//if[aType~`rollUp;(aComp`rollUp)[aComp;anEvent]];
	//if[aType~`rollDown;(aComp`rollDown)[aComp;anEvent]];
	};

.vnc.events.createEventFrom:{[aType;anEventToClone]
	//-1 raze "  synth ",(string aType);
	anEventToClone[`type]:aType;
	anEventToClone};

.vnc.events.mouseDownMatch:{answer:001b~((flip .vnc.events.recentEvents)[`type]=`any`buttonDown`buttonDown);answer};
.vnc.events.mouseUpMatch:  {answer:001b~((flip .vnc.events.recentEvents)[`type]=`any`mouseMove`mouseMove);answer};
.vnc.events.mouseDragMatch:{answer:011b~((flip .vnc.events.recentEvents)[`type]=`any`buttonDown`buttonDown);answer};
.vnc.events.mouseDropMatch:{answer:111b~((flip .vnc.events.recentEvents)[`type]=`buttonDown`buttonDown`mouseMove);answer};
.vnc.events.mouseDoubleClickMatch:{correctClickPattern:111b~((flip .vnc.events.recentEvents)[`type]=`buttonDown`mouseMove`buttonDown);
	times:(flip .vnc.events.recentEvents)[`time];
	points:(flip .vnc.events.recentEvents)[`location];
	dct:((`time$times[2])-(`time$times[0])) mod 1000;
	//-1 string dct;
	isUnderTimeThreshold:"i"$(.vnc.events.mouseDoubleClickTime > dct);
	isInSameSpot:"i"$points[2]~points[0];
	answer:correctClickPattern & isUnderTimeThreshold & isInSameSpot;
	answer};

.vnc.events.decodeMouseEvents:{[x]
	anEvent:();
	aMask:`unknown;
	bm:x 1;
	aButton:`null;
	anX:.vnc.decodeFromTwoBytes[x 2;x 3];
	aY:.vnc.decodeFromTwoBytes[x 4;x 5];
	if[bm~0x00;aMask:`mouseMove;];
	if[bm~0x01;aMask:`buttonDown;aButton:.vnc.event.mouseOrientation 0];
	if[bm~0x02;aMask:`buttonDown;aButton:`middle];
	if[bm~0x04;aMask:`buttonDown;aButton:.vnc.event.mouseOrientation 1];
	if[bm~0x05;aMask:`buttonDown;aButton:`both];
	if[bm~0x07;aMask:`buttonDown;aButton:`all];
	if[bm~0x08;aMask:`rollUp];
	if[bm~0x10;aMask:`rollDown];
	theEvents:();
	anEvent:.vnc.event.null;
	anEvent[`type`location`time`button]:(aMask;(anX;aY);.z.Z;aButton);
	//-1 .event.toString[anEvent];
	.vnc.events.addToMouseHistory[anEvent];
	
	if[.vnc.events.mouseDoubleClickMatch[];
		theEvents,:enlist .vnc.events.createEventFrom[`doubleClick;anEvent];
		.vnc.events.recentEvents:3 # enlist .vnc.event.null];
	if[.vnc.events.mouseDragMatch[];theEvents,:enlist .vnc.events.createEventFrom[`mouseDrag;anEvent]];
	if[.vnc.events.mouseDropMatch[];theEvents,:enlist .vnc.events.createEventFrom[`mouseDrop;anEvent]];
	if[.vnc.events.mouseDownMatch[];theEvents,:enlist .vnc.events.createEventFrom[`mouseDown;anEvent]];
	if[.vnc.events.mouseUpMatch[];theEvents,:enlist .vnc.events.createEventFrom[`mouseUp;anEvent]];
	if[0=count theEvents;theEvents:enlist anEvent];
	theEvents:1 # theEvents;
	theEvents};

// end of mouse decoding ------------------------------------------------------------------------------------

// focus stuff here
.vnc.events.focusOwner:();
.vnc.events.transferFocus:{[aComp]
	if[not()~.vnc.events.focusOwner;(.vnc.events.focusOwner`onFocusLost)[.vnc.events.focusOwner]];
	.vnc.events.focusOwner::aComp;
	if[not()~.vnc.events.focusOwner;(.vnc.events.focusOwner`onFocusGain)[.vnc.events.focusOwner]];
	};

.vnc.events.updateCursorPosition:{[anEvent]
	// handle the cursor here
	oldMouseBounds:.vnc.layer.pointer[0];
	mx:(anEvent `location) 0;
	my:(anEvent `location) 1;
	if[mx>(-2+.vnc.bounds 2);mx:-30;my:-30];
	if[my>(-2+.vnc.bounds 3);mx:-30;my:-30];
	.[`.vnc.layer.pointer;(0;0 1);:;(mx,my)];
	newMouseBounds:.vnc.layer.pointer[0];
	mouseDamageRegion:.rect.intersect[.vnc.bounds;.rect.union[oldMouseBounds;newMouseBounds]];
	.vnc.addToDamageRegions[mouseDamageRegion];
	};



