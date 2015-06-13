/*
 *	Author:      Gilbert Maystre
 *	Date:        May 12, 2015
 */

package cs211.imageprocessing;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import processing.core.PApplet;
import processing.core.PImage;
import processing.core.PVector;
import static cs211.imageprocessing.ImageProcessing.*;

public class Week9 {

    //those field were given
    private static final float discretizationStepsPhi = 0.06f;
    private static final float discretizationStepsR = 2.5f;
    
    private int phiDim;
    private int rDim;
    private int[] accumulator;
    private final PImage edgeImg;
        
    //optimization purposes
    private final float[] cosMul;
    private final float[] sinMul;

    //TODO: understand how to call methods like createImage outside a PApplet class
    private final PApplet dummyContext;

    public Week9(PApplet dummyContext, PImage edgeImg){
        // dimensions of the accumulator
        this.phiDim = (int) (Math.PI / discretizationStepsPhi);
        this.rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
        
        accumulator = new int[(phiDim + 2) * (rDim + 2)];// our accumulator (with a 1 pix margin around)
        this.edgeImg = edgeImg;
        
        this.cosMul = new float[phiDim];
        this.sinMul = new float[phiDim];
        double inv = 1f/discretizationStepsR;
        for(int phi = 0; phi < phiDim; phi++){
            double cur = phi*discretizationStepsPhi;
            this.cosMul[phi] = (float) (Math.cos(cur)*inv);
            this.sinMul[phi] = (float) (Math.sin(cur)*inv);
        }
        
        this.dummyContext = dummyContext;

        
        hough();
    }

    private void hough(){
        // Fill the accumulator: on edge points (ie, white pixels of the edge image), store all possible (r, phi) pairs describing lines going through the point.
        for (int y = 0; y < edgeImg.height; y++) {
            for (int x = 0; x < edgeImg.width; x++) {
                // Are we on an edge?
                if (dummyContext.brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
                    for (int phi = 0; phi < phiDim; phi++) {

                        double discreteRadius = x * cosMul[phi] + y * sinMul[phi];
                        int r = (int) Math.round(discreteRadius + (rDim - 1)/2f);

                        accumulator[(phi+1) * (rDim + 2) + r + 1] += 1;
                    }
                } 
            }
        }
    }

    

    /**
     * This method computes and draw each intersection between the lines
     * @param lines the lines to compute intersection from (in parametric format)
     * @return a list of intersection
     */
    public ArrayList<PVector> getAndDrawIntersections(List<PVector> lines){        
        ArrayList<PVector> intersections = new ArrayList<PVector>();
        for (int i = 0; i < lines.size() - 1; i++) {
            PVector line1 = lines.get(i);
            for (int j = i + 1; j < lines.size(); j++) {
                PVector line2 = lines.get(j);

                //formulas given in the pdf
                double d = Math.cos(line2.y)*Math.sin(line1.y) - Math.cos(line1.y)*Math.sin(line2.y);
                float x = (float) ((line2.x*Math.sin(line1.y) - line1.x*Math.sin(line2.y))/d);
                float y = (float) ((-line2.x*Math.cos(line1.y) + line1.x*Math.cos(line2.y))/d);

                intersections.add(new PVector(x, y));

                dummyContext.fill(255, 128, 0);
                dummyContext.ellipse(x, y, 10, 10);
            }
        }
        return intersections;
    }
    
    /**
     * This function transforms a list of IDs to a list of parameters
     * @param ids the list of line in form of IDs
     * @return the list of line in parametric form
     */
    public ArrayList<PVector> accToParam(List<Integer> ids){
        ArrayList<PVector> toReturn = new ArrayList<PVector>();
        for(Integer idx : ids){
            int accPhi = (int) Math.round((idx / (rDim + 2)) - 1);
            int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
            float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
            float phi = accPhi * discretizationStepsPhi;

            toReturn.add(new PVector(r, phi));
        }

        return toReturn;
    }
    

    /**
     * This function returns a picture of the accumulator
     * @param width wanted width of the picture
     * @param height wanted height of the picture
     * @return a nice picture representing the accumulator
     */
    public PImage paramSpace(int width, int height){
        PImage houghImg = dummyContext.createImage(rDim + 2, phiDim + 2, ALPHA);
        for (int i = 0; i < accumulator.length; i++) {
            houghImg.pixels[i] = dummyContext.color(min(255, accumulator[i]));
        }
        houghImg.updatePixels();

        houghImg.resize(width, height);
        return houghImg;
    }

    /**
     * The complete optimized version of drawLines, checking neighborhood to find maximas
     * @param minimalVote eligibility parameter
     * @param neighbourhood neigborhooud radius
     * @param n number of best lines to keep
     * @return a list of IDs for good lines
     */
    public List<Integer> optimizeWithNeighboorsLines(int minimalVote, int neighbourhood, int n){
        ArrayList<Integer> bestCandidates = new ArrayList<Integer>();

        for (int accR = 0; accR < rDim; accR++) {
            for (int accPhi = 0; accPhi < phiDim; accPhi++) {
                // compute current index in the accumulator
                int idx = (accPhi + 1) * (rDim + 2) + accR + 1;

                if (accumulator[idx] > minimalVote) {
                    boolean bestCandidate = true;
                    // iterate over the neighbourhood
                    for(int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) { 
                        // check we are not outside the image
                        if( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) 
                            continue;

                        for(int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
                            // check we are not outside the image
                            if(accR+dR < 0 || accR+dR >= rDim) 
                                continue;

                            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
                            if(accumulator[idx] < accumulator[neighbourIdx]) { // the current idx is not a local maximum!
                                bestCandidate = false;
                                break;
                            }
                        }
                        if(!bestCandidate) 
                            break;
                    }
                    if(bestCandidate) {
                        // the current idx *is* a local maximum
                        bestCandidates.add(idx);
                    }
                }
            }
        }

        HoughComparator comp = new HoughComparator(accumulator);
        Collections.sort(bestCandidates, comp);
        List<Integer> toReturn = bestCandidates.subList(0, Math.min(n, bestCandidates.size()));
        
        return toReturn;
    }

    
    /**
     * This method simply draw the n best line amongst all that were voted 
     * a minimal number of time
     * @param minimalVote the minimal voting number to eligibility
     * @param n the number of line to be voted
     * @return a list of IDs for good lines
     */
    public List<Integer> findNBestLines(int minimalVote, int n){
        ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
        for (int idx = 0; idx < accumulator.length; idx++) {
            if (accumulator[idx] > minimalVote) {
                bestCandidates.add(idx);
            }
        }

        HoughComparator comp = new HoughComparator(accumulator);
        Collections.sort(bestCandidates, comp);
        return bestCandidates.subList(0, Math.min(n, bestCandidates.size()));
    }
    

    /**
     * This method simply draw all lines that were voted more than nbVote time
     * @param nbVote the minimal number of vote to be drawn
     * @return a list of IDs for good lines
     */
    public List<Integer> drawLines(int nbVote){
        ArrayList<Integer> ids = new ArrayList<Integer>();
        for(int idx = 0; idx < accumulator.length; idx++){
            if(accumulator[idx] > nbVote){
                ids.add(idx);
            }
        }
       return ids;
    }

    //this method was given as is in the exercise of week 9
    
    /**
     * This method draws lines specified by their ID
     * @param ids a list of all line to draw
     */
    public void drawLines(List<Integer> ids){
        for(Integer idx : ids){
            // first, compute back the (r, phi) polar coordinates:
            int accPhi = (int) Math.round((idx / (rDim + 2)) - 1);
            int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
            float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
            float phi = accPhi * discretizationStepsPhi;

            // Cartesian equation of a line: y = ax + b
            // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
            // => y = 0 : x = r / cos(phi)
            // => x = 0 : y = r / sin(phi)
            // compute the intersection of this line with the 4 borders of // the image
            int x0 = 0;
            int y0 = (int) Math.round((r / sin(phi)));
            int x1 = (int) Math.round((r / cos(phi)));
            int y1 = 0;
            int x2 = edgeImg.width;
            int y2 = (int) Math.round((-cos(phi) / sin(phi) * x2 + r / sin(phi)));
            int y3 = edgeImg.width;
            int x3 = (int) Math.round((-(y3 - r / sin(phi)) * (sin(phi) / cos(phi))));
            // Finally, plot the lines
            dummyContext.stroke(204,102,0);

            if (y0 > 0) {
                if (x1 > 0)
                    dummyContext.line(x0, y0, x1, y1);
                else if (y2 > 0)
                    dummyContext.line(x0, y0, x2, y2);
                else
                    dummyContext.line(x0, y0, x3, y3);
            }
            else {
                if (x1 > 0) {
                    if (y2 > 0)
                        dummyContext.line(x1, y1, x2, y2); else
                            dummyContext.line(x1, y1, x3, y3);
                }
                else
                    dummyContext.line(x2, y2, x3, y3);
            }
        } 
    }

}
