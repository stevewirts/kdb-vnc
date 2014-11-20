package vnc;

//import java.io.IOException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import k4_1.K4C;


public class KDBVNCHandler {

	protected Socket socket;
	protected K4C q;
	protected InputStream is;
	protected OutputStream os;
	protected boolean running;
	protected Thread qListeningThread;
	
	protected void initializeConnections(String aKDBHost, int aKDBPort) {
		
		KDBVNC aContainer = KDBVNC.getCurrent();
		try 
			{
				// q connection
				q = new K4C(aKDBHost, aKDBPort);
				
				// vnc streams
				os = socket.getOutputStream();
				is = socket.getInputStream();
			}
		catch (Exception e) 
			{
				System.out.println("couldn't initialize connections");
			}
	}


	public void startASnycQListeningThread() {
		Runnable aRunnable = new Runnable() {
			public void run() {
				qListeningLoop();
			}
		};
		Thread aThread = new Thread(aRunnable);
		aThread.start();
	}

	


	protected void vncListeningLoop() {
		while (isRunning())
			{
				byte[] someData = readVNC();
				byte[] aResult = k(".vnc.fromVNC", someData);
				sendToViewer(aResult);
			}
	}
	protected void qListeningLoop() {	
		
		// this polling goofeyness is to allow I socket in Q
		// because java sockets are blocking, I have to poll to see if any messages
		// have arrived, I can't just yield, because java will use all the cpu for polling
		// I'll poll 3 times a second, if any data comes in, then I'll poll 20 times a second
		// until there is no data for ~ten polls, then the poll time slowly goes back to
		// 3 times a second
		
		long wait = 333;
		try {
				while (isRunning())
					{ 
						while (!q.hasAMessageWaiting()) try { Thread.sleep(wait); wait = Math.min(333,wait + 5); } catch (Exception ex) {};
						wait = 5;
						
						// just incase we're interrupted because the connection was closed.
						if (!q.isConnected())
						{
							stop();
							return;
						}
						Object aResult = q.k();
						if (aResult instanceof byte[])
							{
								byte[] someBytes = (byte[])aResult;
								sendToViewer(someBytes);
							}
					}
			} 
		catch (Exception e) 
			{
				stop();
			}
	}
	
	protected void startSyncVNCListeningThread() {
		Runnable aRunnable = new Runnable() {
			public void run() {
				vncListeningLoop();
			}
		};
		Thread aThread = new Thread(aRunnable);
		aThread.start();
	}
	protected void syncHandShake() {
		try {
			byte[] vncServerVersion = k(".vnc.version");
			byte[] aFirstResult = vncQuery(vncServerVersion);
			byte[] authenticationType = k(".vnc.authType");
			byte[] aSecondResult = vncQuery(authenticationType);
			byte[] aSucceed = k(".vnc.authOk");
			byte[] aThirdResult = vncQuery(aSucceed);
			byte[] initializeMessage = k(".vnc.clientInit");
			byte[] aResponse = vncQuery(initializeMessage);  // got a big pile of junk back here /just ignore it for now
			byte[] theColorMap = k(".vnc.colorMap");
			sendToViewer(theColorMap);
			byte[] firstUpdate = k(".vnc.initViewer[]"); 
			aResponse = vncQuery(firstUpdate);
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
	protected void syncHandShake_01() {
		try {
			byte[] vncServerVersion = k(".vnc.version");
			byte[] aFirstResult = vncQuery(vncServerVersion);
			byte[] authenticationType = k(".vnc.authType");
			byte[] aSecondResult = vncQuery(authenticationType);
			byte[] aSucceed = k(".vnc.authOk");
			byte[] aThirdResult = vncQuery(aSucceed);
			byte[] initializeMessage = k(".vnc.clientInit");
			byte[] aResponse = vncQuery(initializeMessage);  // got a big pile of junk back here /just ignore it for now
			byte[] theColorMap = k(".vnc.colorMap");
		//	byte[] aCMResponse = vncQuery(theColorMap);
			byte[] aCMResponse = vncQuery(theColorMap);
			byte[] firstUpdate = k(".vnc.initViewer[]"); 
			aResponse = vncQuery(firstUpdate);
			byte[] aQResponse = k(".vnc.fromVNC",aResponse);
			sendToViewer(aQResponse);
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
	public byte[] k(String aQuery) {
		try
			{
				byte[] aResult = (byte[])q.k(aQuery);
				return aResult;
			}
		catch(Exception ex)
			{
				stop();
			}
		return null;
	}
	public void ks(String aFunc, Object anArg) {
		try
			{
				q.ks(aFunc, anArg);
			}
		catch(Exception ex)
			{
				stop();
			}
	}
	public void ks(String aQuery) {
		try
			{
				q.ks(aQuery);
			}
		catch(Exception ex)
			{
				stop();
			}
	}
	public byte[] k(String aFunc, Object anArg) {
		try
			{
				Object aResult = q.k(aFunc, anArg);
				if (aResult instanceof byte[]) return (byte[])aResult;
				return null;
			}
		catch(Exception ex)
			{
				stop();
			}
		return null;
	}


	protected byte[] vncQuery(byte[] theBytes) {
		try {
			if (theBytes == null) return null;
			os.write(theBytes);
			os.flush();
			byte[] theData = readVNC();
			return theData;
		} catch (Exception e) {
			stop();
		} 
		return null;
	}
	protected void sendToViewer(byte[] theBytes) {
		if (theBytes == null || theBytes.length == 0) return;
		try {
			os.write(theBytes);
			os.flush();
		} catch (IOException e) {
			stop();
		}
	}


	protected byte[] readVNC() {
		try
			{
				byte aByte = (byte)is.read();
				if (aByte == -1)
					{
						stop();
						return null;
					}
				int aSize = is.available();
				byte[] theData = new byte[aSize + 1];
				theData[0] = aByte;
				is.read(theData,1,aSize);
				return theData;
			}
		catch (IOException e)
			{
				vncClosed();
			}
		return null;
	}
	protected void vncClosed() {
		System.out.println("a VNC client closed, shutting down handler");
		stop();
	}


	protected Thread fromKThread;





	public KDBVNCHandler(Socket aSocket) {
		super();
		socket = aSocket;
	}
	public void start(String aKDBHost, int aKDBPort) {
		initializeConnections(aKDBHost, aKDBPort);
		running = true;
		syncHandShake();
		startSyncVNCListeningThread();
		startASnycQListeningThread();
	}
	


	public boolean isRunning() {
		return KDBVNC.getCurrent().isRunning() && running;
	}
	public synchronized void stop() {
		if (!running) return;
		running = false;
		try {if (is != null) {is.close();is=null;}} catch (Exception e2) {};
		try {if (os != null) {os.close();os=null;}} catch (Exception e2) {};
		try {if (socket != null) {socket.close();socket=null;}} catch (Exception e2) {};
		
		if (q != null) 
			{
				try {q.ks(".vnc.removeHandle[]");} catch (Exception e2) {}
				try {q.close();q=null;} catch (Exception e2) {};
			}
		System.out.println("shut down handler");	
	}
	
}
