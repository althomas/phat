import serial
import signal
import sys

def signal_handler(signal, frame):
    m2.close()
    sys.exit(0)
signal.signal(signal.SIGINT, signal_handler)


m2 = serial.Serial('COM5', 9600)  # A new serial port is opened @ 9600 baud and named 'm2'
m2.flushInput()		# The input buffer is cleared, in case anything is leftover

filename = sys.argv[1]
f = open(filename, 'w')

runtime = sys.argv[2]		# Record data for this number of seconds
m2.write(runtime)

data = m2.read()

while data != "\n":
	data = m2.read()
	f.write(data)

m2.close()
f.close()
