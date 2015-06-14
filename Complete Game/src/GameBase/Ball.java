package GameBase;

import processing.core.PVector;

/**
 * @author Julien Lamour
 * @author Gilbert Maystre
 * @author Martin Fontanet
 * 
 * 
 *         Reprentation of a ball for our project.
 */
public class Ball {

	/**
	 * considering that the ball has a mass of M = 1 with the only forces of the
	 * system to be gravitational force & friction force We got Fres = gravityF
	 * - frictionF = m * a = a since we assume velocity new = velocity old + a
	 * we get velocity new = velocityold + (gravityForce - frictionForce)
	 *
	 * gravityForce = (..., 0, ...) frictionForce = (
	 * 
	 **/

	PVector location;
	PVector velocity;
	PVector gravityForce;
	PVector frictionForce;

	Game parent;

	float radius;
	final static float gravityCst = 0.9f;
	final static float mu = 0.08f; // before .17
	final static float rebounce = 0.8f;

	final static boolean drawVector = false;

	Ball(Game parent, float radius, float boxThickness) {
		location = new PVector(0, -(radius + boxThickness / 2), 0);
		gravityForce = new PVector(0, 0, 0);
		velocity = new PVector(0, 0, 0);
		frictionForce = new PVector(0, 0, 0);

		this.radius = radius;
		this.parent = parent;
	}

	/**
	 * Updates the ball position
	 * 
	 * @param rx
	 * @param rz
	 * @param boxLength
	 */
	void update(float rx, float rz, float boxLength) {

		gravityForce.x = (float) (Math.sin(rz) * gravityCst);
		gravityForce.z = (float) -Math.sin(rx) * gravityCst;

		frictionForce = velocity.get();
		frictionForce.normalize();
		frictionForce.mult(-mu);

		velocity.add(gravityForce);
		velocity.add(frictionForce);

		// Here we simulate the static friction (which
		// we set equal to the kinetic friction constant
		// It is useful when the plate is not tilted enough

		if (velocity.mag() <= mu) {
			velocity = new PVector(0, 0, 0);
		}

		location.add(velocity);

		// Bounds-check, x axis
		if (location.x >= boxLength / 2 - radius) {
			subScore();
			velocity.x = -rebounce * velocity.x;
			location.x = boxLength / 2 - radius;
		} else if (location.x <= -boxLength / 2 + radius) {
			subScore();
			velocity.x = -rebounce * velocity.x;
			location.x = -boxLength / 2 + radius;
		}

		// z axis
		if (location.z >= boxLength / 2 - radius) {
			subScore();
			velocity.z = -rebounce * velocity.z;
			location.z = boxLength / 2 - radius;
		} else if (location.z <= -boxLength / 2 + radius) {
			subScore();
			velocity.z = -rebounce * velocity.z;
			location.z = -boxLength / 2 + radius;
		}

		// Cylinders check :

		for (PVector pos : parent.obstacles) {
			PVector sub = new PVector(location.x, 0, location.z);
			sub.sub(new PVector(pos.x, 0, pos.z));

			if (sub.mag() < parent.cylinderBaseSize + radius) {
				// sub is the normal
				parent.lastScore = (int) velocity.mag();
				parent.score += parent.lastScore;
				// updateScores();
				sub.normalize();

				PVector x = sub.get();
				x.mult((float) (2.0 * velocity.dot(sub)));
				velocity.sub(x);
				velocity.mult(rebounce);

				PVector old = new PVector(location.x, 0, location.z);

				location.add(velocity);

				old.sub(pos);
				old.normalize();
				old.mult(parent.cylinderBaseSize + radius);
				old.add(pos);

				location = new PVector(old.x, location.y, old.z);
			}
		}
	}

	/**
	 * Updates the score of the game.
	 */
	void updateScore() {
		parent.scores.add(0, parent.score);
		if (parent.scores.size() > 50)
			parent.scores.remove(49);
	}

	/**
	 * Substracts the computed amount (depenting on difficultyLevel)
	 * to the score
	 */
	void subScore() {
		parent.lastScore = (int) (parent.difficultyLevel * 0.1 * velocity.mag());
		parent.score -= parent.lastScore;
	}

	/**
	 * Displays the ball
	 */
	void display() {
		parent.translate(location.x, location.y, location.z);

		if (drawVector) {
			parent.fill(parent.color(255, 0, 0));
			drawVector(gravityForce, 1000);
			parent.fill(parent.color(0, 255, 0));
			drawVector(frictionForce, 1000);
			parent.fill(parent.color(0, 0, 255));
			drawVector(velocity, 10);
		}

		parent.fill(parent.color(188, 61, 219));
		parent.sphere(radius);
	}

	void drawVector(PVector x, float multiplier) {
		PVector perp = new PVector(-x.z, 0, x.x);
		perp.normalize();
		parent.beginShape();
		parent.vertex(-radius * perp.x, 0, -radius * perp.z);
		parent.vertex(x.x * multiplier, 0, x.z * multiplier);
		parent.vertex(radius * perp.x, 0, radius * perp.z);
		parent.endShape();
	}

	/**
	 * Check if the ball hits any obstacle.
	 */
	void checkObstaclesCollision() {
		for (int i = 0; i < parent.obstacles.size(); i++) {
			PVector tmp = parent.obstacles.get(i);
			PVector v = new PVector(tmp.x, tmp.y, tmp.z);

			PVector tempLocation = new PVector(location.x, location.y,
					location.z);
			tempLocation.add(velocity);
			float d = (float) Math.sqrt((tempLocation.x - v.x)
					* (tempLocation.x - v.x) + (tempLocation.z - v.z)
					* (tempLocation.z - v.z));

			boolean collision = d - parent.cylinderBaseSize - radius < 0;

			if (collision && velocity.mag() >= mu) {
				PVector n = new PVector(location.x - v.x, 0, location.z - v.z);
				n.normalize();

				float f = 2 * n.dot(velocity);
				n.mult(f);
				velocity.sub(n);
			}
		}
	}
}
