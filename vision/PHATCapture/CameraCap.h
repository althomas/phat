/* File: CameraCap.h
   Author: Cam Cogan
   Desc: Header file for camera capture object. Adapted from TestPGCameras.cpp,
         this class wraps under-the-hood methods with private access and only
  	 affords what was formerly the program's main method as a public function.
*/

#ifndef CAMERACAP_H_
#define CAMERACAP_H_

#include "FlyCapture2.h"
#include <vector>

using namespace FlyCapture2;

class CameraCap
{
private:
	unsigned int nFrames;
	unsigned int nCameras;
	enum AviType
	{
		UNCOMPRESSED,
		MJPG,
		H264
	};
	void PrintBuildInfo();
	void PrintCameraInfo(CameraInfo *pCamInfo);
	void PrintError(Error error);
	void SaveAviHelper(AviType aviType, 
		std::vector<Image>& vecImages,
		float frameRate);

public:
	CameraCap(unsigned int nF);
	int CaptureFromCameras();
	int getNumCameras();
	void setNumFrames(unsigned int n);
};

#endif
