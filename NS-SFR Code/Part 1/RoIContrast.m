function [RoIConValue, Clipping, pvSTD]=RoIContrast(PixelVals)
% ROICONTRAST Measures the Michelson contrast of a RoI crop. 
%
% Input:
%    PixelVals:      A list of pixel values (type double). Two columns,
%                    column one is left side of the edge and colomn two is 
%                    the right side of the edge. 
%
% Output:
%    RoIContrast:    The normalised Michelson contrast of tyhe ROI
%    Clipping:       1=There is clipping in RoI (Either highlights reach 
%                    255, or shadows reach 0), 0=There is not clipping in RoI
%    pvSTD:          The standered Deviation of the pixel vales

% Mean Tone Values:
Tone1=nanmean(PixelVals(:,1,:));
Tone2=nanmean(PixelVals(:,2,:));

% Convert to Greyscale Tone from RGB
[~,~,rgb1]=size(Tone1);
[~,~,rgb2]=size(Tone2);

if rgb1==3
    Tone1=rgb2gray(Tone1);
end

if rgb2==3
    Tone2=rgb2gray(Tone2);
end
%Michelson contrast:

if Tone1<Tone2
    RoIConValue=((Tone2-Tone1)/(Tone2+Tone1));
    % Determin if the pixel values have clipping
    t1=find(PixelVals(:,1)==0);
    t2=find(PixelVals(:,1)==1);
    % Determin the standered deviation of the pixel values
    pvSTD(1,2)=nanstd(PixelVals(:,1));
    pvSTD(1,1)=nanstd(PixelVals(:,2));
elseif Tone1>Tone2
    RoIConValue=((Tone1-Tone2)/(Tone1+Tone2));
    % Determin if the pixel values have clipping
    t1=find(PixelVals(:,1)==1);
    t2=find(PixelVals(:,1)==0);
    % Determin the standered deviation of the pixel values
    pvSTD(1,1)=nanstd(PixelVals(:,1));
    pvSTD(1,2)=nanstd(PixelVals(:,2));
else
    RoIConValue=nan;
    t1=1;
    t2=1;
    % Determin the standered deviation of the pixel values
    pvSTD(1,1)=nan;
    pvSTD(1,2)=nan;
end

t1=isempty(t1);
t2=isempty(t2);

% Determine Clipping
if t1==1 || t2==1 
    Clipping=0;
else
    Clipping=1;
end