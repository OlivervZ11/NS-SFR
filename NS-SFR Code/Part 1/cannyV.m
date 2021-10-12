function [BWv]=cannyV(img, T_Low, T_High)

% CANNY VERTICAL is the canny edge detector adapted to give only
% horizontal output.
%
% Input:
%    img:       Image
%    T_Low:     (Optional) Lower threshold, defult = 0.075
%    T_High:    (Optional) Higher threshold, defult = 0.175
%
% Output:
%    BWv:       Vertical Canny Edge Detection Binary Image
%
% Rachmawan (version 1.0.0.0, https://nl.mathworks.com/matlabcentral/
%            fileexchange/46859-canny-edge-detection)
% Adapted by O.van Zwanenberg 2019, University of Westminster

% Convert img to grayscale and double
if size (img, 3)>1
    img = rgb2gray(img);
end
img = double (img);

% Value for Thresholding
if ~exist('T_Low','var')
    T_Low = 0.075;
end
if ~exist('T_High','var')
    T_High = 0.175;
end

% Gaussian Filter Coefficient
B = [2, 4, 5, 4, 2; 4, 9, 12, 9, 4;5, 12, 15, 12, 5;4, 9, 12, 9, 4;2, 4, 5, 4, 2 ];
B = 1/159.* B;

% Convolution of image by Gaussian Coefficient
A=conv2(img, B, 'same');

% Filter for horizontal and vertical direction
KGx = [-1, 0, 1; -2, 0, 2; -1, 0, 1];
KGy = [0, 0, 0; 0, 0, 0; 0, 0, 0];

% Convolution by image by horizontal and vertical filter
Filtered_X = conv2(A, KGx, 'same');
Filtered_Y = conv2(A, KGy, 'same');

% Calculate directions/orientations
arah = atan2 (Filtered_Y, Filtered_X);
arah = arah*180/pi;
pan=size(A,1);
leb=size(A,2);

% Adjustment for negative directions, making all directions positive
for i=1:pan
    for j=1:leb
        if (arah(i,j)<0) 
            arah(i,j)=360+arah(i,j);
        end
    end
end

arah2=zeros(pan, leb);

% Adjusting directions to nearest 0, 45, 90, or 135 degree
for i = 1  : pan
    for j = 1 : leb
        if ((arah(i, j) >= 0 ) && (arah(i, j) < 22.5) || (arah(i, j) >= 157.5) && (arah(i, j) < 202.5) || (arah(i, j) >= 337.5) && (arah(i, j) <= 360))
            arah2(i, j) = 0;
        elseif ((arah(i, j) >= 22.5) && (arah(i, j) < 67.5) || (arah(i, j) >= 202.5) && (arah(i, j) < 247.5))
            arah2(i, j) = 45;
        elseif ((arah(i, j) >= 67.5 && arah(i, j) < 112.5) || (arah(i, j) >= 247.5 && arah(i, j) < 292.5))
            arah2(i, j) = 90;
        elseif ((arah(i, j) >= 112.5 && arah(i, j) < 157.5) || (arah(i, j) >= 292.5 && arah(i, j) < 337.5))
            arah2(i, j) = 135;
        end
    end
end

% Calculate magnitude
magnitude = (Filtered_X.^2) + (Filtered_Y.^2);
magnitude2 = sqrt(magnitude);
bw = zeros (pan, leb);

% Non-Maximum Supression
for i=2:pan-1
    for j=2:leb-1
        if (arah2(i,j)==0)
            bw(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i,j+1), magnitude2(i,j-1)]));
        elseif (arah2(i,j)==45)
            bw(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i+1,j-1), magnitude2(i-1,j+1)]));
        elseif (arah2(i,j)==90)
            bw(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i+1,j), magnitude2(i-1,j)]));
        elseif (arah2(i,j)==135)
            bw(i,j) = (magnitude2(i,j) == max([magnitude2(i,j), magnitude2(i+1,j+1), magnitude2(i-1,j-1)]));
        end
    end
end

bw = bw.*magnitude2;

% Hysteresis Thresholding
T_Low = T_Low * max(max(bw));
T_High = T_High * max(max(bw));
T_res = zeros (pan, leb);

for i = 1  : pan
    for j = 1 : leb
        if (bw(i, j) < T_Low)
            T_res(i, j) = 0;
        elseif (bw(i, j) > T_High)
            T_res(i, j) = 1;
        % Using 8-connected components
        elseif ( bw(i+1,j)>T_High || bw(i-1,j)>T_High || bw(i,j+1)>T_High || bw(i,j-1)>T_High || bw(i-1, j-1)>T_High || bw(i-1, j+1)>T_High || bw(i+1, j+1)>T_High || bw(i+1, j-1)>T_High)
            T_res(i,j) = 1;
        end
    end
end

BWv = logical(T_res);

