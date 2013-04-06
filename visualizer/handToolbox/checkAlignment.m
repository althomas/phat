function checkAlignment(humMat,datamat)
%function checkAlignment(humMat,datamat)
%
%This function allows to plot the fingertip positions of the artificial
%hand against the human dataset. The human data will be plotted in small
%dots and the robot hand in thick dots. The points should cover roughly the
%same area. The robot input data should have the origin at the MCP of the
%middle. The function translates it to the correct position (as will be
%done for the projection as well). 
%
%   input:
%       - humMat: Matrix of human hand movements of size N1 x 60
%       - dataMat: Matris of robot hand movements of size N2 x 60
%
%
%Copyright(c) Thomas Feix, thomas@xief.net
%Grade your Hand Toolbox downloaded available at grasp.xief.net
%
%The Toolbox is distributed under GPL3 licence. 
%Revision 2.1, 2012-12-18


if size(humMat,2) ~= size(datamat,2)
    error('Dimension of the human and robot dataset has to be the same')
end
    
if size(datamat,2) == 60
    posCol = [1 2 3;13 14 15;25 26 27;37 38 39;49 50 51];
else
    error('Do not recognize data dimension')
end


humMat = scaleData(humMat,-1); %translate the hand so that it is at the correct place.


symbols = {'r.' 'g.' 'b.' 'y.' 'c.'};
figure
clf
hold on
for f = 1:size(posCol,1)
    plot3(humMat(:,posCol(f,1)),humMat(:,posCol(f,2)),humMat(:,posCol(f,3)),symbols{f},'MarkerSize',2)
    plot3(datamat(:,posCol(f,1)),datamat(:,posCol(f,2)),datamat(:,posCol(f,3)),symbols{f},'MarkerSize',6)        
end

hold off
set(gca,'XDir','reverse');
set(gca,'ZDir','reverse');
xlabel('X')
ylabel('Y')
zlabel('Z')
grid on