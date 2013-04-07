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
            qprodtemp = quaternion(w,x,y,z);
            qprod = qnorm(qprodtemp);
            
        end
        
        function rotVect = rotbyq(q,v) %% rotated vector = q * vector * qconjugate
            magv = sqrt(v(1)^2 + v(2)^2 + v(3)^2);
            v = v ./ magv;%normalize v
            
            vecQ = quaternion(0,v(1),v(2),v(3)); %turn v into a quaternion with w = 0
            
            qconj = q.conj(); %get q conjugate
            
            vqc = qmult(vecQ,qconj); %v*qconj;
            rotVectq = qmult(q,vqc); %q * (v*qconj);
            
        end
        
%         function rotq = angle2quat(thx,thy,thz) %function to generate quaternion based on angle rotated around each axis
%              %roll angle: thx, pitch angle: thy, yaw angle: thz
%              %thx = r; thy = p; thz = y;
%              
%              qx = sin(thx) * cos(thy) * cos(thz) - cos(thx) * sin(thy) * sin(thz);
%              qy = cos(thx) * sin(thy) * cos(thz) + sin(thx) * cos(thy) * sin(thz);
%              qz = cos(thx) * cos(thy) * sin(thz) - sin(thx) * sin(thy) * cos(thz);
%              qw = cos(thx) * cos(thy) * cos(thz) + sin(thx) * sin(thy) * sin(thz);
%              rotq = quaternion(qw,qx,qy,qz);
%         end
        
    end
end
  
