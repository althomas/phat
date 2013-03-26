classdef quaternion
    %quaternion object: Q = w + x*i + y*j + z*k
    properties
        w;
        x;
        y;
        z;
    end
    
    methods
        
        function obj = quaternion(w,x,y,z) %quaternion constructor method
            obj.w = w;
            obj.x = x;
            obj.y = y;
            obj.z = z;
        end
        
        function mag = mag(q) %returns the magnitude of q
            mag2 = q.w^2 + q.x^2 + q.y^2 + q.z^2;
            mag = sqrt(mag2);
            
        end
        
        function Qcon = conj(q) % returns the conjugate of q
            Qcon = quaternion(q.w,-1*q.x,-1*q.y,-1*q.z);
            
        end
        
        function qnorm = qnorm(q) %returns the normalized q
            m = q.mag;
            qnorm = quaternion(q.w/m,q.x/m,q.y/m,q.z/m);
        end
        
        function qprod = qmult(q1,q2) %%quaternion multiply, q1 * q2 (NOT NORMALIZED)
            x = q1.w*q2.x + q1.x*q2.w + q1.y*q2.z - q1.z*q2.y;
            y = q1.w*q2.y + q1.y*q2.w + q1.z*q2.x - q1.x*q2.z;
            z = q1.w*q2.z + q1.z*q2.w + q1.x*q2.y - q1.y*q2.x;
            w = q1.w*q2.w - q1.x*q2.x - q1.y*q2.y - q1.z*q2.z;
            qprod = quaternion(w,x,y,z);
            
        end
        
        function rotVect = rotbyq(v,q) %% rotated vector = q * vector * qconjugate
            magv = sqrt(v(1)^2 + v(2)^2 + v(3)^2);
            v = v ./ magv;%normalize v
            
            vecQ = quaternion(0,v(1),v(2),v(3)); %turn v into a quaternion with w = 0
            
            qconj = q.conj(); %get q conjugate
            
            vqc = qmult(vecQ,qconj); v*qconj
            rotVect = qmult(q,vqc); q * (v*qconj)
            
        end
        
%         function rotq = a2q(thx,thy,thz)
%             
%         end
        
    end
end
  