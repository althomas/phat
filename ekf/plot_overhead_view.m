% Ashleigh Thomas thomasas@seas.upenn.edu
% University of Pennsylvania 2013

function plot_overhead_view (x) 

start = 50;

clf;
hold on;

plot(x(start:end,2), x(start:end,3), 'ro-')
plot(x(start:end,5), x(start:end,6), 'go-')
plot(x(start:end,8), x(start:end,9), 'bo-')
plot(x(start:end,11), x(start:end,12), 'ro-');
plot(x(start:end,14), x(start:end,15), 'mo-');
plot(x(start:end,17), x(start:end,18), 'ko-');
%plot(x(start:end,20), x(start:end,21), 'bo-' ); 

%plot(x(1,2:end), x(2,2:end), 'ro-');

xlabel('x');
ylabel('y');
title('Overhead view of grasping motion');
axis([-1.5 5 -1 5]);
hold off;




