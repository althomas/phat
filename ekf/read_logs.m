% reads log files 

%function [est, truth]=read_logs(logfile, test)
function [in,vis]=read_logs(logfile_in, logfile_vis)


in = dlmread(logfile_in, '\t'); 
vis = dlmread(logfile_vis, '\t'); 

end
