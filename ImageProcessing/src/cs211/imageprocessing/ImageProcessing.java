package cs211.imageprocessing;

import java.util.List;

import processing.core.PApplet;
import processing.core.PImage;
import processing.video.Capture;

@SuppressWarnings("serial")
public class ImageProcessing extends PApplet {
    Capture cam;
    PImage settingImg;
    PImage flowImg;

    private final Week8 week8;

    private int lowHue = 96;
    private int highHue = 129;
    private int lowBr = 53;
    private int hiBr = 121;
    private int minSat = 91;
    private int nbVote = 174;

    private int selectedImage = 0;
    private boolean modify = true;
    private boolean start = true;
    private boolean set = false;
    private boolean normal = false;

    /**
     * TO THE CORRECTOR : set selectedImage accordingly, enable modify to play with the parameters.
     */

    public ImageProcessing(){
        week8 = new Week8(this);        
    }

    public void setup() {
        size(1080, 720);

        String[] cameras = Capture.list(); 
        if (cameras.length == 0){
            println("There are no cameras available for capture.");
            exit();
        } 
        else{
            println("Available cameras:");
            for (int i = 0; i < cameras.length; i++) {
                println((i == 1)? "choosed : " : "" +cameras[i]);
            }
            cam = new Capture(this, cameras[1]);
            cam.start();
        }
    }

    public void draw() {
        if(set){
            PImage colors = week8.hueThreshold(settingImg, lowHue, highHue, lowBr, hiBr, minSat);
            PImage blurred = week8.convolute(colors, Week8.gaussian, Week8.gaussianWeight);
            PImage tresholded = week8.binThreshold(blurred, 125);
            PImage sobeliz = week8.sobel(tresholded);
            
            image(sobeliz, 0, 0);

            Week9 current = new Week9(this, sobeliz);
            List<Integer> lines = current.optimizeWithNeighboorsLines(nbVote, 10, 6);
            current.drawLines(lines);
            current.getAndDrawIntersections(current.accToParam(lines)); 
            
            //print the best quad
            QuadGraph qg = new QuadGraph(current.accToParam(lines), 1080, 720, this);
            //qg.drawQuads();
            qg.drawQuad(qg.selectBestQuad(0, Integer.MAX_VALUE));
        }
        else{
            //start or normal mode
            if (cam.available() == true) {
                cam.read();
            }
            flowImg = cam.get();
            image(flowImg, 0, 0);
            
            if(normal){
                PImage colors = week8.hueThreshold(flowImg, lowHue, highHue, lowBr, hiBr, minSat);
                PImage blurred = week8.convolute(colors, Week8.gaussian, Week8.gaussianWeight);
                PImage tresholded = week8.binThreshold(blurred, 125);
                PImage sobeliz = week8.sobel(tresholded);

                //print the lines
                Week9 current = new Week9(this, sobeliz);
                List<Integer> lines = current.optimizeWithNeighboorsLines(nbVote, 10, 6);
//                current.drawLines(lines);
//
//                //print the intersection found
//                current.getAndDrawIntersections(current.accToParam(lines)); 
                
                
                //print the best quad
                QuadGraph qg = new QuadGraph(current.accToParam(lines), 1080, 720, this);
                //qg.drawQuads();
                qg.drawQuad(qg.selectBestQuad(0, Integer.MAX_VALUE));
            }
        }

        //here are shown explicitly the method proposed in the pdf
//        PImage colors = week8.hueThreshold(img, lowHue, highHue, lowBr, hiBr, minSat);
//        PImage blurred = week8.convolute(colors, Week8.gaussian, Week8.gaussianWeight);
//        PImage tresholded = week8.binThreshold(blurred, 125);
//        PImage sobeliz = week8.sobel(tresholded);
//
//        //print the original image
//        //image(img, 0, 0);
//
//        image(sobeliz, 0, 0);
//
//        //print the lines
//        Week9 current = new Week9(this, sobeliz);
//        List<Integer> lines = current.optimizeWithNeighboorsLines(nbVote, 10, 4);
//        current.drawLines(lines);
//
//        //print the intersection found
//        current.getAndDrawIntersections(current.accToParam(lines));  

        //print the best quad
        //QuadGraph qg = new QuadGraph(current.accToParam(lines), 800, 600, this);
        //qg.drawQuads();
        //qg.drawQuad(qg.selectBestQuad(700*700, 300*300));

        //print the accumulator
        //image(current.paramSpace(600, 600), 800, 0);

        //print the sobelized image

    }


    public void keyPressed(){
        if(modify){
            if (key == CODED) {
                if(keyCode == UP){
                    highHue = Math.min(255,  highHue + 1);
                }
                else if(keyCode == DOWN){
                    highHue = Math.max(0, highHue - 1);
                }
                else if(keyCode == LEFT){
                    lowHue = Math.max(0, lowHue - 1);
                }
                else if(keyCode == RIGHT){
                    lowHue = Math.min(255, lowHue + 1);
                }    
            }

            if(key == 'q'){
                lowBr = Math.max(0, lowBr - 1);
            }
            else if(key == 'w'){
                lowBr = Math.min(255, lowBr + 1);
            }
            else if(key == 'a'){
                hiBr = Math.max(0, hiBr - 1);
            }
            else if(key == 's'){
                hiBr = Math.min(255, hiBr + 1);
            }
            else if(key == 'y'){
                minSat = Math.max(0, minSat - 1);
            }
            else if(key == 'x'){
                minSat = Math.min(255, minSat + 1);
            }
            else if(key == 'e'){
                nbVote = Math.max(0, nbVote - 1);
            }
            else if(key == 'r'){
                nbVote = nbVote + 1;
            }
            else if(key == 'o'){
                selectedImage = Math.max(0, selectedImage - 1);
            }
            else if(key == 'p'){
                selectedImage = Math.min(3, selectedImage + 1);
            }
            else if(key == '\n'){
                if(start){
                    settingImg = flowImg;
                    start = false;
                    set = true;
                }
                else if(set){
                    set = false;
                    normal = true;
                }
            }

            System.out.println("lowHue: "+lowHue+" highHue: "+highHue+" lowBr: "+lowBr+" highBr: "+hiBr+" minSat: "+minSat+" nbVote: "+nbVote+" selectedImage:"+selectedImage); 

            redraw();
        }

    }    
}