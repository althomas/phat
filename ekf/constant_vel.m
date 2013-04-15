function h = constant_vel(p_0)
  h.vel = @vel;
  h.pos = @pos;
  h.integrate = @integrate;
  h.p_0 = p_0;


  function [v]=vel(t)
    % continuous velocity function
    v = -5*[
          0 0 0; % hand
          .005 .005 0; % thumb
          -.01 0 0; % index
          -.01 0 0; % middle
          -.01 0 0; % ring
          -.01 0 0; % pinky
          ];
  end


  function [p]=pos(t)
    % continuous position function

    p = p_0 + integrate(t);
  end

  function [z]=integrate(t)
    % numerical integration - left-aligned
    blocks = 300; % blocks per second (unit value of t)
    z = 0;

    for i=1:ceil(blocks*t) 

      z = z + vel(i/blocks)/blocks; 

    end
  end
end
