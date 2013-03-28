% Ashleigh Thomas thomasas@seas.upenn.edu
% 
% starting point to run ekf

clear all;
clf;

c = config();

n=c.n;  
q=c.q;   
r=c.r;   
Q=c.Q; 
R=c.R; 
t=c.t;
f=c.f;  
h=c.h;                              
x_0=c.x_0;                              
P=c.P;          
N=c.N; 
truthfiles=c.truthfiles;               



% read in test data (with truth) 
[in,vis] = read_logs(c.testlog_in,c.testlog_vis);
if truthfiles
  [true_in, true_vis] = read_logs(c.truthlog_in,c.truthlog_vis);
end

%in = true_in;
%vis = true_vis;

% at this point we have to match up timestamps (and length!), but for now we assume
% they match up perfectly

%data = cat(2,in(:,2:4),vis(:,2:end)); % this throws out the timestamp entirely
N = length(vis(:,1)); % Should replace this with "read until there's no more to read"

x(:,1) = x_0;


for k=1:N
  z(:,k) = vis(k,2:end)';      % measurments from vision                   
  u(:,k) = in(k,2:end)';            % inertial measurements

  [x(:,k+1), P] = ekf(f, x(:,k), u(:,k), t, P, h, z(:,k), Q, R);            % ekf

end

plot_overhead_view(x);

% plot data
%for k=1:n                                 % plot results
%  subplot(n,1,k)
  %plot(1:N, sV(k,:), '-', 1:N, xV(k,:), '--')
%  hold on;
%  plot( 1:N, vis(:,2),'b',1:N, x(1,:), 'r:o'); %ekf estimate coordinates
%  scatter(1:N, z(1,:), 'kx'); % vision measured coordinates  

%  quiver(1:N, x(1,:), cos(u(1,:)), sin(u(1,:)), .1 );
 

%  xlabel('timestep');
%  ylabel('x position');
%  legend('true position','estimate from EKF', 'measured position (from vision)');
%  title('Estimate using noisy data vs true readings of x position. Std of measurements: 0.01 ');
%  axis([0 20 -.2 1.4]);
  %legend ('actual state', 'estimate', 'Location', 'EastOutside');
  %legend ('estimate', 'Location', 'EastOutside');
%end


