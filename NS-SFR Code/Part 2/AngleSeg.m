function [SagTan]=AngleSeg(SegsVAL, Angle, O)
% AngleSeg splits the ROI anlge into either aceptible for Sagittal or 
% Tangential MTF Plot
%
% INPUT:
%   SegsVAL     =  The poition in the frame the ROI resides, segments 1-16
%   Angle       =  The edge angle
%   Orientation =  The orientation of the edge, H=4 and V=5
% Output:
%   SagTan  =  Is it Sagittal(=1) or Tangential(=2), or neather(=0)?
%               
% O. van Zwanenberg (Feb. 2020)
% UNIVERSITY OF WESTMINSTER 
%              - COMPUTATIONAL VISION AND IMAGING TECHNOLOGY RESEARCH GROUP

SagTan=0;
O=O;
switch SegsVAL
 case 1
     if Angle>=67.5 && Angle<=90 %&& O==5 % Must be a Vertical Edge
         SagTan=1; %Sagittal
     elseif Angle>=-22.5 && Angle<=0 %&& O==5 % Must be a Vertical Edge
         SagTan=2; %Tangentail 
     end
 case 2
     if Angle>=45 && Angle<=67.5 %&& O==5 % Must be a Vertical Edge
         SagTan=1; %Sagittal
     elseif Angle>=-45 && Angle<=-22.5 %&& O==5 % Must be a Vertical Edge
         SagTan=2; %Tangentail 
     end
 case 3
     if Angle>=22.5 && Angle<=45 %&& O==4 % Must be a Horizontal Edge
         SagTan=1; %Sagittal
     elseif Angle>=-67.5 && Angle<=-45 %&& O==4 % Must be a Horizontal Edge
         SagTan=2; %Tangentail 
     end
 case 4
     if Angle>=0 && Angle<=22.5 %&& O==4 % Must be a Horizontal Edge
         SagTan=1; %Sagittal
     elseif Angle>=-90 && Angle<=-67.5 %&& O==4 % Must be a Horizontal Edge
         SagTan=2; %Tangentail 
     end
 case 5
     if Angle>=-22.5 && Angle<=0 %&& O==4 % Must be a Horizontal Edge
         SagTan=1; %Sagittal
     elseif Angle>=67.5 && Angle<=90 %&& O==4 % Must be a Horizontal Edge
         SagTan=2; %Tangentail 
     end
 case 6
     if Angle>=-45 && Angle<=-22.5 %&& O==4 % Must be a Horizontal Edge
         SagTan=1; %Sagittal
     elseif Angle>=45 && Angle<=67.5 %&& O==4 % Must be a Horizontal Edge
         SagTan=2; %Tangentail 
     end
 case 7
     if Angle>=-67.5 && Angle<=-45 %&& O==5 % Must be a Vertical Edge
         SagTan=1; %Sagittal
     elseif Angle>=22.5 && Angle<=45 %&& O==5 % Must be a Vertical Edge
         SagTan=2; %Tangentail 
     end
 case 8
     if Angle>=-90 && Angle<=-67.5 %&& O==5 % Must be a Vertical Edge
         SagTan=1; %Sagittal
     elseif Angle>=0 && Angle<=22.5 %&& O==5 % Must be a Vertical Edge
         SagTan=2; %Tangentail 
     end
case 9
     if Angle>=67.5 && Angle<=90 %&& O==5 % Must be a Vertical Edge 
         SagTan=1; %Sagittal
     elseif Angle>=-22.5 && Angle<=0 %&& O==5 % Must be a Vertical Edge
         SagTan=2; %Tangentail 
     end
 case 10
     if Angle>=45 && Angle<=67.5 %&& O==5 % Must be a Vertical Edge
         SagTan=1; %Sagittal
     elseif Angle>=-45 && Angle<=-22.5 %&& O==5 % Must be a Vertical Edge
         SagTan=2; %Tangentail 
     end
 case 11
     if Angle>=22.5 && Angle<=45 %&& O==4 % Must be a Horizontal Edge
         SagTan=1; %Sagittal
     elseif Angle>=-67.5 && Angle<=-45 %&& O==4 % Must be a Horizontal Edge
         SagTan=2; %Tangentail 
     end
 case 12
     if Angle>=0 && Angle<=22.5 %&& O==4 % Must be a Horizontal Edge
         SagTan=1; %Sagittal
     elseif Angle>=-90 && Angle<=-67.5 %&& O==4 % Must be a Horizontal Edge
         SagTan=2; %Tangentail 
     end
 case 13
     if Angle>=-22.5 && Angle<=0 %&& O==4 % Must be a Horizontal Edge
         SagTan=1; %Sagittal
     elseif Angle>=67.5 && Angle<=90 %&& O==4 % Must be a Horizontal Edge
         SagTan=2; %Tangentail 
     end
 case 14
     if Angle>=-45 && Angle<=-22.5 %&& O==4 % Must be a Horizontal Edge
         SagTan=1; %Sagittal
     elseif Angle>=45 && Angle<=67.5 %&& O==4 % Must be a Horizontal Edge
         SagTan=2; %Tangentail 
     end
 case 15
     if Angle>=-67.5 && Angle<=-45 %&& O==5 % Must be a Vertical Edge
         SagTan=1; %Sagittal
     elseif Angle>=22.5 && Angle<=45 %&& O==5 % Must be a Vertical Edge
         SagTan=2; %Tangentail 
     end
 case 16
     if Angle>=-90 && Angle<=-67.5 %&& O==5 % Must be a Vertical Edge
         SagTan=1; %Sagittal
     elseif Angle>=0 && Angle<=22.5 %&& O==5 % Must be a Vertical Edge
         SagTan=2; %Tangentail 
     end
end

end