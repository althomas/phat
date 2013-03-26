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
x=x_0+q*randn(n,1); 
P=c.P;          
N=c.N;                
xV = zeros(n,N);          %estimate       % allocate memory
sV = zeros(n,N);          %actual
%zV = zeros(1,N); % do we need this?



% read in test data (with truth) 
[in,vis]=read_logs(c.testlog_in,c.testlog_vis);
% at this point we have to match up timestamps (and length!), but for now we assume
% they match up perfectly

data = cat(2,in(:,2:4),vis(:,2:end)); % this throws out the timestamp entirely
N = length(vis(:,1)); % Should replace this with "read until there's no more to read"




for k=1:N
  z = vis(k,2:end)' + r*randn(3,1);                    % actual measurments from vision
  zV(:,k) = z;                                  % save vision measurements for plots
  u = in(k,2:4)' + q*randn(3,1);                      % inertial measurements
  uV(:,k) = u;
  [x, P] = ekf(f,x,u,t,P,h,z,Q,R);            % ekf
  xV(:,k) = x;                            % save estimate
%  s = f(s) + q*randn(n,1);                % update process
end



% plot data
%for k=1:n                                 % plot results
%  subplot(n,1,k)
  %plot(1:N, sV(k,:), '-', 1:N, xV(k,:), '--')
  hold on;
  plot( 1:N, vis(:,2),'b',1:N, xV(1,:), 'r:o'); %ekf estimate coordinates
  scatter(1:N, zV(1,:), 'kx'); % vision measured coordinates  

  quiver(1:N, xV(1,:), cos(uV(1,:)), sin(uV(1,:)), .1 );
 

  xlabel('timestep');
  ylabel('x position');
  legend('true position','estimate from EKF', 'measured position (from vision)');
  title('Estimate using noisy data vs true readings of x position. Std of measurements: 0.01 ');
  axis([0 20 -.2 1.4]);
  %legend ('actual state', 'estimate', 'Location', 'EastOutside');
  %legend ('estimate', 'Location', 'EastOutside');
%end


