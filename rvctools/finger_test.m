% Copyright (C) 1993-2013, by Peter I. Corke
%
% This file is part of The Robotics Toolbox for MATLAB (RTB).
% 
% RTB is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% RTB is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Leser General Public License
% along with RTB.  If not, see <http://www.gnu.org/licenses/>.
%
% http://www.petercorke.com

%%begin ==========================================
% Ashleigh Thomas
% University of Pennsylvania
% thomasas@seas.upenn.edu


% Link: 
%  theta    kinematic: joint/link angle (if specified, not revolute)
%  d        kinematic: link offset (if specified, not prismatic)
%  a        kinematic: link length
%  alpha    kinematic: link twist 
%  sigma    kinematic: 0 if revolute, 1 if prismatic
%  mdh      kinematic: 0 if standard D&H, else/MDH 1
%  offset   kinematic: joint variable/coordinate offset
%  name     joint coordinate name
%  qlim     kinematic: joint variable limits [min max]

%Config parameters:

% lengths of links: 
% tip-1st knuckle, 1st-2nd, 2nd-3rd, 3rd-center of hand
t = [1 1 1]; % thumb
i = [1 1 1]; % index
m = [1 1 1]; % middle
r = [1 1 1]; % ring
p = [1 1 1]; % pinky
w = 2; % length from center of hand to center of wrist
a = [-pi/6 0 pi/6 pi/3]; % angles between wrist-hand and hand-3rd: imrp


% need a mask matrix
% If the manipulator has fewer than 6 DOF then this method of solution
%    will fail, since the solution space has more dimensions than can
%    be spanned by the manipulator joint coordinates.  In such a case
%    it is necessary to provide a mask matrix, C{m}, which specifies the 
%    Cartesian DOF (in the wrist coordinate frame) that will be ignored
%    in reaching a solution.  The mask matrix has six elements that
%    correspond to translation in X, Y and Z, and rotation about X, Y and
%    Z respectively.  The value should be 0 (for ignore) or 1.  The number
%    of non-zero elements should equal the number of manipulator DOF.

%    For instance with a typical 5 DOF manipulator one would ignore
%    rotation about the wrist axis, that is, M = [1 1 1 1 1 0].
mask = [1 1 1 0 0 0];
%mask = [1 1 1 1 0 0];



L0 = Link('d', 0, 'a', 1, 'alpha', 0);
L1 = Link('d', 0, 'a', 1, 'alpha', 0); 
L2 = Link('d', 0, 'a', 1, 'alpha', 0);
%L2a = Link('d', 0, 'a', .1, 'alpha', -pi/2);

%L1.offset = 1;

L1.name = 'M1';
L2.name = 'M2';

% For a given joint angle, say q=0.2 rad, we can determine the link transform
% matrix
L1.A(0.2);


% Now we need to join these into a serial-link robot manipulator

bot = SerialLink([L2 L1 L0], 'name', 'finger');

bot.base = [1 0 0 0;
            0 0 1 0;
            0 1 0 0;
            0 0 0 1];


q = [0 -pi/4 -pi/4];
ii = bot.fkine(q);



% put checks in to see if desired
% location is too far away

% initial guess for IK
q0 = -rand(bot.n,1)*pi;

trials = 15;
for j=1:trials

    qh = bot.ikine(ii,q0,mask);
    
    if isnan(qh)*ones(bot.n,1) == 0
        % no values of qh are NaN
        if -pi/2 <= qh(1) && qh(1) <= pi/4 
            if -3*pi/4 <= qh(2) && qh(2) <= 0 
                if -pi/2 <= qh(3) && qh(3) <= 0
                    % all values are within limits
                    break;
                end
            end
        end
    end
    
    q0 = -rand(bot.n,1)*pi;
    

end



    

clf;
bot.plot(qh);
qh




