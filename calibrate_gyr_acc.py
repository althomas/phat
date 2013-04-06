"""
Program to determine the accelerometer offsets, accelerometer scales, and gyro offsets to properly calibrate the mIMU 9-dof imu
	developed by Jonathan Fiene at UPENN.

	This calibration routine is adapted from one developed by Fabio Varesano at the Universita' degli Studi di Torino, and made available 
	under version 3 of the GPL

	This code comes with no warranty, nor any implication of one.

	Author: Sam Wolfson, ESE, SEAS, UPENN
"""
import sys
import numpy
from numpy import linalg

def calibrate(ax,ay,az,gx,gy,gz):
	H = numpy.array([ax,ay,az, -ay**2,-az**2, numpy.ones([len(ax),1])])
	H = numpy.transpose(H)
	w = ax**2

	(X, residues, rank, shape) = linalg.lstsq(H, w)
	
	OSx = X[0] / 2
	OSy = X[1] / (2 * X[3])
	OSz = X[2] / (2 * X[4])

	A = X[5] + OSx**2 + X[3] * OSy**2 + X[4]*OSz**2
	B = A/X[3]
	C = A/X[4]

	SCx = numpy.sqrt(A)
	SCy = numpy.sqrt(B)
	SCz = numpy.sqrt(C)
	
	GOSx = 0
	GOSy = 0
	GOSz = 0
	count = 0

	for value in gx:
		GOSx += value
		count +=1
	
	GOSx = GOSx/count

	count = 0
	for value in gy:
		GOSy += value
		count +=1
	
	GOSy = GOSy/count

	count = 0
	for value in gz:
		GOSz += value
		count +=1
	
	GOSz = GOSz/count

	return([OSx, OSy, OSz], [SCx, SCy, SCz],[GOSx, GOSy, GOSz])

if __name__ == "__main__":
	#filename = argv[:1]
	#print filename
	dat_f = open("caltest.txt", 'r')
	acc_x = []
	acc_y = []
	acc_z = []
	gyr_x = []
	gyr_y = []
	gyr_z = []

	for line in dat_f:
		reading = line.split()
		acc_x.append(int(reading[0]))
		acc_y.append(int(reading[1]))
		acc_z.append(int(reading[2]))
		gyr_x.append(int(reading[1]))
		gyr_y.append(int(reading[2]))
		gyr_z.append(int(reading[3]))

	(accel_offsets, scale, gyro_offset) = calibrate(numpy.array(acc_x),numpy.array(acc_y),numpy.array(acc_z),numpy.array(gyr_x), numpy.array(gyr_y), numpy.array(gyr_z))

	print accel_offsets
	print scale
	print gyro_offset


