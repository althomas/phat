%% normalize magnetometer data

function [magnx magny magnz] = normMag(magx, magy, magz)
    
    for i = 1:length(magx)
        norm2 = magx(i)^2 + magy(i)^2 + magz(i)^2;
        norm = sqrt(norm2);
        magnx(i) = magx(i)/norm; magny(i) = magy(i)/norm; magnz(i) = magz(i)/norm;
    end
end