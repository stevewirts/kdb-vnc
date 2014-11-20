\d .o
exitHere:();

test:{c:(-1 _ .o.instanceFromChain[.o.superChain[`Octopus]]);.o.mergeBaseAndChildClasses[c 0;c 1]};

instances:(enlist `null)!(enlist ());
instanceCount:0;
registerInstance:{[anInstance]
	anInstanceId:anInstance`id;
	instances[anInstanceId]::anInstance;
	//instances _: `null;
	};

Classes:(enlist `null)!enlist ();
Class:{[x] theData:{(x 0)!(x 1)} (flip x);
	anInstance:expandFields[theData];
	theData:anInstance,theData;
	Classes[theData`class]::theData;theData};

expandFields:{[aDef]
	anInstance:expandScalarFields[aDef];
	aDef:anInstance,aDef;	
	anInstance:expandObjectFields[aDef];
	aDef:anInstance,aDef;
	aDef};

expandObjectFields:{[aDef] `.o.q`expandObjectFields;
	"if you see this in an error it probably means";
	"you need to enlist the single field you've specified";
	if[not `objectFields in key aDef;:aDef];
	theFields:aDef`objectFields;
	i:0;
	aStop:count theFields;
	while[i<aStop;aProp:.o.createObjectFieldArray theFields[i];aDef[aProp[0]]:aProp[1];i+:1];
	aDef _: `fields;
	aDef};

expandScalarFields:{[aDef] `.o.q`expandScalarFields;
	"if you see this in an error it probably means";
	"you need to enlist the single field you've specified";
	if[not `fields in key aDef;:aDef];
	theFields:aDef`fields;
	i:0;
	aStop:count theFields;
	while[i<aStop;aProp:.o.createFieldArray theFields[i];aDef[aProp[0]]:aProp[1];i+:1];
	aDef _: `fields;
	aDef};

createFieldArray:{[theFieldName] `o.q`createFieldArray;
	theFieldName:string theFieldName;
	anUppercase:(upper (theFieldName[0])),(1 _ theFieldName);
	aProp:`$theFieldName;
	aSetter:`$("set",anUppercase);
	aGetter:`$("get",anUppercase);
	aVar:("a",anUppercase);
	aSetFunc:value "{[self;",aVar,"] (self`set)[self;`",theFieldName,";",aVar,"];}";
	aGetFunc:value "{[self] (self`get)[self;`",theFieldName,"]}";
	aMap:((aProp;aSetter;aGetter);(();aSetFunc;aGetFunc));
	aMap};

createObjectFieldArray:{[theFieldName] `o.q`createObjectFieldArray;
	theFieldName:string theFieldName;
	anUppercase:(upper (theFieldName[0])),(1 _ theFieldName);
	aProp:`$theFieldName;
	aSetter:`$("set",anUppercase);
	aGetter:`$("get",anUppercase);
	aVar:("a",anUppercase);
	aSetFunc:value "{[self;",aVar,"] $[not 99h~type ",aVar,";",aVar,":`null;",aVar,":",aVar,"`id];(self`set)[self;`",theFieldName,";",aVar,"];}";
	aGetFunc:value "{[self] anId:(self`get)[self;`",theFieldName,"];if[anId~`null;:`null];anInstance:.o.instances[anId];anInstance}";
	aMap:((aProp;aSetter;aGetter);((`null);aSetFunc;aGetFunc));
	aMap};

superChain:{[aClassName]
	theList:enlist aClassName;
	while[not `Object~last theList;theList,:(.o.Classes[last theList]`superClass)];
	theChain:reverse theList;
	theChain};

instanceFromChain:{[aChain]
	anInstance:Classes each aChain;
	anInstance};

super:{[self;args]
	//super `foo
	aFunctionName:args;
	if[not -11h~type args;aFunctionName:first args];
	aChain:superChain[self`superClass];
	theClasses:.o.Classes aChain;
	theFuncs:{y[x]}[aFunctionName] each theClasses;
	theFuncs:theFuncs where 100 = type each theFuncs;
	aFunc:last theFuncs (where not {x~y}[(self[aFunctionName])] each theFuncs);
	aResult:$[1 ~ count args;
		aFunc[self];
		aFunc[self;1 _ args]];
	aResult};

toString:{[anInstance] aString:(anInstance`toString)[anInstance];aString};

Class	(
	(`class;`Object);
	(`superClass;`null);
	(`id;`uninitialized);
	(`notifyChange;{[self;aProp;anObserved] 
			-1 (.o.toString anObserved)," changed ",(string aProp);
			});
	(`initialize;{[self]
			self[`id]:`$((string self`class),"_",string .o.instanceCount);
			.o.instanceCount:1+.o.instanceCount;
			registerInstance[self];
			self});
	(`toStringData;{[self] string self`id});
	(`toString;{[self] part:"an ";if[0N=first where"AEIOUaeiou"=(string(self`class))[0];part:"a "];raze part,(string self`class),"(",((self`toStringData)[self]),")"});
	(`set;{[self;aProperty;aValue] .[`.o.instances;(self`id;aProperty);:;aValue]});
	(`get;{[self;aProperty] .o.instances[self`id](aProperty)})
	);

Class	(
	(`class;`ObjectSet);
	(`superClass;`Object);
	(`fields;enlist `objectIds);
	(`objectIds;());
	(`add;{[self;anObject] `ObjectSet`add;
		if[(self`contains)[self;anObject];:exitHere];
		anId:anObject`id;
		theIds:(self`getObjectIds)[self];
		theIds,:anId;
		(self`setObjectIds)[self;theIds];
		});
	(`remove;{[self;anObject]  `ObjectSet`remove;
		if[not (self`contains)[self;anObject];:exitHere];
		anId:anObject`id;
		theIds:(self`getObjectIds)[self];
		theIds:theIds where not theIds = anId;
		(self`setObjectIds)[self;theIds];
		});
	(`contains;{[self;anObject]  `ObjectSet`contains;
		theIds:(self`getObjectIds)[self];
		anId:anObject`id;
		theAnswer:anId in theIds;
		theAnswer});
	(`do;{[self;aFunc]  `ObjectSet`do;
		theIds:(self`getObjectIds)[self];
		theObjects:.o.instances theIds;
		aResult:aFunc each theObjects;
		aResult});
	(`clear;{[self] `ObjectSet`clear;
		(self`setObjectIds)[self;()];
		});
	(`isEmpty;{[self] `ObjectSet`isEmpty;
		theIds:(self`getObjectIds)[self];
		anAnswer:0~count theIds;
		anAnswer});
	(`size;{[self] `ObjectSet`size;
		aSize:count (self`getObjectIds)[self];
		aSize})
	);

Class 	(
	(`class;`DependencyPropertyFilter);
	(`superClass;`Object);
	(`objectFields;enlist `dependent);
	(`fields;enlist `property);
	(`notifyChange;{[self;aProp;anObserved] 
		myProp:(self`getProperty)[self];
		myDep:(self`getDependent)[self];
		if[aProp~myProp;(myDep`notifyChange)[myDep;aProp;anObserved]];
		})
	);

Class	(
	(`class;`Model);
	(`superClass;`Object);
	(`objectFields;enlist `dependents);
	(`initDependents;{[self] `Model`initDependents;
		theDeps:.o.new`ObjectSet;
		(self`setDependents)[self;theDeps];
		});
	(`addToDependents;{[self;aDependent;aProperty] `Model`addToDependents;
		if[`null~(self`getDependents)[self];(self`initDependents)[self]];
		theDeps:(self`getDependents)[self];
		aDT:.o.new`DependencyPropertyFilter;
		(aDT`setProperty)[aDT;aProperty];
		(aDT`setDependent)[aDT;aDependent];
		(theDeps`add)[theDeps;aDT];
		});
	(`removeFromDependents;{[self;aDependent] `Model`removeFromDependents;
		if[`null~(self`getDependents)[self];(self`initDependents)[self]];
		theDeps:(self`getDependents)[self];
		theId:aDependent`id;
		aSF:{[aMatch;o] theDep:(o`getDependent)[o];
			if[aMatch~theDep`id;:o];
			`null}[theId];
		theMatches:(theDeps`do)[theDeps;aSF];
		aContainingDep:first theMatches where {not `null~x} each theMatches;
		if[(not aContainingDep ~ `)&(not 0 ~ count aContainingDep);(theDeps`remove)[theDeps;aContainingDep]];
		});
	(`notifyDependents;{[self;aProperty] `Model`notifyDependents;
		if[`null~(self`getDependents)[self];(self`initDependents)[self]];
		theDeps:(self`getDependents)[self];
		aFunc:{[aProp;anObserved;aDependent]
			(aDependent`notifyChange)[aDependent;aProp;anObserved];
			}[aProperty;self];
		(theDeps`do)[theDeps;aFunc];
		});
	(`set;{[self;aProperty;aValue] .[`.o.instances;(self`id;aProperty);:;aValue];(self`notifyDependents)[self;aProperty]})
	);

new:{[args]
	theType:args;
	if[0h~type theType;theType:first args];
	aSuperChain:.o.superChain[theType];
	theClasses:.o.Classes aSuperChain;
	$[not 1~count theClasses;anInstance:{x,y}/[theClasses];anInstance:first theClasses];
	anInit:anInstance`initialize;
	$[1 ~ count args;
		anInstance:anInit[anInstance];
		anInstance:anInit[anInstance;1 _ args]];
	if[`build in key anInstance;(anInstance`build)[anInstance]];
	anInstance:.o.instances[anInstance`id];
	anInstance};











