The EKF for Primate Hand Actuation Tracker (PHAT)
Ashleigh Thomas
thomasas@seas.upenn.edu


To run EKF:

make a simlink from the desired configuration file in ./config
to "./config.m" in phat/ekf/

DAVID: I have created an appropriately named config file for you.
Go in there and change "c.testlog_in" and "c.testlog_vis" to 
local paths to your inertial and vision logs, respectively. 

Then link to the config file. I do this with a sym link in linux.
I have no idea how to do it in windows. I'm sorry. I think Sam does.

Once that's all set up, run this:

in matlab, 
>> run_ekf


and a pretty picture should show up. 
