function [ImageInfo]=ImInfo(imfiles, A, Im)

% IMINFO Function to extract metadata, caulate basic stats and store in a
% struct array. 
%
%Inout
%   imfiles:    Directory to images within ImageDatabase
%   A:          Image Number
%   Im:         Original image
%
%Output:
%   ImageInfo:  The struct array containing useful data on the image

    
FileName=fullfile(imfiles(A).name);
PathName=fullfile(imfiles(A).folder);
    
%Convert image to greyscale if not alreafy greyscale
dim=size((size(Im)), 2);
if dim==3
    Im=rgb2gray(Im);
end
%Extract Image Mettadata
MD=imfinfo(fullfile(imfiles(A).folder, imfiles(A).name));
MD2=MD.DigitalCamera;
    
if isfield(MD2, 'UnknownTags')
    MD3=MD2.UnknownTags;
    MD3=struct2cell(MD3);
    Lens=MD3{3,3};
else
    Lens=[];
end
%Calculate the Stats

h=imhist(Im);
mn=mean2(Im);
st=std2(Im);
va=(st)^2;
mode=(find(h==(max(h))))-1;
med=median(double(Im(:)));
maximum=max(Im(:));
minimum=min(Im(:));
    
%Place results in Structure Array
ImageInfo = struct('Name', FileName, 'FilePath', PathName, 'CameraModel', MD.Model, 'LensModel', Lens, 'FileSize', MD.FileSize, 'ImageFormat', MD.Format, 'ColourSpace', MD2.ColorSpace, 'ColourType', MD.ColorType, 'Hight', MD.Height, 'Width', MD.Width, 'BitDepth', MD.BitDepth, 'ApertureFNumber', MD2.FNumber, 'ISOSpeedRating', MD2.ISOSpeedRatings, 'ShutterSpeed', MD2.ExposureTime, 'FocalLength', MD2.FocalLength, 'MeanValue', mn, 'StandardDeviation', st,'Variation', va,'Mode', mode,'Median', med,'MaximumValue', maximum,'MinimumValue', minimum);
% ImageInfo = struct('ColourSpace', MD2.ColorSpace, 'ColourType', MD.ColorType);



