function [normdist]=RadialDist(BB, Im)
% Radial Distance is a function that caculates the radial ditance the ROI is
% from the centure of the frame.
%
% Input: 
%   BB       =     The Region of Interest Bounding Boxs coordinates,  
%                  determined from edge detection [xleft, yTop, width, hight]
%   Im       =     Orininal image size [X,Y]
%
% Output:
%   normdist =     Normilaised distance from the frame centure
%
% O.van Zwanenberg (2019), Univeristy of Westminster PhD Reserch

%Determine the centure coodinates
CenCo(1,1)=Im(1,1)/2;
CenCo(1,2)=Im(1,2)/2;
CenCo=round(CenCo);

%Measure the disance from centure to corner, i.e. max distance 
CO = [CenCo(1,1),CenCo(1,2);Im(1,1),Im(1,2)];
MAXdist = pdist(CO,'euclidean');

%Determine the centure coordinates of the ROI (BB)
Cox=round(BB(1,1)+(BB(1,3)/2));
Coy=round(BB(1,2)+(BB(1,4)/2));
CO = [CenCo(1,2),CenCo(1,1);Coy,Cox];

%Caulated distance from centure (and normalise)
dist = pdist(CO,'euclidean');
normdist=dist/MAXdist;