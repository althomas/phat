% Ashleigh Thomas thomasas@seas.upenn.edu
% Creates test files for use in EKF. 
% Log files are stored in ./logs

clear all;
N = 20;                                   % total dynamic steps
n=4;                                      %number of state
s=[1;0;0;2];                              % initial state
h=@(x)x(1);                               % measurement equation
r=0.1;                                    %std of measurement 

xV = zeros(n,N);          %estimate       % allocate memory
sV = zeros(n,N);          %actual


for k=1:N
  z = h(s) + r*randn;                     % measurments (create test data)
  sV(:,k)= s;                             % save actual state
  zV(k)  = z;                             % save measurment
end

save ('test_log_1.mat' , sV ,zV);
