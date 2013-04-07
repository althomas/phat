//=============================================================================
// Copyright © 2008 Point Grey Research, Inc. All Rights Reserved.
//
// This software is the confidential and proprietary information of Point
// Grey Research, Inc. ("Confidential Information").  You shall not
// disclose such Confidential Information and shall use it only in
// accordance with the terms of the license agreement you entered into
// with PGR.
//
// PGR MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE
// SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE, OR NON-INFRINGEMENT. PGR SHALL NOT BE LIABLE FOR ANY DAMAGES
// SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING
// THIS SOFTWARE OR ITS DERIVATIVES.
//=============================================================================
//=============================================================================
// $Id: MultipleCameraEx.cpp,v 1.17 2010-02-26 01:00:50 soowei Exp $
//=============================================================================

#include "stdafx.h"

#include "FlyCapture2.h"
#include <vector>

using namespace FlyCapture2;

enum AviType
{
    UNCOMPRESSED,
    MJPG,
    H264
};

void PrintBuildInfo()
{
    FC2Version fc2Version;
    Utilities::GetLibraryVersion( &fc2Version );
    char version[128];
    sprintf( 
        version, 
        "FlyCapture2 library version: %d.%d.%d.%d\n", 
        fc2Version.major, fc2Version.minor, fc2Version.type, fc2Version.build );

    printf( "%s", version );

    char timeStamp[512];
    sprintf( timeStamp, "Application build date: %s %s\n\n", __DATE__, __TIME__ );

    printf( "%s", timeStamp );
}

void PrintCameraInfo( CameraInfo* pCamInfo )
{
    printf(
        "\n*** CAMERA INFORMATION ***\n"
        "Serial number - %u\n"
        "Camera model - %s\n"
        "Camera vendor - %s\n"
        "Sensor - %s\n"
        "Resolution - %s\n"
        "Firmware version - %s\n"
        "Firmware build time - %s\n\n",
        pCamInfo->serialNumber,
        pCamInfo->modelName,
        pCamInfo->vendorName,
        pCamInfo->sensorInfo,
        pCamInfo->sensorResolution,
        pCamInfo->firmwareVersion,
        pCamInfo->firmwareBuildTime );
}

void PrintError( Error error )
{
    error.PrintErrorTrace();
}

void SaveAviHelper(
    AviType aviType, 
    std::vector<Image>& vecImages, 
    unsigned int numCameras, 
    float frameRate)
{
    Error error;
    AVIRecorder **aviRecorders = (AVIRecorder **) malloc(sizeof(AVIRecorder) * numCameras);
  
	for(unsigned int i = 0; i < numCameras; i++){
		AVIRecorder *tempNameGoesHere = new AVIRecorder();
		aviRecorders[i] = tempNameGoesHere;
	}

    // Open the AVI file for appending images
	//printf("Made it into the helper function.\n");
    switch (aviType)
    {
    case UNCOMPRESSED:
        {

            AVIOption option;     
            option.frameRate = frameRate;
			char aviFileName[512] = {0};
			for(unsigned int i = 0; i < numCameras; i++){
				sprintf(aviFileName, "raw_footage%d", i);
				error = aviRecorders[i]->AVIOpen(((std::string) aviFileName).c_str(), &option);
				if(error != PGRERROR_OK){
					PrintError(error);
					return;
				}
			}
        }
        break;
    case MJPG:
        {
            MJPGOption option;
            option.frameRate = frameRate;
            option.quality = 75;
            char aviFileName[512] = {0};
			printf("Got to the avi recorder allocation.\n");
			for(unsigned int i = 0; i < numCameras; i++){
				sprintf(aviFileName, "raw_footage%d", i);
				printf("Avifilename produced %s\n",aviFileName);
				error = aviRecorders[i]->AVIOpen(((std::string) aviFileName).c_str(), &option);
				if(error != PGRERROR_OK){
					PrintError(error);
					return;
				}
				printf("avi recorder %d established.\n", i);
			}
        }
        break;
    case H264:
        {
            H264Option option;
            option.frameRate = frameRate;
            option.bitrate = 1000000;
            option.height = vecImages[0].GetRows();
            option.width = vecImages[0].GetCols();
            char aviFileName[512] = {0};
			for(unsigned int i = 0; i < numCameras; i++){
				sprintf(aviFileName, "raw_footage%d", i);
				error = aviRecorders[i]->AVIOpen(((std::string) aviFileName).c_str(), &option);
				if(error != PGRERROR_OK){
					PrintError(error);
					return;
				}
			}
        }
        break;
    }       

    if (error != PGRERROR_OK)
    {
        PrintError(error);
        return;
    } 

	printf("Size of vector: %d\n", vecImages.size());

    //printf( "\nAppending %d images to AVI file: %s ... \n", vecImages.size(), aviFileName.c_str() );
	printf("aviRecorders[0]: %x\naviRecorders[1]: %x\n",aviRecorders[0],aviRecorders[1]);
    for (unsigned int imageCnt = 0; imageCnt < vecImages.size(); imageCnt++)    
    {
        // Append the image to AVI file
        error = aviRecorders[imageCnt % numCameras]->AVIAppend(&vecImages[imageCnt]);
        if (error != PGRERROR_OK)
        {
            PrintError(error);
            break;
        }

        printf("Appended image %d...\n", imageCnt); 
    }

    // Close the AVI file
	for(unsigned int i = 0; i < numCameras; i++){
	    error = aviRecorders[i]->AVIClose( );
	}

	free(aviRecorders);

    if (error != PGRERROR_OK)
    {
        PrintError(error);
        return;
    } 
}


int main(int /*argc*/, char** /*argv*/)
{
    PrintBuildInfo();

    const int k_numImages = 100;
    Error error;

	//The vector to be used for storing images temporarily
	std::vector<Image> vecImages;

    BusManager busMgr;
    unsigned int numCameras;
    error = busMgr.GetNumOfCameras(&numCameras);
    if (error != PGRERROR_OK)
    {
        PrintError( error );
        return -1;
    }

    printf( "Number of cameras detected: %u\n", numCameras );

    if ( numCameras < 1 )
    {
        printf( "Insufficient number of cameras... press Enter to exit.\n" );
        getchar();
        return -1;
    }

	vecImages.resize(k_numImages * numCameras);

    Camera** ppCameras = new Camera*[numCameras];

    // Connect to all detected cameras and attempt to set them to
    // a common video mode and frame rate
    for ( unsigned int i = 0; i < numCameras; i++)
    {
        ppCameras[i] = new Camera();

        PGRGuid guid;
        error = busMgr.GetCameraFromIndex( i, &guid );
        if (error != PGRERROR_OK)
        {
            PrintError( error );
            return -1;
        }

        // Connect to a camera
        error = ppCameras[i]->Connect( &guid );
        if (error != PGRERROR_OK)
        {
            PrintError( error );
            return -1;
        }

        // Get the camera information
        CameraInfo camInfo;
        error = ppCameras[i]->GetCameraInfo( &camInfo );
        if (error != PGRERROR_OK)
        {
            PrintError( error );
            return -1;
        }

        PrintCameraInfo(&camInfo); 

        // Set all cameras to a specific mode and frame rate so they
        // can be synchronized
        error = ppCameras[i]->SetVideoModeAndFrameRate( 
            VIDEOMODE_640x480Y8, 
            FRAMERATE_30 );
        if (error != PGRERROR_OK)
        {
            PrintError( error );
            printf( 
                "Error starting cameras. \n"
                "This example requires cameras to be able to set to 640x480 Y8 at 30fps. \n"
                "If your camera does not support this mode, please edit the source code and recompile the application. \n"
                "Press Enter to exit. \n");
            getchar();
            return -1;
        }
    }
    
    error = Camera::StartSyncCapture( numCameras, (const Camera**)ppCameras );
    if (error != PGRERROR_OK)
    {
        PrintError( error );
        printf( 
            "Error starting cameras. \n"
            "This example requires cameras to be able to set to 640x480 Y8 at 30fps. \n"
            "If your camera does not support this mode, please edit the source code and recompile the application. \n"
            "Press Enter to exit. \n");
        getchar();
        return -1;
    }

	Image image;
    for ( int j = 0; j < k_numImages; j++ )
    {
        // Display the timestamps for all cameras to show that the image
        // capture is synchronized for each image
        for ( unsigned int i = 0; i < numCameras; i++ )
        {
            error = ppCameras[i]->RetrieveBuffer( &image );
            if (error != PGRERROR_OK)
            {
                PrintError( error );
                return -1;
            }

            TimeStamp timestamp = image.GetTimeStamp();
            printf( 
                "Cam %d - Frame %d - TimeStamp [%d %d]\n", 
                i, 
                j, 
                timestamp.cycleSeconds, 
                timestamp.cycleCount);
			vecImages[i + numCameras * j].DeepCopy( &image );
        }
    }

	PropertyInfo propInfo;
	propInfo.type = FRAME_RATE;
	error = ppCameras[0]->GetPropertyInfo( &propInfo );
	if(error != PGRERROR_OK)
	{
		PrintError(error);
		return -1;
	}

	float frameRateToUse = 15.0f;

	if(propInfo.present == true)
	{
		Property prop;
		prop.type = FRAME_RATE;
		error = ppCameras[0]->GetProperty( &prop );
		if(error == PGRERROR_OK)
		{
			PrintError(error);
		}
		frameRateToUse = prop.absValue;
	}

	printf("Writing .avi files with frame rate of %3.1f\n",frameRateToUse);

	SaveAviHelper(MJPG, vecImages, numCameras, frameRateToUse);

    for( unsigned int i = 0; i < numCameras; i++ )
    {
        ppCameras[i]->StopCapture();
        ppCameras[i]->Disconnect();
        delete ppCameras[i];
    }

    delete [] ppCameras;

    printf( "Done! Press Enter to exit...\n" );
    getchar();

	return 0;
}
