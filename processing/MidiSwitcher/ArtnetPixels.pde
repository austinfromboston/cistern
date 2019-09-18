/*
 * Arnet based Control client for Processing,
 * designed to sample each LED's color from some point on the canvas.
 *
 * Micah Elizabeth Scott, 2013 (for Open Pixel Control)
 * Mike Stevenson, 2019 (for ArtNetClient)
 * This file is released into the public domain.
 */

import java.net.*;
import java.util.Arrays;
import ch.bildspur.artnet.*;

public class ArtnetPixels implements Runnable
{
  //Thread thread;
  Socket socket;
  ArtNetClient artnet;
  OutputStream output, pending;
  String host;
  int port;
  int universes;
  int pixelsPerUni;

  int[][] pixelLocations;
  byte[][] packetData;
  byte firmwareConfig;
  String colorCorrection;
  boolean enableShowLocations;

  ArtnetPixels(PApplet parent, String host, boolean showLocations, int universes, int pixelsPerUni)
  {
    if (pixelsPerUni > 170) {
      throw new IllegalArgumentException(
        "Universe support 512 bytes for up to  170 pixels. Layout has " + pixelsPerUni + " pixels per universe.");
    }
    
    this.host = host;
    this.artnet = new ArtNetClient(new ArtNetBuffer(), 6454, 6454);
    artnet.start();
    
    this.enableShowLocations = showLocations;
    
    
    this.universes = universes;
    this.pixelsPerUni = pixelsPerUni;
    this.pixelLocations = new int[universes][pixelsPerUni];
    this.packetData = new byte[universes][pixelsPerUni * 3];
    
    parent.registerMethod("draw", this);
  }

  // Set the location of a single LED
  void addPixel(int universe, int index, int x, int y)  
  {
    pixelLocations[universe][index] = x + width * y;
  }
  
  

   /**
   * Angle is in radians, measured clockwise from +X.
   **/
  void pixelLayout(LayoutLoader layout)
  {
    for (int i = 0; i < this.universes; i++) {
      for (int j = 0; j < this.pixelsPerUni; j++) {
        
        int targetPixel = (i * this.pixelsPerUni) + j;
        Coordinate targetCoord = layout.points.get(targetPixel);
        
        addPixel(i,j,(int) targetCoord.x,(int) targetCoord.z);
      }
    }
  }


  // Should the pixel sampling locations be visible? This helps with debugging.
  // Showing locations is enabled by default. You might need to disable it if our drawing
  // is interfering with your processing sketch, or if you'd simply like the screen to be
  // less cluttered.
  void showLocations(boolean enabled)
  {
    enableShowLocations = enabled;
  }

  // Automatically called at the end of each draw().
  // This handles the automatic Pixel to LED mapping.
  // If you aren't using that mapping, this function has no effect.
  // In that case, you can call setPixelCount(), setPixel(), and writePixels()
  // separately.
  void draw()
  {

    //int numPixels = pixelLocations.length;

    loadPixels();
    //println("pixels per Uni ", this.pixelsPerUni);

    for (int i = 0; i < this.universes; i++) {
      int ledAddress = 0;
      for (int j = 0; j < this.pixelsPerUni; j++) {
        int pixelLocation = pixelLocations[i][j];
        int pixel = pixels[pixelLocation];
  
        packetData[i][ledAddress] = (byte)(pixel >> 16);
        packetData[i][ledAddress + 1] = (byte)(pixel >> 8);
        packetData[i][ledAddress + 2] = (byte)pixel;
        ledAddress += 3;
  
        if (enableShowLocations) {
          pixels[pixelLocation] = 0xFFFFFF ^ pixel;
        }
      }
    }

    writePixels();

    if (enableShowLocations) {
      updatePixels();
    }
  }
  

  

  // Transmit our current buffer of pixel values to the OPC server. This is handled
  // automatically in draw() if any pixels are mapped to the screen, but if you haven't
  // mapped any pixels to the screen you'll want to call this directly.
  void writePixels()
  {
    if (packetData == null || packetData.length == 0) {
      // No pixel buffer
      return;
    }

    if (artnet == null) {
      return;
    }

    
    try {

      for (int i = 0; i < this.universes; i++) {
       
           int universe = i + 1;
           println("Universe is packet is " + universe );
           byte[] pixelBytes = packetData[i];
           println("Length of the pixelBytes packet is " + pixelBytes.length );
           int padLen = 512 - (3 * this.pixelsPerUni);
           byte[] pad = new byte[padLen];
           
           byte[] dmxData = concat(pixelBytes, pad);
           println("Length of the dmxData packet is " + dmxData.length );
           
           artnet.unicastDmx(this.host, 0, universe, dmxData);
      
      }
    
    } catch (Exception e) {
      dispose();
    }
  }

  void dispose()
  {
    // Destroy the socket. Called internally when we've disconnected.
    // (Thread continues to run)
    if (output != null) {
      println("Disconnected from OPC server");
    }
    socket = null;
    output = pending = null;
  }

  public void run()
  {
    // Thread tests server connection periodically, attempts reconnection.
    // Important for OPC arrays; faster startup, client continues
    // to run smoothly when mobile servers go in and out of range.
    for(;;) {

      if(artnet == null) { // No OPC connection?
        try {              // Make one!
 
          artnet = new ArtNetClient();
          artnet.start();
          println("Connected to ArtNet client");

        } catch (Exception e) {
          dispose();
        }
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
