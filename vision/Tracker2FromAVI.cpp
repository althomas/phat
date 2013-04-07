//Tracker2

#include<opencv/cvaux.h>
#include<opencv/highgui.h>
#include<opencv/cxcore.h>

#include<stdio.h>
#include<stdlib.h>
#include "blob.h"
#include "BlobResult.h"

#define NUM_BEACONS 4
//#define USE_BLOBS

int main(int argc, char *argv[]){

#ifdef USE_BLOBS
  CBlobResult blobs;
	CBlob *currentBlob;
	int blobX = 0, blobY = 0;
#endif

	int i = 0; //Your friendly neighborhood loop counter

	int frame_count = 0;

	FILE *out = NULL;

	out = fopen("C:\\Users\\PHAT\\Desktop\\testOutput2.txt","w");

	if(!out){
		printf("ERROR: failed to open output text file.\n");
		getchar();
		return -1;
	}

	//CvSize size640x480 = cvSize(640, 480);	//Use a 640 x 480 size for all windows--verify webcam is 640 x 480

	CvCapture *p_capVideo = NULL;				//We will assign our web cam video stream to this later
	p_capVideo = cvCaptureFromAVI("C:\\Users\\PHAT\\My Documents\\Visual Studio 2010\\Projects\\TestPGCameras\\TestPGCameras\\raw_footage2-0000.avi");

	if(!p_capVideo){
		fprintf(stderr,"Failure initializing video stream\n");
		getchar();
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

	CvMemStorage *p_strStorage = NULL;			//A necessary sorting variable to pass into HoughCircles()

	CvSeq *p_seqCircles = NULL;				//Will be returned by cvHoughCircles() and contain all circles
											//Call cvGetSeqElem(p_seqCircles, i) will return a 3-element array of the ith circle
	
	float *p_fltXYRadius = NULL;			//Pointer to the the 3-element array ^
											//[0] => x position of detected object; [1] => y position of detected object; [2] => radius

	char charCheckForEscKey;				//char for checking key press (Esc exits program)

	//p_capWebcam = cvCaptureFromCAM(0);		//Gather images from first (only) connected webcam

	//Declare 2 windows
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

	printf("AVI FPS: %f\n",fps);

	p_imgOriginal = cvQueryFrame(p_capVideo);	//Get frame

	//fprintf(out, "Timestamp\tRx\tRy\tGx\tGy\tBx\tBy\tYx\tYy\n");

	if(p_imgOriginal == NULL){
		printf("ERROR: p_imgOriginal is NULL (capture failed).\n");
		getchar();
		return -1;
	}

	printf("Got to frame-by-frame analysis.\n");
	
	while(1){								//Use ESC key to exit

		if(!p_imgOriginal){
			printf("Reached end of video file.\n");
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

		printf("Filtered frame.\n");

		p_strStorage = cvCreateMemStorage(0);	//Allocate necessary memory variable to pass into cvHoughCircles
		
		printf("Allocated memory for cvHoughCircles.\n");

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

		printf("Gaussian smooth performed.\n");

		for(i = 0; i < NUM_BEACONS; i++){
			//Below we grab the data from each color, one at a time, and write the location of the beacons, along with the timestamp
			//of the data in question, to an output file.

#ifdef USE_BLOBS
			blobs = CBlobResult(processedImages[i], NULL, 0);
			if(blobs.GetNumBlobs()){
				//Extract information about beacon. NOTE: this assumes that only one beacon per color is found, as it only takes the
				//first element of p_seqCircles. If more than one "beacon" is found, the real beacon may be neglected.
				currentBlob = blobs.GetBlob(0);
				blobX = currentBlob->GetBoundingBox().x + (currentBlob->GetBoundingBox().width / 2);
				blobY = currentBlob->GetBoundingBox().y + (currentBlob->GetBoundingBox().height / 2);
				data_out[i * 2] = (float) blobX;
				data_out[i * 2 + 1] = (float) blobY;
			} else {
				data_out[i * 2] = 0.0;
				data_out[i * 2 + 1] = 0.0;
			}
#endif
#ifndef USE_BLOBS
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
#endif
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
				getchar();
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
			getchar();
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

	cvDestroyWindow("Original");
	cvDestroyWindow("Processed");

	return 0;
}
