%%wrapper script that takes in the input data for all (7) IMUs and produces
%%the time, accelerometer, gyro, and magnetometer vectors for each one.

%%split the input data file into one file for each IMU-

function []  = extract_all_dat(datafile,outfile)
addpath('./madgwick_algorithm_matlab/quaternion_library'); %we are going to need the quaternion stuff
addpath('./IMUcalibration/IMUcalibration/IMU7'); %contains the calibration files for each IMU
addpath('./madgwick_algorithm_matlab');

datafile = 'clench.txt'; %%change the input file name
%datafile = 'glove_test_041613-1.txt'; %%change the input file name
delim = '\t'; %% we are working with tab-delimited files
fullinput = importdata(datafile,delim);

datimu0 = zeros((length(fullinput))/6,10);
datimu1 = zeros((length(fullinput))/6,10);
datimu2 = zeros((length(fullinput))/6,10);
datimu3 = zeros((length(fullinput))/6,10);
datimu4 = zeros((length(fullinput))/6,10);
datimu5 = zeros((length(fullinput))/6,10);
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
[time1 accel1 gyro1 magn1] = dat_extract('dat7xp.txt','dat7xn.txt','dat7yp.txt', 'dat7yn.txt','dat7zp.txt','dat7zn.txt', datimu1);
[time2 accel2 gyro2 magn2] = dat_extract('dat2xp.txt','dat2xn.txt','dat2yp.txt', 'dat2yn.txt','dat2zp.txt','dat2zn.txt', datimu2);
[time3 accel3 gyro3 magn3] = dat_extract('dat3xp.txt','dat3xn.txt','dat3yp.txt', 'dat3yn.txt','dat3zp.txt','dat3zn.txt', datimu3);
[time4 accel4 gyro4 magn4] = dat_extract('dat4xp.txt','dat4xn.txt','dat4yp.txt', 'dat4yn.txt','dat4zp.txt','dat4zn.txt', datimu4);
[time5 accel5 gyro5 magn5] = dat_extract('dat5xp.txt','dat5xn.txt','dat5yp.txt', 'dat5yn.txt','dat5zp.txt','dat5zn.txt', datimu5);
%[time6 accel6 gyro6 magn6] = dat_extract('dat6xp.txt','dat6xn.txt','dat6yp.txt', 'dat6yn.txt','dat6zp.txt','dat6zn.txt', datimu6);

%apply offset and scale for the magnetometer data --has to be done here,
%can't be done in the m2

magn0x = (magn0(:,1) - 7.325.*ones(length(magn0(:,1)),1))./478.8;
magn0y = (magn0(:,2) - 132.605.*ones(length(magn0(:,2)),1))./503.007;
magn0z = (magn0(:,3) - 25.099.*ones(length(magn0(:,3)),1))./466.445;

magn1x = (magn1(:,1) - 14.523.*ones(length(magn1(:,1)),1))./483.016;
magn1y = (magn1(:,2) + 166.266.*ones(length(magn1(:,2)),1))./537.540;
magn1z = (magn1(:,3) + 52.696.*ones(length(magn1(:,3)),1))./457.337;

magn2x = (magn2(:,1) - 14.346.*ones(length(magn2(:,1)),1))./485.878;
magn2y = (magn2(:,2) + 151.004.*ones(length(magn2(:,2)),1))./498.971;
magn2z = (magn2(:,3) - 7.399.*ones(length(magn2(:,3)),1))./452.192;

magn3x = (magn3(:,1) + 3.807.*ones(length(magn3(:,1)),1))./507.577;
magn3y = (magn3(:,2) + 149.197.*ones(length(magn3(:,2)),1))./490.679;
magn3z = (magn3(:,3) - 113.054.*ones(length(magn3(:,3)),1))./500.417;

magn4x = (magn4(:,1) + 11.898.*ones(length(magn4(:,1)),1))./497.647;
magn4y = (magn4(:,2) - 138.081.*ones(length(magn4(:,2)),1))./501.624;
magn4z = (magn4(:,3) - 317.285.*ones(length(magn4(:,3)),1))./467.103;

magn5x = (magn5(:,1) - 18.274.*ones(length(magn5(:,1)),1))./498.209;
magn5y = (magn5(:,2) + 156.761.*ones(length(magn5(:,2)),1))./500.586;
magn5z = (magn5(:,3) - 39.877.*ones(length(magn5(:,3)),1))./483.893;


%reform the magnetometer matrice
magn0 = [magn0x magn0y magn0z];
magn1 = [magn1x magn1y magn1z];
magn2 = [magn2x magn2y magn2z];
magn3 = [magn3x magn3y magn3z];
magn4 = [magn4x magn4y magn4z];
magn5 = [magn5x magn5y magn5z];
%magn5 = [magn5x magn5z magn5y];


%apply madgwick AHRS to the data from each IMU

%%%%%%%IMU0%%%%%%%%%%%%%%%

AHRS0 = MadgwickAHRS('SamplePeriod', time0(10) - time0(9), 'Beta', 1);
%quat0 = [ones(length(time0),1) zeros(length(time0), 3)];
quat0 =  zeros(length(time0), 4);
for t = 1:length(time0)
    AHRS0.Update(gyro0(t,:) * (pi/180), accel0(t,:), magn0(t,:));	% gyroscope units must be radians
    quat0(t, :) = AHRS0.Quaternion;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%IMU1%%%%%%%%%%%%%%
AHRS1 = MadgwickAHRS('SamplePeriod', time1(10) - time1(9), 'Beta', 1);
quat1 = zeros(length(time1), 4);
for t = 1:length(time1)
    AHRS1.Update(gyro1(t,:) * (pi/180), accel1(t,:), magn1(t,:));	% gyroscope units must be radians
    quat1(t, :) = AHRS1.Quaternion;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%IMU2%%%%%%%%%%%%%%
AHRS2 = MadgwickAHRS('SamplePeriod', time2(10) - time2(9), 'Beta', 1);
quat2 = zeros(length(time2), 4);
for t = 1:length(time2)
    AHRS2.Update(gyro2(t,:) * (pi/180), accel2(t,:), magn2(t,:));	% gyroscope units must be radians
    quat2(t, :) = AHRS2.Quaternion;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%IMU3%%%%%%%%%%%%%%
AHRS3 = MadgwickAHRS('SamplePeriod', time3(10) - time3(9), 'Beta', 1);
quat3 = zeros(length(time3), 4);
for t = 1:length(time3)
    AHRS3.Update(gyro3(t,:) * (pi/180), accel3(t,:), magn3(t,:));	% gyroscope units must be radians
    quat3(t, :) = AHRS3.Quaternion;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%IMU4%%%%%%%%%%%%%%
AHRS4 = MadgwickAHRS('SamplePeriod', time4(10) - time4(9), 'Beta', 1);
quat4 = zeros(length(time4), 4);
for t = 1:length(time4)
    AHRS4.Update(gyro4(t,:) * (pi/180), accel4(t,:), magn4(t,:));	% gyroscope units must be radians
    quat4(t, :) = AHRS4.Quaternion;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%IMU5%%%%%%%%%%%%%%
AHRS5 = MadgwickAHRS('SamplePeriod', time5(10) - time5(9), 'Beta', 1);
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

dyn_acc_0 = dyn_acc(quat0(150:end,:),accel0(150:end,:));
dyn_acc_1 = dyn_acc(quat1(150:end,:),accel1(150:end,:));
dyn_acc_2 = dyn_acc(quat2(150:end,:),accel2(150:end,:));
dyn_acc_3 = dyn_acc(quat3(150:end,:),accel3(150:end,:));
dyn_acc_4 = dyn_acc(quat4(150:end,:),accel4(150:end,:));
dyn_acc_5 = dyn_acc(quat5(150:end,:),accel5(150:end,:));

%use this to extract everything after the first 100
% dyn_acc_0_f = dyn_acc_0(100:end,:);
% dyn_acc_1_f = dyn_acc_0(100:end,:);
% dyn_acc_2_f = dyn_acc_0(100:end,:);
% dyn_acc_3_f = dyn_acc_0(100:end,:);
% dyn_acc_4_f = dyn_acc_0(100:end,:);
% dyn_acc_5_f = dyn_acc_0(150:end,:);
%dyn_acc_6 = dyn_acc(quat6,accel6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%rotate dynamic acceleration into the frame of the earth%%%%%

%%these results are all quaternions
acc_earth_q_0 = dyn_acc_earthFrame(dyn_acc_0,quat0(150:end,:));
acc_earth_q_1 = dyn_acc_earthFrame(dyn_acc_1,quat1(150:end,:));
acc_earth_q_2 = dyn_acc_earthFrame(dyn_acc_2,quat2(150:end,:));
acc_earth_q_3 = dyn_acc_earthFrame(dyn_acc_3,quat3(150:end,:));
acc_earth_q_4 = dyn_acc_earthFrame(dyn_acc_4,quat4(100:end,:));
acc_earth_q_5 = dyn_acc_earthFrame(dyn_acc_5,quat5(150:end,:));
%acc_earth_q_5 = dyn_acc_earthFrame(dyn_acc_5_f,quat5(150:end,:));
%acc_earth_q_6 = dyn_acc_earthFrame(dyn_acc_6,quat6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%get the acceleration vector components%%%%%%%%%%%%%%%%%%%%

%ax0 = acc_earth_q_0(200:end,2); ay0 = acc_earth_q_0(200:end,3); az0 = acc_earth_q_0(200:end,4);
%ax1 = acc_earth_q_1(200:end,2); ay1 = acc_earth_q_1(200:end,3); az1 = acc_earth_q_1(200:end,4);
%ax2 = acc_earth_q_2(200:end,2); ay2 = acc_earth_q_2(200:end,3); az2 = acc_earth_q_2(200:end,4);
%ax3 = acc_earth_q_3(200:end,2); ay3 = acc_earth_q_3(200:end,3); az3 = acc_earth_q_3(200:end,4);
%ax4 = acc_earth_q_4(200:end,2); ay4 = acc_earth_q_4(200:end,3); az4 = acc_earth_q_4(200:end,4);
%ax5 = acc_earth_q_5(200:end,2); ay5 = acc_earth_q_5(200:end,3); az5 = acc_earth_q_5(200:end,4);
%ax6 = acc_earth_q_6(:,2); ay6 = acc_earth_q_6(:,3); az6 = acc_earth_q_6(:,4);

ax0 = acc_earth_q_0(:,2); ay0 = acc_earth_q_0(:,3); az0 = acc_earth_q_0(:,4);
ax1 = acc_earth_q_1(:,2); ay1 = acc_earth_q_1(:,3); az1 = acc_earth_q_1(:,4);
ax2 = acc_earth_q_2(:,2); ay2 = acc_earth_q_2(:,3); az2 = acc_earth_q_2(:,4);
ax3 = acc_earth_q_3(:,2); ay3 = acc_earth_q_3(:,3); az3 = acc_earth_q_3(:,4);
ax4 = acc_earth_q_4(:,2); ay4 = acc_earth_q_4(:,3); az4 = acc_earth_q_4(:,4);
ax5 = acc_earth_q_5(:,2); ay5 = acc_earth_q_5(:,3); az5 = acc_earth_q_5(:,4);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%numerically integrate to get velocity components %%%%%%

% vx0 = numInt(ax0,time0,ax0(1,:));vy0 = numInt(ay0,time0,ay0(1,:));vz0 = numInt(az0,time0,az0(1,:));
% vx1 = numInt(ax1,time1,ax1(1,:));vy1 = numInt(ay1,time1,ay1(1,:));vz1 = numInt(az1,time1,az1(1,:));
% vx2 = numInt(ax2,time2,ax2(1,:));vy2 = numInt(ay2,time2,ay2(1,:));vz2 = numInt(az2,time2,az2(1,:));
% vx3 = numInt(ax3,time3,ax3(1,:));vy3 = numInt(ay3,time3,ay3(1,:));vz3 = numInt(az3,time3,az3(1,:));
% vx4 = numInt(ax4,time4,ax4(1,:));vy4 = numInt(ay4,time4,ay4(1,:));vz4 = numInt(az4,time4,az4(1,:));
% vx5 = numInt(ax5,time5,ax5(1,:));vy5 = numInt(ay5,time5,ay5(1,:));vz5 = numInt(az5,time5,az5(1,:));
time0 = time0(150:end,:);
time1 = time1(150:end,:);
time2 = time2(150:end,:);
time3 = time3(150:end,:);
time4 = time4(150:end,:);
time5 = time5(150:end,:);
vx0 = numInt(ax0,time0,0);vy0 = numInt(ay0,time0,0);vz0 = numInt(az0,time0,0);
vx1 = numInt(ax1,time1,0);vy1 = numInt(ay1,time1,0);vz1 = numInt(az1,time1,0);
vx2 = numInt(ax2,time2,0);vy2 = numInt(ay2,time2,0);vz2 = numInt(az2,time2,0);
vx3 = numInt(ax3,time3,0);vy3 = numInt(ay3,time3,0);vz3 = numInt(az3,time3,0);
vx4 = numInt(ax4,time4,0);vy4 = numInt(ay4,time4,0);vz4 = numInt(az4,time4,0);
vx5 = numInt(ax5,time5,0);vy5 = numInt(ay5,time5,0);vz5 = numInt(az5,time5,0);
%vx6 = numInt(ax6,time6,ax6(1,:));vy6 = numInt(ay6,time6,ay6(1,:));vz6 = numInt(az6,time6,az6(1,:));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%form data vectors for each IMU%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%format: [timestamp IMU# vx vy vz]

vdat0 = [time0 1.*ones(length(time0),1) vx0 vy0 vz0];
vdat1 = [time1 2.*ones(length(time1),1) vx1 vy1 vz1];
vdat2 = [time2 3.*ones(length(time2),1) vx2 vy2 vz2];
vdat3 = [time3 4.*ones(length(time3),1) vx3 vy3 vz3];
vdat4 = [time4 5.*ones(length(time4),1) vx4 vy4 vz4];
vdat5 = [time5 6.*ones(length(time5),1) vx5 vy5 vz5];
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


%dlmwrite('imudata4.txt',result,'\t');
dlmwrite(outfile,result,'\t');

end







