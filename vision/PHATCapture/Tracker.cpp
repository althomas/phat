/* File: Tracker.cpp
   Author: Cam Cogan
   Desc: Implementation file for video analysis class
   Credits: The implementation below would not have been possible without the
            assistance of the video "OpenCV tutorial 1 - config with MS VC++
	    2010, 1st object recognition and tracking program" (available at
	    www.youtube.com/watch?v=2i2bt-YSIYQ as of 4/8/2013) by the Youtube
	    user 18F4550videos.
*/

#include "Tracker.h"

//Software currently implemented using 4 beacons. Much of this is hard-coded,
//so the definition occurs here in the .cpp file so it can be changed as needed.
#define NUM_BEACONS 4

Tracker::Tracker(const char *outputFilePath)
{
	textFilePath = new char[BUFFER_SIZE];
	int strlength = strlen(outputFilePath);
	strncpy(textFilePath, outputFilePath, strlength);
	//strncpy doesn't copy a null character over, so we must do it here
	textFilePath[strlength] = '\0';
}

Tracker::~Tracker()
{
	delete[] textFilePath;
}

int Tracker::AnalyzeVideo(const char *videoFileName, const char *textFileName)
{

	char *outputFileName = (char *)malloc(sizeof(char) * BUFFER_SIZE);

	if(!outputFileName){
		fprintf(stderr,"Problem allocating heap memory for char *outputFileName.\n");
		return -1;
	}

	int i = 0; //Your friendly neighborhood loop counter

	int frame_count = 0;

	//Forming the filename of the output file

	int inputStringLength = strlen(textFileName);
	int folderStringLength = strlen(textFilePath);

	if((inputStringLength + folderStringLength + 1) > BUFFER_SIZE){
		fprintf(stderr,"ERROR: File output name larger than max buffer size of %d.\n",BUFFER_SIZE);
		return -1;
	}

	strncpy(outputFileName,textFilePath,folderStringLength);

	for(i = 0; i < inputStringLength; i++){
		outputFileName[folderStringLength + i] = textFileName[i];
	}

	outputFileName[inputStringLength + folderStringLength] = '\0';

	FILE *out = NULL;

	out = fopen(outputFileName,"w");

	//Below we have two different forms of failure outlined for writing the 
	//output text files. In the first, the program suspects the user input is
	//incorrect and is a bad path, and signals to the main routine to reset the
	//Tracker object's default path to the project directory a la "". In the 
	//second case, this reset has already been performed, and so the program
	//fails and exits, notifying the user that the video files can still be 
	//recovered.
	if(!out && strcmp(this->textFilePath,"")){
		fprintf(stderr,"ERROR: failed to open output text file: \n%s\n\n",outputFileName);
		return DIRECTORY_NAME_FAILURE;
	}

	if(!(out || strcmp(this->textFilePath,""))){
		fprintf(stderr,"ERROR: failed to open output text file: \n%s\n\n",outputFileName);
		return EMPTY_DIRECTORY_NAME_FAILURE;
	}

	if(!out){
		fprintf(stderr,"ERROR: failed to open output text file: \n%s\n\n",outputFileName);
		return -1;
	}

	printf("Opened:\n%s\n\n",outputFileName);

	CvCapture *p_capVideo = NULL;
	p_capVideo = cvCaptureFromAVI(videoFileName);

	if(!p_capVideo){
		fprintf(stderr,"Failure initializing video stream for file %s\n\n",videoFileName);
		return -1;
	}

	/*Apparently IPL is short for Intel Image Processing Library, and is the standard struct used n OpenCV1.x */
	IplImage *p_imgOriginal = NULL;				//Pointer to an image structure; this will be the input image from the webcam
	IplImage *p_imgProcessedRed = NULL;			//Pointer to an image structure; this will be the processed image
	IplImage *p_imgProcessedBlu = NULL;			//Pointer to an image structure; this will be the processed image
	IplImage *p_imgProcessedGrn = NULL;			//Pointer to an image structure; this will be the processed image
	IplImage *p_imgProcessedYlo = NULL;			//Pointer to an image structure; this will be the processed image
	IplImage *p_imgProcessed = NULL;			//Pointer to an image structure; this will be the processed image

	//An array to hold the processed images for each color, allowing us to find the beacons color-by-color. Assumes RGBY beacons.
	IplImage **processedImages = (IplImage **) malloc(sizeof(IplImage*) * NUM_BEACONS);

	//An array for storing the location data for each beacon at each frame in the video
	double *data_out = (double *) malloc(sizeof(double) * NUM_BEACONS * 2);

	for(i = 0; i < NUM_BEACONS * 2; i++){
		data_out[i] = 0.0;
	}

	CvMemStorage *p_strStorage = NULL;		//A necessary sorting variable to pass into HoughCircles()

	CvSeq *p_seqCircles = NULL;				//Will be returned by cvHoughCircles() and contain all circles
											//Call cvGetSeqElem(p_seqCircles, i) will return a 3-element array of the ith circle
	
	float *p_fltXYRadius = NULL;			//Pointer to the the 3-element array ^
											//[0] => x position of detected object; [1] => y position of detected object; [2] => radius

	char charCheckForEscKey;				//char for checking key press (Esc exits program)

	//Declare analysis windows
	//cvNamedWindow("Original Image", CV_WINDOW_AUTOSIZE);	//Original image from webcam
	cvNamedWindow("Processed Image", CV_WINDOW_AUTOSIZE);	//Processed image

	p_imgOriginal = cvQueryFrame(p_capVideo);

	int width = p_imgOriginal->width;
	int height = p_imgOriginal->height;
	int channels = p_imgOriginal->nChannels;
	int step = p_imgOriginal->widthStep;

	CvSize p_imgSize = cvSize(width, height);
	
	p_imgProcessed = cvCreateImage(p_imgSize, IPL_DEPTH_8U, 1);
	p_imgProcessedRed = cvCreateImage(p_imgSize, IPL_DEPTH_8U, 1);
	p_imgProcessedGrn = cvCreateImage(p_imgSize, IPL_DEPTH_8U, 1);
	p_imgProcessedBlu = cvCreateImage(p_imgSize, IPL_DEPTH_8U, 1);
	p_imgProcessedYlo = cvCreateImage(p_imgSize, IPL_DEPTH_8U, 1);

	processedImages[0] = p_imgProcessedRed;
	processedImages[1] = p_imgProcessedGrn;
	processedImages[2] = p_imgProcessedBlu;
	processedImages[3] = p_imgProcessedYlo;

	double fps = 0.0;

	fps = cvGetCaptureProperty(p_capVideo, CV_CAP_PROP_FPS);

	p_imgOriginal = cvQueryFrame(p_capVideo);	//Get frame

	//fprintf(out, "Timestamp\tRx\tRy\tGx\tGy\tBx\tBy\tYx\tYy\n");

	if(p_imgOriginal == NULL){
		printf("ERROR: p_imgOriginal is NULL (capture failed).\n");
		return -1;
	}
	
	while(1){								//Use ESC key to exit

		if(!p_imgOriginal){
			printf("Reached end of video file.\n\n");
			break;
		}
		
		//Locate beacons for each color in frame

		cvInRangeS(p_imgOriginal,			//Function input
				  CV_RGB(175, 0, 0),		//Min filtering value--if color is greater or equal to this...
				  CV_RGB(255, 120, 120),	//Max filtering value--...and if color is less than this
				  p_imgProcessedRed);		//Function output (void function, paramter passed by reference)

		cvInRangeS(p_imgOriginal,			//Function input
				  CV_RGB(0, 170, 0),		//Min filtering value--if color is greater or equal to this...
				  CV_RGB(200, 255, 160),	//Max filtering value--...and if color is less than this
				  p_imgProcessedGrn);		//Function output (void function, paramter passed by reference)
		
		cvInRangeS(p_imgOriginal,			//Function input
				  CV_RGB(0, 0, 170),		//Min filtering value--if color is greater or equal to this...
				  CV_RGB(120, 120, 255),	//Max filtering value--...and if color is less than this
				  p_imgProcessedBlu);		//Function output (void function, paramter passed by reference)

		cvInRangeS(p_imgOriginal,			//Function input
				  CV_RGB(210, 180, 40),		//Min filtering value--if color is greater or equal to this...
				  CV_RGB(255, 255, 150),	//Max filtering value--...and if color is less than this
				  p_imgProcessedYlo);		//Function output (void function, paramter passed by reference)

		p_strStorage = cvCreateMemStorage(0);	//Allocate necessary memory variable to pass into cvHoughCircles

		//Here, we smooth the images for each color, making it easier for Hough Circles to work with

		cvSmooth(p_imgProcessedRed,			//Function input
				 p_imgProcessedRed,			//Function output (void, pass by reference)
				 CV_GAUSSIAN,				//Use Gaussian filter (averages nearby pixels, with closest weighted more)
				 9,							//Smoothing window width
				 9);						//Smoothing window height

		cvSmooth(p_imgProcessedGrn,			//Function input
				 p_imgProcessedGrn,			//Function output (void, pass by reference)
				 CV_GAUSSIAN,				//Use Gaussian filter (averages nearby pixels, with closest weighted more)
				 9,							//Smoothing window width
				 9);						//Smoothing window height

		cvSmooth(p_imgProcessedBlu,			//Function input
				 p_imgProcessedBlu,			//Function output (void, pass by reference)
				 CV_GAUSSIAN,				//Use Gaussian filter (averages nearby pixels, with closest weighted more)
				 9,						//Smoothing window width
				 9);						//Smoothing window height

		cvSmooth(p_imgProcessedYlo,			//Function input
				 p_imgProcessedYlo,			//Function output (void, pass by reference)
				 CV_GAUSSIAN,				//Use Gaussian filter (averages nearby pixels, with closest weighted more)
				 9,							//Smoothing window width
				 9);						//Smoothing window height

		for(i = 0; i < NUM_BEACONS; i++){
			//Below we grab the data from each color, one at a time, and write the location of the beacons, along with the timestamp
			//of the data in question, to an output file.
			p_seqCircles = cvHoughCircles(processedImages[i],	//Input image; note that this HAS TO BE GRAYSCALE
										p_strStorage,		//Provide function with memory storage, makes function return pointer to a CVSeq struct
										CV_HOUGH_GRADIENT,	//Two-pass algorithm for detecting circles
										2,				//Size of image divided by this value gives accumulator resolution
										processedImages[i]->height,	//Min distance in pixels between the centers of detected circles
										100,				//High threshold of the Canny edge detector, called by cvHoughCircle
										50,				//Low threshold " " " ...; as rule of thumb, low should be half of high
										3,				//Minimum circle radius in pixels
										200);				//Maximum circle radius in pixels			

			//Extract data from result of Hough Circles algorithm into data_out; use zeros to indicate no beacon found.
			if(p_seqCircles->total){
				//Extract information about beacon. NOTE: this assumes that only one beacon per color is found, as it only takes the
				//first element of p_seqCircles. If more than one "beacon" is found, the real beacon may be neglected.
				p_fltXYRadius = (float *)cvGetSeqElem(p_seqCircles, 0);
				data_out[i * 2] = p_fltXYRadius[0];
				data_out[i * 2 + 1] = p_fltXYRadius[1];
			} else {
				data_out[i * 2] = 0.0;
				data_out[i * 2 + 1] = 0.0;
			}
			//printf("Beacon %d position: x = %f, y = %f\n", i, data_out[i * 2], data_out[i * 2 + 1]);

			//Write data to output text file
			switch (i)
			{
			case 0: 
				//First beacon: include timestamp
				fprintf(out, "%f,%d,%d,", ((float) frame_count) / fps, (int) data_out[i * 2], (int) data_out[i * 2 + 1]);
				if(data_out[i * 2] != 0.0){
					cvCircle(p_imgProcessedRed,				//Draw a red circle around the detected object
						 cvPoint(cvRound(data_out[i * 2]), cvRound(data_out[i * 2 + 1])),
						 10,						//Circle of radius 10
						 CV_RGB(255, 255, 255),		//White circle
						 3);						//3 pixels thick
				}
				break;
			case 1:
				fprintf(out, "%d,%d,", (int) data_out[i * 2], (int) data_out[i * 2 + 1]);
				if(data_out[i * 2] != 0.0){
					cvCircle(p_imgProcessedGrn,				//Draw a red circle around the detected object
						 cvPoint(cvRound(data_out[i * 2]), cvRound(data_out[i * 2 + 1])),
						 10,						//Circle of radius 10
						 CV_RGB(255, 255, 255),		//White circle
						 3);						//3 pixels thick
				}
				break;
			case 2:
				fprintf(out, "%d,%d,", (int) data_out[i * 2], (int) data_out[i * 2 + 1]);
				if(data_out[i * 2] != 0.0){
					cvCircle(p_imgProcessedBlu,				//Draw a red circle around the detected object
						 cvPoint(cvRound(data_out[i * 2]), cvRound(data_out[i * 2 + 1])),
						 10,						//Circle of radius 10
						 CV_RGB(255, 255, 255),		//White circle
						 3);						//3 pixels thick
				}
				break;
			case 3:
				//Last beacon: include line break
				fprintf(out, "%d,%d\n", (int) data_out[i * 2], (int) data_out[i * 2 + 1]);
				if(data_out[i * 2] != 0.0){
					cvCircle(p_imgProcessedYlo,				//Draw a red circle around the detected object
						 cvPoint(cvRound(data_out[i * 2]), cvRound(data_out[i * 2 + 1])),
						 10,						//Circle of radius 10
						 CV_RGB(255, 255, 255),		//White circle
						 3);						//3 pixels thick
				}
				break;
			default:
				fprintf(stderr, "Somehow the switch statement got broken. Look into it.\n");
				return -1;
				break;
			}//End beacon switch statement
			
		}//End analysis loop

		//cvShowImage("Original", p_imgOriginal);	//Original image, with circle overlaid

		cvAddWeighted(p_imgProcessedBlu, 1, p_imgProcessedRed, 1, 0.0, p_imgProcessed);
		cvAddWeighted(p_imgProcessed, 1, p_imgProcessedGrn, 1, 0.0, p_imgProcessed);
		cvAddWeighted(p_imgProcessed, 1, p_imgProcessedYlo, 1, 0.0, p_imgProcessed);

		if(!p_imgProcessed){
			fprintf(stderr, "ERROR: p_imgProcessed still NULL!\n");
			return -1;
		}

		cvShowImage("Processed", p_imgProcessed);	//Image after processing

		cvReleaseMemStorage(&p_strStorage);		//Deallocate necessary storage variable to pass into cvHoughCircles

		charCheckForEscKey = cvWaitKey(10);
		if(charCheckForEscKey == 27) break;		//If Esc key (ASCII 27) was pressed, jump out of while loop

		//Reset data array, allowing us to keep track of poor entries
		for(i = 0; i < NUM_BEACONS * 2; i++){
			data_out[i] = 0.0;
		}

		//Grab new frame
		p_imgOriginal = cvQueryFrame(p_capVideo);
		
		frame_count++;

	}//End while

	cvReleaseCapture(&p_capVideo);

	fclose(out);

	free(processedImages);
	free(data_out);
	free(outputFileName);

	cvDestroyWindow("Original");
	cvDestroyWindow("Processed");

	return 0;
}

void Tracker::ResetFilePath()
{
	strcpy(this->textFilePath,"");
}
