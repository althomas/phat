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
		free(outputFileName);
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
		free(outputFileName);
		return DIRECTORY_NAME_FAILURE;
	}

	if(!(out || strcmp(this->textFilePath,""))){
		fprintf(stderr,"ERROR: failed to open output text file: \n%s\n\n",outputFileName);
		free(outputFileName);
		return EMPTY_DIRECTORY_NAME_FAILURE;
	}

	if(!out){
		fprintf(stderr,"ERROR: failed to open output text file: \n%s\n\n",outputFileName);
		free(outputFileName);
		return -1;
	}

	printf("Opened:\n%s\n\n",outputFileName);

	CvCapture *p_capVideo = NULL;
	p_capVideo = cvCaptureFromAVI(videoFileName);

	if(!p_capVideo){
		fprintf(stderr,"Failure initializing video stream for file %s\n\n",videoFileName);
		fclose(out);
		free(outputFileName);
		return -1;
	}

	//A set of IPL Images pointers (the standard image struct for OpenCV in C)
	//for frames pre- and post-analysis.
	IplImage *p_imgOriginal = NULL;		//The original		
	IplImage *p_imgProcessedRed = NULL;	//Filtered for red		
	IplImage *p_imgProcessedBlu = NULL;	//Filtered for blue
	IplImage *p_imgProcessedGrn = NULL;	//Filtered for green
	IplImage *p_imgProcessedWit = NULL;	//Filtered for yellow
	IplImage *p_imgProcessed = NULL;	//The four above images combined for viewing

	//An array to hold the processed images for each color, allowing us to
	//find the beacons color-by-color. Assumes RGBY beacons.
	IplImage **processedImages = (IplImage **) malloc(sizeof(IplImage*) * NUM_BEACONS);

	//An array for storing the location data for each beacon at each frame in the video
	double *data_out = (double *) malloc(sizeof(double) * NUM_BEACONS * 2);

	if(!(processedImages && data_out)){
		fprintf(stderr,"Problem allocating memory for buffers processedImages and data_out.\n");
		free(outputFileName);
		fclose(out);
		if(processedImages){
			free(processedImages);
		}
		if(data_out){
			free(data_out);
		}
		cvReleaseCapture(&p_capVideo);
		return -1;
	}

	for(i = 0; i < NUM_BEACONS * 2; i++){
		data_out[i] = 0.0;
	}

	//A necessary sorting variable to pass into HoughCircles()
	CvMemStorage *p_strStorage = NULL;	

	//Buffer into which cvHoughCircles will write circle information
	CvSeq *p_seqCircles = NULL;			
										
	//Pointer to allow access to the the 3-element arrays contained in
	//p_seqCircles. 3-element array will by in form [x; y; r]
	float *p_fltXYRadius = NULL;		

	//char for checking key press to exit program
	char charCheckForEscKey;

	//Declare analysis windows
	//cvNamedWindow("Original Image", CV_WINDOW_AUTOSIZE);	//Original image
	//cvNamedWindow("Processed Image", CV_WINDOW_AUTOSIZE);	//Processed image

	//Here we acquire qualities about the video to calibrate the IPLImage buffers
	p_imgOriginal = cvQueryFrame(p_capVideo);

	//Cancel if frame acquisition failed
	if(!p_imgOriginal){
		fprintf(stderr,"ERROR: p_imgOriginal is NULL (capture failed).\n");
		fclose(out);
		free(outputFileName);
		free(processedImages);
		free(data_out);
		cvReleaseCapture(&p_capVideo);
		return -1;
	}

	int width = p_imgOriginal->width;
	int height = p_imgOriginal->height;
	int channels = p_imgOriginal->nChannels;
	int step = p_imgOriginal->widthStep;

	//Creating a macro for the correct size
	CvSize p_imgSize = cvSize(width, height);
	
	//Now, assign the buffers correct sizes accordingly
	p_imgProcessed = cvCreateImage(p_imgSize, IPL_DEPTH_8U, 1);
	p_imgProcessedRed = cvCreateImage(p_imgSize, IPL_DEPTH_8U, 1);
	p_imgProcessedGrn = cvCreateImage(p_imgSize, IPL_DEPTH_8U, 1);
	p_imgProcessedBlu = cvCreateImage(p_imgSize, IPL_DEPTH_8U, 1);
	p_imgProcessedWit = cvCreateImage(p_imgSize, IPL_DEPTH_8U, 1);

	//Assign values to image buffer to allow for iteration
	processedImages[0] = p_imgProcessedRed;
	processedImages[1] = p_imgProcessedGrn;
	processedImages[2] = p_imgProcessedBlu;
	processedImages[3] = p_imgProcessedWit;

	double fps = 0.0;

	fps = cvGetCaptureProperty(p_capVideo, CV_CAP_PROP_FPS);

	//Deprecated fprintf statement outlining format of output text file
	//fprintf(out, "Timestamp\tRx\tRy\tGx\tGy\tBx\tBy\tYx\tYy\n");
	
	while(1){

		if(!p_imgOriginal){
			printf("Reached end of video file.\n\n");
			break;
		}
		
		//Filter the original frame for the beacons based on RGB values derived
		//experimentally.

		cvInRangeS(p_imgOriginal,		//Function input
				  CV_RGB(180, 0, 0),	//Min filtering value--if color is greater or equal to this...
				  CV_RGB(255, 60, 20),	//Max filtering value--...and if color is less than this
				  p_imgProcessedRed);	//Function output (void function, paramter passed by reference)

		cvInRangeS(p_imgOriginal,			
				  CV_RGB(40, 100, 0),		
				  CV_RGB(155, 255, 20),	
				  p_imgProcessedGrn);		
		
		cvInRangeS(p_imgOriginal,			
				  CV_RGB(0, 50, 145),		
				  CV_RGB(70, 255, 255),	
				  p_imgProcessedBlu);		

		//Yellow's tricky; set to dummy values for white right now
		cvInRangeS(p_imgOriginal,			
				  CV_RGB(180, 180, 180),		
				  CV_RGB(255, 255, 255),	
				  p_imgProcessedWit);		

		//Allocate necessary memory variable to pass into cvHoughCircles
		p_strStorage = cvCreateMemStorage(0);

		for(i = 0; i < NUM_BEACONS; i++){
			//Here, we smooth the images for each color, making it easier for
			//Hough Circles to work with. This blur operation is done with a 
			//large window size (21) to allow the formation of blobs in the
			//processed images. To ensure that Hough Circles can pick up these
			//blobs, which may be a faint gray, the images are then saturated.
			//The black background stays black, and the detected blobs are 
			//amplified to pure white from gray.
			cvSmooth(processedImages[i],
				     processedImages[i],
					 CV_GAUSSIAN,
					 21,
					 21);

			cvScale(processedImages[i],processedImages[i],255.0,0.0);

			//Below we grab the data from each color, one at a time, and write the location of the beacons, along with the timestamp
			//of the data in question, to an output file.
			p_seqCircles = cvHoughCircles(processedImages[i],	//Input image; note that this HAS TO BE GRAYSCALE
										p_strStorage,		//Provide function with memory storage, makes function return pointer to a CVSeq struct
										CV_HOUGH_GRADIENT,	//Two-pass algorithm for detecting circles
										2,				//Size of image divided by this value gives accumulator resolution
										processedImages[i]->height,	//Min distance in pixels between the centers of detected circles
										100,			//High threshold of the Canny edge detector, called by cvHoughCircle
										10,				//Low threshold " " " ...; is set low to allow better blob detection
										4,				//Minimum circle radius in pixels
										50);			//Maximum circle radius in pixels			

			//Extract data from result of Hough Circles algorithm into data_out; use zeros to indicate no beacon found.
			if(p_seqCircles->total){
				//Extract information about beacon. NOTE: this assumes that only
				//one beacon per color is found, as it only takes the first
				//element of p_seqCircles. If more than one "beacon" is found,
				//the real beacon may be neglected.
				p_fltXYRadius = (float *)cvGetSeqElem(p_seqCircles, 0);
				data_out[i * 2] = p_fltXYRadius[0];
				data_out[i * 2 + 1] = p_fltXYRadius[1];
			} else {
				//If no circle is found, indicate as such in buffer with value 0.0
				data_out[i * 2] = 0.0;
				data_out[i * 2 + 1] = 0.0;
			}

			//Write data to output text file
			switch (i)
			{
			case 0: 
				//First beacon: include timestamp. Note that timestamp values
				//are calculated via the framerate, necessitating that the .avi
				//file framerate reflects the real-time capture rate.
				fprintf(out, "%f,%d,%d,", ((float) frame_count) / fps, (int) data_out[i * 2], (int) data_out[i * 2 + 1]);
				if(data_out[i * 2] != 0.0){
					//Here we mark the beacon found in a visible window. This 
					//is repeated for each beacon and the outputs are combined
					//using an alpha blend into one picture for viewing.
					cvCircle(p_imgOriginal,		
						 cvPoint(cvRound(data_out[i * 2]), //Circle x coordinate
						 cvRound(data_out[i * 2 + 1])),    //Circle y coordinate
						 10,						//Circle of radius 10
						 CV_RGB(120, 120, 120),		//Gray circle
						 3);						//3 pixels thick
				}
				break;
			case 1:
				fprintf(out, "%d,%d,", (int) data_out[i * 2], (int) data_out[i * 2 + 1]);
				if(data_out[i * 2] != 0.0){
					cvCircle(p_imgOriginal,	
						 cvPoint(cvRound(data_out[i * 2]),
						 cvRound(data_out[i * 2 + 1])),
						 10,						
						 CV_RGB(120, 120, 120),		
						 3);				
				}
				break;
			case 2:
				fprintf(out, "%d,%d,", (int) data_out[i * 2], (int) data_out[i * 2 + 1]);
				if(data_out[i * 2] != 0.0){
					cvCircle(p_imgOriginal,		
						 cvPoint(cvRound(data_out[i * 2]),
						 cvRound(data_out[i * 2 + 1])),
						 10,				
						 CV_RGB(120, 120, 120),	
						 3);						
				}
				break;
			case 3:
				//Last beacon: include line break
				fprintf(out, "%d,%d\n", (int) data_out[i * 2], (int) data_out[i * 2 + 1]);
				if(data_out[i * 2] != 0.0){
					cvCircle(p_imgOriginal,	
						 cvPoint(cvRound(data_out[i * 2]),
						 cvRound(data_out[i * 2 + 1])),
						 10,			
						 CV_RGB(120, 120, 120),
						 3);				
				}
				break;
			default:
				fprintf(stderr, "Somehow the switch statement got broken. Look into it.\n");
				fclose(out);
				free(outputFileName);
				free(processedImages);
				free(data_out);
				cvReleaseCapture(&p_capVideo);
				return -1;
				break;
			}//End beacon switch statement
			
		}//End analysis loop

		//cvShowImage("Original", p_imgOriginal);	//Original image, with circle overlaid

		//Combine filtered images, with overlaid circles, into one visible image
		cvAddWeighted(p_imgProcessedBlu, 1, p_imgProcessedRed, 1, 0.0, p_imgProcessed);
		cvAddWeighted(p_imgProcessed, 1, p_imgProcessedGrn, 1, 0.0, p_imgProcessed);
		cvAddWeighted(p_imgProcessed, 1, p_imgProcessedWit, 1, 0.0, p_imgProcessed);

		//...and hope nothing goes wrong!
		if(!p_imgProcessed){
			fprintf(stderr, "ERROR: p_imgProcessed still NULL!\n");
			free(outputFileName);
			fclose(out);
			free(processedImages);
			free(data_out);
			cvReleaseCapture(&p_capVideo);
			return -1;
		}

		//Show off your work
		cvShowImage("Original", p_imgOriginal);
		cvShowImage("Processed", p_imgProcessed);

		//Deallocate necessary storage variable
		cvReleaseMemStorage(&p_strStorage);	

		//If Esc key (ASCII 27) was pressed, jump out of while loop
		charCheckForEscKey = cvWaitKey(10);
		if(charCheckForEscKey == 27) break;		

		//Reset buffer array
		for(i = 0; i < NUM_BEACONS * 2; i++){
			data_out[i] = 0.0;
		}

		//Grab new frame
		p_imgOriginal = cvQueryFrame(p_capVideo);
		
		frame_count++;

	}//End while

	//Housekeeping...
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
