function [AreaTot area boxInds] = handMetricBox(latent,model)
%[AreaTot area] = handMetric(latent,Prob,mins,dx,boxes,XTest,showPlots)
%
%The function calculates the coverage of a given kinematic hand setup. It
%returns the area of the complete latent space and the area of the
%space covered by the hand trajectory.
%
%     input:
%       - latent: The projection of the hand movement to the latent space.
%           Size: N x 2
% 
%     output:
%       - AreaTot: Total area of the latent space. Each box is weighted by
%           it's probability. 
%       - area: Area of the trajectory in latent space. Each box is
%           weighted by it's probability. 
% 
%
%Copyright(c) Thomas Feix, thomas@xief.net
%Grade your Hand Toolbox downloaded available at grasp.xief.net
%
%The Toolbox is distributed under GPL3 licence. 
%Revision 2.1, 2012-12-18
Prob = model.Prob;
cubeVol = prod(Prob.dx);
AreaTot = sum(sum(sum(Prob.Prob)))*cubeVol; %has to be calculated here because Prob is altered later
CumProb = 0;
boxInds = [];
%start Boxcounting
for i = 1:size(latent,1)
   p = floor((latent(i,:)-Prob.mins)./Prob.dx);         %distance from zero to the point in dx steps. 

   if min(p) >= 0 %if one of the entries in p is < 0 then this point is outside the latent area


       if size(latent,2) == 2
           ind = p*[Prob.boxes(2); 1]+1;

           if sum(p>=Prob.boxes) == 0 %check if one of the box coordinates is bigger than the box count
               if Prob.Prob(ind) ~= 0
                    boxInds = [boxInds ind];
                    CumProb = CumProb + Prob.Prob(ind);
                    Prob.Prob(ind) = 0;
               end
           end
       else
           error('Wrong latent dimension. The system needs a two dimensional latent space.')
          
       end
%            if sum(p>=boxes) == 0
%                
%                CumProb = CumProb + Prob(ind);
%                Prob(ind) = 0;   %Set this box to 0, so that it will not be recounted.       
%            end
   end
end
area = CumProb*cubeVol;


