%%script to transform the dynamic acceleration from the frame of the sensor
%%to the frame of the earth

function [dyn_acc_q_earth] = dyn_acc_earthFrame(dynamic_acc,quaternion)


dyn_acc_q = [zeros(length(dynamic_acc),1) dynamic_acc]; %make the quaternion of the dynamic acceleration
dyn_acc_q_earth = zeros(length(dyn_acc_q),4);

for i = 1:length(dyn_acc_q)
    
    %% doing quaternion*dyn_acc_q*quaternionconj
    conj = quaternConj(quaternion(i,:));
    temp = quaternProd(dyn_acc_q(i,:),conj);
    dyn_acc_q_earth(i,:) = quaternProd(quaternion(i,:),temp);
    
end
end