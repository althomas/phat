% Ashleigh Thomas thomasas@seas.upenn.edu
% University of Pennsylvania 2013

function plot_overhead_view (x) 

start = 25;

hold on;

plot(x(1,start:end), x(2,start:end), 'ro-', x(4,start:end), x(5,start:end), 'go-', x(7,start:end), x(8,start:end), 'bo-', x(10,start:end), x(11,start:end), 'ro-', x(13,start:end), x(14,start:end), 'mo-', x(16,start:end), x(17,start:end), 'ko-', x(19,start:end), x(20,start:end), 'bo-' ); 

%plot(x(1,2:end), x(2,2:end), 'ro-');

xlabel('x');
ylabel('y');
title('Overhead view of grasping motion');
axis([-1.5 5 -1 5]);
hold off;




