function rotq = a2q(thx,thy,thz) %function to generate quaternion based on angle rotated around each axis
             %roll angle: thx, pitch angle: thy, yaw angle: thz
             %thx = r; thy = p; thz = y;
             thx = thx /2;
             thy = thy /2;
             thz = thz /2;
             
             qx = sin(thx) * cos(thy) * cos(thz) - cos(thx) * sin(thy) * sin(thz);
             qy = cos(thx) * sin(thy) * cos(thz) + sin(thx) * cos(thy) * sin(thz);
             qz = cos(thx) * cos(thy) * sin(thz) - sin(thx) * sin(thy) * cos(thz);
             qw = cos(thx) * cos(thy) * cos(thz) + sin(thx) * sin(thy) * sin(thz);
             
             %if number is too small, just call it 0
             if abs(qw) < 1e-14
                 qw = 0;
             end
             
             if abs(qx) < 1e-14
                 qx = 0;
             end
             
             if abs(qy) < 1e-14
                 qy = 0;
             end
             
             if abs(qz) < 1e-14
                 qz = 0;
             end
             
             %make the quaternion
             
             rotq = quaternion(qw,qx,qy,qz);
             rotq.qnorm();
end