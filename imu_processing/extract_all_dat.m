%%wrapper script that takes in the input data for all (7) IMUs and produces
%%the time, accelerometer, gyro, and magnetometer vectors for each one.

%%split the input data file into one file for each IMU-

addpath('madgwick_algorithm_matlab/quaternion_library'); %we are going to need the quaternion stuff
%addpath('IMUcalibration/IMUcalibration/IMU7'); %contains the calibration files for each IMU
addpath('madgwick_algorithm_matlab');

datafile = 'data.txt'; %%change the input file name
delim = '\t'; %% we are working with tab-delimited files
fullinput = importData(datafile,delim);

datimu0 = zeros(length(fullinput),10);
datimu1 = zeros(length(fullinput),10);
datimu2 = zeros(length(fullinput),10);
datimu3 = zeros(length(fullinput),10);
datimu4 = zeros(length(fullinput),10);
datimu5 = zeros(length(fullinput),10);
%datimu6 = zeros(length(fullinput),10);

counter0 = 0;
counter1 = 0;
counter2 = 0;
counter3 = 0;
counter4 = 0;
counter5 = 0;
%counter6 = 0;

for i = 1:length(fullinput)
    
    a = mod(i-1,6);
    
    if a == 0
        counter0 = counter0 + 1;
        datimu0(counter0,:) = fullinput(i,:);
    elseif a == 1
        counter1 = counter1 +1;
        datimu1(counter1,:) = fullinput(i,:);
    elseif a == 2
        counter2 = counter2 + 1;
        datimu2(counter2,:) = fullinput(i,:);
    elseif a == 3
        counter3 = counter3 + 1;
        datimu3(counter3,:) = fullinput(i,:);
    elseif a == 4
        counter4 = counter4 + 1;
        datimu4(counter4,:) = fullinput(i,:);
    elseif a == 5
        counter5 = counter5 + 1;
        datimu5(counter5,:) = fullinput(i,:);
   %% elseif a == 6
    %    counter6 = counter6 + 1;
    %    datimu6(counter6,:) = fullinput(i,:);
    else
        Disp('extra data?');
    end
        
end

%extract, convert, and calibrate the data from each IMU

[time0 accel0 gyro0 magn0] = dat_extract('dat0xp.txt','dat0xn.txt','dat0yp.txt', 'dat0yn.txt','dat0zp.txt','dat0zn.txt', datimu0);
[time1 accel1 gyro1 magn1] = dat_extract('dat1xp.txt','dat1xn.txt','dat1yp.txt', 'dat1yn.txt','dat1zp.txt','dat1zn.txt', datimu1);
[time2 accel2 gyro2 magn2] = dat_extract('dat2xp.txt','dat2xn.txt','dat2yp.txt', 'dat2yn.txt','dat2zp.txt','dat2zn.txt', datimu2);
[time3 accel3 gyro3 magn3] = dat_extract('dat3xp.txt','dat3xn.txt','dat3yp.txt', 'dat3yn.txt','dat3zp.txt','dat3zn.txt', datimu3);
[time4 accel4 gyro4 magn4] = dat_extract('dat4xp.txt','dat4xn.txt','dat4yp.txt', 'dat4yn.txt','dat4zp.txt','dat4zn.txt', datimu4);
[time5 accel5 gyro5 magn5] = dat_extract('dat5xp.txt','dat5xn.txt','dat5yp.txt', 'dat5yn.txt','dat5zp.txt','dat5zn.txt', datimu5);
%[time6 accel6 gyro6 magn6] = dat_extract('dat6xp.txt','dat6xn.txt','dat6yp.txt', 'dat6yn.txt','dat6zp.txt','dat6zn.txt', datimu6);


%apply madgwick AHRS to the data from each IMU

%%%%%%%IMU0%%%%%%%%%%%%%%%

AHRS0 = MadgwickAHRS('SamplePeriod', time0(10) - time0(9), 'Beta', 0.1);
quat0 = zeros(length(time0), 4);
for t = 1:length(time0)
    AHRS0.Update(gyro0(t,:) * (pi/180), accel0(t,:), magn0(t,:));	% gyroscope units must be radians
    quat0(t, :) = AHRS0.Quaternion;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%IMU1%%%%%%%%%%%%%%
AHRS1 = MadgwickAHRS('SamplePeriod', time1(10) - time1(9), 'Beta', 0.1);
quat1 = zeros(length(time1), 4);
for t = 1:length(time1)
    AHRS1.Update(gyro1(t,:) * (pi/180), accel1(t,:), magn1(t,:));	% gyroscope units must be radians
    quat1(t, :) = AHRS1.Quaternion;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%IMU2%%%%%%%%%%%%%%
AHRS2 = MadgwickAHRS('SamplePeriod', time2(10) - time2(9), 'Beta', 0.1);
quat2 = zeros(length(time2), 4);
for t = 1:length(time2)
    AHRS2.Update(gyro2(t,:) * (pi/180), accel2(t,:), magn2(t,:));	% gyroscope units must be radians
    quat2(t, :) = AHRS2.Quaternion;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%IMU3%%%%%%%%%%%%%%
AHRS3 = MadgwickAHRS('SamplePeriod', time3(10) - time3(9), 'Beta', 0.1);
quat3 = zeros(length(time3), 4);
for t = 1:length(time3)
    AHRS0.Update(gyro3(t,:) * (pi/180), accel3(t,:), magn3(t,:));	% gyroscope units must be radians
    quat3(t, :) = AHRS3.Quaternion;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%IMU4%%%%%%%%%%%%%%
AHRS4 = MadgwickAHRS('SamplePeriod', time4(10) - time4(9), 'Beta', 0.1);
quat4 = zeros(length(time4), 4);
for t = 1:length(time4)
    AHRS4.Update(gyro4(t,:) * (pi/180), accel4(t,:), magn4(t,:));	% gyroscope units must be radians
    quat4(t, :) = AHRS4.Quaternion;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%IMU5%%%%%%%%%%%%%%
AHRS5 = MadgwickAHRS('SamplePeriod', time5(10) - time5(9), 'Beta', 0.1);
quat5 = zeros(length(time5), 4);
for t = 1:length(time5)
    AHRS5.Update(gyro5(t,:) * (pi/180), accel5(t,:), magn5(t,:));	% gyroscope units must be radians
    quat5(t, :) = AHRS5.Quaternion;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%IMU6%%%%%%%%%%%%%%
%AHRS6 = MadgwickAHRS('SamplePeriod', time6(10) - time6(9), 'Beta', 0.1);
%quat6 = zeros(length(time6), 4);
%for t = 1:length(time6)
 %   AHRS6.Update(gyro6(t,:) * (pi/180), accel6(t,:), magn6(t,:));	% gyroscope units must be radians
 %   quat6(t, :) = AHRS6.Quaternion;
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%compensate for gravity for each IMU%%%%%%%%%%

%dyn_acc is dynamic acceleration in the frame of the sensor%

dyn_acc_0 = dyn_acc(quat0,accel0);
dyn_acc_1 = dyn_acc(quat1,accel1);
dyn_acc_2 = dyn_acc(quat2,accel2);
dyn_acc_3 = dyn_acc(quat3,accel3);
dyn_acc_4 = dyn_acc(quat4,accel4);
dyn_acc_5 = dyn_acc(quat5,accel5);
%dyn_acc_6 = dyn_acc(quat6,accel6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%rotate dynamic acceleration into the frame of the earth%%%%%

%%these results are all quaternions
acc_earth_q_0 = dyn_acc_earthFrame(dyn_acc_0,quat0);
acc_earth_q_1 = dyn_acc_earthFrame(dyn_acc_1,quat1);
acc_earth_q_2 = dyn_acc_earthFrame(dyn_acc_2,quat2);
acc_earth_q_3 = dyn_acc_earthFrame(dyn_acc_3,quat3);
acc_earth_q_4 = dyn_acc_earthFrame(dyn_acc_4,quat4);
acc_earth_q_5 = dyn_acc_earthFrame(dyn_acc_5,quat5);
%acc_earth_q_6 = dyn_acc_earthFrame(dyn_acc_6,quat6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%get the acceleration vector components%%%%%%%%%%%%%%%%%%%%

ax0 = acc_earth_q_0(:,2); ay0 = acc_earth_q_0(:,3); az0 = acc_earth_q_0(:,4);
ax1 = acc_earth_q_1(:,2); ay1 = acc_earth_q_1(:,3); az1 = acc_earth_q_1(:,4);
ax2 = acc_earth_q_2(:,2); ay2 = acc_earth_q_2(:,3); az2 = acc_earth_q_2(:,4);
ax3 = acc_earth_q_3(:,2); ay3 = acc_earth_q_3(:,3); az3 = acc_earth_q_3(:,4);
ax4 = acc_earth_q_4(:,2); ay4 = acc_earth_q_4(:,3); az4 = acc_earth_q_4(:,4);
ax5 = acc_earth_q_5(:,2); ay5 = acc_earth_q_5(:,3); az5 = acc_earth_q_5(:,4);
%ax6 = acc_earth_q_6(:,2); ay6 = acc_earth_q_6(:,3); az6 = acc_earth_q_6(:,4);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%numerically integrate to get velocity components %%%%%%

vx0 = numInt(ax0,time0,ax0(1,:));vy0 = numInt(ay0,time0,ay0(1,:));vz0 = numInt(az0,time0,az0(1,:));
vx1 = numInt(ax1,time1,ax1(1,:));vy1 = numInt(ay1,time1,ay1(1,:));vz1 = numInt(az1,time1,az1(1,:));
vx2 = numInt(ax2,time2,ax2(1,:));vy2 = numInt(ay2,time2,ay2(1,:));vz2 = numInt(az2,time2,az2(1,:));
vx3 = numInt(ax3,time3,ax3(1,:));vy3 = numInt(ay3,time3,ay3(1,:));vz3 = numInt(az3,time3,az3(1,:));
vx4 = numInt(ax4,time4,ax4(1,:));vy4 = numInt(ay4,time4,ay4(1,:));vz4 = numInt(az4,time4,az4(1,:));
vx5 = numInt(ax5,time5,ax5(1,:));vy5 = numInt(ay5,time5,ay5(1,:));vz5 = numInt(az5,time5,az5(1,:));
%vx6 = numInt(ax6,time6,ax6(1,:));vy6 = numInt(ay6,time6,ay6(1,:));vz6 = numInt(az6,time6,az6(1,:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%form data vectors for each IMU%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%format: [timestamp IMU# vx vy vz]

vdat0 = [time0 0.*ones(length(time0),1) vx0 vy0 vz0];
vdat1 = [time1 1.*ones(length(time1),1) vx1 vy1 vz1];
vdat2 = [time2 2.*ones(length(time2),1) vx2 vy2 vz2];
vdat3 = [time3 3.*ones(length(time3),1) vx3 vy3 vz3];
vdat4 = [time4 4.*ones(length(time4),1) vx4 vy4 vz4];
vdat5 = [time5 5.*ones(length(time5),1) vx5 vy5 vz5];
%vdat6 = [time6 6.*ones(length(time6),1) vx6 vy6 vz6];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%Interleave the vectors from each IMU to provide output to EKF %%%%%%%%%%

result = zeros(6*length(vdat4),5);

counter0 = 0;
counter1 = 0;
counter2 = 0;
counter3 = 0;
counter4 = 0;
counter5 = 0;
%counter6 = 0;

for i = 1:6*length(vdat5)
	
	if mod(i-1,6) == 0
		counter0 = counter0 + 1;	
		result(i,:) = vdat0(counter0,:);
	elseif mod(i-1,6) == 1
		counter1 = counter1 + 1;	
		result(i,:) = vdat1(counter1,:);
	elseif mod(i-1,6) == 2
		counter2 = counter2 + 1;	
		result(i,:) = vdat2(counter2,:);
	elseif mod(i-1,6) == 3
		counter3 = counter3 + 1;	
		result(i,:) = vdat3(counter3,:);
	elseif mod(i-1,6) == 4
		counter4 = counter4 + 1;	
		result(i,:) = vdat4(counter4,:);
	elseif mod(i-1,6) == 5
		counter5 = counter5 + 1;	
		result(i,:) = vdat5(counter5,:);
	else
		Disp('error: something is up!');

	end

end


dlmwrite('imudata.txt',result,'\t');






