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

unsigned long overflow = 0;
unsigned long micros;
int raw_data_buffer[3];
int ax, ay, az, gx, gy, gz;
int i = 0;
int j = 0;
int bar0[6];
int bar1[6];
int bar2[6];
int bar3[6];

ISR(TIMER3_OVF_vect){
	set(TIFR3,TOV3);
	//measure(0);
	//m_usb_tx_int(overflow % 2);
	overflow++;
}

void selectIMU(int select){
	switch(select){
		case 0:
			clear(PORTB,0);
			clear(PORTB,1);
			break;
		case 1:
			set(PORTB,0);
			clear(PORTB,1);
			break;
		case 2:
			clear(PORTB,0);
			set(PORTB,1);
			break;
		case 3:
			set(PORTB,0);
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
	
	for(i = 0; i<100; i++){
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
	}
}

void measure(int select){
	m_green(TOGGLE);
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
	}
	
	m_usb_tx_int(select);
	m_usb_tx_string("\t");
	
	micros = 8192 * overflow + (unsigned long)((float)(((unsigned long)(TCNT3H) << 8) | TCNT3L) * 8192 / 65535);
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
	m_usb_tx_string("\n");
}

int main(void)
{
	m_clockdivide(1);	// 16 MHz

	set(DDRB,0);  // set B0 as output
	set(DDRB,1);  // set B1 as output
	
	m_usb_init();
	while(!m_usb_isconnected()){
		m_green(ON);
	}
	m_green(OFF);
	set(DDRB,2);

	clear(PORTB,0);
	clear(PORTB,1);
	m_wait(10);
	if(!m_imu_init(0,1)){
		m_red(ON);  // RED LED turns on if there's a problem
		m_usb_tx_string("IMU0 could not connect");
	}
	set(PORTB,0);
	m_wait(10);
	if(!m_imu_init(0,1)){
		m_red(ON);  // RED LED turns on if there's a problem
		m_usb_tx_string("IMU1 could not connect");
	}
	clear(PORTB,0);
	set(PORTB,1);
	m_wait(10);
	if(!m_imu_init(0,1)){
		m_red(ON);  // RED LED turns on if there's a problem
		m_usb_tx_string("IMU2 could not connect");
	}
	set(PORTB,0);
	m_wait(10);
	if(!m_imu_init(0,1)){
		m_red(ON);  // RED LED turns on if there's a problem
		m_usb_tx_string("IMU3 could not connect");
	}

	calibrate(0);
	calibrate(1);
	calibrate(2);
	calibrate(3);
	
	// ENABLE Timer 3 overflow interrupt
	overflow = 0;
	set(TIMSK3,TOIE3);
	set(TCCR3B,CS30);
	sei(); // enable global interrupts	

	while(1){
		measure(0);
		m_wait(50);
		measure(1);
		m_wait(50);
		measure(2);
		m_wait(50);
		measure(3);
		m_wait(50);
	}
	
/*		
		m_imu_accel(raw_data_buffer);
		ax = raw_data_buffer[0];
		ay = raw_data_buffer[1];
		az = raw_data_buffer[2];
		m_usb_tx_int(gx);
		m_usb_tx_string("\t");
		m_usb_tx_int(gy);
		m_usb_tx_string("\t");
		m_usb_tx_int(gz);
		m_usb_tx_string("\t");
		
		m_imu_mag(raw_data_buffer);
		gx = raw_data_buffer[0];
		gz = raw_data_buffer[1];
		gy = raw_data_buffer[2];
		m_usb_tx_int(gx);
		m_usb_tx_string("\t");
		m_usb_tx_int(gy);
		m_usb_tx_string("\t");
		m_usb_tx_int(gz);
		m_usb_tx_string("\n");
		
		m_wait(75);
	}
*/
/*
	while(1){
		m_green(TOGGLE);
	}
	m_green(OFF);
*/
	//for(i = 0; i < 100; i++){
		//m_green(TOGGLE);
		//toggle(PORTB,2);
		//timearray[i] = (unsigned long)(4096 * overflow) + (unsigned long)((float)(((unsigned long)(TCNT3H) << 8) | TCNT3L) * 4096 / 65535);
/*		
		m_imu_accel(raw_data_buffer);
		datarray[i][0] = raw_data_buffer[0] - axbar;
		datarray[i][1] = raw_data_buffer[1] - aybar;
		datarray[i][2] = raw_data_buffer[2] - azbar;
		m_imu_gyro(raw_data_buffer);
		datarray[i][3] = raw_data_buffer[0] - gxbar;
		datarray[i][4] = raw_data_buffer[1] - gybar;
		datarray[i][5] = raw_data_buffer[2] - gzbar;
		
		//m_wait(10);  // delay(1)
	//}
	
	
	for(i = 0; i < 250; i++){
		m_usb_tx_ulong(timearray[i]);
		//m_usb_tx_string("\t");
		//for(j = 0; j < 6; j++){
		//	m_usb_tx_int(datarray[i][j]);
		//	m_usb_tx_string("\t");
		//	m_wait(10);
		//}
		m_wait(20);
		m_usb_tx_string("\n");
		m_wait(20);
	}
	cli();
	*/
}
