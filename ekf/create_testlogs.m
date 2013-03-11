% Ashleigh Thomas thomasas@seas.upenn.edu
% Creates test files for use in EKF. 
% Log files are stored in ./logs

clear all;


N = 20;                                   % total dynamic steps
n_in=6;                                      %number of state
s_in=[1 0 0 2 4 2];                              % initial state
n_vis=3;
s_vis=[1 1 1];
%h=@(x)x(1);                               % measurement equation
r_in=0.1;                                    %std of measurement 
r_vis=0.1;

truth_in = zeros(n_in,N);          %               % allocate memory
est_in = zeros(n_in,N);          %actual
truth_vis = zeros(n_vis,N);          %               % allocate memory
est_vis = zeros(n_vis,N);          %actual


%zV(1)='e';
for k=1:N
  z_in = s_in + r_in*randn(1,n_in); %h(s) + r*randn;                     % measurments (create test data) 
  truth_in(:,k)= s_in;                             % save actual state
  est_in(:,k)  = z_in;                            % save measurment
  z_vis = s_vis + r_vis*randn(1,n_vis);  
  truth_vis(:,k)= s_vis;                            
  est_vis(:,k)  = z_vis;                            
end
x = (1:N)';

testlogfile_in = './logs/log_in_1.txt';
truthlogfile_in = './logs/log_in_1_truth.txt';
testlogfile_vis = './logs/log_vis_1.txt';
truthlogfile_vis = './logs/log_vis_1_truth.txt';


testdata_in = cat(2,x,est_in');
truthdata_in = cat(2,x,truth_in');
testdata_vis = cat(2,x,est_vis');
truthdata_vis = cat(2,x,truth_vis');

% first column is measurements, 
% next three are actual
%save log_1.txt testdata -ASCII
%save log_1_truth.txt truthV -ASCII
%dlmwrite(logfile,zV, 'delimiter', '\t')
%dlmwrite(logfile,sV,'-append', 'delimiter', '\t')
dlmwrite(testlogfile_in, testdata_in, 'delimiter', '\t');
dlmwrite(truthlogfile_in, truthdata_in, 'delimiter', '\t');
dlmwrite(testlogfile_vis, testdata_vis, 'delimiter', '\t');
dlmwrite(truthlogfile_vis, truthdata_vis, 'delimiter', '\t');
