%test to extract dynamic acceleration from the fingerpitch stuff

%data is the result of calling dat_extract on the fingerpitch.txt data set
%using IMU1 cal set

%requires dat_extract and madTest to be used first to populate the data

function [dynamic_acc] = dyn_acc(q, accel)
g = zeros(length(accel),3);%g(0) = x component, g(1) = y component, g(2) = z component
dynamic_acc = zeros(length(accel),3);



for i= 1:length(accel)
    
    g(i,1) = 2*(q(i,2)*q(i,4) - q(i,1)*q(i,3));
    g(i,2) = 2*(q(i,1)*q(i,2) + q(i,3)*q(i,4));
    g(i,3) = q(i,1)*q(i,1) - q(i,2)*q(i,2) - q(i,3)*q(i,3) + q(i,4)*q(i,4);
    
    dynamic_acc(i,1) = accel(i,1) - g(i,1);
    dynamic_acc(i,2) = accel(i,2) - g(i,2);
    dynamic_acc(i,3) = accel(i,3) - g(i,3);

end
end

