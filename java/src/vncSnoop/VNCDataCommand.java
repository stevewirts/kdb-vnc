package vncSnoop;


public class VNCDataCommand {

	protected long elapsedType;
	protected byte[] data;

	public VNCDataCommand(long aTime, byte[] theData) {
		super();
		setElapsedType(aTime);
		setData(theData);
	}

	public byte[] getData() {
		return data;
	}
	public void setData(byte[] data) {
		this.data = data;
	}
	public long getElapsedType() {
		return elapsedType;
	}
	public void setElapsedType(long elapsedType) {
		this.elapsedType = elapsedType;
	}
}
