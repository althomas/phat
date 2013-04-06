function datamat = robotfkine(robot,values)
%function datamat = robotfkine(robot,values)
%
%Calculate the fingertip poses of the robot model with the provided joint
%values. 
%
%Requires the robotic Toolbox of P. Corke
%
%   input:
%       - robot: Robot hand model struct. For example sensorhandmodel.m creates
%           such a struct.
%       - values: Joint values for the robot hand.
%
%
%Copyright(c) Thomas Feix, thomas@xief.net
%Grade your Hand Toolbox downloaded available at grasp.xief.net
%
%The Toolbox is distributed under GPL3 licence. 
%Revision 2.1, 2012-12-18

if sum(robot(1).dof) ~= size(values,2)
    error(['Number of Dimensions in the hand (' num2str(sum(robot(1).dof)) ')'...
        ' does not fit to the number of dimensions in the value matrix (' num2str(size(values,2)) ')'])
end


datamat = zeros(size(values,1),60);
for i = 1:size(values,1)    %samples
    ind = 1;
    tempvals = zeros(1,60);
    for f = 1:size(robot.finger,2) %fingers
        temp = fkine(robot.finger{f},values(i,ind:ind+robot.dof(f)-1));
        rots = temp(1:3,1:3);
        tempvals(1,(f-1)*12+1:(f*12)) = [temp(1:3,4)' rots(:)' ];
        ind = ind + robot.dof(f);
    end
    datamat(i,:) = tempvals;
end
    
