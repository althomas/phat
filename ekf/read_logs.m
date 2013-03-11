% reads log files 

%function [est, truth]=read_logs(logfile, test)
function [in,vis]=read_logs

%logfile = './logs/log_1.txt';
logfile_in = './logs/test_in.txt';
logfile_vis = './logs/test_vis.txt';
%logfile = './logs/restData.txt';

%tdfread(logfile);
in = dlmread(logfile_in, '\t'); 
vis = dlmread(logfile_vis, '\t'); 
