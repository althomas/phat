% Ashleigh Thomas thomasas@seas.upenn.edu
% University of Pennsylvania 2013

function plot_overhead_view2 (x) 

start = 150;

clf;
hold on;

%plot(x(start:end,2), x(start:end,3), 'c.'); % hand
%plot(x(start:end,5), x(start:end,6), 'k.'); %thumb
%plot(x(start:end,8), x(start:end,9), 'r.'); % index
%plot(x(start:end,11), x(start:end,12), 'c.'); % middle
%plot(x(start:end,14), x(start:end,15), 'k.'); % ring
%plot(x(start:end,17), x(start:end,18), 'r.'); %pinky



%slowplot test

time = 0:5e-2:10;
aviobj = avifile('~/Desktop/testvideo1.avi');
%aviobj.FrameRate = 20;
%open(aviobj);
hh = figure;


for i = 1:length(time)
    figure(hh)



    plot3(x(start:end,2), x(start:end,3), x(start:end,4), 'c.'); % hand
    plot3(x(start:end,5), x(start:end,6), x(start:end,7), 'k.'); %thumb
    plot3(x(start:end,8), x(start:end,9), x(start:end,10),'r.'); % index
    plot3(x(start:end,11), x(start:end,12), x(start:end,13),'c.'); % middle
    plot3(x(start:end,14), x(start:end,15), x(start:end,16),'k.'); % ring
    plot3(x(start:end,17), x(start:end,18), x(start:end,19),'r.'); %pinky

%plot(x(1,2:end), x(2,2:end), 'ro-');

    
    aviobj = addframe(aviobj, getframe(hh));
end

xlabel('x');
ylabel('y');
title('Overhead view of Data');
%axis([-1.5 5 -1 5]);
hold off;

aviobj = close(aviobj);


