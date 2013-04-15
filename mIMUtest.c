/*
 * mIMUtest.c
 *
 * Created: 2/2/2013 3:29:45 PM
 *  Author: Nick
 */ 

#include <avr/io.h>
#include "m_imu.h"
#include "m_usb.h"
#include "m_bus.h"
#include "m_general.h"

void selectIMU(int select);
void calibrate(int select);
void measure(int select);

unsigned long overflow = 0;
unsigned long micros;
int raw_data_buffer[3];
int ax, ay, az, gx, gy, gz, mx, my, mz;
int i = 0;
int j = 0;
int sel;
int bar0[6];
int bar1[6];
int bar2[6];
int bar3[6];
int bar4[6];
int bar5[6];

ISR(TIMER1_COMPB_vect){
	set(TIFR1,OCF1B);
	OCR1B += 521;
}

ISR(TIMER1_OVF_vect){
	set(TIFR1,TOV1);
	TCNT1 = 0;
}

ISR(TIMER3_OVF_vect){
	set(TIFR3,TOV3);
	//sel = overflow % 2;
	measure(0);
	overflow++;
}

void selectIMU(int select){
	switch(select){
		case 0:
			clear(PORTF,0);
			clear(PORTF,1);
			clear(PORTB,1);
			break;
		case 1:
			set(PORTF,0);
			clear(PORTF,1);
			clear(PORTB,1);
			break;
		case 2:
			clear(PORTF,0);
			set(PORTF,1);
			clear(PORTB,1);
			break;
		case 3:
			set(PORTF,0);
			set(PORTF,1);
			clear(PORTB,1);
			break;
		case 4:
			clear(PORTF,0);
			clear(PORTF,1);
			set(PORTB,1);
			break;
		case 5:
			set(PORTF,0);
			clear(PORTF,1);
			set(PORTB,1);
			break;
	}
}

void calibrate(int select){
	long axbar = 0;
	long aybar = 0;
	long azbar = 0;
	long gxbar = 0;
	long gybar = 0;
	long gzbar = 0;
	int bar[6];
	
	selectIMU(select);
	
	for(i = 0; i < 100; i++){
		m_wait(10);
		m_green(TOGGLE);
		toggle(PORTB,2);

		/*
		m_imu_accel(raw_data_buffer);
		axbar = axbar + (long)raw_data_buffer[0];
		aybar = aybar + (long)raw_data_buffer[1];
		azbar = azbar + (long)raw_data_buffer[2];
		*/
		
		m_imu_gyro(raw_data_buffer);
		gxbar = gxbar + (long)raw_data_buffer[0];
		gybar = gybar + (long)raw_data_buffer[1];
		gzbar = gzbar + (long)raw_data_buffer[2];
	}
		
	bar[0] = (int)axbar/i;
	bar[1] = (int)aybar/i;
	bar[2] = (int)azbar/i;
	bar[3] = (int)gxbar/i;
	bar[4] = (int)gybar/i;
	bar[5] = (int)gzbar/i;

	switch(select){
		case 0:
			for(i = 0; i < 6; i++){
				bar0[i] = bar[i];
			}
			break;
		case 1:
			for(i = 0; i < 6; i++){
				bar1[i] = bar[i];
			}
			break;
		case 2:
			for(i = 0; i < 6; i++){
				bar2[i] = bar[i];
			}
			break;
		case 3:
			for(i = 0; i < 6; i++){
				bar3[i] = bar[i];
			}
			break;
		case 4:
			for(i = 0; i < 6; i++){
				bar4[i] = bar[i];
			}
			break;
		case 5:
			for(i = 0; i < 6; i++){
				bar5[i] = bar[i];
			}
			break;
	}
}

void measure(int select){
	//m_green(TOGGLE);
	toggle(PORTB,2);
	int* bar;

	selectIMU(select);
	
	switch(select){
		case 0:
			bar = bar0;
			break;
		case 1:
			bar = bar1;
			break;
		case 2:
			bar = bar2;
			break;
		case 3:
			bar = bar3;
			break;
		case 4:
			bar = bar4;
			break;
		case 5:
			bar = bar5;
			break;
	}
	
	//m_usb_tx_int(select);
	//m_usb_tx_string("\t");
	
	micros = 4096 * overflow + (unsigned long)((float)(((unsigned long)(TCNT3H) << 8) | TCNT3L) * 4096 / 65536);
	m_usb_tx_ulong(micros);
	m_usb_tx_string("\t");
	
	m_imu_accel(raw_data_buffer);
	ax = raw_data_buffer[0] - bar[0];
	ay = raw_data_buffer[1] - bar[1];
	az = raw_data_buffer[2] - bar[2];
	m_usb_tx_int(ax);
	m_usb_tx_string("\t");
	m_usb_tx_int(ay);
	m_usb_tx_string("\t");
	m_usb_tx_int(az);
	m_usb_tx_string("\t");

	m_imu_gyro(raw_data_buffer);
	gx = raw_data_buffer[0] - bar[3];
	gy = raw_data_buffer[1] - bar[4];
	gz = raw_data_buffer[2] - bar[5];
	m_usb_tx_int(gx);
	m_usb_tx_string("\t");
	m_usb_tx_int(gy);
	m_usb_tx_string("\t");
	m_usb_tx_int(gz);
	m_usb_tx_string("\t");
	
	m_imu_mag(raw_data_buffer);
	mx = raw_data_buffer[0];
	my = raw_data_buffer[2];
	mz = raw_data_buffer[1];
	m_usb_tx_int(mx);
	m_usb_tx_string("\t");
	m_usb_tx_int(my);
	m_usb_tx_string("\t");
	m_usb_tx_int(mz);
	m_usb_tx_string("\n");
}

int main(void)
{
	unsigned long runtime = 0;
	
	m_clockdivide(0);	// 16 MHz

	OCR1B = 521;  // initialize output compare register (interrupt every 521 cycles)
	set(DDRB,6);  // set B6 as output (output compare pin)
	
	set(DDRB,4);  // set B4 as output (green LED for data synchronization)
	set(PORTB,4);  // turn on green LED on B4
	
	set(DDRF,0);  // set F0 as output
	set(DDRF,1);  // set F1 as output
	set(DDRB,1);  // set B1 as output
	
	m_usb_init();
	while(!m_usb_isconnected()){
		m_green(ON);
	}
	m_green(OFF);
	set(DDRB,2);

	while(!m_usb_rx_available());  // wait for runtime argument from Python script
	m_wait(5);
	while(m_usb_rx_available()){
		runtime = runtime * 10 + (m_usb_rx_char() - '0');  // build number of seconds
	}
	runtime = runtime * 1000000;  // convert to microseconds

	clear(PORTF,0);  // S0
	clear(PORTF,1);  // S1
	clear(PORTB,1);  // S2
	m_wait(10);
	if(!m_imu_init(0,1)){
		m_red(ON);  // RED LED turns on if there's a problem
		m_usb_tx_string("IMU0 could not connect");
	}
	/*
	set(PORTF,0);
	m_wait(10);
	if(!m_imu_init(0,1)){
		m_red(ON);  // RED LED turns on if there's a problem
		m_usb_tx_string("IMU1 could not connect");
	}
	clear(PORTF,0);
	set(PORTF,1);
	m_wait(10);
	if(!m_imu_init(0,1)){
		m_red(ON);  // RED LED turns on if there's a problem
		m_usb_tx_string("IMU2 could not connect");
	}
	set(PORTF,0);
	m_wait(10);
	if(!m_imu_init(0,1)){
		m_red(ON);  // RED LED turns on if there's a problem
		m_usb_tx_string("IMU3 could not connect");
	}
	set(PORTB,1);
	clear(PORTF,0);
	clear(PORTF,1);
	m_wait(10);
	if(!m_imu_init(0,1)){
		m_red(ON);  // RED LED turns on if there's a problem
		m_usb_tx_string("IMU4 could not connect");
	}
	set(PORTF,0);
	m_wait(10);
	if(!m_imu_init(0,1)){
		m_red(ON);  // RED LED turns on if there's a problem
		m_usb_tx_string("IMU5 could not connect");
	}
	*/
	//calibrate(0);
	//calibrate(1);
	//calibrate(2);
	//calibrate(3);
	//calibrate(4);
	//calibrate(5);
	
	// Initialize Timer 1 output compare interrupt 
	set(TIMSK1,OCIE1B);
	set(TCCR1B,CS12);
	clear(TCCR1B,CS11);
	set(TCCR1B,CS10);
	clear(TCCR1B,WGM13);
	set(TCCR1B,WGM12);
	clear(TCCR1A,WGM11);
	clear(TCCR1A,WGM10);
	clear(TCCR1A,COM1B1);
	set(TCCR1A,COM1B0);
	
	// Initialize Timer 1 overflow interrupt
	set(TIMSK1,TOIE1);
	
	// Initialize Timer 3 overflow interrupt
	overflow = 0;
	set(TIMSK3,TOIE3);
	clear(TCCR3B,CS32);
	clear(TCCR3B,CS31);
	set(TCCR3B,CS30);
	
	sei();  // enable global interrupts
	clear(PORTB,4);  // turn off green LED --> signal to camera
	
	while(overflow * 4096 < runtime){
		m_green(TOGGLE);
	}
	m_usb_tx_string(" ");
	m_green(OFF);
	//cli();
	while(1);
}
