package vncSnoop;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.List;


public class VNCProxy {

	protected static VNCProxy current;
	protected String vncHost;
	protected int vncPort;
	protected List clients;
	protected ServerSocket serverSocket;
	protected boolean running = false;
	
	public static void main(String[] args) {
		VNCProxy.init("adsrv080",5900);
	}
	
	protected VNCProxy(String aHost, int aPort) {
		super();
		setVncHost(aHost);
		setVncPort(aPort);
	}

	public static VNCProxy getCurrent() {
		return current;
	}
	protected static void init(String aVNCHost, int aVNCPort) {
		VNCProxy aProxy = new VNCProxy(aVNCHost, aVNCPort);
		setCurrent(aProxy);
		aProxy.start();
	}
	protected void start() {
		ServerSocket aSS = getServerSocket();
		running = true;
		System.out.println("VNCProxy 1.0 started.");
		while (running)
			{
				try {
					Socket aSocket = aSS.accept();
					VNCClientHandler aHandler = newClient(aSocket);
					aHandler.start();
				} catch (IOException e) {}
			}
		System.out.println("VNCProxy stopped.");
	}
	protected static void setCurrent(VNCProxy current) {
		VNCProxy.current = current;
	}
	public String getVncHost() {
		return vncHost;
	}
	public void setVncHost(String vncHost) {
		this.vncHost = vncHost;
	}
	public int getVncPort() {
		return vncPort;
	}
	public void setVncPort(int vncPort) {
		this.vncPort = vncPort;
	}
	public List getClients() {
		if (clients == null) setClients(new ArrayList());
		return clients;
	}
	public VNCClientHandler newClient(Socket aSocket) {
		//VNCClientHandler aHandler = new VNCClientHandler(this, aSocket);
		VNCClientHandler aHandler = new VNCHandlerRecorder(this, aSocket);
		getClients().add(aHandler);
		return aHandler;
	}
	public void setClients(List clients) {
		this.clients = clients;
	}
	public ServerSocket getServerSocket() {
		if (serverSocket == null) setServerSocket(getDefaultServerSocket());
		return serverSocket;
	}
	protected ServerSocket getDefaultServerSocket() {
		try {
			int aPort = getVncPort();
			ServerSocket aSocket = new ServerSocket(aPort);
			aSocket.setSoTimeout(500); // so it will check on whether to shut down or not
			return aSocket;
		} catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
	public void setServerSocket(ServerSocket serverSocket) {
		this.serverSocket = serverSocket;
	}
}
