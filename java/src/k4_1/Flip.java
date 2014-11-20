package k4_1;

import java.lang.reflect.Array;

public class Flip extends KType {
	public String[] x;

	public Object[] y;

	public Flip(Dict X) {
		x = (String[]) X.x;
		y = (Object[]) X.y;
	}
	public Dict asDict() {
		Dict aDict = new Dict(x,y);
		return aDict;
	}
	public Object getValue(int anX, int aY) {
		Object[] theCols = (Object[])y;
		Object aCol = theCols[anX];
		Object aResult = Array.get(aCol, aY);
		return aResult;
	}
	public String[] getKeys() {
		//none here dude!
		return new String[0];
	}
}