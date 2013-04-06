    function [latentpos] = data2latent(model,points)
%Project points from data space to latent space
%
%function [latentpos] = data2latent(model,points)
%Projects Points from the data space to the latent space. Now works with
%PCA and fgpvlm models. 
%
%Uses modelOut() for projection in fgplvm case. For PCA PCAdata2latent() is
%used
%
%input:
%   - model: GPLVM Model or PCA model
%   - points: n x d matrix of data points. 
%output:
%   - latentpos: n x q matrix of the latent points.
%
%
%Copyright(c) Thomas Feix, thomas@xief.net
%Grade your Hand Toolbox downloaded available at grasp.xief.net
%
%The Toolbox is distributed under GPL3 licence. 
%Revision 2.1, 2012-12-18


if strcmp(model.b.type, 'fgplvm')
    % compute kernel
    n2 = dist2(points,model.b.X);
    wi2 = .5.*model.b.inverseWidth;
    sk = exp(-n2*wi2);
    k = model.b.variance*sk;
    
    % compute mapping 
    latentpos = k*model.b.A+ones(size(points,1),1)*model.b.bias;
elseif strcmp(model.type, 'PCA')
   latentpos = PCAdata2latent(model.evec, points, model.q); 
else
    error('Unknown model type')
end

latentpos = real(latentpos);