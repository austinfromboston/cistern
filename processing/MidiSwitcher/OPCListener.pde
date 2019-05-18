import java.net.*;
import java.util.Arrays;
import java.io.*;



public class OPCListener implements Runnable {
  Thread thread;
  ServerSocket pendingSocket;
  Socket socket;
  InputStream input;
  //BufferedReader input;
  //DatagramPacket input;
  //OutputStream output, pending;
  int port;
  int ledCount;
  public int[] opcColors;

  static final int HEADER_SIZE=4;
  static final int PAINT_COMMAND=0;
  int[] pixelLocations;
  byte[] packetData;
  byte firmwareConfig;
  String colorCorrection;
  ArrayList<String> dataReceived;
  int frameSize;
  int frameIndex;
  long deadConnectionStartTime;
  
  OPCListener(int port, int ledCount)
  {
    this.port = port;
    this.ledCount = ledCount;
    thread = new Thread(this);
    thread.start();
    //parent.registerMethod("draw", this);
    this.frameSize = ledCount * 3;
    this.opcColors = new int[this.frameSize];
    this.frameIndex = 0;
    this.deadConnectionStartTime = 0;
  }
  

  void dispose()
  {
    // Destroy the socket. Called internally when we've disconnected.
    // (Thread continues to run)
    if (input != null) {
    }
    try{
    pendingSocket.close();
    input.close();
    socket.close();
    } catch (IOException e){
    } catch (NullPointerException e){
    }
    
    //socket = null;
    input = null;
  }
  void debugFrame() {
    if (input != null) {
      try {
        //println(String.format("avaiable bytes %s", input.available()));
        if(input.available() >= HEADER_SIZE) {
          byte[] headerBuf = new byte[HEADER_SIZE];
          input.read(headerBuf);
          int channel = headerBuf[0];
          int command = headerBuf[1];
          
          //int high = (headerBuf[2]<<8) & 0xFF;
          //int low = (headerBuf[3] & 0xFF);
          int high = (headerBuf[2] + 127) * 256;
          int low = (headerBuf[3] + 127);
          int declaredLength = high + low;
          println("raw header: ", headerBuf[0], headerBuf[1], headerBuf[2], headerBuf[3]);
          println("header: ", channel, command, high, low, declaredLength);
          byte[] dataBuf = new byte[declaredLength];
          input.read(dataBuf);
          for(int i = 0; i + 3 < dataBuf.length; i = i + 3) {
           // println(String.format("data: [%d] [%d,%d,%d]", i, dataBuf[i] & 0xFF, dataBuf[i+1] & 0xFF, dataBuf[i+2] & 0xFF));
          }
          input.read(dataBuf);
          for(int i = 0; i + 3 < dataBuf.length; i = i + 3) {
           // println(String.format("data: [%d] [%d,%d,%d]", i + dataBuf.length, dataBuf[i] & 0xFF, dataBuf[i+1] & 0xFF, dataBuf[i+2] & 0xFF));
          }
          
        }
      } catch(IOException e) {
        println("error reading input");
      }
    }
  }
  
  void readColors() throws IOException {
    if (input != null) {
      //try {
        if(input.available() >= HEADER_SIZE) {
          byte[] headerBuf = new byte[HEADER_SIZE];
          input.read(headerBuf);
          //int channel = headerBuf(0);
          int command = headerBuf[1];
          
          int high = (((int) headerBuf[2]<<8)) & 0xFF;
          int low = (headerBuf[3] & 0xFF);
          //int declaredLength = high + low;
          int declaredLength = frameSize;
          //println("expecting length", headerBuf[2], headerBuf[3], high, low, declaredLength);
          //println("avaiable bytes", input.available());
          byte[] dataBuf = new byte[declaredLength];

          if(command == PAINT_COMMAND && declaredLength > 0) {
            // skip forward if multiple frames are available
            if(input.available() >= (this.frameSize * 2 + HEADER_SIZE)) {
              input.skip(declaredLength);
            } else {
              input.read(dataBuf);
              if (declaredLength > 0) { //setting pixel values
                for(int i = 0; i < dataBuf.length; i++) {
                  int targetIndex = (i + this.frameIndex) % this.frameSize;
                  this.opcColors[targetIndex] = (int) dataBuf[i] & 0xFF;
                }
              }
            }
            this.frameIndex = (this.frameIndex + declaredLength) % this.frameSize;
          }
          this.deadConnectionStartTime = 0;
        } else {
          long currentTime = System.currentTimeMillis();
          if(this.deadConnectionStartTime == 0) {
            this.deadConnectionStartTime = currentTime;
          } else if (currentTime > (this.deadConnectionStartTime  + 5*1000)) {
            this.deadConnectionStartTime = 0;
            throw new EOFException();
          }
        }
    }
  }
  
  public void run()
  {
    // Thread tests server connection periodically, attempts reconnection.
    // Important for OPC arrays; faster startup, client continues
    // to run smoothly when mobile servers go in and out of range.
    for(;;) {
        println("at very beginning of inifinte loop");
      if(input == null) { // No OPC connection?
        try {              // Make one!
          pendingSocket = new ServerSocket(port);
          //socket.setTcpNoDelay(true);
          //input = new BufferedReader(new InputStreamReader(socket.getInputStream()));
          //input = socket.getInputStream(); // Avoid race condition...
          socket = pendingSocket.accept();
          println("Connected to OPC server");
          input = socket.getInputStream();
          //sendColorCorrectionPacket();        // These write to 'pending'
          //sendFirmwareConfigPacket();         // rather than 'output' before
          // pending not set null, more config packets are OK!
          for(;;) {
            this.readColors();
          }
          //this.debugFrame();
        } catch (ConnectException e) {
          dispose();
        } catch (IOException  e) {
          dispose();
        }
      } else {
        //this.debugFrame();
        //this.readColors();
      }

      // Pause thread to avoid massive CPU load
      try {
        Thread.sleep(500);
      }
      catch(InterruptedException e) {
      }
    }
  }
}
