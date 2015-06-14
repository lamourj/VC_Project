package detectionUtilities;

import java.util.ArrayList;
import java.util.List;

import processing.core.PApplet;
import processing.core.PImage;
import processing.core.PVector;
import processing.video.Capture;
import processing.video.Movie;
import GameBase.TwoDThreeD;

/**
 * @author Gilbert Maystre
 * @author Julien Lamour
 *
 *         Implements the detection with a input video or camera stream.
 */
@SuppressWarnings("serial")
public class ImageProcessing extends PApplet {

	// movie and cam
	Movie mov;
	Capture cam;

	//Image useful for whole game
	PImage workingOn;
	private boolean paused = false;

	// settings
	int view = 1;
	private int lowHue = 93;
	private int highHue = 135;
	private int lowBr = 58;
	private int hiBr = 169;
	private int minSat = 91;
	private int nbVote = 100;

	private boolean isCamera;

	public final int videoWidth = 640;
	public final int videoHeight = 480;

	private final Week8 week8;
	private TwoDThreeD tr;

	/**
	 * Note: coordinates are in Radians.
	 */
	public PVector rotations3d;

	/**
	 * Builder for <code>ImageProcessing</code> class.
	 * 
	 * @param isCamera
	 *            which should be <code>true</code> to enable webcam-control or
	 *            <code>false</code> for input video control.
	 */
	public ImageProcessing(boolean isCamera) {
		week8 = new Week8(this);
		tr = new TwoDThreeD(videoWidth, videoHeight);
		this.isCamera = isCamera;
	}

	public void setup() {
		size(videoWidth, videoHeight);

		if (isCamera) {
			String[] cameras = Capture.list();
			if (cameras.length == 0) {
				println("There are no cameras available for capture.");
				exit();
			} else {
				println("Available cameras:");
				for (int i = 0; i < cameras.length; i++) {
					println(cameras[i]);
				}
				cam = new Capture(this, cameras[4]);
				cam.start();
			}
		} else {
			mov = new Movie(this, "../data/testvideo.mp4");
			mov.loop();
		}
	}

	public void draw() {

		if (isCamera) {
			if (cam.available()) {
				cam.read();
			}
			workingOn = cam.get();
		} else {
			if (mov.available()) {
				mov.read();
			}
			workingOn = mov.get();
		}

		PImage colors = week8.hueThreshold(workingOn, lowHue, highHue, lowBr,
				hiBr, minSat);
		PImage blurred = week8.convolute(colors, Week8.gaussian,
				Week8.gaussianWeight);
		PImage tresholded = week8.binThreshold(blurred, 125);
		PImage sobeliz = week8.sobel(tresholded);

		if (view == 1) {
			image(workingOn, 0, 0);
		} else {
			image(sobeliz, 0, 0);
		}

		Week9 current = new Week9(this, sobeliz);
		List<Integer> lines = current
				.optimizeWithNeighboorsLines(nbVote, 10, 6);
		// current.drawLines(lines);
		// current.getAndDrawIntersections(current.accToParam(lines));
		QuadGraph qg = new QuadGraph(current.accToParam(lines), videoWidth,
				videoHeight, this);

		// on dessine le meilleur quad en rouge
		fill(255, 0, 0, 80);
		PVector[] bestQuads = qg.selectBestQuad();
		qg.drawQuad(bestQuads);

		if (bestQuads != null && bestQuads.length == 4) {
			ArrayList<PVector> bestQuadsList = new ArrayList<>();

			for (int i = 0; i < bestQuads.length; i++)
				bestQuadsList.add(bestQuads[i]);

			rotations3d = tr.get3DRotations(bestQuadsList);
		}
		/*
		 * if (!paused) { mov.play(); } else { mov.pause(); }
		 */
	}

	public void keyPressed() {
		if (paused && !isCamera) {
			if (key == CODED) {
				if (keyCode == UP) {
					highHue = Math.min(255, highHue + 1);
				} else if (keyCode == DOWN) {
					highHue = Math.max(0, highHue - 1);
				} else if (keyCode == LEFT) {
					lowHue = Math.max(0, lowHue - 1);
				} else if (keyCode == RIGHT) {
					lowHue = Math.min(255, lowHue + 1);
				}
			}
			if (key == 'q') {
				lowBr = Math.max(0, lowBr - 1);
			} else if (key == 'w') {
				lowBr = Math.min(255, lowBr + 1);
			} else if (key == 'a') {
				hiBr = Math.max(0, hiBr - 1);
			} else if (key == 's') {
				hiBr = Math.min(255, hiBr + 1);
			} else if (key == 'y') {
				minSat = Math.max(0, minSat - 1);
			} else if (key == 'x') {
				minSat = Math.min(255, minSat + 1);
			} else if (key == 'e') {
				nbVote = Math.max(0, nbVote - 1);
			} else if (key == 'r') {
				nbVote = nbVote + 1;
			}

			System.out.println("Hue: [" + lowHue + " ; " + highHue
					+ "] Saturation: [" + minSat + " ; 255] Brightness: ["
					+ lowBr + " ; " + hiBr + "] Number of vote: " + nbVote);
		}
		
		if (key == '1') {
			view = 1;
		} else if (key == '2') {
			view = 2;
		}
	}

	public boolean isPaused() {
		return paused;
	}

	public void setPaused(boolean paused) {
		this.paused = paused;
	}
}