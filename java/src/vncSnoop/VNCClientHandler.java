package vncSnoop;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.net.UnknownHostException;




public class VNCClientHandler {

	protected Socket socket;
	protected Socket vncSocket;
	protected InputStream is;
	protected OutputStream os;
	protected InputStream vncis;
	protected OutputStream vncos;
	protected VNCProxy container;
	protected Thread thread;
	public Thread getVncThread() {
		if (vncThread == null) setVncThread(getDefaultVNCThread());
		return vncThread;
	}
	public void setVncThread(Thread vncThread) {
		this.vncThread = vncThread;
	}
	protected Thread vncThread;
	protected boolean running = false;
	protected int counter;
	
	public VNCClientHandler(VNCProxy aContainer, Socket aSocket) {
		super();
		setContainer(aContainer);
		setSocket(aSocket);
	}

	public Socket getSocket() {
		return socket;
	}
	public void setSocket(Socket socket) {
		this.socket = socket;
	}
	public void start() {
		getThread();
		try {Thread.sleep(1000);} catch (Exception ex) {}
		getVncThread();
	}
	public VNCProxy getContainer() {
		return container;
	}
	public void setContainer(VNCProxy container) {
		this.container = container;
	}
	public Thread getThread() {
		if (thread == null) setThread(getDefaultThread());
		return thread;
	}
	protected Thread getDefaultThread() {
		final VNCClientHandler self = this;
		Runnable aRunnable = new Runnable() {
			public void run() {
				self.loop();
			}
		};
		Thread aThread = new Thread(aRunnable);
		aThread.start();
		return aThread;
	}
	protected Thread getDefaultVNCThread() {
		final VNCClientHandler self = this;
		Runnable aRunnable = new Runnable() {
			public void run() {
				self.vncLoop();
			}
		};
		Thread aThread = new Thread(aRunnable);
		aThread.start();
		return aThread;
	}
	protected void loop() {
		running = true;
		while (running) iterate();
	}
	protected void vncLoop() {
		running = true;
		while (running) vncIterate();
	}
	protected void iterate() {
		try {
			InputStream anIs = getIs();
			OutputStream aVncos = getVncos();
			
			int aByte = anIs.read();
			int aClientSize = anIs.available();
			
			byte[] aClientPayload = new byte[1 + aClientSize];
			aClientPayload[0] = (byte)aByte;
				
			anIs.read(aClientPayload,1,aClientSize);
			fromClient(aClientPayload);
			aVncos.write(aClientPayload);
			aVncos.flush();
		//	System.out.print(aClientSize);
		//	counter++;
		//	if ((counter % 20) == 0) System.out.println();
			
			} catch (IOException e) {
			e.printStackTrace();
			System.out.println("shutting down socket due to error");
			running = false;
		}
		
		
	}
	public void toClient(byte[] theData) {
		
	}

	public void fromClient(byte[] theData) {
		
	}
	protected void vncIterate() {
		try {
			InputStream anIs = getVncis();
			OutputStream aVncos = getOs();
			
			int aByte = anIs.read();
			int aClientSize = anIs.available();
			
			byte[] aClientPayload = new byte[1 + aClientSize];
			aClientPayload[0] = (byte)aByte;
			
			anIs.read(aClientPayload, 1, aClientSize);
			toClient(aClientPayload);
			aVncos.write(aClientPayload);
			aVncos.flush();
			//System.err.print(aClientSize);
			counter++;
		//	if ((counter % 20) == 0) System.out.println();
			} catch (IOException e) {
			e.printStackTrace();
			System.out.println("shutting down socket due to error");
			running = false;
		}
		
		
	}
	public void setThread(Thread thread) {
		this.thread = thread;
	}
	public Socket getVncSocket() {
		if (vncSocket == null) setVncSocket(getDefaultVNCSocket());
		return vncSocket;
	}
	protected Socket getDefaultVNCSocket() {
		// let's make the proxy connection through to the Real VNC server.
		try {
			String aHost = getContainer().getVncHost();
			int aPort = getContainer().getVncPort();
			Socket aSocket = new Socket(aHost, aPort);
			return aSocket;
		} catch (UnknownHostException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
	public void setVncSocket(Socket vncSocket) {
		this.vncSocket = vncSocket;
	}
	public InputStream getIs() {
		if (is == null) setIs(getDefaultIs());
		return is;
	}
	protected InputStream getDefaultIs() {
		try {
			InputStream aStream = getSocket().getInputStream();
			return aStream;
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
	protected InputStream getDefaultVncis() {
		try {
			InputStream aStream = getVncSocket().getInputStream();
			return aStream;
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
	public void setIs(InputStream is) {
		this.is = is;
	}
	public OutputStream getOs() {
		if (os == null) setOs(getDefaultOs());
		return os;
	}
	protected OutputStream getDefaultOs() {
		try {
			OutputStream aOS = getSocket().getOutputStream();
			return aOS;
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
	protected OutputStream getDefaultVncos() {
		try {
			OutputStream aOS = getVncSocket().getOutputStream();
			return aOS;
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
	public void setOs(OutputStream os) {
		this.os = os;
	}
	public InputStream getVncis() {
		if (vncis == null) setVncis(getDefaultVncis());
		return vncis;
	}
	public void setVncis(InputStream vncis) {
		this.vncis = vncis;
	}
	public OutputStream getVncos() {
		if (vncos == null) setVncos(getDefaultVncos());
		return vncos;
	}
	public void setVncos(OutputStream vncos) {
		this.vncos = vncos;
	}
}
