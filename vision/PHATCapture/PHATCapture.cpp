/* File: PHATCapture.cpp
   Author: Cam Cogan
   Desc: Main routine for simultaneous video capture and analysis from n
         cameras (current intended implementation uses 3).
*/

#include <stdio.h>
#include <iostream> //For atoi

#include "CameraCap.h"
#include "Tracker.h"

int captureVideo(CameraCap *cam);

int main(){
  char userFileName[512];
	char userInput[32];
	int numFrames = 0;
	int strlength = 0;
	int analysisFailure = -1;

	for(int i = 0; i < 32; i++){
		userInput[i] = 0;
	}

	for(int i = 0; i < BUFFER_SIZE; i++){
		userFileName[i] = 0;
	}

	printf("Welcome to PHAT Capture, developed at the University of Pennsylvania\nby a team of undergraduate electrical engineering students.\n\n");

	printf("Please enter the number of frames to capture from each camera.\n\n");
	fgets(userInput, 32, stdin);
	numFrames = atoi(userInput);

	while(numFrames < 1){
		printf("\nInvalid entry detected. Please enter a positive integer value for number of\nframes to capture.\n\n");
		fgets(userInput, 32, stdin);
		numFrames = atoi(userInput);
	}

	CameraCap *phatCap = new CameraCap((unsigned int) numFrames);

	userInput[0] = 'R';

	while(userInput[0] == 'r' || userInput[0] == 'R'){
		if(captureVideo(phatCap)){
			delete phatCap;
			return -1;
		}
		printf(".avi files successfully written. Enter 'r' to retry capture or anything else to\nproceed to analysis.\n\n");
		fgets(userInput, 32, stdin);
	}

	userInput[0] = 'r';

	while(!(userInput[0] == 'y' || userInput[0] == 'Y')){
		printf("\n\nPlease input path to folder in which to place output text files. Note that:\n");
		printf("\ta) You must use '\\\\' to indicate a '\\\' in the path name, and\n");
		printf("\tb) You must place a '\\\\' after the folder name.\n\n");
		fgets(userFileName, BUFFER_SIZE, stdin);
		printf("Received folder location:\n\n%s\n\nEnter 'y' if correct, or anything else to try again.\n\n",userFileName);
		fgets(userInput, 32, stdin);
	}

	//fgets includes the carriage return as a character, so we must replace it
	//with a null character
	strlength = strlen(userFileName);
	userFileName[strlength - 1] = '\0';

	printf("\nNow performing analysis...\n\n");

	Tracker *phatTracker = new Tracker(userFileName);

	analysisFailure = phatTracker->AnalyzeVideo(0,"test0");

	if(analysisFailure){
		printf("A problem occurred while analyzing the video files. These files can be found in the project folder.\n");
	}

	delete phatCap, phatTracker;

	return 0;
}

int captureVideo(CameraCap *cam){
	int capFailure = -1;
	char userInput[32];
	int numFrames = 0;
	while(capFailure){

		capFailure = cam->CaptureFromCameras();
		
		if(capFailure){
			printf("Image capture from cameras failed. Enter:\n");
			printf("\t'r' to retry capture,\n");
			printf("\t'n' to enter new number of frames and retry, or\n");
			printf("\tany other value to exit.\n\n");
			fgets(userInput,32,stdin);
			if(userInput[0] == 'r' || userInput[0] == 'R'){
				continue;
			} else if(userInput[0] == 'n' || userInput[0] == 'N') {
				printf("Please enter the number of frames to capture from each camera.\n\n");
				fgets(userInput, 32, stdin);
				numFrames = atoi(userInput);

				while(numFrames < 1){
					printf("\nInvalid entry detected. Please enter a positive integer value for number of\nframes to capture.\n\n");
					fgets(userInput, 32, stdin);
					numFrames = atoi(userInput);
					cam->setNumFrames((unsigned int) numFrames);
				}
			} else {
				return -1;
			}
		}
	}
	return 0;
}
