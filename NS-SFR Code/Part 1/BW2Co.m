function [BWco]=BW2Co(BW, xy)
% BW2Co converts a binary image into the a list od [X,Y] coordinates.
%
% Input:
%   BW:         Binary image
%   xy:         Detemines the which axis is in order, i.e. if the for loops
%               run row by row (=1) or column by column (=2). 
%               (The defult = 2, column by column)
%
% Output: 
%   BWco:       List of coodinates [X,Y]
%
% Copyright (c) 2019 O. van Zwanenberg, University of Westminster
%--------------------------------------------------------------------------
switch nargin
    case 1
        xy=2;
    case 2
      if xy~=1 && xy~=2
          disp('xy must either be 1 or 2');
          return 
      end
    otherwise
        disp('Incorrect number or arguments');
        return 
end
%--------------------------------------------------------------------------

[y,x]=size(BW);
k=0;

i=sum(BW(:) == 1);
BWco=zeros(i,2);
% row by row
if xy==1
    for X=1:x
        for Y=1:y
            if BW(Y,X)==1
                k=k+1;
                BWco(k,1)= X;
                BWco(k,2)= Y;
            end
        end 
    end
end
% column by column
if xy==2
    for Y=1:y
        for X=1:x
            if BW(Y,X)==1
                k=k+1;
                BWco(k,1)= X;
                BWco(k,2)= Y;
            end
        end 
    end
end