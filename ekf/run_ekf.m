% Ashleigh Thomas thomasas@seas.upenn.edu
% 
% starting point to run ekf


n=6;      %number of state (make sure to change f and s accordingly)
q=0.1;    %std of process 
r=0.1;    %std of measurement 
Q=q^2*eye(n); % covariance of process
R=r^2;        % covariance of measurement
f=@(x)[sin(x(2));x(3);0.05*x(1)*(x(2)+x(3))];  % nonlinear state equations
f=@(x)[sin(x(1));x(1);x(2);x(3);x(4)*x(5);x(6)];
h=@(x)x(1);                               % measurement equation
s=[1;0;0;2;4;2];                              % initial state
x=s+q*randn(n,1); %initial state          % initial state with noise
P = eye(n);                               % initial state covraiance
N=20;                                     % total dynamic steps
xV = zeros(n,N);          %estimate       % allocate memory
sV = zeros(n,N);          %actual
zV = zeros(1,N); % do we need this?


% create test data and update process
for k=1:N
  z = h(s) + r*randn;                     % measurments (create test data)
  sV(:,k)= s;                             % save actual state
  zV(k)  = z;                             % save measurment
  [x, P] = ekf(f,x,P,h,z,Q,R);            % ekf
  xV(:,k) = x;                            % save estimate
  s = f(s) + q*randn(n,1);                % update process
end

% read in test data (with truth) and 
for k=1:N
  z = h(s) + r*randn;                     % measurments (create test data)
  sV(:,k)= s;                             % save actual state
  zV(k)  = z;                             % save measurment
  [x, P] = ekf(f,x,P,h,z,Q,R);            % ekf
  xV(:,k) = x;                            % save estimate
  s = f(s) + q*randn(n,1);                % update process
end



% plot data
for k=1:n                                 % plot results
  subplot(n,1,k)
  plot(1:N, sV(k,:), '-', 1:N, xV(k,:), '--')
  legend ('actual state', 'estimate', 'Location', 'EastOutside');
end

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
