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

function finger(x)


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
  t = [1 1 1 ]; % thumb
  i = [1 1 1 ]; % index
  m = [1 1 1 ]; % middle
  r = [1 1 1 ]; % ring
  p = [1 1 1 ]; % pinky
  w = 2; % length from center of hand to center of wrist
  a = [-3*pi/4 -pi/6 0 pi/6 pi/3]; % angles between wrist-hand and hand-3rd: timrp
  l = [1 1.1 1 1.1 1.3];

  outfile = 'jointcoords.txt';
  % clear text file
  data = [];
  dlmwrite(outfile, data, 'delimiter', ',');


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
  %mask = [1 0 1 0 1 0];


  t0 = Link('d', 0, 'a', t(1), 'alpha', 0);
  t1 = Link('d', 0, 'a', t(2), 'alpha', 0); 
  t2 = Link('d', 0, 'a', t(3), 'alpha', 0);
  %L2a = Link('d', 0, 'a', .1, 'alpha', -pi/2);

  i0 = Link('d', 0, 'a', i(1), 'alpha', 0);
  i1 = Link('d', 0, 'a', i(2), 'alpha', 0); 
  i2 = Link('d', 0, 'a', i(3), 'alpha', 0);

  m0 = Link('d', 0, 'a', m(1), 'alpha', 0);
  m1 = Link('d', 0, 'a', m(2), 'alpha', 0); 
  m2 = Link('d', 0, 'a', m(3), 'alpha', 0);

  r0 = Link('d', 0, 'a', r(1), 'alpha', 0);
  r1 = Link('d', 0, 'a', r(2), 'alpha', 0); 
  r2 = Link('d', 0, 'a', r(3), 'alpha', 0);

  p0 = Link('d', 0, 'a', p(1), 'alpha', 0);
  p1 = Link('d', 0, 'a', p(2), 'alpha', 0); 
  p2 = Link('d', 0, 'a', p(3), 'alpha', 0);

  bot(1) = SerialLink([t2 t1 t0], 'name', 'thumb');
  bot(2) = SerialLink([i2 i1 i0], 'name', 'index');
  bot(3) = SerialLink([m2 m1 m0], 'name', 'middle');
  bot(4) = SerialLink([r2 r1 r0], 'name', 'ring');
  bot(5) = SerialLink([p2 p1 p0], 'name', 'pinky');


  fingerLength = [sum(t) sum(i) sum(m) sum(r) sum(p)];


  for j=1:5
      bot(j).base = [1 0 0 0; 
                     0 0 1 0; 
                     0 1 0 0; 
                     0 0 0 1];
  end


  for q=1200:1:1210

    beacons = [x(q,5:7); x(q,8:10); x(q,11:13); x(q,14:16); x(q,17:19)];
    
    timestamp = x(q,1);
    handLoc = x(q,2:4);
    wristLoc = [0 -w 0]; 

    % move center of hand is at (0,0,0)
    beacons = beacons - ones(5,1)*handLoc; 

    % now move each third knuckle to (0,0,0) by subtracting off offset from center of hand to knuckle
    for j=1:5    
      beacons(j,:) = beacons(j,:) - [-sin(a(j))*l(j)  cos(a(j))*l(j)  0];
    end
    

    % now need to rotate about z-axis so that y value is 0
    for j=1:5
      if beacons(j,2) < -.002  || beacons(j,2) > .002 %essentionally, y != 0
        phi(j) = acot(-beacons(1)/beacons(2));
        beacons(j,:) = (rotz(phi(j)) * beacons(j,:)')';
      else
        phi(j) = 0;
      end
    end


    theta = NaN*ones(5,3);
    % IK for each finger
    for j=1:5

      % put checks in to see if desired
      % location is too far away
      %if norm(beacon(j,:)) > fingerLength(j)
        

      % set locations for IK
      ii = [1 0 0 beacons(j,1);
            0 0 1 0;
            0 1 0 beacons(j,3);
            0 0 0 1];

      % initial guess for IK
      q0 = -rand(bot(j).n,1)*pi;
      q0 = [0 -pi/4 -pi/4];    

      trials = 15;
      for k=1:trials

        qh = bot(j).ikine(ii,q0,mask);

        if isnan(qh)*ones(bot(j).n,1) == 0
          % no values of qh are NaN
          if -pi/2 <= qh(1) && qh(1) <= pi/4 
            if -3*pi/4 <= qh(2) && qh(2) <= 0 
              if -pi/2 <= qh(3) && qh(3) <= 0
                % all values are within limits
                theta(j,:) = qh;
                break;
              end
            end
          end
        end
        q0 = -rand(bot(j).n,1)*pi;
      end
    end



  % given q, find coordinates for each joint and rotate back
  % then add back the center of hand to 3rd knuckle offset

    for j=1:5
      index = (j-1)*4 + 1;
      loc = bot(j).base;
      pose(index, :) = loc(1:3,4)';

      if isnan(pose(index,:))
        pose(index,:) = [0 0 0];
      else
        pose(index,:) = (rotz(-phi(j)) * pose(index,:)')';
      end     

      pose(index,:) = pose(index,:) +  [-sin(a(1))*l(1)  cos(a(1))*l(1)  0];
    
      for s=1:3    
        loc = loc*bot(j).links(s).A(theta(j,s));
        pose(index+s,:) = loc(1:3,4)';

        if isnan(pose(index+s,:))
          pose(index+s,:) = [0 0 0];
        else
          pose(index+s,:) = (rotz(-phi(j)) * pose(index+s,:)')';
        end     
      
        pose(index+s,:) = pose(index+s,:) +  [-sin(a(1+s))*l(1+s)  cos(a(1+s))*l(1+s)  0];
 
      end
    end


    % remove thumb's 3rd knuckle
    pose(4,:) = [];
    %add wrist locations to end
    pose(20,:) = handLoc;
    pose(21,:) = wristLoc;


    phi
    theta
    pose

    % now write to file
    data = [timestamp*ones(length(pose(:,1)),1)    pose];

    dlmwrite(outfile, data, 'delimiter', ',', '-append');
  end


end

