/*
 * Simple Open Pixel Control client for Processing,
 * designed to sample each LED's color from some point on the canvas.
 *
 * Micah Elizabeth Scott, 2013
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
  int universe;

  int[][] pixelLocations;
  byte[] packetData;
  byte firmwareConfig;
  String colorCorrection;
  boolean enableShowLocations;

  ArtnetPixels(PApplet parent, String host, boolean showLocations)
  {
    this.host = host;
    
    this.artnet = new ArtNetClient(new ArtNetBuffer(), 6454, 6454);
    artnet.start();
    this.enableShowLocations = showLocations;
    parent.registerMethod("draw", this);
  }

  // Set the location of a single LED
  void led(int universe, int index, int x, int y)  
  {
    // For convenience, automatically grow the pixelLocations array. We do want this to be an array,
    // instead of a HashMap, to keep draw() as fast as it can be.
    if (pixelLocations == null) {
      pixelLocations = new int[index + 1];
    } else if (index >= pixelLocations.length) {
      pixelLocations = Arrays.copyOf(pixelLocations, index + 1);
    }

    pixelLocations[index] = x + width * y;
  }
  
  // Set the location of several LEDs arranged in a strip.
  // Angle is in radians, measured clockwise from +X.
  // (x,y) is the center of the strip.
  void ledStrip(int universe, int index, int count, float x, float y, float spacing, float angle, boolean reversed)
  {
    float s = sin(angle);
    float c = cos(angle);
    for (int i = 0; i < count; i++) {
      led(universe, 
        reversed ? (index + count - 1 - i) : (index + i),
        (int)(x + (i - (count-1)/2.0) * spacing * c + 0.5),
        (int)(y + (i - (count-1)/2.0) * spacing * s + 0.5));
    }
  }
  
  /**
   *
   * Set the location of several LEDs arranged in a ray, starting from (x,y).
   * index is the index of the first LED.
   * count is the number of LEDs in the ray.
   * offset is the distance from (x,y) in pixels of the first LED in the ray.
   * spacing is the distance in pixels between each LED.
   * Angle is in radians, measured clockwise from +X.
   **/
  void ledRay(int universe, int index, int count, float x, float y, float offset, float spacing, float angle)
  {
    float s = sin(angle);
    float c = cos(angle);
    for (int i = 0; i < count; i++) {
      led(
        universe,
        (index + i),
        (int)(x + c * (offset + i * spacing)),
        (int)(y + s * (offset + i * spacing))
      );
    }
  }
   /**
   * Angle is in radians, measured clockwise from +X.
   **/
  void ledRayLayout(int universe, int index, int ray, LayoutLoader layout, int ledCount)
  {
    int rayOffset = ray * ledCount;
    for (int i = 0; i < ledCount; i++) {
      Coordinate targetCoord = layout.points.get(rayOffset + i);
      led(
        universe,
        (index + i),
        (int) targetCoord.x,
        (int) targetCoord.z
      );
    }
  }

  // Set the locations of a ring of LEDs. The center of the ring is at (x, y),
  // with "radius" pixels between the center and each LED. The first LED is at
  // the indicated angle, in radians, measured clockwise from +X.
  void ledRing(int universe, int index, int count, float x, float y, float radius, float angle)
  {
    for (int i = 0; i < count; i++) {
      float a = angle + i * 2 * PI / count;
      led(universe, index + i, (int)(x - radius * cos(a) + 0.5),
        (int)(y - radius * sin(a) + 0.5));
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
  
  // Enable or disable dithering. Dithering avoids the "stair-stepping" artifact and increases color
  // resolution by quickly jittering between adjacent 8-bit brightness levels about 400 times a second.
  // Dithering is on by default.
  void setDithering(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x01;
    else
      firmwareConfig |= 0x01;
    sendFirmwareConfigPacket();
  }

  // Enable or disable frame interpolation. Interpolation automatically blends between consecutive frames
  // in hardware, and it does so with 16-bit per channel resolution. Combined with dithering, this helps make
  // fades very smooth. Interpolation is on by default.
  void setInterpolation(boolean enabled)
  {
    if (enabled)
      firmwareConfig &= ~0x02;
    else
      firmwareConfig |= 0x02;
    sendFirmwareConfigPacket();
  }

  // Put the Fadecandy onboard LED under automatic control. It blinks any time the firmware processes a packet.
  // This is the default configuration for the LED.
  void statusLedAuto()
  {
    firmwareConfig &= 0x0C;
    sendFirmwareConfigPacket();
  }    

  // Manually turn the Fadecandy onboard LED on or off. This disables automatic LED control.
  void setStatusLed(boolean on)
  {
    firmwareConfig |= 0x04;   // Manual LED control
    if (on)
      firmwareConfig |= 0x08;
    else
      firmwareConfig &= ~0x08;
    sendFirmwareConfigPacket();
  } 

  // Set the color correction parameters
  void setColorCorrection(float gamma, float red, float green, float blue)
  {
    colorCorrection = "{ \"gamma\": " + gamma + ", \"whitepoint\": [" + red + "," + green + "," + blue + "]}";
    sendColorCorrectionPacket();
  }
  
  // Set custom color correction parameters from a string
  void setColorCorrection(String s)
  {
    colorCorrection = s;
    sendColorCorrectionPacket();
  }

  // Send a packet with the current firmware configuration settings
  void sendFirmwareConfigPacket()
  {
  }

  // Send a packet with the current color correction settings
  void sendColorCorrectionPacket()
  {
  }

  // Automatically called at the end of each draw().
  // This handles the automatic Pixel to LED mapping.
  // If you aren't using that mapping, this function has no effect.
  // In that case, you can call setPixelCount(), setPixel(), and writePixels()
  // separately.
  void draw()
  {
    if (pixelLocations == null) {
      // No pixels defined yet
      return;
    }
    //if (output == null) {
    //  return;
    //}

    int numPixels = pixelLocations.length;

    setPixelCount(numPixels);
    loadPixels();
    int ledAddress = 0;
    for (int i = 0; i < numPixels; i++) {
      int pixelLocation = pixelLocations[i];
      int pixel = pixels[pixelLocation];

      packetData[ledAddress] = (byte)(pixel >> 16);
      packetData[ledAddress + 1] = (byte)(pixel >> 8);
      packetData[ledAddress + 2] = (byte)pixel;
      ledAddress += 3;

      if (enableShowLocations) {
        pixels[pixelLocation] = 0xFFFFFF ^ pixel;
      }
    }

    writePixels();

    if (enableShowLocations) {
      updatePixels();
    }
  }
  
  // Change the number of pixels in our output packet.
  // This is normally not needed; the output packet is automatically sized
  // by draw() and by setPixel().
  void setPixelCount(int numPixels)
  {
    int numBytes = 3 * numPixels;
    if (packetData == null || packetData.length != numBytes) {
      // Set up our packet buffer
      packetData = new byte[numBytes];
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

      // This should execute once for every 150 pixels
      int packetLength = packetData.length;
      //println("packet length is " + packetLength);
      int universe = 1;
      for (int i = 0; i < packetLength; i+= 450) {
        
       int pixelBytes = Math.min(packetLength - i, 510);
       //println("pixelBytes " + pixelBytes);
      
       byte[] pixelArr = subset(packetData, i, pixelBytes);
       byte[] pad = new byte[512 - pixelBytes];
       
       byte[] dmxData = concat(pixelArr, pad);

       // send dmx to localhost
       /**
        * Send a dmx package to a specific unicast address.
        * @param address Receiver address.
        * @param subnet Receiving subnet.
        * @param universe Receiving universe.
        * @param dmxData Dmx data to send.
        */
        //println("sending " + dmxData);
        //println("sending size" + dmxData.length);
        //println("sending byte " + int(dmxData[181]));
        //println("sending byte " + int(dmxData[21]));
        //println("sending byte " + int(dmxData[301]));
        //println("sending byte " + int(dmxData[401]));

       //artnet.broadcastDmx(24, this.universe, dmxData);
       artnet.unicastDmx(this.host, 0, universe, dmxData);
       universe++;
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
          //socket = new Socket(host, port);
          //socket.setTcpNoDelay(true);
          //pending = socket.getOutputStream(); // Avoid race condition...
          artnet = new ArtNetClient();
          artnet.start();
          println("Connected to ArtNet client");
          //sendColorCorrectionPacket();        // These write to 'pending'
          //sendFirmwareConfigPacket();         // rather than 'output' before
          //output = pending;                   // rest of code given access.
          // pending not set null, more config packets are OK!
        //} catch (ConnectException e) {
        //  dispose();
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
