### VisualComputing_Project CS-211 2015
2014-15 Visual Computing Project for EPFL course CS-211 'Introduction to Visual Computing'.

##### INFO


Implementing a game with data visualization, controlled either by mouse or webcam/video with a green Lego plate. Also includes some 3D design with Blender.

Note that in the current configuration, the program is in demo mode, the input being the sample video given for grading. <b>The game mode can easily be changed to use the mouse or the webcam stream: on <code>GameBase/Game.java</code>, simply adjust the two booleans <code>IS_MOUSE_CONTROLLED</code> and <code>IS_WEBCAM_CONTROLLED</code> in the way you want to play.</b>

<i>Note also that there are apparently some issues with lauching the program on Linux/Windows with the sample input video, which cannot be played with some special configurations. We developed it on MAC OSX without having any problem.</i>

##### COMMANDS

The command is made with the mouse when mouse-mode (see INFO section), or by detection from the video/camera stream if not in mouse-mode.

You can <b>add obstacles</b> when playing (in every mode). To do so, just ensure that you are in the window containing the plate (and not the camera stream), and press <code>SHIFT</code>. Then, you can add a new obstacle on the plate by a left-clic with the mouse.
