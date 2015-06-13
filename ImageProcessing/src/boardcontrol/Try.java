/*
 *	Author:      Gilbert Maystre
 *	Date:        May 15, 2015
 */

package boardcontrol;

import processing.core.PApplet; import processing.core.PImage; import processing.video.*;

@SuppressWarnings("serial")
public class Try extends PApplet {
    Capture cam;
    PImage img;
    
//    Movie cam;
    public void setup() {
        size(640, 360);
        String[] cameras = Capture.list(); if (cameras.length == 0) {
            println("There are no cameras available for capture.");
            exit(); } else {
                println("Available cameras:");
                for (int i = 0; i < cameras.length; i++) {
                    println(cameras[i]);
                }
                cam = new Capture(this, cameras[4]);
                cam.start();
                
//                cam = new Movie(this, "/testvideo.mp4");
//                cam.loop();
            }
    }
    public void draw() {
        if (cam.available() == true) {
            cam.read();
        }
        img = cam.get();
        image(img, 0, 0);
    }
}