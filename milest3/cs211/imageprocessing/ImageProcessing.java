package cs211.imageprocessing;

import java.util.List;

import processing.core.PApplet;
import processing.core.PImage;

@SuppressWarnings("serial")
public class ImageProcessing extends PApplet {
    PImage[] imgs;

    private final Week8 week8;

    private int lowHue = 102;
    private int highHue = 137;
    private int lowBr = 24;
    private int hiBr = 136;
    private int minSat = 100;
    private int nbVote = 174;

    private int selectedImage = 0;
    private boolean modify = false;

    /**
     * TO THE CORRECTOR : set selectedImage accordingly, enable modify to play with the parameters.
     */

    public ImageProcessing(){
        week8 = new Week8(this);        
    }

    public void setup() {
        imgs = new PImage[4];
        imgs[0] = loadImage("../data/board1.jpg");
        imgs[1] = loadImage("../data/board2.jpg");
        imgs[2] = loadImage("../data/board3.jpg");
        imgs[3] = loadImage("../data/board4.jpg");

        size(2200, 600);
        noLoop();
    }

    public void draw() {
        //here are shown explicitly the method proposed in the pdf
        PImage colors = week8.hueThreshold(imgs[selectedImage], lowHue, highHue, lowBr, hiBr, minSat);
        PImage blurred = week8.convolute(colors, Week8.gaussian, Week8.gaussianWeight);
        PImage tresholded = week8.binThreshold(blurred, 125);
        PImage sobeliz = week8.sobel(tresholded);

        //print the original image
        image(imgs[selectedImage], 0, 0);
        
        //print the lines
        Week9 current = new Week9(this, sobeliz);
        List<Integer> lines = current.optimizeWithNeighboorsLines(nbVote, 10, 4);
        current.drawLines(lines);

        //print the intersection found
        current.getAndDrawIntersections(current.accToParam(lines));  

        //print the best quad
        //QuadGraph qg = new QuadGraph(current.accToParam(lines), 800, 600, this);
        //qg.drawQuads();

        //print the accumulator
        image(current.paramSpace(600, 600), 800, 0);
        
        //print the sobelized image
        image(sobeliz, 1400, 0);
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

            System.out.println("lowHue: "+lowHue+" highHue: "+highHue+" lowBr: "+lowBr+" highBr: "+hiBr+" minSat: "+minSat+" nbVote: "+nbVote+" selected image:"+selectedImage); 

            redraw();
        }

    }    
}




