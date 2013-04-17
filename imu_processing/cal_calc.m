%%script to calculate the scales and offsets for each axis of the
%%accelerometer

%%requires 6 data sets, one for each direction and axis of the
%%accelerometer:
%x axis --up
%x axis --down
%y axis --up
%y axis --down
%z axis --up
%z axis --down

function [wx wy wz osx osy osz ] = cal_calc(xp,xn,yp,yn,zp,zn)
	ascale = 8192;
    
	x_xp = xp(:,2)./ascale;
	x_xn = xn(:,2)./ascale;
	y_yp = yp(:,3)./ascale;
	y_yn = yn(:,3)./ascale;
	z_zp = zp(:,4)./ascale;
	z_zn = zn(:,4)./ascale;

	xpav = average_vector(x_xp);
	xnav = average_vector(x_xn);
	ypav = average_vector(y_yp);
	ynav = average_vector(y_yn);
	zpav = average_vector(z_zp);
	znav = average_vector(z_zn);

	wx = 2 / (xpav - xnav);
	wy = 2 / (ypav - ynav);
	wz = 2 / (zpav - znav);
	
	osx = -(xpav + xnav)/(xpav - xnav);
	osy = -(ypav + ynav)/(ypav - ynav);
	osz = -(zpav + znav)/(zpav - znav);
    

	
end
