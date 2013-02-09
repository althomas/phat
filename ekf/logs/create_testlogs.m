% Ashleigh Thomas thomasas@seas.upenn.edu
% Creates test files for use in EKF. 
% Log files are stored in ./logs

clear all;
N = 20;                                   % total dynamic steps
n=6;                                      %number of state
s=[1 0 0 2 4 2];                              % initial state
h=@(x)x(1);                               % measurement equation
r=0.1;                                    %std of measurement 

truthV = zeros(n,N);          %               % allocate memory
estV = zeros(n,N);          %actual

%zV(1)='e';
for k=1:N
  z = s + r*randn(1,n); %h(s) + r*randn;                     % measurments (create test data) 
  truthV(:,k)= s;                             % save actual state
  estV(:,k)  = z;                            % save measurment
end
x = (1:20)';

testlogfile = 'log_1.txt';
truthlogfile = 'log_1_truth.txt';

estV = estV';
truthV = truthV';

testdata = cat(2,x,estV);
truthdata = cat(2,x,truthV);

% first column is measurements, 
% next three are actual
%save log_1.txt testdata -ASCII
%save log_1_truth.txt truthV -ASCII
%dlmwrite(logfile,zV, 'delimiter', '\t')
%dlmwrite(logfile,sV,'-append', 'delimiter', '\t')
dlmwrite(testlogfile, testdata, 'delimiter', '\t');
dlmwrite(truthlogfile, truthdata, 'delimiter', '\t');
