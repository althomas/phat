/* File: Tracker.h
   Author: Cam Cogan
   Desc: Header file for class meant to wrap image analysis with OpenCV.
*/

#ifndef TRACKER_H_
#define TRACKER_H_

#include<opencv/cvaux.h>
#include<opencv/highgui.h>
#include<opencv/cxcore.h>

#include<stdio.h>
#include<stdlib.h>
#include<cstring>
#include<string>

#define BUFFER_SIZE 512

class Tracker
{
private:
  char *textFilePath;

public:
	Tracker(const char *outputFilePath);
	~Tracker();
	int AnalyzeVideo(const char *videoFileName, const char *textFileName);
};

#endif
