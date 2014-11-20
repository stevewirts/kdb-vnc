package k4_1;

public class Minute extends KType {
	public int i;

	Minute(int x) {
		i = x;
	}

	public String toString() {
		return i2(i / 60) + ":" + i2(i % 60);
	}
}