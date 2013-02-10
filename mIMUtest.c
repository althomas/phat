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

int main(void)
{
  m_clockdivide(0);	// 16 MHz
	
	int raw_data_buffer[3];
	int i;
	int ax, ay, az, gx, gy, gz;
	long axbar = 0;
	long aybar = 0; 
	long azbar = 0;
	long gxbar = 0; 
	long gybar = 0;
	long gzbar = 0;
	
	m_usb_init();
	while(!m_usb_isconnected());
	
	set(DDRB,2);
	
	if(!m_imu_init(0,0)) m_red(ON); // RED turns on if there's a problem
	
	for(i = 0; i<500; i++){
		m_wait(500);
		m_green(TOGGLE);
		toggle(PORTB,2);
		
		m_imu_accel(raw_data_buffer);
		axbar = axbar + (long)raw_data_buffer[0];
		aybar = aybar + (long)raw_data_buffer[1];
		azbar = azbar + (long)raw_data_buffer[2];
		
		m_imu_gyro(raw_data_buffer);
		gxbar = gxbar + (long)raw_data_buffer[0];
		gybar = gybar + (long)raw_data_buffer[1];
		gzbar = gzbar + (long)raw_data_buffer[2];
	}
		
	axbar = (int)(axbar/(long)i);
	aybar = (int)(aybar/(long)i);
	azbar = (int)(azbar/(long)i);
	gxbar = (int)(gxbar/(long)i);
	gybar = (int)(gybar/(long)i);
	gzbar = (int)(gzbar/(long)i);
	
	m_usb_tx_int(axbar);
	m_usb_tx_string("\t");
	m_usb_tx_int(aybar);
	m_usb_tx_string("\t");
	m_usb_tx_int(azbar);
	m_usb_tx_string("\t");
	m_usb_tx_int(gxbar);
	m_usb_tx_string("\t");
	m_usb_tx_int(gybar);
	m_usb_tx_string("\t");
	m_usb_tx_int(gzbar);
	m_usb_tx_string("\n");
	m_usb_tx_string("\n");	
	
	while(1){
		m_wait(500);
		m_green(TOGGLE);
		toggle(PORTB,2);
		
		m_imu_accel(raw_data_buffer);
		ax = raw_data_buffer[0] - axbar;
		ay = raw_data_buffer[1] - aybar;
		az = raw_data_buffer[2] - azbar;
		m_usb_tx_int(ax);
		m_usb_tx_string("\t");
		m_usb_tx_int(ay);
		m_usb_tx_string("\t");
		m_usb_tx_int(az);
		m_usb_tx_string("\t");
		
		m_imu_gyro(raw_data_buffer);
		gx = raw_data_buffer[0] - gxbar;
		gy = raw_data_buffer[1] - gybar;
		gz = raw_data_buffer[2] - gzbar;
		m_usb_tx_int(gx);
		m_usb_tx_string("\t");
		m_usb_tx_int(gy);
		m_usb_tx_string("\t");
		m_usb_tx_int(gz);
		m_usb_tx_string("\n");
	}
}
