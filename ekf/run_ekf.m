% Ashleigh Thomas thomasas@seas.upenn.edu
% 
% starting point to run ekf

clear all;

n=3;      %number of states (make sure to change f and s accordingly)
q=0.01;    %std of process 
r=0.01;    %std of measurement 
Q=q^2*eye(n); % covariance of process
R=r^2*eye(n);        % covariance of measurement
t = .01;        %timestep in seconds
f=@(x,u,t)[x(1)+t*u(1);x(2)+t*u(2);x(3)+t*u(3)];  % nonlinear state equations
h=@(x,u,t)[x(1);x(2);x(3)];                               % measurement equation
x_0=[0;0;0];                              % initial state (note: this used to be called s)
x=x_0+q*randn(n,1); %initial state          % initial state with noise
P = eye(n);                               % initial state covraiance
N=20;                                     % total dynamic steps
xV = zeros(n,N);          %estimate       % allocate memory
sV = zeros(n,N);          %actual
zV = zeros(1,N); % do we need this?


% create test data and update process
%for k=1:N
%  z = h(s) + r*randn;                     % measurments (create test data)
%  sV(:,k)= s;                             % save actual state
%  zV(k)  = z;                             % save measurment
%  [x, P] = ekf(f,x,P,h,z,Q,R);            % ekf
%  xV(:,k) = x;                            % save estimate
%  s = f(s) + q*randn(n,1);                % update process
%end

% read in test data (with truth) 
[in,vis]=read_logs();
% at this point we have to match up timestamps (and length!), but for now we assume
% they match up perfectly

data = cat(2,in(:,2:4),vis(:,2:end)); % this throws out the timestamp entirely
N = length(vis(:,1));


for k=1:N
  z = vis(k,2:end)' + r*randn(3,1);                    % actual measurments from vision
  u = in(k,2:4)' + q*randn(3,1);                      % inertial measurements
  [x, P] = ekf(f,x,u,t,P,h,z,Q,R);            % ekf
  xV(:,k) = x;                            % save estimate
%  s = f(s) + q*randn(n,1);                % update process
end



% plot data
%for k=1:n                                 % plot results
%  subplot(n,1,k)
  %plot(1:N, sV(k,:), '-', 1:N, xV(k,:), '--')
  plot(1:N, vis(:,2),'b', 1:N, xV(1,:), 'r:o');
  xlabel('timestep');
  ylabel('x position');
  legend('true position','estimate from EKF');
  title('Estimate using noisy data vs true readings of x position. Std of measurements: 0.01 ');
  axis([0 20 -.2 1.4]);
  %legend ('actual state', 'estimate', 'Location', 'EastOutside');
  %legend ('estimate', 'Location', 'EastOutside');
%end

% Original example
%{
n=3;      %number of state
q=0.1;    %std of process 
r=0.1;    %std of measurement
Q=q^2*eye(n); % covariance of process
R=r^2;        % covariance of measurement  
f=@(x)[x(2);x(3);0.05*x(1)*(x(2)+x(3))];  % nonlinear state equations
h=@(x)x(1);                               % measurement equation
s=[0;0;1];                                % initial state
x=s+q*randn(3,1); %initial state          % initial state with noise
P = eye(n);                               % initial state covraiance
N=20;                                     % total dynamic steps
xV = zeros(n,N);          %estmate        % allocate memory
sV = zeros(n,N);          %actual
zV = zeros(1,N);
for k=1:N
  z = h(s) + r*randn;                     % measurments
  sV(:,k)= s;                             % save actual state
  zV(k)  = z;                             % save measurment
  [x, P] = ekf(f,x,P,h,z,Q,R);            % ekf 
  xV(:,k) = x;                            % save estimate
  s = f(s) + q*randn(3,1);                % update process 
end
for k=1:3                                 % plot results
  subplot(3,1,k)
  plot(1:N, sV(k,:), '-', 1:N, xV(k,:), '--')
end
%}
