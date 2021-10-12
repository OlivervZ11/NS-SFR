function [BW]=EdgeReduction(bw, Thresh)
%EdgeReduction removed all edges under the specified length threshold
%
%Input:
%   bw       Edge Detection Binary image (e.g. Canny output)
%   Thresh   Minimum Edge length 
%
%Output:
%   BW       Edge Detection Binary Image with edges over 'thresh' pixels 
%   

%Label the objects within the binary images and extract properties for connected components:
L=bwlabel(bw);
s = regionprops(L,'PixelIdxList');

% Sort based on number of pixels in each connected component:
d = cellfun('length',{s(:).PixelIdxList}); %total number of pixels in each region
[D,order] = sort(d,'descend');

[~, Ds]=size(D);
for DS=1:Ds
    Dn=D(1,DS);
    if Dn<Thresh
        order(1, DS)=nan;
    end
end

% Deselect edges below Thresh pixels
BW = ismember(L,order);