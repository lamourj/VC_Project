# VisualComputing_Project CS-211 2015
2014-15 Visual Computing Project for EPFL course CS-211 'Introduction à l'informatique visuelle'.

Implementing a game with data visualization, controlled either by mouse or webcam/video with a green Lego plate. Also includes some 3D design with Blender.

Note that in the current configuration, the program is in demo mode, the input being the sample video given for grading. It will be later modified to fit with the webcam stream (note that this is note a huge modification to do, as most of it is just replacing the <code>ImageProcessing</code> object by a <code>Try</code> object in the PFrame class in <code>Game.java (GameBase package)</code>).

The game can be set back to mouse-control by setting the <code>IS_MOUSE_CONTROLLED</code> boolean to <code>true</code>, in the main class <code>Game.java (GameBase package)</code>.

<b>Note also that there are apparently some issues with lauching the program on Linux/Windows as the sample input video cannot be played with some special configurations. We developed it on MAC OSX without having any problem.</b>
