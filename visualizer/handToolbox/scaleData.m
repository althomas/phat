function Data = scaleData(Data, handlength)
%function Data = scaleData(Data, handlength)
%
%Divides the data by the handlength and moves the origin to the correct
%position. 
%If handlength = -1 then only the inverse origin offset is
%applied. That is used for the visualizations to move the hand data to the
%origin of the hand model. 
%
%   input:
%       - Data: Matrix containing the movements of an artifical hand of
%           size N x 60
%       - handlength: Handlengh of the artificial hand.
%
%   output:
%       - Data: Positions translated to the human MCP joint and divided by
%           the handlength. Size N x 60. 
%
%
%Copyright(c) Thomas Feix, thomas@xief.net
%Grade your Hand Toolbox downloaded available at grasp.xief.net
%
%The Toolbox is distributed under GPL3 licence. 
%Revision 2.1, 2012-12-18


offset = [-0.117902759163447   2.754445041773011   2.445418854958001]; %offset to the human mean mcp joint


if size(Data,2) == 60
    incr = 60/5;
else
    error('Do not recognize data dimension')
end

offsetmat = repmat(offset,size(Data,1),1);

if handlength > 0
    for f = 0:4
        Data(:,(1:3)+f*incr) = Data(:,(1:3)+f*incr) + offsetmat;
        Data(:,(1:3)+f*incr) = Data(:,(1:3)+f*incr)/handlength; %division by handlength
    end
elseif handlength == -1
    for f = 0:4
        Data(:,(1:3)+f*incr) = Data(:,(1:3)+f*incr) - offsetmat;
    end
    
else
    error('Wrong handlenght')
end













