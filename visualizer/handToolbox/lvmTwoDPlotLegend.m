function lvmTwoDPlotLegend(X, lbl, symbol,mSize)
%function lvmTwoDPlotLegend(X, lbl, symbol,mSize)
%
%Plots the latent space trajectory. 
%
%Input:
%     -X: The latent space trajectory, size: Nx2
%     -lbl: A matrix containing labels of the points. Different labels will be plotted with differenty symbols
%     -symbol: A cell array containing the plotting symbols
%     -mSize: number that specifies the size of the plotted marker
%
%
%Copyright(c) Thomas Feix, thomas@xief.net
%Grade your Hand Toolbox downloaded available at grasp.xief.net
%
%The Toolbox is distributed under GPL3 licence. 
%Revision 2.1, 2012-12-18


if nargin < 2
  lbl = [];
end

if nargin < 3
  symbol = [];
end

if nargin < 4
    mSize = 13;
end

moreColors = 0;
if size(symbol,2) < size(lbl,2) %check if there are enough symbols for the number of differnet labelss
    disp('Not enough symbols, switching to latent Colormap mode!')
    LineColors = plotColormap(size(lbl,2));
    moreColors = 1;
end

hold on
for i = 1:size(lbl,2)
   inds = find(lbl(:,i) == 1);
   if moreColors
        plot(X(inds,1),X(inds,2),'.-','markerSize',mSize+2,'lineWidth',2,'Color',LineColors(i,:))   
   else
        plot(X(inds,1),X(inds,2),[symbol{i} ''],'markerSize',mSize,'lineWidth',1)   
   end
end


