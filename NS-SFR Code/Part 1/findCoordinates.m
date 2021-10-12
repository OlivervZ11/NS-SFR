function [c, r]=findCoordinates(BW)
%FINDCOORDINATES Finds the coordinates from a binary image, extracting the 
%non-zeros values from the matrix and records the [X, Y] values in a matrix
%
%Input:
%   BW: Binary image such as from a edge detection (Canny, Sobel, LoG, DoG
%   etc.)
%
%Output:
%   c: Column index - A double matrix that list the Y coordinates of
%   non-zero values. 
%   r: Row index - A double matrix that list the X coordinates of
%   non-zero values. 

[Y,X] = find(BW(:,:) ~= 0);
[m,~]=size(X);
c=zeros(1,m);
r=zeros(1,m);
for M=1:m
    c(1,M)=X(M,1);
    r(1,M)=Y(M,1);
end