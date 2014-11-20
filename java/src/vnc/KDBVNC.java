package vnc;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketTimeoutException;


public class KDBVNC {

	protected static KDBVNC current;
	protected boolean running = false;

	public static KDBVNC getCurrent() {
		return current;
	}
	public static void start(String aKDBHost, int qPort, int vncPort) {
		KDBVNC aKV = new KDBVNC();
		KDBVNC.current = aKV;
		System.out.println("KDB NVC gateway q:" + qPort + ", vnc:" + vncPort);
		aKV.startServerSocket(aKDBHost, qPort, vncPort);
	}
	public boolean isRunning() {
		return running;
	}
	protected ServerSocket createServerSocket(int aPort) {
		try {
			ServerSocket aSS = new ServerSocket(aPort);
			aSS.setSoTimeout(500);
			return aSS;
		} catch (IOException e) {
			running = false;
			e.printStackTrace();
		}
		return null;
	}	
	public KDBVNC() {
		super();
	}
	public static void main(String[] args) {
		int qPort = 5001;
		int vncPort = 5900;
		KDBVNC.start("localhost",qPort,vncPort);
	}
	protected void startServerSocket(String aKDBHost, int aKDBPort, int aMyPort) {
		running = true;
		ServerSocket aSS = createServerSocket(aMyPort);
		while (isRunning())
			{
				try {
						Socket aSocket = aSS.accept();
						KDBVNCHandler aHandler = new KDBVNCHandler(aSocket);
						aHandler.start(aKDBHost, aKDBPort);
					}
				catch (SocketTimeoutException ste) {}
				catch (IOException e)
					{
						running = false;
						e.printStackTrace();
					}
			}
	}


	


}
