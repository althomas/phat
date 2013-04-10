% Ashleigh Thomas thomasas@seas.upenn.edu University of Pennsylvania
% Creates test files for use in EKF. 
% Log files are stored in ./logs
% This creates full-sized log files for 7 IMU/LED pairs

% creates continuous true velocity function,
% integrates to find true position function.
% Discrete samples + normally distributed noise
% as well as some drift for velocity data
% creates noisy sample data.
% the "true" data is discrete position samples at every
% timestamp used for the noisy data (velocity as well as positon)

clear all;

logname = 'full';

testlogfile_in = cat(2,'./logs/',logname,'_in.txt');
truthlogfile_in = cat(2,'./logs/',logname,'_in_truth.txt');
testlogfile_vis = cat(2,'./logs/',logname,'_vis.txt');
truthlogfile_vis = cat(2,'./logs/',logname,'_vis_truth.txt');
truthlogfile = cat(2,'./logs/',logname,'_truth.txt'); % has true vision for every timestamp (both intertial and position

n = 7; % number of IMU/LED pairs
duration = 15; % duration of entire sample scheme in seconds
n_in=3*n;                                      %number of state
s_in=zeros(n_in,1);                              % initial state
n_vis = 3*n;
p_0 = [ -1; 2; 0; % arm
        1; 2; 0; % hand
        2; 0; 0; % thumb
        3.7; 1; 0; % index
        4.5; 2; 0; % middle
        3.7; 3; 0; % ring
        3.5; 4; 0; % pinky
                  ];                    % initial state
r_in=0.1;                                    %std of measurement 
r_vis=0.1;
hz_in = 140;
hz_vis = 15;
period_in = 1/hz_in;
period_vis = 1/hz_vis;


% create timestamps

offset_in = ceil(rand*period_in);
offset_vis = ceil(rand*period_vis);

samples_in = ceil(duration*hz_in);
samples_vis = ceil(duration*hz_vis);

t_in = ( (1:samples_in)*period_in + offset_in*ones(samples_in) )'
t_vis = ( (1:samples_vis)*period_vis + offset_in*ones(samples_vis) )'


% create drift direction and amplitude for each imu
max_drift_amp = .01;
drift = max_drift_amp * ( rand(7,3) - rand(7,3) ) /2;

% sample according to timestamps
for k=1:length(t_in)
  %full_truth_in(k,:) = [t_in(k) vel(t_in(k))]; 
  imu = ((k mod 7)+1);
  truth_in(k,:) = [t_in(k) imu vel(t_in(k))(imu)];
  % add normally distributed noise and drift
  est_in(k,:) = truth_in(k,:) + [0 0 r_in*randn(1,3)] + [0 0 drift(imu,:)*t_in(k)];
end

for k=1:length(t_vis)
  %full_truth_vis(k,:) = [t_vis(k) pos(t_vis(k))];
  
  p = pos(t_vis(k));
  % create stationary data (with noise)
  flag = round(rand(1));
  if flag == 0
    truth_vis(k,:) = [t_vis(k) flag p(2,:) p(1,:) p(4,:) p(6,:)];
  else  
    truth_vis(k,:) = [t_vis(k) flag p(2,:) p(3,:) p(5,:) p(7,:)];
  end

  % add normally distributed noise
  est_vis(k,:) = truth_vis(k,:) + [0 0 r_vis*randn(1,12)];                         

end


% create truth file




dlmwrite(testlogfile_in, est_in, 'delimiter', '\t');
dlmwrite(truthlogfile_in, truth_in, 'delimiter', '\t');
dlmwrite(testlogfile_vis, est_vis, 'delimiter', '\t');
dlmwrite(truthlogfile_vis, truth_vis, 'delimiter', '\t');
dlmwrite(truthlogfile, truth_vis, 'delimiter', '\t');


function [v]=vel(t)
% continuous velocity function
v = -[0 0 0; % arm
      0 0 0; % hand
      .005 .005 0; % thumb
      -.01 0 0; % index
      -.01 0 0; % middle
      -.01 0 0; % ring
      -.01 0 0; % pinky
      ];


function [p]=pos(t)
% continuous position function

p = p_0 + integrate(t);

function [z]=integrate(t)
% numerical integration - left-aligned
blocks = 300; % blocks per second (unit value of t)

for i=1:ceil(blocks*t) 

  z = z + vel(i/blocks)/blocks; 

end
