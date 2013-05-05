phat
====

Primate Hand Actuation Tracker

Contact info <@seas.upenn.edu>:

Cam Cogan       {ccog}
David Hallac    {hallac}
Nick Howarth    {nhowarth}
Ashleigh Thomas {thomasas}
Sam Wolfson     {swolfson}


IMU Data Acquisition:
Requirements:  Python, pyserial (Python Serial package)
1.	Plug in m2 microcontroller to computer via USB
2.	Open Python terminal and type:
python_serial.py <filename> <time>
where ‘filename’ is the name of the file you want to dump the data into and ‘time’ is the number of seconds for which to record data.  
3.	Before running the script, press the reset button on the m2. You will see the green on-board LED flash. (If the orange LED turns on, you are holding down the button for too long. Press the button again until the green LED comes on.) 
4.	 Press enter to run the script and acquire data. 

IMU Data Processing:
Requirements:  MATLAB
1.	Make sure that everything in the IMU processing folder is in the MATLAB path, including the madgwick_algorithm_matlab and IMUcalibration folders
2.	The command to perform the parsing and extraction is extract_all_dat(infile,outfile)
a.	Infile is the file name and path of the datafile created by the serial connection program, e.g: ‘~/Desktop/inputfile.txt’. 
b.	Outfile is the desired file name and path of the output file that extract_all_dat will create, e.g. ‘~/Desktop/outputfile.txt’
c.	The single quotes are important, because MATLAB is expecting a string

Camera Data Acquisition and Processing:
Requirements:  OpenCV, MATLAB
1)	Plug in each of three cameras into Firewire hub and ensure that the Firewire hub is powered. Each of the three cameras should have a green LED on. If any other color LED is on, or if the green LED is flashing, consult the online documentation for the cameras. Should one camera break, the system can accommodate two. 
2)	Run PHATCapture.exe by either:
a.	Locating it in the PHATCapture\Debug directory, or
b.	Compiling the program from scratch by opening the PHATCapture.sln file in Microsoft Visual Studios 2010, selecting Build -> Rebuild Solution, and then selecting Debug -> Start Without Debugging. If you choose to compile, ensure that you have FlyCap2 and OpenCV 2.2 (note: not 2.2 or higher) installed on your machine in the location specified in the solution’s Properties section.
3)	Follow the on-screen prompts in the terminal to run the program for a specified length. The cameras may require several attempts to successfully synchronize. Should any errors arise, check the terminal for helpful error messages. If errors occur after video capture but before analysis, the video files can be located within the PHATCapture\PHATCapture directory. These files should be moved elsewhere if you wish to analyze them later, as they will otherwise be overwritten with the next trial.
4)	The program will save one text file for each camera in your setup specifying the location of each beacon at any given time. These files are located in the folder specified during the program’s execution. If an invalid directory is provided, or if you select the default option, the text files will also be located in the PHATCapture\PHATCapture directory. As with Step 3, any data you are intent on preserving should be moved from this file, or it may be overwritten with the next execution of the program.
5)	After generating these three text files, open up parsefiles.m in MATLAB
6)	 Edit lines 27-29 to point to the correct three files in MATLAB
a.	Line 27: c0 = camera down the shorter axis (2’9”)
b.	Line 28: c1 = camera down the axis with the longer length (3’)
c.	Line 29: c2 = camera on top of the rig pointing down
7)	Run ParseFiles.m
a.	If you cannot find the output file, edit line 444 to choose the path of where you want to write your output
8)	finalOutput.txt is your desired file from the Camera Rig

Kalman Filter:
Requirements:  MATLAB
1.	Set up the configuration file in /phat/ekf. There are a few options for this:
a.	Make a symlink from your desired configuration file in ./config to ./config.m
b.	Copy your desired configuration into ./ and name is config.m
2.	Make sure that your config file links to the correct log files
3.	>> run_ekf
4.	The EKF output will be displayed in a figure.

Inverse Kinematics:
Requirements:  MATLAB
1.	Go to /phat/rvctools
2.	>> startup_rvc
3.	Make sure that the output from the Kalman filter is stored in a global variable named ‘x’
4.	>> finger
5.	Data will be written to an output file specified at the top of /phat/rvctools/robot/demos/finger.m

Wireframe
Requirements:  pygame

How it works:
A still-frame of the hand model is referred to as a "frame." Each frame is composed of 21 coordinate points, so the number of lines in the input file must be a multiple of 21. The program breaks the input file into frames. For each frame, each point is projected from 3D to 2D. Lines are then drawn between the lines to replicate the fingers. The hand model can be rotated around 3 axes by pressing certain keys on the keyboard (see next section). If there are multiple frames in the input file, the hand can be animated by pressing the space bar to enable play mode. The program will display the motion frame-by-frame at a frame rate of 5 fps (frame rate can be modified by altering argument to self.clock.tick in run). Upon reaching the end of the list of joint positions, play mode will again be disabled until the space bar is pressed again. The user may rotate the hand regardless of whether play mode is enabled.  

To use:
On the command line, run:  python pyhand.py <hand_coordinate_file>
(Sample:  python pyhand.py hand.txt)

<hand_coordinate_file> must be in following format (spaces not necessary):

I0x, I0y, I0z
I1x, I1y, I1z
I2x, I2y, I2z
I3x, I3y, I3z
M0x, M0y, M0z
... # M1-M3
R0x, R0y, R0z
... # R1-R3
P0x, P0y, P0z
... # P1-P3
T0x, T0y, T0z
T1x, T1y, T1z
T2x, T2y, T2z
W0x, W0y, W0z
W1x, W1y, W1z
... # next frame(s)

where I = index, M = middle, R = ring, P = pinky, T = thumb, W = wrist,
0 = fingertip, 1 = first joint from fingertip, 2 = second joint from fingertip,
3 = 3rd joint from fingertip (N/A for thumb), 
and x, y, and z represent the x-, y-, and z-coordinates of the joint.
Exception: W0 represents the wrist, and W1 represent some point on the forearm.

Once running in pygame environment:
-  Can rotate about x-axis by pressing 'h' / 'l' on the keyboard.
-  Can rotate about y-axis by pressing 'u' / 'n' on the keyboard.
-  Can rotate about z-axis by pressing 'j' / 'k' on the keyboard.
-  Start animation by pressing SPACE bar on the keyboard.
