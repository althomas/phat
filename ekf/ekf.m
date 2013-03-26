function [x_apost,P_apost]=ekf(fstate,x,u,t,P,hmeas,z,Q,R)
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
%
% By Yi Cao at Cranfield University, 02/01/2008
n = length(x);

% PREDICT
[x_apri,F]=jaccsd(fstate,x,u,t);  %nonlinear update and linearization at current state

                              % gives f(x,u) and f'(x,u)
P_apri=F*P*F'+Q;                 %partial update (a priori estimate covariance): P_{k|k-1}

% UPDATE
%[z_pred,H]=jaccsd(hmeas,x_apri,t);    %nonlinear measurement and linearization
                                       % predicted measurement=hmeas(x_apriori), H
z_pred = hmeas(x_apri);
H = eye(3);

%P12=P*H';                   %cross covariance
 % K=P12*inv(H*P12+R);       %Kalman filter gain
 % x=x1+K*(z-z1);            %state estimate
 % P=P-K*P12';               %state covariance matrix
%R=chol(H*P12+R);            %Cholesky factorization = chol(S_k)
%U=P12/R;                    %K=U/R'; Faster because of back substitution
%x=x1+U*(R'\(z-z1));         %Back substitution to get state update !!!!
%P=P-U*U';                   %Covariance update, U*U'=P12/R/R'*P12'=K*P12.

PHtrans = P*H';
S = H*PHtrans + R;           % residual covariance
y = z - z_pred;            % residual
K = PHtrans*inv(S);         % near optimal Kalman gain
x_apost = x_apri + K*y;     % a posteriori state estimate
P_apost = (eye(n) - K*H)*P_apri; % a posteriori estimate covariance

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

