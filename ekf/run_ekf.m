% Ashleigh Thomas thomasas@seas.upenn.edu
% 
% starting point to run ekf

clear all;

c = config();

remove_imu = 0;

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
  true_pos = dlmread(c.truthlog, '\t'); 
end

if (remove_imu == 1)
    in(:,3:end) = in(:,3:end)*0;
end

moreData = true; % this becomes false when there is no more data to read
N_in = length(in(:,1));
N_vis = length(vis(:,1));

cin = 1;
cvis = 1;

% IMUs update only one at a time, so will have to keep track of previous timestamp
lastts = in(1,1)*ones(1,6);

% at this point we have to match up timestamps (and length!), but for now we assume
% they match up perfectly

% get handles for each ekf function
ekf = ekf();

k = 1; % number of data points we have so far
% timestamp data
x(1,:) = [0 x_0];


while (moreData)
  time_in = in(cin,1);
  time_vis = vis(cvis,1);
  
  if (time_in < time_vis)
    % predict

    u = in(cin,2:end);            % inertial measurements
    imu = u(1);
    t = time_in - lastts(imu);
    lastts(imu) = time_in;    
    
    x(k+1,1) = time_in;
    [x(k+1,2:end), P] = ekf.predict(f, x(k,2:end), u, t, P, Q);
    cin = cin + 1;
  elseif (time_in > time_vis)
    % update
    z = vis(cvis,2:end);      % measurments from vision                   
    t = 0; % only need time for IMUs
    x(k+1,1) = time_vis;    
    [x(k+1,2:end), P] = ekf.update(x(k,2:end), P, h, z, R);          
    cvis = cvis + 1;
  else 
    % both updates at same time
    % predict  
    u = in(cin,2:end);            % inertial measurements
    imu = u(1);    
    t = time_in - lastts(imu);
    lastts(imu) = time_in;    
    
    [x_apri, P] = ekf.predict(f, x(k,2:end), u, t, P, Q);
    cin = cin + 1;

    % update
    z = vis(cvis,2:end);      % measurments from vision                   
    x(k+1,1) = time_vis;    
    [x(k+1,2:end), P] = ekf.update(x_apri, P, h, z, R);          
    cvis = cvis + 1;

  end

  k = k+1;

  if (cvis > N_vis) || (cin > N_in)
    moreData = false;
  end

end

plot_overhead_view(x);




