function h = plotColormap(m)
%function h = plotColormap(m)
%Colormap to create multiple color labels
%
%input:
%   -m: number of different colors needed
%
%output:
%   -h: color matrix, mx3
%
%Copyright(c) Thomas Feix, thomas@xief.net
%Grade your Hand Toolbox downloaded available at grasp.xief.net
%
%The Toolbox is distributed under GPL3 licence. 
%Revision 2.1, 2012-12-18

r = [1 1 0 0 1 0];

g = [0 1 1 1 0 0];

b = [0 0 0 1 1 1];

x = linspace(0,1,length(r));
x1 = linspace(0,1,m);
h = [interp1(x,r,x1); interp1(x,g,x1); interp1(x,b,x1)]';