% Ashleigh Thomas thomasas@seas.upenn.edu
% University of Pennsylvania 2013
% config file for using test data 
% which can be compared to a truth value

function c = config_test
  % input log files from inertial and visual sensors.
  % for fabricated data, include "truth" files with no noise for comparison
  c.testlog_in = './logs/full_in.txt'; % (intertial data)
  c.testlog_vis = './logs/full_vis.txt'; % (visions data)
  c.truthfiles = false; % if true, then we have created (instead of measuring) data
                        % and there are files (below) that have the "true" data,
                        % ie data without any added noise.
  c.truthlog_in = './logs/full_in_truth.txt';
  c.truthlog_vis = './logs/full_vis_truth.txt';
  c.truthlog = './logs/full_truth.txt';

  c.pairs = 6;           % number of IMU/LED pairs
  c.n = 3*c.pairs;      %number of states (make sure to change f and s accordingly)
  c.q = 0.06;           %std of process 
  c.r = 0.02;           %std of measurement 
  % Notes for q and r: if q >> r, then we essentially take the vision measurements


  c.Q = c.q^2 * eye(c.n); % covariance of process
  c.R = c.r^2 * eye(c.n); % covariance of measurement
  c.t = .01;            %timestep in seconds
  c.f = @(x,u,t)[x + t*u];   % nonlinear state equations
  c.h = @(x,u,t)[x];                               % measurement equation

  % initial states
  c.x_0 = zeros(1,c.n);                              % initial state 
  c.P = eye(c.n);                               % initial state covraiance
  c.N = 50;                                     % total dynamic steps



end


