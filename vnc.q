//q vnc.q -p 5001

\l o.q
ts:.o.toString;
\l vnc_utils.q
\l vnc_colors.q
\l vnc_events.q
\l graphics.q

debug:0;

refresh:{.vnc.addToDamageRegions[.vnc.bounds];.vnc.pushUpdates[];}

newWindow:{[aBounds]
  w:.o.new[(`Window;screen;aBounds)];
  refresh[];
  };

test:{
  /w:.o.new[(`Window;screen;(150;150;200;100))];
  /table:.o.new[(`Table;w;(0 0;0 0;100 0;100 0))];
  /(table`show)[table;"trade"];
  /w:.o.new[(`Window;screen;(300 300 264 102))];
  /aButton:.o.new[(`Button;w;((25 0);(25 0);(75 0);(75 0)))];
  /(aButton`setAction)[aButton;{[aButton] .o.new[(`Window;screen;(150;150;200;100))]}];
  /(aButton`setTextFunc)[aButton;{[self] "open window"}];
  sho trade;
  };

tmpc:0;
sho:{[aTable]
  if[not -11h~type aTable;
    aTmpName:`$("tmp_",(string tmpc));
    .[aTmpName;();:;aTable];
    aTable:aTmpName;
    tmpc::tmpc+1];

  w:.o.new[(`Window;screen;(100;100;200;400))];
  tf:{[aTitle;self] aTitle}[string aTable];
  .[`.o.instances;(w`id;`title);:;tf];
  table:.o.new[(`Table;w;(0 0;0 0;100 0;100 0))];
  (table`show)[table;string aTable];
  refresh[];
  };

.vnc.init:{
  .vnc.bounds::0 0 800 600;
  .vnc.version::0x524642203030332e3030380a;
  .vnc.authType::0x0101;
  .vnc.authOk::0x00000000;
  tmp:.vnc.encodeAsTwoBytes[.vnc.bounds 2];
  tmp,:.vnc.encodeAsTwoBytes[.vnc.bounds 3];
  .vnc.clientInit::tmp,0x08080000000700070003000306000000000000054b44422051;

  //.vnc.background::({x*y}/[.vnc.bounds[2 3]])#.vnc.colors[`Teal][0];
  //.vnc.screenBuffer::({x*y}/[.vnc.bounds[2 3]])#.vnc.transparentColor;
  .vnc.background::(.vnc.bounds[2]*.vnc.bounds[3])#.vnc.colors[`Teal][0];
  .vnc.screenBuffer::(.vnc.bounds[2]*.vnc.bounds[3])#.vnc.transparentColor;

  .vnc.damageRegions::();
  .vnc.outgoingHandles::();

  // the last layer IS the cursor arrow
  .vnc.layer.pointer::(0 0 12 21;0x03000000000000000000000003030000000000000000000003fd0300000000000000000003fdfd03000000000000000003fdfdfd030000000000000003fdfdfdfd0300000000000003fdfdfdfdfd03000000000003fdfdfdfdfdfd030000000003fdfdfdfdfdfdfd0300000003fdfdfdfdfdfdfdfd03000003fdfdfdfdfdfdfdfdfd030003fdfdfdfdfdfd030303030303fdfdfd03fdfd030000000003fdfd0303fdfd030000000003fd03000003fdfd03000000030300000003fdfd0300000003000000000003fdfd03000000000000000003fdfd0300000000000000000003fdfd03000000000000000003fdfd0300000000000000000003030000);
  //.vnc.layer.taskBar:((0;(-30 + .vnc.bounds 3);(.vnc.bounds 2);30);((.vnc.bounds 2)#.vnc.colors[`White][0]),(29*.vnc.bounds 2)#.vnc.colors[`Gray20Percent][0]);

  .vnc.layers::();
  screen::.o.new`Screen;
  .vnc.events.focusOwner::screen;
  test[];
  };

.o.Class(
  (`class;`Component);
  (`superClass;`Model);
  (`fields;enlist `bounds);
  (`bounds;(0 0 0 0));
  (`objectFields;enlist `parent);
  (`setBounds;{[self;aNewBounds] `Component`setBounds;
      aCurrentBounds:(self`getBounds)[self];
      (self`set)[self;`bounds;aNewBounds];
      anUpdateBounds:.rect.union[aCurrentBounds;aNewBounds];
      .vnc.addToDamageRegions[anUpdateBounds];});
  (`initialize;{[self;args] `Component`initialize;
      self:((.o.Classes`Object)`initialize)[self];
      aParent:args 0;
      aBounds:args 1;
      (self`setBounds)[self;aBounds];
      //(self`setParent)[self;aParent];
      if[not aParent~`null;(aParent`addToComponents)[aParent;self]];
      self});
  (`toStringData;{[self] (.o.super[self;`toStringData]),",",.rect.toString[(self`getBounds)[self]]});
  (`draw;{[self] "implement me!";key -1});
  (`requestFocus;{[self] `Component`requestFocus;
      aParent:(self`getParent)[self];
      (aParent`delegateFocusTo)[aParent;self];});
  (`deleteMeRequest;{[self] (self`deleteMe)[self]});
  (`deleteMe;{[self] `Component`deleteMe;
      aParent:(self`getParent)[self];
      (aParent`removeFromChildren)[aParent;self]});
  (`onFocusLost;{[self;theEvent] -1 "on focus lost";});
  (`onFocusGain;{[self;theEvent] -1 "on focus gained";});
  (`mouseDown;{[self;theEvent] -1 (string self`id)," mouse down";});
  (`mouseUp;{[self;theEvent] -1 (string self`id)," mouse up";});
  (`mouseMove;{[self;theEvent] });
  (`doubleClick;{[self;theEvent] -1 "doubleClick";});
  (`mouseDrag;{[self;theEvent] -1 "mouse drag";});
  (`mouseDrop;{[self;theEvent] -1 "mouse drop";});
  (`rollUp;{[self;theEvent] -1 "roll up";});
  (`refresh;{[self] .vnc.addToDamageRegions[(self`getBounds)[self]]});
  (`rollDown;{[self;theEvent] -1 "roll down";})
  );

.vnc.layoutFunction:{[aParent;aChild] `Composite`layoutFunction;
  aPB:(aParent`getBounds)[aParent];
  mC:(aChild`bounds);
  anX:aPB[0]+$[1~count mC[0];mC 0;(mC[0][1])+"i"$((mC[0][0])%100)*aPB[2]];
  aY :aPB[1]+$[1~count mC[1];mC 1;(mC[1][1])+"i"$((mC[1][0])%100)*aPB[3]];
  aW :(aPB[0]-anX)+$[1~count mC[2];mC 2;(mC[2][1])+"i"$((mC[2][0])%100)*(aPB[2])];
  aH :(aPB[1]-aY) +$[1~count mC[3];mC 3;(mC[3][1])+"i"$((mC[3][0])%100)*(aPB[3])];
  aRect:(anX;aY;aW;aH);
  aRect};

.o.Class(
  (`class;`Composite);
  (`superClass;`Component);
  (`draw;{[self] `Composite`draw;
    .vnc.renderChildren self;
    });
  (`fields;enlist `children);
  (`build;{[self] self});
  (`getChildren;{[self] `Composite`getChildren;
    theIds:(.o.instances[self`id])[`children];
    theChildren:.o.instances[theIds];
    theChildren});
  (`children;());
  (`objectFields;enlist `dragObject);
  (`determineLayout;{[self;aComponent] `Composite`determineLayout;
      nbf:{[self]
      aP:(self`getParent)[self];
      aRect:.vnc.layoutFunction[aP;self];
      aRect};
      .[`.o.instances;(aComponent`id;`getBounds);:;nbf];
      });
  (`addToComponents;{[self;aChild] `Composite`addToComponents;
      (self`determineLayout)[self;aChild];
      theChildren:(self`get)[self;`children],(aChild`id);
      (aChild`setParent)[aChild;self];
      (self`setChildren)[self;theChildren];});
  (`removeFromChildren;{[self;aChild] `Composite`removeChild;
      theChildren:(self`get)[self;`children];
      theNewChildren:theChildren where not theChildren = aChild`id;
      (self`setChildren)[self;theNewChildren];
      (self`refresh)[self]});
  (`rollDown;{[self;theEvent]
        aComp:(self`componentAt)[self;theEvent`location];
        if[not `null~aComp;(aComp`rollDown)[aComp;theEvent]];});
  (`rollUp;{[self;theEvent]
        aComp:(self`componentAt)[self;theEvent`location];
        if[not `null~aComp;(aComp`rollUp)[aComp;theEvent]];});
  (`mouseDown;{[self;theEvent]
        aComp:(self`componentAt)[self;theEvent`location];
        if[not `null~aComp;(aComp`mouseDown)[aComp;theEvent]];});
  (`mouseUp;{[self;theEvent]
        aComp:(self`componentAt)[self;theEvent`location];
        if[not `null~aComp;(aComp`mouseUp)[aComp;theEvent]];});
  (`mouseDrag;{[self;theEvent] `Composite`mouseDrag;
        aDragObject:(self`getDragObject)[self];
        if[`null~aDragObject;
          aDragObject:(self`componentAt)[self;theEvent`location];
          if[aDragObject~`null;:exitHere];
          (self`setDragObject)[self;aDragObject]];
        (aDragObject`mouseDrag)[aDragObject;theEvent];});
  (`mouseDrop;{[self;theEvent] `Composite`mouseDrop;
        aDragObject:(self`getDragObject)[self];
        if[`null~aDragObject;:exitHere];
        (self`setDragObject)[self;`null];
        (aDragObject`mouseDrop)[aDragObject;theEvent];});
  (`mouseMove;{[self;theEvent]
        aComp:(self`componentAt)[self;theEvent`location];
        if[not `null~aComp;(aComp`mouseMove)[aComp;theEvent]];});
  (`doubleClick;{[self;theEvent]
        aComp:(self`componentAt)[self;theEvent`location];
        if[not `null~aComp;(aComp`doubleClick)[aComp;theEvent]];});
  (`componentAt;{[self;aPoint]
      theChildren:(self`getChildren)[self];
      theIndexes:where {.rect.contains[(y`getBounds)[y];x]}[aPoint] each theChildren;
      aChild:`null;
      if[not 0~count theIndexes;aChild:theChildren[last theIndexes]];
      aChild});
  (`toFront;{[self;aComp] `Composite`toFront;
      wId:aComp`id;
      theIds:(.o.instances[self`id])[`children];
      theChildren:(theIds where not wId = theIds),(aComp`id);
      (self`setChildren)[self;theChildren];})
  );

.o.Class(
  (`class;`Screen);
  (`superClass;`Composite);
  (`objectFields;enlist `dragObject);
  (`initialize;{[self]
      self:((.o.Classes`Object)`initialize)[self];
      self});
  (`determineLayout;{[self;aComp] `Screen`determineLayout;});
  (`getBounds;{[self] .vnc.bounds});
  (`mouseDrag;{[self;theEvent] `Screen`mouseDrag;
      aDragObject:(self`getDragObject)[self];
      if[`null~aDragObject;
        aDragObject:(self`componentAt)[self;theEvent`location];
        if[`null~aDragObject;:exitHere];
        (self`setDragObject)[self;aDragObject]];
      (aDragObject`mouseDrag)[aDragObject;theEvent];});
  (`mouseDrop;{[self;theEvent] `Screen`mouseDrag;
      aDragObject:(self`getDragObject)[self];
      if[`null~aDragObject;:exitHere];
      (self`setDragObject)[self;`null];
      (aDragObject`mouseDrop)[aDragObject;theEvent];});
  (`mouseDown;{[self;anEvent] `Screen`mouseDown;
      aLoc:anEvent`location;
      aChild:(self`componentAt)[self;aLoc];
      if[`null~aChild;(self`requestFocus)[self];:exitHere];
      (aChild`mouseDown)[aChild;anEvent];});
  (`mouseUp;{[self;anEvent] `Screen`mouseUp;
      aLoc:anEvent`location;
      aChild:(self`componentAt)[self;aLoc];
      if[`null~aChild;:exitHere];
      (aChild`mouseUp)[aChild;anEvent];});
  (`delegateFocusTo;{[self;aChild] `Screen`delegateFocusTo;
        (self`toFront)[self;aChild];
        oldFO:.vnc.events.focusOwner;
        .vnc.events.focusOwner::aChild;
        if[(not (oldFO`id)~(aChild`id));
          (oldFO`onFocusLost)[oldFO]];
        .vnc.events.focusOwner::aChild;
        (aChild`onFocusGain)[aChild];});
  (`requestFocus;{[self] `Component`requestFocus;
      oldOwner:.vnc.events.focusOwner;
      if[(oldOwner`id)~self`id;:exitHere];
      .vnc.events.focusOwner::self;
      (oldOwner`onFocusLost)[oldOwner];})
  );

.o.Class(
  (`class;`Window);
  (`superClass;`Component);
  (`draw;{[self]  `Window`draw;
      .vnc.renderWindow self;});
  (`title;{[self] string (self`id)});
  (`contentBounds;(5 27 -10 -32));
  (`minimumSize;(150 64));
  (`objectFields;enlist `components);
  (`initialize;{[self;args] `Window`initialize;
    self:((.o.Classes`Component)`initialize)[self;args];
    aComp:.o.new[(`Composite;`null;(0;0;0;0))];
    (aComp`setParent)[aComp;self];
    nbf:{[self]
    aP:(self`getParent)[self];
    aCB:aP`contentBounds;
    aNR:(aP`getBounds)[aP];
    aNR:((aCB[0]+aNR[0]);(aCB[1]+aNR[1]);(aCB[2]+aNR[2]);(aCB[3]+aNR[3]));
    aNR};
    .[`.o.instances;(aComp`id;`getBounds);:;nbf];
    (self`setComponents)[self;aComp];
    self});
  (`fields;`dragOffset`dragFunc);
  (`dragOffset;`null);
  (`dragFunc;`determineDragMode);
  (`mouseDown;{[self;theEvent] `Window`mouseDown;
      aPoint:theEvent`location;
      aRect:(self`getBounds)[self];
      bsx:14;
      bsy:12;
      bmx:-8 + (aRect 0)+(aRect 2) - bsx;
      aCloseButtonBounds:(bmx;8 + aRect 1;bsx;bsy);
      if[.rect.contains[aCloseButtonBounds;aPoint];
          :(self`deleteMeRequest)[self]];
      (self`requestFocus)[self];
      (self`clientMouseDown)[self;theEvent];});
  (`mouseUp;{[self;theEvent] `Window`mouseUp;
      aPoint:theEvent`location;
      aRect:(self`getBounds)[self];
      (self`clientMouseUp)[self;theEvent];});
  (`addToComponents;{[self;aComp] `Window`addToComponents;
      theContainer:(self`getComponents)[self];
      (theContainer`addToComponents)[theContainer;aComp];
      });
  (`clientMouseUp;{[self;theEvent] `Window`clientMouseUp;
      aClient:(self`getComponents)[self];
      if[aClient~`null;:exitHere];
      (aClient`mouseUp)[aClient;theEvent]});
  (`clientMouseDown;{[self;theEvent] `Window`clientMouseDown;
      aClient:(self`getComponents)[self];
      if[aClient~`null;:exitHere];
      (aClient`mouseDown)[aClient;theEvent];});
  (`determineDragMode;{[self;theEvent] `Window`determineDragMode;
      aPoint:theEvent`location;
      aBounds:(self`getBounds)[self];
      titleBarBounds:aBounds;
      titleBarBounds[3]:20;
      if[.rect.contains[titleBarBounds;aPoint];
        (self`setDragFunc)[self;`dragAround];
        (self`mouseDrag)[self;theEvent];
        :exitHere];
      stretchRect:((-15+(aBounds 2)+aBounds 0);(-15+(aBounds 3)+aBounds 1);10;10);
      if[.rect.contains[stretchRect;aPoint];
        (self`setDragFunc)[self;`stretchAround];
        (self`mouseDrag)[self;theEvent];
        :exitHere];
      (self`setDragFunc)[self;`clientMouseDrag];
      (self`mouseDrag)[self;theEvent];
      });
  (`mouseDrag;{[self;theEvent] `Window`mouseDrag;
      aFuncSymbol:(self`getDragFunc)[self];
      (self aFuncSymbol)[self;theEvent]});
  (`dragAround;{[self;theEvent] `Window`dragAround;
      aPoint:theEvent`location;
      aBounds:(self`getBounds)[self];
      aDragOffset:(self`getDragOffset)[self];
      if[aDragOffset~`null;
        aDragOffset:((aPoint 0)-(aBounds 0);(aPoint 1)-(aBounds 1));
        (self`setDragOffset)[self;aDragOffset]];
      aNewBounds:((aPoint 0)-(aDragOffset 0);(aPoint 1)-(aDragOffset 1)),aBounds[2 3];
      (self`setBounds)[self;aNewBounds];});
  (`stretchAround;{[self;theEvent] `Window`stretchAround;
      aMax:self`minimumSize;
      aPoint:theEvent`location;
      aBounds:(self`getBounds)[self];
      aW:(aMax 0)|(7 + (aPoint 0) - aBounds 0);
      aH:(aMax 1)|(7 + (aPoint 1) - aBounds 1);
      aNewBounds:aBounds[0 1],(aW;aH);
      (self`setBounds)[self;aNewBounds];});
  (`clientMouseDrag;{[self;theEvent] `Window`clientMouseDrag;
      aClient:(self`getComponents)[self];
      if[aClient~`null;:exitHere];
      (aClient`mouseDrag)[aClient;theEvent]});
  (`clientMouseDrop;{[self;theEvent] `Window`clientMouseDrop;
      aClient:(self`getComponents)[self];
      if[aClient~`null;:exitHere];
      (aClient`mouseDrop)[aClient;theEvent]});
  (`mouseDrop;{[self;theEvent] `Window`clientMouseDrop;
      if[(self`getDragFunc)[self]~`clientMouseDrag;
        (self`clientMouseDrop)[self;theEvent]];
      (self`setDragOffset)[self;`null];
      (self`setDragFunc)[self;`determineDragMode]});
  (`onFocusGain;{[self] .vnc.addToDamageRegions[(self`getBounds)[self]]});
  (`onFocusLost;{[self] .vnc.addToDamageRegions[(self`getBounds)[self]]})
  );


.o.Class(
  (`class;`Button);
  (`superClass;`Component);
  (`fields;`isDown`contentFunc`textFunc`action);
  (`isDown;0);
  (`contentFunc;{[self;aRect]
    aFont:.vnc.font.getFont[`courier_11];
    aString:(self`textFunc)[self];
    aStringBounds:.vnc.font.bounds[aFont;aString];
    aCenteredSB:.rect.centered[aStringBounds;aRect];
    if[(self`getIsDown)[self];aCenteredSB:(2 +(aCenteredSB 0);2 +(aCenteredSB 1);(aCenteredSB 2);(aCenteredSB 3))];
    .vnc.g.drawString[0;aFont;`Black;aString;aCenteredSB 0;aCenteredSB 1];});
  (`textFunc;{[self] string self`id});
  (`action;{[self] -1 (string self`id)," fired";});
  (`mouseDown;{[self;theEvent] (self`setIsDown)[self;1];(self`refresh)[self]});
  (`mouseUp;{[self;theEvent] `Button`mouseUp;
      aPoint:theEvent`location;
      aBounds:(self`getBounds)[self];
      if[.rect.contains[aBounds;aPoint];(self`action)[self]];
      (self`setIsDown)[self;0];(self`refresh)[self]});
  (`mouseDrag;{[self;theEvent] `Button`mouseDrag;});
  (`mouseDrop;{[self;theEvent] (self`mouseUp)[self;theEvent]});
  (`draw;{[self] `Button`draw;
      aRenderFunc:(self`getContentFunc)[self];
      isDown:(self`getIsDown)[self];
      aBounds:(self`getBounds)[self];
      color1:`White;
      color2:`Black;
      if[isDown;color1:`Black;color2:`White];
      .vnc.g.fill3DRect[0;aBounds;`Gray20Percent;color1;color2];
      aRenderFunc[self;aBounds]})
  );

.o.Class(
  (`class;`VScrollbar);
  (`superClass;`Composite);
  (`objectFields;enlist `thumb);
  (`buttonSize;10);
  (`setMax;{[self;aMax]
    aThumb:(self`getThumb)[self];
    (aThumb`setMax)[aThumb;aMax];
    });
  (`getValue;{[self] `VScrollbar`getValue;
    aThumb:(self`getThumb)[self];
    aValue:(aThumb`getValue)[aThumb];
    aValue});
  (`notifyChange;{[self;aProp;anObserved]
      if[not `value = aProp;:exitHere];
      (self`notifyDependents)[self;`value];
      });
  (`build;{[self] `VScrollbar`build;
    aSize:(self`buttonSize);
    aReduceButton:.o.new[(`Button;self;((100;(neg aSize));(0 0);(100 0);(0;aSize)))];
    (aReduceButton`setTextFunc)[aReduceButton;{[self] ""}];
    anIncreaseButton:.o.new[(`Button;self;((100;(neg aSize));(100;(neg aSize));(100 0);(100 0)))];
    (anIncreaseButton`setTextFunc)[anIncreaseButton;{[self] ""}];
    aThum:.o.new[(`VScrollThumb;self;( (100;(neg aSize)) ; (0;aSize) ; (100 0) ; (100;(neg aSize)) ))];
    (aReduceButton`setAction)[aReduceButton;{[x;y] (x`goUp)[x;1]}[aThum]];
    (anIncreaseButton`setAction)[anIncreaseButton;{[x;y] (x`goDown)[x;1]}[aThum]];
    (self`setThumb)[self;aThum];
    (aThum`addToDependents)[aThum;self;`value];
    })
  );

.o.Class(
  (`class;`HScrollbar);
  (`superClass;`VScrollbar);
  (`build;{[self] `HScrollbar`build;
    aSize:(self`buttonSize);
    aReduceButton:.o.new[(`Button;self;((0 0);(100;(neg aSize));(0;aSize);(100 0)))];
    (aReduceButton`setTextFunc)[aReduceButton;{[self] ""}];
    anIncreaseButton:.o.new[(`Button;self;((100;(neg aSize));(100;(neg aSize));(100 0);(100 0)))];
    (anIncreaseButton`setTextFunc)[anIncreaseButton;{[self] ""}];
    aThum:.o.new[(`HScrollThumb;self;((0;aSize);(100;(neg aSize));(100;neg aSize);(100 0)))];
    (aReduceButton`setAction)[aReduceButton;{[x;y] (x`goUp)[x;1]}[aThum]];
    (anIncreaseButton`setAction)[anIncreaseButton;{[x;y] (x`goDown)[x;1]}[aThum]];
    (self`setThumb)[self;aThum];
    (aThum`addToDependents)[aThum;self;`value];
    })
  );


.o.Class(
  (`class;`VScrollThumb);
  (`superClass;`Component);
  (`fields;`pageSize`max`min`value`thickness);
  (`pageSize;10);
  (`value;0);
  (`max;100);
  (`min;0);
  (`orientation;1);
  (`thickness;10);
  (`pageUp;{[self] `ScrollThumb`pageUp;
    aPage:(self`getPageSize)[self];
    (self`goUp)[self;aPage];
    });
  (`pageDown;{[self] `ScrollThumb`pageDown;
    aPage:(self`getPageSize)[self];
    (self`goDown)[self;aPage];
    });
  (`goDown;{[self;anAmount] `Scrollthumb`goDown;
    aMax:(self`getMax)[self];
    oldValue:(self`getValue)[self];
    aNewValue:aMax & oldValue+anAmount;
    (self`setValue)[self;aNewValue];
    (self`refresh)[self];
    });
  (`goUp;{[self;anAmount] `Scrollthumb`goUp;
    aMin:(self`getMin)[self];
    oldValue:(self`getValue)[self];
    aNewValue:aMin | oldValue-anAmount;
    (self`setValue)[self;aNewValue];
    (self`refresh)[self];
    });
  (`mouseDown;{[self;theEvent] `Scrollthumb`mouseDown;
    aPoint:theEvent`location;
    aThumbBounds:(self`getThumbBounds)[self];
    if[.rect.contains[aThumbBounds;aPoint];(self`mouseDrag)[self;theEvent];:exitHere];
    $[(aPoint (self`orientation))<(aThumbBounds (self`orientation));
      (self`pageUp)[self];
      (self`pageDown)[self]];
    });
  (`mouseDrag;{[self;theEvent] `Scrollthumb`mouseDrag;
    aMax:(self`getMax)[self];
    aMin:(self`getMin)[self];
    aPoint:theEvent`location;
    myBounds:(self`getBounds)[self];
    aThickness:(self`getThickness)[self];
    aY:(neg "i"$aThickness%2) + aPoint (self`orientation);
    aRange:(myBounds 2+(self`orientation))-aThickness;
    aFrac:(aY-(myBounds (self`orientation)))%aRange;
    aNewValue:aMin + "i"$aFrac*(aMax - aMin);
    aNewValue:aMax & aMin | aNewValue;
    (self`setValue)[self;aNewValue];
    (self`refresh)[self];
    });
  (`mouseDrop;{[self;theEvent] `Scrollthumb`mouseDrop;-1 "drop"});
  (`getThumbBounds;{[self] `ScrollThumb`getThumbBounds;
    aMax:(self`getMax)[self];
    aMin:(self`getMin)[self];
    aValue:(self`getValue)[self];
    myBounds:(self`getBounds)[self];
    aThickness:(self`getThickness)[self];
    aYRange:(myBounds 2+(self`orientation))-aThickness;
    aFrac:aValue%(aMax-aMin);
    aYDelta:"i"$aFrac*aYRange;
    aYPos:(myBounds (self`orientation)) + aYDelta;
    aThumbBounds:(aYPos;myBounds[1];aThickness;myBounds[3]);
    if[self`orientation;aThumbBounds:(myBounds[0];aYPos;myBounds[2];aThickness)];
    aThumbBounds});
  (`draw;{[self] `ScrollThumb`draw;
    myBounds:(self`getBounds)[self];
    aThumbBounds:(self`getThumbBounds)[self];
    .vnc.g.fillRect[0;myBounds;`Gray10Percent];
    .vnc.g.fill3DRect[0;aThumbBounds;`Gray20Percent;`White;`Black];
    })
  );


.o.Class(
  (`class;`HScrollThumb);
  (`superClass;`VScrollThumb);
  (`orientation;0)
  );

//----------------------  TABLE CONTROL  ---------------------------------------------------------------

/ create table with 2 columns and 6 rows
stock:([stock:`xx`yyyy`aaa`bbb`ccc`dd]
 industry:`auto`auto`comp`comp`comp`comp);

/ create table with 4 columns and n rows
n:10000000;
trade:([]
 c:til n;
 stock:`stock $ n ? exec stock from stock;
 price:50 + .25 * n ? 200;
 amount:100 * 10 + n ? 20;
 date:2000.01.01 + asc n ? 365;
 stock1:`stock $ n ? exec stock from stock;
 price1:50 + .25 * n ? 200;
 amount1:100 * 10 + n ? 20;
 date1:2000.01.01 + asc n ? 365;
 stock2:`stock $ n ? exec stock from stock;
 price2:50 + .25 * n ? 200;
 amount2:100 * 10 + n ? 20;
 date2:2000.01.01 + asc n ? 365;
 stock3:`stock $ n ? exec stock from stock;
 price3:50 + .25 * n ? 200;
 amount3:100 * 10 + n ? 20;
 date3:2000.01.01 + asc n ? 365;
 stock4:`stock $ n ? exec stock from stock;
 price4:50 + .25 * n ? 200;
 amount4:100 * 10 + n ? 20;
 date4:2000.01.01 + asc n ? 365);

.o.Class(
  (`class;`TableRenderer);
  (`superClass;`Component);
  (`objectFields;enlist `table);
  (`getColumnLabel;{[self;anIndex] "col_",string anIndex});
  (`getColumnWidth;{[self;anIndex] 75});
  (`getBackgroundColor;{[self;aPoint] `White});
  (`getForegroundColor;{[self;aPoint] `TableRenderer`getForegroundColor;
    aColIndex:aPoint 0;
    aTable:(self`getTable)[self];
    aType:(aTable`getColumnType)[aTable;aColIndex];
    if[aType~`date;:`Red];
    `Black});
  (`getFont;{[self] aTable:(self`getTable)[self];aFont:(aTable`getFont)[aTable];aFont});
  (`getShowableColumsAt;{[self;anIndex] 3});
  (`getTableSize;{[self] aTable:(self`getTable)[self];aSize:(aTable`getTableSize)[aTable];aSize});
  (`getColumnType;{[self;anIndex] `TableRenderer`getColumnTypes;
    aTable:(self`getTable)[self];
    aType:(aTable`getColumnType)[aTable;anIndex];
    aType});
  (`getColAlignment;{[self;aColIndex] `TableRenderer`getCellPadding;
    aTable:(self`getTable)[self];
    aType:(aTable`getColumnType)[aTable;aColIndex];
    if[aType~`symbol;:`left];
    `right});
  (`drawCol;{[self;aCol;aStartX] `TableRenderer`drawCol;
    aTable:(self`getTable)[self];
    theTableName:(aTable`getKsql)[aTable];
    aScrollX:(aTable`getHScrollValue)[aTable];
    aScrollY:(aTable`getVScrollValue)[aTable];
    myBounds:(self`getBounds)[self];
    aFont:.vnc.font.getFont[(self`getFont)[self]];
    aRowHeight:aFont 2;
    numRows:(aTable`getNumOfVisibleRows)[aTable];
    aQuery:raze "select from (",(string theTableName),") where i in (",(string aScrollY)," + til ",(string numRows),")";
    //-1 aQuery;
    theData:value aQuery;
    aColumnLabel:raze string (key first theData)[aCol];
    // draw column heading

    aColWidth:(self`getColumnWidth)[self;aCol];
    aBounds:.vnc.font.bounds[aFont;aColumnLabel];
    anAlignPadding:aColWidth-"i"$floor(aBounds 2)%2;
    .vnc.g.drawString[0;aFont;`Red;aColumnLabel;aStartX + myBounds 0;(myBounds 1)+aRowHeight];
    aCount:2;
    anAlign:(self`getColAlignment)[self;aCol];
    while[aCount<numRows;
      aRow:aScrollY+aCol;
      aY:(myBounds 1)+ aRowHeight*aCount;
      anX:aStartX + myBounds 0;
      aRowOfData:theData[-1 + aCount];
      theText:raze string (value aRowOfData)[aCol];
      aBounds:.vnc.font.bounds[aFont;theText];
      foregroundColor:(self`getForegroundColor)[self;(aCol;aRow)];
      backgroundColor:(self`getBackgroundColor)[self;(aCol;aRow)];
      .vnc.g.fillRect[0;(anX;aY;aColWidth-2;aRowHeight-1);backgroundColor];
      anAlignPadding:10;
      if[anAlign~`right;anAlignPadding:-3+aColWidth-(aBounds 2)];
      if[anAlign~`center;anAlignPadding:aColWidth-"i"$floor(aBounds 2)%2];
      .vnc.g.drawString[0;aFont;foregroundColor;theText;anAlignPadding+anX;aY];
      aCount:aCount+1];
    });
  (`draw;{[self] `TableRenderer`draw;
    aTable:(self`getTable)[self];
    numberOfRealCols:(aTable`getNumberOfColumns)[aTable];
    (aTable`syncScrollers)[aTable];
    myBounds:(self`getBounds)[self];
    aScrollX:(aTable`getHScrollValue)[aTable];
    numOfVisibleCols:(aTable`getNumOfVisibleCols)[aTable];
    numCols:
    aCount:0;
    theNumRows:(self`getTableSize)[self];
    aFont:.vnc.font.getFont[(self`getFont)[self]];
    .vnc.g.drawString[0;aFont;`Black;("(",(string theNumRows)," records)");myBounds 0;myBounds 1];
    // render columns
    while[aCount<(numOfVisibleCols & numberOfRealCols);
      colNum:aCount + aScrollX;
      aColWidth:(self`getColumnWidth)[self;colNum];
      (self`drawCol)[self;colNum;aCount*aColWidth];
      aCount:aCount+1];
    })
  );

.o.Class(
  (`class;`Table);
  (`superClass;`Composite);
  (`objectFields;`vScroll`hScroll`renderer);
  (`fields;`ksql`font);
  (`font;`courier_9);
  (`ksql;"trade");
  (`getColumnWidth;{[self;anIndex] 75});
  (`getColumnType;{[self;anIndex] `Table`getColumnTypes;
    aTableName:(self`getKsql)[self];
    theTypes:value "first value flip select t from meta (",aTableName,")";
    aType:theTypes[anIndex];
    aType});
  (`getNumOfVisibleRows;{[self] `Table`getNumOfVisibleRows;
    aFont:.vnc.font.getFont[(self`getFont)[self]];
    aCharW:aFont 1;
    aCharH:aFont 2;
    myBounds:(self`getBounds)[self];
    aRowHeight:aCharH;
    numRows:-1+"i"$floor (myBounds 3)%aRowHeight;
    numRows});
  (`getNumOfVisibleCols;{[self] `Table`getNumOfVisibleCols;
    aFont:.vnc.font.getFont[(self`getFont)[self]];
    aCharW:aFont 1;
    aCharH:aFont 2;
    myBounds:(self`getBounds)[self];
    aVScroller:(self`getVScroll)[self];
    aScrollerSize:aVScroller`buttonSize;
    myFitWith:(myBounds 2)-aScrollerSize;
    aColWidth:(self`getColumnWidth)[self;0];
    numCols:"i"$floor myFitWith%aColWidth;
    numCols});
  (`getHScrollValue;{[self]
    aHScroll:(self`getHScroll)[self];
    aValue:(aHScroll`getValue)[aHScroll];
    aValue});
  (`getVScrollValue;{[self]
    aVScroll:(self`getVScroll)[self];
    aValue:(aVScroll`getValue)[aVScroll];
    aValue});
  (`notifyChange;{[self;aProp;anObserved]  `Table`notifyChange;
      if[not `value = aProp;:exitHere];
      (self`refresh)[self];
      });
  (`show;{[self;aTableName] `Table`show;
      (self`setKsql)[self;aTableName];
      (self`syncScrollers)[self];
      });
  (`getNumberOfColumns;{[self] `Table`getNumberOfColumns;
      aTableName:(self`getKsql)[self];
      aSize:value raze "count cols ",aTableName;aSize});
  (`getTableSize;{[self]  `Table`getTableSize;
      aTableName:(self`getKsql)[self];
      aSize:value raze "count ",aTableName;aSize});
  (`syncScrollers;{[self] `Table`syncScrollers;
      aTableName:(self`getKsql)[self];
      aMaxCols:value raze "count cols ",aTableName;
      aMaxRows:(self`getTableSize)[self];
      aBoundsAdjustedColsValue:aMaxCols-(self`getNumOfVisibleCols)[self];
      aBoundsAdjustedRowsValue:aMaxRows-(self`getNumOfVisibleRows)[self];
      aHScroller:(self`getHScroll)[self];
      (aHScroller`setMax)[aHScroller;aBoundsAdjustedColsValue];
      aVScroller:(self`getVScroll)[self];
      (aVScroller`setMax)[aVScroller;aBoundsAdjustedRowsValue];
      });
  (`build;{[self] `Table`build;
    aFont:.vnc.font.getFont[(self`getFont)[self]];
    aCharW:aFont 1;
    aCharH:aFont 2;
    aVScrollbar:.o.new[(`VScrollbar;self;(0 0;(0;aCharH + 2);100 0;100 -12))];
    (self`setVScroll)[self;aVScrollbar];
    (aVScrollbar`addToDependents)[aVScrollbar;self;`value];
    aHScrollbar:.o.new[(`HScrollbar;self;(0 0;0 0;100 -12;100 0))];
    (self`setHScroll)[self;aHScrollbar];
    (aHScrollbar`addToDependents)[aHScrollbar;self;`value];
    aRenderer:.o.new[(`TableRenderer;self;(0 0;0 0;100 -12;100 -12))];
    (self`setRenderer)[self;aRenderer];
    (aRenderer`setTable)[aRenderer;self];
    })
  );


//----------------- END Table Control --------------------------------------------------------------------

.vnc.renderChildren:{[self] `Screen`renderChildren;
  theChildren:(self`getChildren)[self];
  {(x`draw)[x]} each theChildren;
  };

.vnc.renderAll:{
  st:.z.Z;
  (screen`draw)[screen];
  };

.vnc.renderWindow:{[aWindow]
    titleBarColor:`DarkBlue;
    if[not (aWindow`id)~.vnc.events.focusOwner`id;titleBarColor:`Gray40Percent];
    aRect:(aWindow`getBounds)[aWindow];
    aText:(aWindow`title)[aWindow];
    bsx:14;
    bsy:12;
    aFont:.vnc.font.getFont[`courier_11];

    // render window surface
    .vnc.g.fill3DRect[0;aRect;`Gray20Percent;`White;`Black];

    // render titleBar
    .vnc.g.fillRect[0;(4 + aRect 0;4 + aRect 1; -9 + aRect 2;20);titleBarColor];
    .vnc.g.drawString[0;aFont;`White;aText;8 + aRect 0;4 + aRect 1];

    bmx:-8 + (aRect 0)+(aRect 2) - bsx;
    //.vnc.renderMinimizeButton[(-32+bmx;8 + aRect 1;bsx;bsy)];
    //.vnc.renderMaximizeButton[(-16+bmx;8 + aRect 1;bsx;bsy)];
    .vnc.renderCloseButton[(bmx;8 + aRect 1;bsx;bsy)];

    aComp:(aWindow`getComponents)[aWindow];
    (aComp`draw)[aComp];
    .vnc.renderStretchBar[aRect];
  };


.vnc.renderStretchBar:{[aRect]
  eX:(aRect 0) + (aRect 2) - 6;
  eY:(aRect 1) + (aRect 3) - 6;
  aDraw:{[x;y;aColor;o].vnc.g.drawLine[0;x;(y - 10) + o;(x - 10) + o;y;aColor]};
  aDraw[eX;eY][`White;0];
  aDraw[eX;eY][`Gray;1];
  aDraw[eX;eY][`Gray;2];
  aDraw[eX;eY][`Gray20Percent;3];
  aDraw[eX;eY][`White;4];
  aDraw[eX;eY][`Gray;5];
  aDraw[eX;eY][`Gray;6];
  aDraw[eX;eY][`Gray20Percent;7];
  aDraw[eX;eY][`White;8];
  aDraw[eX;eY][`Gray;9];
  };

.vnc.renderMinimizeButton:{[aRect]
    //x button (close)
    .vnc.renderWindowButtonBox[aRect];
    .vnc.renderWindowMinimizeBar[aRect];
  };

.vnc.renderMaximizeButton:{[aRect]
    //x button (close)
    .vnc.renderWindowButtonBox[aRect];
    .vnc.renderWindowMaximizeBar[aRect];
  };

.vnc.renderCloseButton:{[aRect]
    //x button (close)
    .vnc.renderWindowButtonBox[aRect];
    .vnc.renderWindowCloseX[aRect];
  };

.vnc.renderWindowCloseX:{[aRect]
    // draw the "x"
    distanceFromEdge:"i"$(aRect 2) % 4;
    lx:(aRect 0) + distanceFromEdge;
    rx:(aRect 0) + (aRect 2) - distanceFromEdge;
    ty:(aRect 1) + distanceFromEdge - 2;
    by:(aRect 1) + (aRect 3) - distanceFromEdge;

    .vnc.g.drawLine[0;lx;by;rx;ty;`Black];
    .vnc.g.drawLine[0;lx - 1;by;rx - 1;ty;`Black];
    .vnc.g.drawLine[0;lx;ty;rx;by;`Black];
    .vnc.g.drawLine[0;lx - 1;ty;rx - 1;by;`Black];
  };

.vnc.renderWindowMinimizeBar:{[aRect]
    // draw the bar
    distanceFromEdge:"i"$(aRect 2) % 4;
    lx:(aRect 0) + distanceFromEdge;
    rx:(aRect 0) + (aRect 2) - distanceFromEdge;
    //ty:(aRect 1) + distanceFromEdge - 2;
    by:(aRect 1) + (aRect 3) - distanceFromEdge;

    .vnc.g.drawLine[0;lx - 1;by;rx - 1;by;`Black];
    .vnc.g.drawLine[0;lx - 1;by + 1;rx - 1;by + 1;`Black];
  };

.vnc.renderWindowMaximizeBar:{[aRect]
    // draw the "x"
    distanceFromEdge:"i"$(aRect 2) % 4;
    lx:(aRect 0) + distanceFromEdge - 1;
    rx:1 + (aRect 0) + (aRect 2) - distanceFromEdge;
    ty:(aRect 1) + distanceFromEdge - 2;
    by:1 + (aRect 1) + (aRect 3) - distanceFromEdge;

    .vnc.g.drawLine[0;lx - 1;ty;rx - 1;ty;`Black];
    .vnc.g.drawLine[0;lx - 1;ty + 1;rx - 1;ty + 1;`Black];
    .vnc.g.drawRect[0;(lx - 1;ty;(1 + rx-lx);(1 + by-ty));`Black];
  };

.vnc.renderWindowButtonBox:{[aRect]
  .vnc.g.fill3DRect[0;aRect;`Gray20Percent;`White;`Black];
  };

.vnc.removeHandle:{
  aHandle:.z.w;
  .vnc.outgoingHandles::.vnc.outgoingHandles where not .vnc.outgoingHandles = aHandle;
  };

.vnc.addToDamageRegions:{[aRect]
  aRect:.rect.intersect[.vnc.bounds;aRect];
  if[1>aRect 2;:()];
  if[1>aRect 3;:()];
  .vnc.damageRegions::distinct (.vnc.damageRegions, enlist aRect);
  };

.vnc.generateRawUpdateChunk:{[rect]
  //rect:.rect.intersect[rect;.vnc.bounds];
  m:12#0x00;
  m[0 1]:.vnc.encodeAsTwoBytes[rect 0];
  m[2 3]:.vnc.encodeAsTwoBytes[rect 1];
  m[4 5]:.vnc.encodeAsTwoBytes[rect 2];
  m[6 7]:.vnc.encodeAsTwoBytes[rect 3];
  m[8]:0x00;
  m[9]:0x00;
  m[10]:0x00;
  m[11]:0x00;
  //-1 .rect.toString[rect];
  indexes:.rect.indexes[.vnc.bounds;rect];
  //indexes:indexes where indexes < count .vnc.background;

  theSubRect:.vnc.screenBuffer[indexes];
  m:m,theSubRect;
  m};

.vnc.generateUpdateMessage:{[rectangles]

  // gotta re-render the layers on the buffer
  .vnc.mergeLayers[];

  // create an array the size necessary to accomodate the Rectangle
  m:4#0x00;
  m[0]:0x00; // always zero for a rectangle update; see "Framebuffer Update" http://www.uk.research.att.com/archive/vnc/rfbproto.pdf
  m[1]:0x00; // padding

  m[2]:0x00; // # of
  m[3]:"x"$count rectangles; // rectangles
  m,:raze .vnc.generateRawUpdateChunk each rectangles;
  m};

.vnc.mergeLayers:{
  //initialize the buffer to the background
  .vnc.screenBuffer[]:.vnc.background;
  .vnc.renderAll[];
  //.vnc.mergeLayer each .vnc.layers;
  .vnc.mergeLayer[.vnc.layer.pointer];
  }


.vnc.mergeLayer:{[aPointerToLayer]

  aLayer:aPointerToLayer[];
  // figure out the layers clipped boundry (as aRectangle)
  aLayerClip:.rect.intersect[.vnc.bounds;aLayer 0];
  aLayerClip[0]:0;
  aLayerClip[1]:0;

  // create the non translated indexes of the clipped rectangle
  indexes:.rect.indexes[0 0,(aLayer 0)[2 3];aLayerClip];

  // get the values that are inside the clipped rectangle
  aClippedLayer:(aLayer 1)[indexes];

  // get the indexes where the values are not transparent;
  nonTranslatedIndexes:where not .vnc.transparentColor=aClippedLayer;

  translatedIndexes:.rect.indexes[.vnc.bounds;aLayer 0][nonTranslatedIndexes];
  @[`.vnc.screenBuffer;translatedIndexes;:;aClippedLayer[nonTranslatedIndexes]];
  };

.vnc.initViewer:{
  aMessage:.vnc.generateUpdateMessage[enlist .vnc.bounds];
  -1 string .vnc.bounds;
  .vnc.recordHandle[];
  .z.w aMessage;
  aMessage};

.vnc.recordHandle:{
  .vnc.outgoingHandles::distinct .vnc.outgoingHandles, .z.w;
  };

.vnc.clearDamageRegions:{
  //-1 "clearDamageRegions";
  .vnc.damageRegions:();
  .vnc.mouseDamage:();
  }

// this is the JAVA proxy entry point
arg:();
.vnc.fromVNC:{[x]
  arg::x;
  aT:value "\\t .vnc.fromVNCtime[]";
  // uncomment the below line to see milliseconds for queries;
  -1 string aT;
  arg};
.vnc.fromVNCtime:{
  x:arg;
    start:.z.Z;
  // this is taking all the time right now
  .vnc.events.handleEvent[x];
    he:(1000000*(.z.Z - start));

    start:.z.Z;
  r:.vnc.pushUpdates[];
    pu:(1000000*(.z.Z - start));
    //-1 .point.toString[(he;pu)];
  arg::r;
  r};

.vnc.pushUpdates:{
  aMessage:();
  theDamage:.vnc.damageRegions;
  if[not 0~count theDamage;
    aMessage:.vnc.generateUpdateMessage[theDamage];
    broadcastList:.vnc.outgoingHandles where not .vnc.outgoingHandles = .z.w;
    //-1 "broadcast list size:",string count broadcastList;
    {.vnc.broadcast[y;x]}[aMessage] each broadcastList;
    .vnc.clearDamageRegions[]];
  aMessage};

.vnc.broadcast:{[aHandle;aMessage]
  // this function removes handles from the global list if they fail sending aMessage
  // it is assumed somehow the vnc client was shutdown and we were not notified

  (neg aHandle) aMessage;
  // can't get protected execution to work
  //@[aHandle;aMessage;.vnc.outgoingHandles::.vnc.outgoingHandles where not .vnc.outgoingHandles = .vnc.tmp1];
  };


mouseX:0;
mouseY:0;
lastBounds:(0;0;0;0);
.vnc.lastMouseEvent:0 0;

.vnc.drawTest:{[anX;aY]
  //-1 .point.toString[(anX;aY)];

  .vnc.addToDamageRegions[(mouseX;mouseY;300;300)];
  mouseX::anX;
  mouseY::aY;
  .vnc.addToDamageRegions[(mouseX;mouseY;300;300)];
  }

popClock:{
  .vnc.renderClock[];
  .vnc.pushUpdates[];
  }



.vnc.init[];






