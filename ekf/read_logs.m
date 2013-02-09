% reads log files 

%function [est, truth]=read_logs(logfile, test)
function read_logs

%logfile = './logs/log_1.txt';
logfile = './logs/freefall.txt';
%logfile = './logs/restData.txt';

%tdfread(logfile);
testdata = dlmread(logfile, '\t'); 
