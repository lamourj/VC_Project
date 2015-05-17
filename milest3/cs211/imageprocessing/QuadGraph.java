package cs211.imageprocessing;

import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;
import java.util.Random;

import processing.core.PApplet;
import processing.core.PVector;

public class QuadGraph {

    private List<int[]> cycles = new ArrayList<int[]>();//the list of all cycles of length 4
    private final int[][] graph;//the graph of intersections
    
    private final List<PVector> lines; //all line in parametric format
    private final int width;
    private final int height;
    
    PApplet dummyContext;
    
    //we remodeled the whole class because it was weird
    public QuadGraph(List<PVector> lines, int width, int height, PApplet dummyContext){
        this.width = width;
        this.height = height;
        //first we build a sound representation of the intersection graph
        int n = lines.size();
        graph = new int[n * (n + 1)/2][2];// The maximum possible number of edges is sum(0..n) = n * (n + 1)/2
        int idx = 0;

        for (int i = 0; i < lines.size(); i++) {
            for (int j = i + 1; j < lines.size(); j++) {
                if (intersect(lines.get(i), lines.get(j))) {
                    graph[idx][0] = i;
                    graph[idx][1] = j;
                    idx++;
                }
            }
        }
        
        System.out.println("graph size : "+graph.length);
        
        this.lines = lines;
        this.width = width;
        this.height = height;
        this.dummyContext = dummyContext;
        
        findCycles();
    }
        
    private PVector intersection(PVector line1, PVector line2){
        double d = Math.cos(line2.y)*Math.sin(line1.y) - Math.cos(line1.y)*Math.sin(line2.y);
        float x = (float) ((line2.x*Math.sin(line1.y) - line1.x*Math.sin(line2.y))/d);
        float y = (float) ((-line2.x*Math.cos(line1.y) + line1.x*Math.cos(line2.y))/d);

        return new PVector(x, y);
    }
    
    public PVector[] selectBestQuad(float max_area, float min_area){
        List<PVector[]> copy = new ArrayList<PVector[]>();
        for(int[] toc : cycles){
            PVector[] toPut = new PVector[4];
            
            PVector l1 = lines.get(toc[0]);
            PVector l2 = lines.get(toc[1]);
            PVector l3 = lines.get(toc[2]);
            PVector l4 = lines.get(toc[3]);

            toPut[0] = intersection(l1, l2);
            toPut[1] = intersection(l2, l3);
            toPut[2] = intersection(l3, l4);
            toPut[3] = intersection(l4, l1);
            
            copy.add(toPut);
        }
        
        Iterator<PVector[]> it = copy.iterator();
        while(it.hasNext()){
            PVector[] n = it.next();
            if(!isConvex(n[0], n[1], n[2], n[3]) || !nonFlatQuad(n[0], n[1], n[2], n[3]) || !validArea(n[0], n[1], n[2], n[3], max_area, min_area)){
                it.remove();
            }   
        }
        
        if(copy.size() == 0){
            System.out.println("nothing good was found");
        }
        
        return copy.get(0); //we return any one if nothing was found it's the first, else it's a good one
        
        
    }
    
    /**
     * This method draws one quad
     * @param quadLines the quad to draw
     */
    public void drawQuad(int[] quadLines){
        
        System.out.println("drawing a quad :)");
        
        PVector l1 = lines.get(quadLines[0]);
        PVector l2 = lines.get(quadLines[1]);
        PVector l3 = lines.get(quadLines[2]);
        PVector l4 = lines.get(quadLines[3]);
        // (intersection() is a simplified version of the
        // intersections() method you wrote last week, that simply
        // return the coordinates of the intersection between 2 lines) 
        PVector c12 = intersection(l1, l2);
        PVector c23 = intersection(l2, l3);
        PVector c34 = intersection(l3, l4);
        PVector c41 = intersection(l4, l1);
        // Choose a random, semi-transparent colour
        Random random = new Random(); 
        
        dummyContext.fill(dummyContext.color(Math.min(255, random.nextInt(300)),
                Math.min(255, random.nextInt(300)),
                Math.min(255, random.nextInt(300)), 50));
        
        dummyContext.quad(c12.x,c12.y,c23.x,c23.y,c34.x,c34.y,c41.x,c41.y);
    }
    
    /**
     *This method draw all quads of length 4 that were found 
     */
    public void drawQuads(){
        System.out.println("printing quads???");
        for (int[] quad : cycles) {
            System.out.println("yes!");
            drawQuad(quad);
        }  
    }

    private boolean intersect(PVector line1, PVector line2) {

        double sin_t1 = Math.sin(line1.y);
        double sin_t2 = Math.sin(line2.y);
        double cos_t1 = Math.cos(line1.y);
        double cos_t2 = Math.cos(line2.y);
        float r1 = line1.x;
        float r2 = line2.x;

        double denom = cos_t2 * sin_t1 - cos_t1 * sin_t2;

        int x = (int) ((r2 * sin_t1 - r1 * sin_t2) / denom);
        int y = (int) ((-r2 * cos_t1 + r1 * cos_t2) / denom);

        if (0 <= x && 0 <= y && width >= x && height >= y)
            return true;
        else
            return false;

    }

    private List<int[]> findCycles() {
        cycles.clear();
        for (int i = 0; i < graph.length; i++) {
            for (int j = 0; j < graph[i].length; j++) {
                findNewCycles(new int[] {graph[i][j]});
            }
        }
        for (int[] cy : cycles) {
            String s = "" + cy[0];
            for (int i = 1; i < cy.length; i++) {
                s += "," + cy[i];
            }
            System.out.println(s);
        }
        
        //small hack to keep only cycles of length 4 ;)
        Iterator<int[]> it = cycles.iterator();
        while(it.hasNext()){
            int[] curr = it.next();
            if(curr.length != 4){
                it.remove();
            }
        }

        return cycles;
    }

    void findNewCycles(int[] path)
    {
            int n = path[0];
            int x;
            int[] sub = new int[path.length + 1];

            for (int i = 0; i < graph.length; i++)
                for (int y = 0; y <= 1; y++)
                    if (graph[i][y] == n)
                    //  edge refers to our current node
                    {
                        x = graph[i][(y + 1) % 2];
                        if (!visited(x, path))
                        //  neighbor node not on path yet
                        {
                            sub[0] = x;
                            System.arraycopy(path, 0, sub, 1, path.length);
                            //  explore extended path
                            findNewCycles(sub);
                        }
                        else if ((path.length > 2) && (x == path[path.length - 1]))
                        //  cycle found
                        {
                            int[] p = normalize(path);
                            int[] inv = invert(p);
                            if (isNew(p) && isNew(inv))
                            {
                                cycles.add(p);
                            }
                        }
                    }
    }

    //  check of both arrays have same lengths and contents
    static Boolean equals(int[] a, int[] b)
    {
        Boolean ret = (a[0] == b[0]) && (a.length == b.length);

        for (int i = 1; ret && (i < a.length); i++)
        {
            if (a[i] != b[i])
            {
                ret = false;
            }
        }

        return ret;
    }

    //  create a path array with reversed order
    static int[] invert(int[] path)
    {
        int[] p = new int[path.length];

        for (int i = 0; i < path.length; i++)
        {
            p[i] = path[path.length - 1 - i];
        }

        return normalize(p);
    }

    //  rotate cycle path such that it begins with the smallest node
    static int[] normalize(int[] path)
    {
        int[] p = new int[path.length];
        int x = smallest(path);
        int n;

        System.arraycopy(path, 0, p, 0, path.length);

        while (p[0] != x)
        {
            n = p[0];
            System.arraycopy(p, 1, p, 0, p.length - 1);
            p[p.length - 1] = n;
        }

        return p;
    }

    //  compare path against known cycles
    //  return true, iff path is not a known cycle
    Boolean isNew(int[] path)
    {
        Boolean ret = true;

        for(int[] p : cycles)
        {
            if (equals(p, path))
            {
                ret = false;
                break;
            }
        }

        return ret;
    }

    //  return the int of the array which is the smallest
    static int smallest(int[] path)
    {
        int min = path[0];

        for (int p : path)
        {
            if (p < min)
            {
                min = p;
            }
        }

        return min;
    }

    //  check if vertex n is contained in path
    static Boolean visited(int n, int[] path)
    {
        Boolean ret = false;

        for (int p : path)
        {
            if (p == n)
            {
                ret = true;
                break;
            }
        }

        return ret;
    }


    
    /** Check if a quad is convex or not.
     * 
     * Algo: take two adjacent edges and compute their cross-product. 
     * The sign of the z-component of all the cross-products is the 
     * same for a convex polygon.
     * 
     * See http://debian.fmi.uni-sofia.bg/~sergei/cgsr/docs/clockwise.htm
     * for justification.
     * 
     * @param c1
     */
    public static boolean isConvex(PVector c1,PVector c2,PVector c3,PVector c4){
        
        PVector v21= PVector.sub(c1, c2);
        PVector v32= PVector.sub(c2, c3);
        PVector v43= PVector.sub(c3, c4);
        PVector v14= PVector.sub(c4, c1);
  
        float i1=v21.cross(v32).z;
        float i2=v32.cross(v43).z;
        float i3=v43.cross(v14).z;
        float i4=v14.cross(v21).z;
        
        if(   (i1>0 && i2>0 && i3>0 && i4>0) 
           || (i1<0 && i2<0 && i3<0 && i4<0))
            return true;
        else 
            System.out.println("Eliminating non-convex quad");
            return false;
   
   }

    /** Compute the area of a quad, and check it lays within a specific range
     */
    public static boolean validArea(PVector c1,PVector c2,PVector c3,PVector c4, float max_area, float min_area){
        
        PVector v21= PVector.sub(c1, c2);
        PVector v32= PVector.sub(c2, c3);
        PVector v43= PVector.sub(c3, c4);
        PVector v14= PVector.sub(c4, c1);
  
        float i1=v21.cross(v32).z;
        float i2=v32.cross(v43).z;
        float i3=v43.cross(v14).z;
        float i4=v14.cross(v21).z;
        
        float area = Math.abs(0.5f * (i1 + i2 + i3 + i4));
        
        //System.out.println(area);
        
        boolean valid = (area < max_area && area > min_area);
   
        if (!valid) System.out.println("Area out of range");
        
        return valid;
   }
  
    /** Compute the (cosine) of the four angles of the quad, and check they are all large enough
     * (the quad representing our board should be close to a rectangle)
     */
    public static boolean nonFlatQuad(PVector c1,PVector c2,PVector c3,PVector c4){
        
        // cos(70deg) ~= 0.3
        float min_cos = 0.3f;
        
        PVector v21= PVector.sub(c1, c2);
        PVector v32= PVector.sub(c2, c3);
        PVector v43= PVector.sub(c3, c4);
        PVector v14= PVector.sub(c4, c1);
  
        float cos1=Math.abs(v21.dot(v32) / (v21.mag() * v32.mag()));
        float cos2=Math.abs(v32.dot(v43) / (v32.mag() * v43.mag()));
        float cos3=Math.abs(v43.dot(v14) / (v43.mag() * v14.mag()));
        float cos4=Math.abs(v14.dot(v21) / (v14.mag() * v21.mag()));
    
        if (cos1 < min_cos && cos2 < min_cos && cos3 < min_cos && cos4 < min_cos)
            return true;
        else {
            System.out.println("Flat quad");
            return false;
        }
   }
}
