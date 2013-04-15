% By Yi Cao at Cranfield University, 02/01/2008
% Modified by Ashleigh Thomas thomasas@seas.upenn.edu
% University of Pennsylvania 2013

function f = ekf()
  % EKF   Extended Kalman Filter for nonlinear dynamic systems
  % [x, P] = ekf(f,x,P,h,z,Q,R) returns state estimate, x and state covariance, P 
  % for nonlinear dynamic system:
  %           x_k+1 = f(x_k) + w_k
  %           z_k   = h(x_k) + v_k
  % where w ~ N(0,Q) meaning w is gaussian noise with covariance Q
  %       v ~ N(0,R) meaning v is gaussian noise with covariance R
  % Inputs:   f: function handle for f(x)
  %           x: "a priori" state estimate
  %           u: inputs (inertial measurements)
  %           P: "a priori" estimated state covariance
  %           h: function handle for h(x)
  %           z: current measurement of position (from vision)
  %           Q: process noise covariance 
  %           R: measurement noise covariance
  % Output:   x: "a posteriori" state estimate
  %           P: "a posteriori" state covariance
  f.predict = @predict;
  f.update = @update;


  %function [x_apost,P_apost]=ekf(fstate,x,u,t,P,hmeas,z,Q,R)
  function [x_apri,P_apri] = predict(fstate,x,u,t,P,Q)

    
    full_u = zeros(6,3);
    full_u( u(1),: ) = u(2:end);
    
    % PREDICT
    [x_apri,F]=jaccsd(fstate,x,full_u(1:end),t);  % nonlinear update and linearization at current state

                                  % gives f(x,u) and f'(x,u)
    P_apri=F*P*F'+Q;                 %partial update (a priori estimate covariance): P_{k|k-1}

  
  end
    
  function [x_apost,P_apost]= update(x,P,hmeas,z,R)
    % UPDATE
    [z_pred,H]=jaccsd(hmeas,x,0,0);    %nonlinear measurement and linearization
                                           % predicted measurement=hmeas(x_apriori), H

    PHtrans = P*H';
    S = H*PHtrans + R;           % residual covariance


    % Calculate residual using only partial data from vision
    
    % only getting 4/7 pieces of data
    % per reading
    % for flag = 0, we get 
    %     hand, arm, index, ring
    % for flag = 1, we get
    %     hand, thumb, middle, pinky
    % we will organize the data as follows:
    %   arm, hand, thumb, index, middle, ring, pinky
    

    

    if (z(1) == 0) 
      % if there is no data from cameras
      if z(2:4) == [0 0 0]
        z(2:4) = z_pred(1:3);
      end
      if z(5:7) == [0 0 0]
        z(5:7) = z_pred(7:9);
      end
      if z(8:10) == [0 0 0]
        z(8:10) = z_pred(13:15);
      end
      
      z_measured = [ z(2:4)  z_pred(4:6)   z(5:7)  z_pred(10:12)   z(8:10)  z_pred(16:18)  ]; 
        
    else 
      % if there is no data from cameras
      if z(2:4) == [0 0 0]
        z(2:4) = z_pred(4:6);
      end
      if z(5:7) == [0 0 0]
        z(5:7) = z_pred(10:12);
      end
      if z(8:10) == [0 0 0]
        z(8:10) = z_pred(16:18);
      end 

      z_measured = [ z_pred(1:3)  z(2:4)   z_pred(7:9)  z(5:7)   z_pred(13:15)  z(8:10)  ];
    end
  
    y = z_measured(1:end) - z_pred;   
    




    K = PHtrans*inv(S);         % near optimal Kalman gain
    x_apost = x + (K*y')';     % a posteriori state estimate
    n = length(x);
    P_apost = (eye(n) - K*H)*P; % a posteriori estimate covariance

  end

  % #############################################################
  function [z,A]=jaccsd(fun,x,u,t)
    % JACCSD Jacobian through complex step differentiation
    % [z J] = jaccsd(f,x)
    % z = f(x)
    % J = f'(x)
    %
  
    z=fun(x,u,t);
    n=numel(x); % number of elements in array
    m=numel(z);
    A=zeros(m,n);
    h=n*eps;
    for k=1:n
        x1=x;
        x1(k)=x1(k)+h*i;
        A(:,k)=imag(fun(x1,u,t))/h;
    end

  end
end
