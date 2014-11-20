package vncSnoop;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.Socket;
import java.util.ArrayList;
import java.util.List;


public class VNCHandlerRecorder extends VNCClientHandler {
	
	protected List fromClient;
	protected List toClient;
	
	public VNCHandlerRecorder(VNCProxy aContainer, Socket aSocket) {
		super(aContainer, aSocket);
	}
	public List getFromClient() {
		if (fromClient == null) setFromClient(new ArrayList());
		return fromClient;
	}
	public void setFromClient(List fromClient) {
		this.fromClient = fromClient;
	}
	public List getToClient() {
		if (toClient == null) setToClient(new ArrayList());
		return toClient;
	}
	public void setToClient(List toClient) {
		this.toClient = toClient;
	}
	public synchronized void recordFromClient(byte[] theData) {
		int anIndex = getFromClient().size() + getToClient().size();
		System.out.println(anIndex + ":" + theData.length);
		VNCDataCommand aCommand = new VNCDataCommand(0,theData);
		getFromClient().add(theData);
	}
	public synchronized void recordToClient(byte[] theData) {
		int anIndex = getFromClient().size() + getToClient().size();
		System.err.println("	" + anIndex + ":" + theData.length);
		VNCDataCommand aCommand = new VNCDataCommand(0,theData);
		getToClient().add(theData);
	}
	public void fromClient(byte[] theData) {
		recordFromClient(theData);
	}
	public void save(String aFileName, byte[] theData, int aStart, int anEnd) {
			try {
				byte[] theBytes = new byte[anEnd - aStart];
				System.arraycopy(theData, aStart, theBytes,0,anEnd);
				FileOutputStream aFOS = new FileOutputStream(aFileName);
				aFOS.write(theData);
				aFOS.close();
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
	}
	public void toClient(byte[] theData) {
		recordToClient(theData);
	}
	
}
