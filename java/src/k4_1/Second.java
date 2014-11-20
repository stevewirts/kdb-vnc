package k4_1;

public class Second extends KType {
	public int i;

	Second(int x) {
		i = x;
	}

	public String toString() {
		return new Minute(i / 60).toString() + ':' + i2(i % 60);
	}
}