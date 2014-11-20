package k4_1;

public class Month extends KType {
	public int i;

	Month(int x) {
		i = x;
	}

	public String toString() {
		int m = i + 24000, y = m / 12;
		return i2(y / 100) + i2(y % 100) + "-" + i2(1 + m % 12);
	}
}