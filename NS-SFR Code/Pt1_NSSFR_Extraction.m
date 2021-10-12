% Natural Scenes derived Spatial Frequency Response (NS-SFR) Extraction
% 
% Copyright (c) 2021 O. van Zwanenberg
% UNIVERSITY OF W1ESTMINSTER PhD Reserch
%              - COMPUTATIONAL VISION AND IMAGING TECHNOLOGY RESEARCH GROUP
% Director of Studies:  S. Triantaphillidou
% Supervisory Team:     R. Jenkin & A. Psarrou

clc; close all; clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% ----- READ FILES ----- %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RAW(.dng) or TIFF(.tif)? 
answer = questdlg('Image Dataset File Format', ...
	'Data', ...
	'RAW(.dng)','TIFF(.tif)', 'RAW(.dng)');
switch answer
    case 'RAW(.dng)' 
        raw = 1;
    case 'TIFF(.tif)'
        raw = 0;
end

% Read image file names from user Folder
selpath = uigetdir([], 'Select folder conatining image dataset');
if raw == 1
    imfiles=dir(fullfile([selpath '\*.dng']));
else
    imfiles=dir(fullfile([selpath '\*.tif']));
end

% imnumber stores the number of files that have been read
imnumber=size(imfiles,1);
if imnumber==0
   disp('No Images found in selected folder');
   beep
   return
end
disp(['Number of Detected images = ' num2str(imnumber)]);

% Select folder to save NS-SFR data
resultdir = uigetdir(selpath, 'Select folder to save NS-SFR data');

% If NS-SFR Data already exisits in dir, code will continue to add to the
% file
mat = dir([resultdir '/*.mat']); 
matemp=isempty(mat);
if matemp==0
    load([resultdir '/ImageNamesIndex.mat']); 
    ContinueA=length(namesIndex);
else 
    ContinueA=0;
end

% Large loop of functions to extract edges and MTFs from each image in imfiles structure
parfor A=1:imnumber
    
    % Display Progress  
    Waitbartex=['Processing Image...' num2str(A) '/' num2str(imnumber)];
    disp(Waitbartex);
    
    % Read Image A
    if raw == 1
        % Read RAW file - imreadDNG is based on a Nikon D800 .NEF RAW file
        [Ir, Ig1, Ig2, Ib, ~]=imreadDNG(fullfile(imfiles(A).folder,...
            imfiles(A).name), 0);
        % Number of colour chanels to process
        CC = 4; % RGGB
    else
        Im=imread(fullfile(imfiles(A).folder, imfiles(A).name));
        Im=Im(:,:,1:3);    
        % Convert to greyscale 
        im=rgb2gray(Im);
        CC = 1; % Greyscale
    end
    %set up array to save NS-SFRs
    MTF_Results=zeros(CC, 6);
    MTF_Results=num2cell(MTF_Results);
    
    % Loop colour channels (for RAW)
    for B =1:CC 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%% ----- PREP IMAGE ----- %%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % RAW data colour channel switch
        if raw == 1
            switch B
                case 1 % Red Channel
                    Im = Ir;
                    Im_lin=Ir;
                    im = Ir;
                case 2 % Green 1 Channel 
                    Im = Ig1;
                    Im_lin=Ig1;
                    im = Ig1;
                case 3 % Green 2 Channel 
                    Im = Ig2;
                    Im_lin=Ig2;
                    im = Ig2;
                case 4 % Blue Channel 
                    Im = Ib;
                    Im_lin=Ib;
                    im = Ib;
            end
        end
        %Determine the orientation of the image (if portrait, flip 90deg)
        [x ,y, ~]=size(Im);
        if y<x
           im=rot90(im); 
           Im=rot90(Im); 
        end
        
        % TIFF files require linerisation
        if raw ==0
            % Extract Image Metadata and Stats
            ImageInfo=ImInfo(imfiles, A, Im);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%% ----- LINEARIZE IMAGE ----- %%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Determine the Colour Space

            ColourSpace=ImageInfo.ColourSpace;
            % Linearize the ime acording to the Colour Space
            if isequal(ColourSpace ,'sRGB')
                Im_lin=rgb2lin(Im,'ColorSpace', 'sRGB');
            elseif isequal(ColourSpace ,'RGB')
                Im_lin=rgb2lin(Im,'ColorSpace', 'adobe-rgb-1998');
            else
                Im_lin=rgb2lin(Im,'ColorSpace', 'sRGB');
            end
        else
             ImageInfo=[];
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%% ----- EDGE DETECTION ----- %%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Apply Horizontal and Vertical Canny:
        if raw == 1
            I = Im_lin;
        else
            I = rgb2gray(Im_lin); 
        end
        [~, Thresh] = edge(I,'canny');
        BWh = cannyH(Im_lin,Thresh(1,1), Thresh(1,2));
        BWv = cannyV(Im_lin,Thresh(1,1), Thresh(1,2));

        % Convert the binary arrays to list of cordinates [x,y]
        BWcoh=BW2Co(BWh);
        BWcov=BW2Co(BWv);

        % Proximity Filter, removes detected edges that are too close
        % i.e., remove textures - Set at 5 pixels Proximity
        [BWHprox, ~]=Proximity(Im_lin ,BWcoh, 'Horizontal', 1, 5);
        [BWVprox, ~]=Proximity(Im_lin ,BWcov, 'Vertical', 1, 5);

        % Remove all edges smaller then 20 pixels in length:
        % (Rotate horizontal image)
        BWH = EdgeReduction(BWHprox, 20);
        BWH = rot90(BWH);
        BWV = EdgeReduction(BWVprox, 20);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%% ----- ISOLATE ROIS & MEASURE PROPERTIES ----- %%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Isolate, extract and store the ROIs and measure the edge parameters
        Im_lin2=rot90(Im_lin);
        [ROIsH]=ROIisolate(Im_lin2, BWH, 1, 3, 0.02);
        [ROIsV]=ROIisolate(Im_lin,  BWV, 1, 3, 0.02);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%% ----- SEGMENT/CROP ROIS ----- %%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % Remove areas of ROI with a change in the edge direction

        [ROIsH2]=EdgeShapeSplit(Im_lin2, ROIsH, 20, 30);
        [ROIsV2]=EdgeShapeSplit(Im_lin,  ROIsV, 20, 30);

        % Remove areas of the ROI with unwated non-uniform areas
        [ROIsH3]=GradYaxis(Im_lin2, ROIsH2, 0.02, 30);
        [ROIsV3]=GradYaxis(Im_lin,  ROIsV2, 0.02, 30);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%% ----- CALCULATE MTFs &  PERCENTILE ----- %%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        MTFerrors=0;
        [ROIsH3, PercentileH, MTFerrors]=nssfr(ROIsH3, MTFerrors);
        [ROIsV3, PercentileV, MTFerrors]=nssfr(ROIsV3, MTFerrors);
        
        % 5th & 95th Percentile of NS-SFR envelopes
        Percentile=zeros(1,2);
        Percentile=num2cell(Percentile);
        Percentile{1,1}=PercentileH;
        Percentile{1,2}=PercentileV;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%% ----- STORE DATA ----- %%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        Text = num2str(imfiles(A).name);
        MTF_Results{B,1} = Text;
        MTF_Results{B,2} = Im;
        MTF_Results{B,3} = ImageInfo;
        MTF_Results{B,4} = ROIsH3;
        MTF_Results{B,5} = ROIsV3;
        MTF_Results{B,6} = Percentile;
        
        errorsfrmat = [num2str(A), '. Number of sfrmat4 errors: ',num2str(MTFerrors)];
        disp(errorsfrmat)
    end
    % Save mtf_Results cell array as .mat file in 'Results' Folder
    AA=num2str(A+ContinueA);
    filename = [resultdir '/Image-' AA '.mat'];
    parsave(filename, MTF_Results)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%List of image names
ex = exist('namesIndex', 'var');
if ex==0
    namesIndex=zeros(imnumber, 1);
    namesIndex=num2cell(namesIndex);
end
for A=(1+ContinueA):(imnumber+ContinueA)
    AA=num2str(A);
    namesIndex{A,1}=['Image-' AA '.mat'];
end 
save([resultdir '/ImageNamesIndex.mat'], 'namesIndex')
disp('Compleated NS-SFR Extraction');
clearvars
beep