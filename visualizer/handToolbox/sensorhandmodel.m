function [data values lbls handlength] = sensorhandmodel
%function [data values lbls handlength] = sensorhandmodel
%
%Create the OB SensorHand Speed hand model. 
%
%   output:
%       - data: Robot hand model struct. 
%       - values: Joint value matrix of size N x (sum(DoF))
%       - lbls: Lable matrix which can be used to highlight different
%           trajectories in the latent space plot. Size N x L, where L is
%           the number of different lables. 
%       - handlength: Size of the hand model to scale the positional
%           variables.
%
%
%Copyright(c) Thomas Feix, thomas@xief.net
%Grade your Hand Toolbox downloaded available at grasp.xief.net
%
%The Toolbox is distributed under GPL3 licence. 
%Revision 2.1, 2012-12-18


handlength = 19.68;

%index:
sl11 = 4.21;
sl12 = 2.65;
sl13 = 1.72;

x1 = 2.89;
y1 = 3.59;
z1 = 2.96;

%thumb:
sl21 = 3.43;
sl22 = 2.64;

x2 = 2.39;
y2 = 3.07;
z2 = 7.18;

%middle:
sl31 = 4.21;
sl32 = 2.65;
sl33 = 1.72;

x3 = 1.29;
y3 = 3.59;
z3 = 2.96;

%ring:
sl41 = 4;
sl42 = 2.4;
sl43 = 1.5;

x4 = 0;
y4 = 3.59;
z4 = 2.96;

%little:
sl51 = 3.8;
sl52 = 2.2;
sl53 = 1.3;

x5 = -1.3;
y5 = 3.59;
z5 = 2.96;

delta =  - [x3 y3 z3]; %to make sure MCP of middle is at [0 0 0]


%disp('######################## Creating Hand #####################');

%dof index thumb middle ring little
dofs= [3 2 3 3 3];

%new order: theta D A alpha


DH = [0 0 sl11 0 0 deg2rad(24); ...         %index
      0 0 sl12 0 0 deg2rad(37.4); ...
      0 0 sl13 0 0 deg2rad(33.1); ...
      0 0 sl21 0 0 -deg2rad(31.01); ...       %thumb
      0 0 sl22 0 0 deg2rad(28.9); ...
      0 0 sl31 0 0 deg2rad(24); ...         %middle 
      0 0 sl32 0 0 deg2rad(37.4); ...
      0 0 sl33 0 0 deg2rad(33.1); ...
      0 0 sl41 0 0 deg2rad(20); ...         %ring
      0 0 sl42 0 0 deg2rad(35); ...
      0 0 sl43 0 0 deg2rad(30); ...
      0 0 sl51 0 0 deg2rad(20); ...         %little
      0 0 sl52 0 0 deg2rad(35); ...
      0 0 sl53 0 0 deg2rad(30)];            


  
  %Base definition matrix
  %trans X, trans Y, trans Z, rot X, rot Y, rot z
  base = [x1 y1 z1 pi/2 0 pi/2; ...
          x2 y2 z2 -pi/2 0 pi/2; ...
          x3 y3 z3 pi/2 0 pi/2; ...
          x4 y4 z4 pi/2 0 pi/2; ...
          x5 y5 z5 pi/2 0 pi/2];
      
      


%       
      
  %This loop creates the individual Fingers. the parameters are from the
  %matrix above.
  num_fing = 1;
  inc = 1;
  names = {'Index' 'Thumb' 'Middle'  'Ring' 'Little'};  
  for i = 1:size(DH,1)
      links(inc) = Link(DH(i,:)); 
    
    if (inc == dofs(num_fing))
       %disp(['Creating Finger: ' num2str(num_fing) ' DoF: ' num2str(dofs(num_fing))]);
       temp = SerialLink(links(1:inc));
       mat = transl(base(num_fing,1:3))*trotz(base(num_fing,6))*troty(base(num_fing,5))*trotx(base(num_fing,4));
       temp.base = transl(delta)*mat;
       temp.tool = trotz(-pi/2)*troty(-pi/2);
       temp.name = names{num_fing};
       finger{num_fing} = temp;
       num_fing = num_fing +1;
       inc = 0;
       clear links;
    end
    inc = inc + 1;
      
  end
  

  data.finger = finger;
  data.dof = dofs;
  %data.pose = pose;
  
  
  
  
%disp('Creating Joint Values')
openingangle = 43;
vals = deg2rad(-openingangle:0.1:0)';     %sensorhand -40...0

n = length(vals);
offset = linspace(0,deg2rad(openingangle/10),n)';
%values = [vals(:,1) zeros(n,1) vals(:,2) zeros(n,2) vals(:,3) zeros(n,2) vals(:,4) zeros(n,2) vals(:,5) zeros(n,2)];
values = [vals zeros(n,2) vals zeros(n,1) vals zeros(n,2) vals-offset zeros(n,2) vals-2*offset zeros(n,2)];



%lbls can be used to highlight different modes of the hand, different hand
%movements or similar. In the low dimensional plot they will be plotted in
%a different color. 
%
%For example if two lables are to be used, where the first half of the
%datapoints belong to class one and the rest to class two, then lbls would
%look like that:
%lbls = (1 0
%        .
%        .
%        1 0
%        0 1
%        .
%        .
%        0 1);
%In that case we only create one label for all points:
lbls = ones(n,1);






