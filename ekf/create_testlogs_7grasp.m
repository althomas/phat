% Ashleigh Thomas thomasas@seas.upenn.edu University of Pennsylvania
% Creates test files for use in EKF. 
% Log files are stored in ./logs
% This creates full-sized log files for 7 IMU/LED pairs

clear all;

n = 7; % number of IMU/LED pairs
N = 75;                                   % total dynamic steps
n_in=3*n;                                      %number of state
s_in=zeros(n_in,1);                              % initial state
n_vis = 3*n;
s_vis=[ -1; 2; 0; % arm
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



for k=1:N

  % movement
  if k > 25
    s_in = s_in - [ 0; 0; 0;
                    0; 0; 0; 
                    .005; .005; 0;
                    -.01; 0; 0;
                    -.01; 0; 0;
                    -.01; 0; 0;
                    -.01; 0; 0;
                  ];
    s_vis = s_vis - .1*s_in;

  end



  % create stationary data (with noise)
  flag = round(rand(1));
  if flag == 0
    truth_vis(:,k)= cat(1,flag, s_vis(4:6),s_vis(1:3),s_vis(10:12),s_vis(16:18) );
  else
    truth_vis(:,k)= cat(1,flag, s_vis(4:6),s_vis(7:9),s_vis(13:15),s_vis(19:21) );
  end                      
  est_vis(:,k) = truth_vis(:,k) + cat(1,0,r_vis*randn(12,1));                         

  truth_in(:,k)= s_in;

  % only one IMU at a time
  imu = k mod 7;                            
  est_in(:,k) = cat(1,imu,truth_in(imu,k) + r_in*randn(1,1));             

end

%timestamps
x_in = ( period_in*(1:N) )'; 
x_vis = ( period_vis*(1:N) )';

testlogfile_in = './logs/test_in_7graspmv.txt';
truthlogfile_in = './logs/test_in_7graspmv_truth.txt';
testlogfile_vis = './logs/test_vis_7graspmv.txt';
truthlogfile_vis = './logs/test_vis_7graspmv_truth.txt';


testdata_in = cat(2,x,est_in');
truthdata_in = cat(2,x,truth_in');
testdata_vis = cat(2,x, est_vis');
truthdata_vis = cat(2,x,truth_vis');



dlmwrite(testlogfile_in, testdata_in, 'delimiter', '\t');
dlmwrite(truthlogfile_in, truthdata_in, 'delimiter', '\t');
dlmwrite(testlogfile_vis, testdata_vis, 'delimiter', '\t');
dlmwrite(truthlogfile_vis, truthdata_vis, 'delimiter', '\t');
