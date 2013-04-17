%%function to take raw data from all three sensors (accelerometer, gyro,
%%magnetometer) and produce three matrices: accel, gyro, magn

%values will be converted to the appropriate unit, and relevant offsets and
%scales will be applied to make the values as precise as possible.

%data set will have 10 columns: [t ax ay az gx gy gz mx my mz]
%calfiles should be a vector with six entries: [xpdat xndat ypdat yndat
%zpdat zndat] --each entry is a string of the text file containing that
%calibration data
%xpfile,xnfile,ypfile,ynfile,zpfile,znfile,data_file
function [time accel gyro magn] = dat_extract(xpfile,xnfile,ypfile,ynfile,zpfile,znfile,data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% xpfile = 'dat1xp.txt'; %file with x axis positive
% xnfile = 'dat1xn.txt'; %file with x axis negative
% 
% ypfile = 'dat1yp.txt'; %file with y axis positive
% ynfile = 'dat1yn.txt'; %file with y axis negative
% 
% zpfile = 'dat1zn.txt'; %file with z axis positive
% znfile = 'dat1zp.txt'; %file with z axis negative
% 
% data_file = 'z_trans.txt';  %file with data set to be used
% 

delimiterIn = '\t'; %files are tab delimited
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%import all the data%%%%%%%%%%%%%%%%%
xp = importdata(xpfile,delimiterIn);
xn = importdata(xnfile,delimiterIn);

yp = importdata(ypfile,delimiterIn);
yn = importdata(ynfile,delimiterIn);

zp = importdata(zpfile,delimiterIn);
zn = importdata(znfile,delimiterIn);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[wx wy wz osx osy osz] = cal_calc(xp, xn, yp, yn, zp, zn); %calculate all the offsets and scales for accelerometers


%%%%%%%%%%%%%%%import dataset%%%%%%%%%%%%%%%

%data = importdata(data_file,delimiterIn); %% data is provided as a matlab
%variable, to allow for integration with extract_all_dat.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ascale = 65535/8; %conversion factors
gscale = 65535/2000;


time = data(:,1);
time = time./1e6; %convert time to s from us

rax = data(:,2)./ascale; %raw acceleration, converted to units of g
ray = data(:,3)./ascale;
raz = data(:,4)./ascale;

rgx = data(:,5)./gscale; %raw gyro, converted to units of deg/s
rgy = data(:,6)./gscale;
rgz = data(:,7)./gscale;


rmx = data(:,8); %raw magnetometer - m2 takes care of this
rmy = data(:,9);
rmz = data(:,10);

ax = wx .* (rax + osx.*ones(length(rax),1)); %correct accel data for offset and scale
ay = -1*wy .* (ray + osy.*ones(length(ray),1));
az = -1*wz .* (raz + osz.*ones(length(raz),1));

% gx = rgx - (osgx/gscale).*ones(length(rgx),1); %don't need this here, M2
% taking care of it

% gy = rgy - (osgy/gscale).*ones(length(rgy),1);
% gz = rgz - (osgz/gscale).*ones(length(rgz),1);

accel = [ax ay az];
gyro = [rgx rgy rgz];
magn = [rmx rmy rmz];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%











