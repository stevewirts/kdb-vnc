package k4_1;

import java.lang.reflect.Array;

public class Dict extends KType {
	public Object x;

	public Object y;

	Dict(Object X, Object Y) {
		x = X;
		y = Y;
	}

	public Dict asDict() {
		return this;
	}
	public Dict asKeyless() {
		String[] theHeaders = getHeaders();
		Object[] theData = getData();
		Dict aNew = new Dict(theHeaders, theData);
		return aNew;
	}
	public String[] getHeaders() {
		
		if (isSimple()) return (String[])x;
		
		// this assumes this object is a table
		int numCols = numCols();
		String[] theHeaders = new String[numCols];
		String[] theKeyHeaders = extractHeaders(x);
		String[] theDataHeaders = extractHeaders(y);
		System.arraycopy(theKeyHeaders,0,theHeaders,0,theKeyHeaders.length);
		System.arraycopy(theDataHeaders,0,theHeaders,theKeyHeaders.length,theDataHeaders.length);
		return theHeaders;
	}
	public Object[] getData() {
		
		if (isSimple()) return (Object[])x;
		
		// this assumes this object is a table
		int numCols = numCols();
		Object[] theData = new Object[numCols];
		Object[] theKeyData = extractColumns(x);
		Object[] theDataData = extractColumns(y);
		System.arraycopy(theKeyData,0,theData,0,theKeyData.length);
		System.arraycopy(theDataData,0,theData,theKeyData.length,theDataData.length);
		return theData;
	}
	protected String[] extractHeaders(Object anObject) {
		String[] theHeaders = (String[])((Flip)anObject).x;
		return theHeaders;
	}
	protected Object[] extractColumns(Object anObject) {
		Object[] theCols = (Object[])((Flip)anObject).y;
		return theCols;
	}
	public int numCols() {
		// this is just a simple table, no keys
		if (isSimple()) return ((Object[])x).length;
		
		// this is a keyed table
		int aKeyTotal = Array.getLength((Object[])((Flip)x).x);
		int aDataTotal = Array.getLength((Object[])((Flip)y).x);
		int theTotal = aKeyTotal + aDataTotal;
		return theTotal;
	}
	public String[] getKeys() {
		if (isSimple()) return new String[0];
		String[] theKeys = extractHeaders(x);
		return theKeys;
	}

	public Object getValue(int anX, int aY) {
		Object[] theCols = extractColumns(x);
		if (anX > (theCols.length - 1))
			{
				anX = anX - theCols.length;
				theCols = extractColumns(y);
			}
		Object aCol = theCols[anX];
		Object aResult = Array.get(aCol, aY);
		return aResult;
	}
	public boolean isSimple() {
		// is this a simple table with no keys
		return !(x instanceof Flip);
	}
}