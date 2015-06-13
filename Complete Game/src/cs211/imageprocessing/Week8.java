/*
 *	Author:      Gilbert Maystre
 *	Date:        May 5, 2015
 */

package cs211.imageprocessing;

import processing.core.PImage;
import processing.core.PApplet;

import static cs211.imageprocessing.ImageProcessing.*;

public final class Week8{

    private final PApplet dummyContext;
    
    public static final float[][] gaussian = {{9, 12, 9}, {12, 15, 12}, {9, 12, 9}};
    public static final float gaussianWeight = 9 + 12 + 9 + 12 + 15 + 12 + 9 + 12 + 9;
    
    public Week8(PApplet dummyContext){
        this.dummyContext = dummyContext;
    }

    /**
     * For good result, this method should be called after a hue select
     * @param p
     * @return
     */
    public PImage sobel(PImage p){        
        PImage result = dummyContext.createImage(p.width, p.height, ALPHA);

        float[][] hKernel = {{0, 1, 0},
                {0, 0, 0},
                {0, -1, 0}};

        float[][] vKernel = {{0, 0, 0},
                {1, 0, -1},
                {0, 0, 0}};

        float max = 0;
        float[] buffer = new float[p.width * p.height];

        for(int x = 0; x < p.width; x++){
            for(int y = 0; y < p.height; y++){
                float sumH = 0;
                float sumV = 0;
                for(int i = 0; i<3; i++){
                    for(int j = 0; j<3; j++){
                        int actualX = min(max(0, x - 1 + i), p.width - 1);
                        int actualY = min(max(0, y - 1 + j), p.height - 1);                        
                        sumH += hKernel[i][j] * dummyContext.brightness(p.get(actualX, actualY));
                        sumV += vKernel[i][j] * dummyContext.brightness(p.get(actualX, actualY));
                    }
                }                
                float toStore = (float) Math.sqrt(sumH*sumH + sumV*sumV);  
                if(toStore > max) max = toStore;
                buffer[y*p.width + x] = toStore;       
            }
        }


        for(int y = 2; y < p.height-2;y++){
            for(int x = 2; x < p.width -2; x++){
                result.pixels[y * p.width + x] = (buffer[y * p.width + x] > (int)(max * 0.3f))? dummyContext.color(255) : dummyContext.color(0);
            }
        }

        return result;
    }

    public PImage convolute(PImage p, float[][] kernel, float weight){
        PImage result = dummyContext.createImage(p.width, p.height, ALPHA);

        for(int x = 0; x < p.width; x++){
            for(int y = 0; y < p.height; y++){
                float sum = 0;
                for(int i = 0; i<3; i++){
                    for(int j = 0; j<3; j++){
                        int actualX = min(max(0, x - 1 + i), p.width - 1);
                        int actualY = min(max(0, y - 1 + j), p.height - 1);                        
                        sum += kernel[i][j] * dummyContext.brightness(p.get(actualX, actualY));
                    }
                }                

                result.set(x, y, dummyContext.color(sum/weight * 255));      
            }
        }
        
        return result;
    }

    /**
     * This method performs a simple hue threshold, if the current threshold is
     * in the range [start, end] then the modified pixel is white, else it is
     * set black.
     * 
     * @param p
     *            the image to modify (a copy is created).
     * @param start
     *            the start hue, should be in [0, 255].
     * @param end
     *            the end hue, should be in [0, 255] and > than start.
     * @return a modified copy of img.
     */
    public PImage hueThreshold(PImage p, float start, float end, float sBr, float eBr, float minSat){
        PImage toReturn = dummyContext.createImage(p.width, p.height, RGB);
        for(int i = 0; i < toReturn.width * toReturn.height; i++){
            float currentHue = dummyContext.hue(p.pixels[i]);
            float currentBrightness = dummyContext.brightness(p.pixels[i]);
            float currentSaturation = dummyContext.saturation(p.pixels[i]);
            int replaceWith = (start <= currentHue && currentHue <= end
                    && sBr <= currentBrightness && currentBrightness <= eBr && currentSaturation >= minSat)? 0xFFFFFF : 0;
            toReturn.set(i%p.width, i/p.width, replaceWith);
        }
        return toReturn;
    }

    /**
     * This method performs a simple binary threshold, if the brightness of the
     * pixel is > that threshold then the pixel is set to white, else it is set
     * to black.
     * 
     * @param img
     *            the image to modify (a copy is created).
     * @param threshold
     *            the threshold, should be in [0, 255] (all white, all black).
     * @return a modified copy of img.
     */
    public PImage binThreshold(PImage img, int threshold){
        PImage toReturn = dummyContext.createImage(img.width, img.height, RGB);

        for(int i = 0; i < toReturn.width * toReturn.height; i++){
            int current = img.pixels[i];
            int replaceWith = (dummyContext.brightness(current) > threshold) ? 0xFFFFFF : 0;
            toReturn.set(i%img.width, i/img.width, replaceWith);
        }

        return toReturn;
    }

    /**
     * This method performs a simple negative binary threshold, if the
     * brightness of the pixel is < that threshold then the pixel is set to
     * white, else it is set to black.
     * 
     * @param img
     *            the image to modify (a copy is created).
     * @param threshold
     *            the threshold, should be in [0, 255] (all black, all white).
     * @return a modified copy of img.
     */
    public PImage negBinThreshold(PImage img, int threshold){
        PImage toReturn = dummyContext.createImage(img.width, img.height, RGB);

        for(int i = 0; i < toReturn.width * toReturn.height; i++){
            int current = img.pixels[i];
            int replaceWith = (dummyContext.brightness(current) < threshold) ? 0xFFFFFF : 0;
            toReturn.set(i%img.width, i/img.width, replaceWith);
        }

        return toReturn;
    }

}
