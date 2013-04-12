%convert acceleration to velocity 
function [v] = numInt(a,t,initCondition)
[l m] = size(a);
v = zeros(length(a),1);
b = zeros(length(a),1);
v(1) = initCondition;
for i=2:length(a)
    T = t(i) - t(i-1);
    %b(i) = ((a(i)+a(i-1))/2)*T; %T is the time between samples a(i-1) and a(i)
    %v(i) = sum(b);
    
    v(i) = v(i-1) + a(i-1)*T;
end

