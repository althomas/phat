/* File: CameraCap.cpp
   Author: Cam Cogan
   Desc: Implementation file for CameraCap class
   Credits: Several functions below use code  derived from software developed
            by Point Grey Research, Inc., without whose cameras and 
			accompanying API this project would not have been possible.
*/

#include "CameraCap.h"

#define PRINT_CAMERA_INFO 0
#define SHUTTER_SPEED 5

CameraCap::CameraCap(unsigned int nF)
{
	nFrames = nF;
	nCameras = 0;
	expFPS = 0.0;
}

void CameraCap::PrintBuildInfo()
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

void CameraCap::PrintCameraInfo(CameraInfo *pCamInfo)
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

void CameraCap::PrintError(Error error)
{
	error.PrintErrorTrace();
}

void CameraCap::SaveAviHelper(AviType aviType, 
    std::vector<Image>& vecImages,
    float frameRate)
{
	Error error;
    AVIRecorder **aviRecorders = (AVIRecorder **) malloc(sizeof(AVIRecorder) * nCameras);
	
	for(unsigned int i = 0; i < nCameras; i++){
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
			for(unsigned int i = 0; i < nCameras; i++){
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
			for(unsigned int i = 0; i < nCameras; i++){
				sprintf(aviFileName, "raw_footage%d", i);
				error = aviRecorders[i]->AVIOpen(((std::string) aviFileName).c_str(), &option);
				if(error != PGRERROR_OK){
					PrintError(error);
					return;
				}
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
			for(unsigned int i = 0; i < nCameras; i++){
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
	
    for (unsigned int imageCnt = 0; imageCnt < vecImages.size(); imageCnt++)    
    {
        // Append the image to AVI file
        error = aviRecorders[imageCnt % nCameras]->AVIAppend(&vecImages[imageCnt]);
        if (error != PGRERROR_OK)
        {
            PrintError(error);
            break;
        }

    }

    // Close the AVI file
	for(unsigned int i = 0; i < nCameras; i++){
	    error = aviRecorders[i]->AVIClose( );
	}

	free(aviRecorders);

    if (error != PGRERROR_OK)
    {
        PrintError(error);
        return;
    } 
}

int CameraCap::CaptureFromCameras()
{
	if(nFrames < 1){
		fprintf(stderr,"Invalid number of frames entered. Camera capture failed.\n\n");
		return -1;
	}

    PrintBuildInfo();

	//Variables used in determing framerate of output AVI files
	float avgFps = 0.0;
	clock_t prevTime;
	clock_t maxTime;
	clock_t minTime;
	clock_t *times = (clock_t *) malloc(nFrames * sizeof(clock_t));

    int k_numImages = nFrames;
    Error error;

	//The vector to be used for storing images temporarily
	std::vector<Image> vecImages;

    BusManager busMgr;
    unsigned int numCameras = 0;
    error = busMgr.GetNumOfCameras(&numCameras);
    if (error != PGRERROR_OK)
    {
        PrintError( error );
        return -1;
    }

	this->nCameras = numCameras;

    printf( "Number of cameras detected: %u\n\n", nCameras );

    if ( nCameras < 1 )
    {
        fprintf(stderr,"Insufficient number of cameras detected.\n\n" );
        return -1;
    }

	vecImages.resize(k_numImages * nCameras);

    Camera** ppCameras = new Camera*[nCameras];

    // Connect to all detected cameras and attempt to set them to
    // a common video mode and frame rate
    for (unsigned int i = 0; i < nCameras; i++)
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
		if(PRINT_CAMERA_INFO){
	        CameraInfo camInfo;
	        error = ppCameras[i]->GetCameraInfo( &camInfo );
	        if (error != PGRERROR_OK)
	        {
	            PrintError( error );
	            return -1;
			}

			PrintCameraInfo(&camInfo); 
		}

		//Manually adjust the shutter speed of the cameras to the value of the
		//macro above.
		PropertyInfo camPropInfo;
		camPropInfo.type = SHUTTER;
		error = ppCameras[i]->GetPropertyInfo(&camPropInfo);
		if(error != PGRERROR_OK)
		{
			PrintError(error);
			return -1;
		}
		if(camPropInfo.present && camPropInfo.autoSupported)
		{
			Property camProp;
			camProp.type = SHUTTER;
			printf("Attempting to set camera shutter speed to manual mode at %d ms...\n",
				SHUTTER_SPEED);
			error = ppCameras[i]->GetProperty(&camProp);
			if(error != PGRERROR_OK)
			{
				PrintError(error);
				return -1;
			}
			camProp.autoManualMode = 0;
			camProp.valueA = SHUTTER_SPEED;
			camProp.absValue = SHUTTER_SPEED;
			error = ppCameras[i]->SetProperty(&camProp);
			if(error != PGRERROR_OK)
			{
				PrintError(error);
				return -1;
			}
			printf("Shutter speed successfully set to %d ms in camera %d.\n\n",
				SHUTTER_SPEED, i + 1);
		} else {
			printf("Shutter param not present in camera %d.\n\n",i + 1);
		}

		// Set all cameras to a specific mode and frame rate so they
        // can be synchronized
        error = ppCameras[i]->SetVideoModeAndFrameRate( 
            VIDEOMODE_640x480Y8, 
            FRAMERATE_30 );
        if (error != PGRERROR_OK)
        {
            PrintError( error );
            fprintf(stderr,"Error starting cameras.\n\n");
            return -1;
        }
    }

	printf("Capturing video...\n\n");
    
    error = Camera::StartSyncCapture( nCameras, (const Camera**)ppCameras );
    if (error != PGRERROR_OK)
    {
        PrintError( error );
        fprintf(stderr,"Error starting cameras.\n\n");
        return -1;
    }

	Image image;
    for ( int j = 0; j < k_numImages; j++ )
    {
        // Display the timestamps for all cameras to show that the image
        // capture is synchronized for each image
        for ( unsigned int i = 0; i < nCameras; i++ )
        {
            error = ppCameras[i]->RetrieveBuffer( &image );
            if (error != PGRERROR_OK)
            {
                PrintError( error );
                return -1;
            }

			vecImages[i + nCameras * j].DeepCopy( &image );
			if(!i)
			{
				times[j] = clock();
			}
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

	prevTime = times[0];

	maxTime = 0;

	minTime = 1000;

	//Below we calculate the average fps. This value is derived by taking first
	//the total time between frames and then dividing through by the number of
	//time periods between frames, equal to nFrames - 1.
	for(int i = 1; i < nFrames; i++)
	{
		avgFps += (float) (CLOCKS_PER_SEC / (times[i] - prevTime));
		if((times[i] - prevTime) > maxTime){
			maxTime = times[i] - prevTime;
		}
		if((times[i] - prevTime) < minTime){
			minTime = times[i] - prevTime;
		}
		prevTime = times[i];
	}

	avgFps /= (nFrames - 1);

	printf("Speed diagnostics:\n\n");

	printf("Max clock_t between frames: %d\n",maxTime);
	printf("Min clock_t between frames: %d\n",minTime);
	printf("Experimental framerate: %f\n\n",avgFps);

	float frameRateToUse = 30.0f;

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
	
	printf("Initializing write of .avi files with frame rate of %3.1f fps.\n\n",avgFps);

	SaveAviHelper(MJPG, vecImages, frameRateToUse);

    for( unsigned int i = 0; i < numCameras; i++ )
    {
        ppCameras[i]->StopCapture();
        ppCameras[i]->Disconnect();
        delete ppCameras[i];
    }

	free(times);

    delete [] ppCameras;

	this->expFPS = avgFps;

	return 0;
}

int CameraCap::getNumCameras()
{
	return this->nCameras;
}

void CameraCap::setNumFrames(unsigned int n)
{
	this->nFrames = n;
}

float CameraCap::getFps()
{
	return this->expFPS;
}
