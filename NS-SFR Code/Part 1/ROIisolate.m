function [ROIs]=ROIisolate(Im, BW, PSt, Var1, Var2)
% ROI CROP is frunction to isolate the crops from a canny detector using
% Binary Boxing, applies a edge mask and then stretches the pixel values 
% either side of th mask to fill the ROI. 
%
% Input:
%       BW:     The Canny Detector Binary image output (Horizontal OR
%               Vertical only)
%       Im:     Orginal image
%       PSt:    Perform the Pixel Stretch ROI isolation method, 1 = yes,
%               0 = no (defult is 1)
%       Var1:   Adjusible varible 1 is the Mask Dilution amount (defult is
%               1 pixel)
%       Var2:   Adjusible varible 2 is the isStepEdege threshold, this 
%               value should be 0-1 (defult is 0.02 normialised pixel 
%               value, aproximaly equal to +/-5 pixel value for 8 bit
%               image)
% Outout:
%       ROIs:   A cell array containing the 'pixel value stretched' ROIs.
%
% Copyright (c) 2019 O. van Zwanenberg
% UNIVERSITY OF WESTMINSTER 
%              - COMPUTATIONAL VISION AND IMAGING TECHNOLOGY RESEARCH GROUP
% Director of Studies:  S. Triantaphillidou
% Supervisory Team:     R. Jenkin & A. Psarrou

switch nargin
    case 2
        PSt=1; 
        Var1=3; 
        Var2=0.02; 
    case 3
        Var1=3; 
        Var2=0.02; 
    case 4
        Var2=0.02; 
    case 5
        
    otherwise
        disp('Incorrect number or arguments');
        return 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% ----- FIND ROIs ----- %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Boundry Box (ROIs):
BB = regionprops(BW,'BoundingBox');
%     figure, imshow(Im)
%     hold on
%     for k = 1 : length(BB)
%         thisBB = BB(k).BoundingBox;
%         rectangle('Position', [thisBB(1),thisBB(2),thisBB(3),thisBB(4)],...
%        'EdgeColor','r','LineWidth',2 )
%     end
%     hold off

% Crop the Bounding Boxs and save the ROIs
[ROI, ROIcanny, ROILoc]=findROI(BB, Im, BW, 128);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% ----- DETERMINE ROI MASKS ----- %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Take the ESF gradients of the ROIs to create the ROI Edge Mask (find the
% edge trasnition location)
SE = strel('square',Var1);
ROIs=zeros(length(ROI),12);
ROIs=num2cell(ROIs);

%non vaule rows array
K=zeros(length(ROI));

for k = 1 : length(ROI)
    
    % Take the 'current' ROI
    roiIm=ROI{k,1};
    empROI=isempty(roiIm);
    roiCanny=ROIcanny{k,1};
    
    % ROI Location
    roiLoc=ROILoc{k,1};
    
    if empROI~=1
        % Take the Gradient of the ROIs (x axis/Rows)
        if size (roiIm, 3)>1
            roiImgrey=rgb2gray(roiIm);
        else
             roiImgrey=(roiIm);
        end

        roiImgrey=im2double(roiImgrey);
        [roiImGrad, ~]=gradient(roiImgrey);
        roiImGrad2=roiImGrad;

        % Thrshold the Gradient Array - anything between -Var2 and Var2 = 0,
        % else = 1
        [m,n] = size(roiImGrad);
        for M=1:m
            for N=1:n
                if roiImGrad(M,N)>Var2 
                    roiImGrad2(M,N)=1;
                elseif roiImGrad(M,N)<-Var2  
                    roiImGrad2(M,N)=-1;
                else
                    roiImGrad2(M,N)=0;
                end
            end
        end
        
        % Move to the next ROI if no mask is detected
        TF = any(roiImGrad2,'all');
        if TF==0
            ROIs {k,1} = [];
            ROIs {k,2} = [];
            ROIs {k,3} = [];
            ROIs {k,4} = [];
            ROIs {k,5} = [];
            ROIs {k,6} = [];
            ROIs {k,7} = [];
            ROIs {k,8} = [];
            ROIs {k,9} = roiLoc;
            ROIs {k,10} = [];
            ROIs {k,11} = [];
            ROIs {k,12} = 5;
            continue
        end

        % Remove any 'non-main' Masks
        [c,r]=findCoordinates(roiCanny);
        cc=find(c~=1);
        
        roimask = bwselect(roiImGrad2,c,r,4);
        
        % Diolate the Mask
        roimask = imdilate(roimask, SE);
        
        %Remove blank non-edge areas:
        [m,n] = size(roimask);
        
        upperY=1;
        lowerY=m;
        upperX=1;
        lowerX=n;

        for M1=1:m
            [~, J]=find(roimask(M1,:)==1);
            empJ=isempty(J);
            if empJ==1
                upperY=M1;
            else
                break
            end
        end
        for M2=M1:m
            [~, J]=find(roimask(M2,:)==1);
            empJ=isempty(J);
            if empJ==1
                lowerY=M2-1;
                break
            end
        end

        for N1=1:n
            [~, I]=find(roimask(:,N1)==1);
            empI=isempty(I);
            if empI==1
                upperX=N1+1;
            else 
                break
            end
        end
        for N2=N1:n
            [~, I]=find(roimask(:,N2)==1);
            empI=isempty(I);
            if empI==1
                lowerX=N2-1;
                break
            end
        end

        %crop roi, mask and Canny
        roiIm=roiIm(upperY:lowerY, :, :);
        roimask=roimask(upperY:lowerY, :);
        roiCanny=roiCanny(upperY:lowerY, :);
        
        roimask2=imcomplement(roimask);
        roimask2=imfill(roimask2 ,'holes');
        ROIobjects=bwconncomp(roimask2);
        numROIobjects=ROIobjects.NumObjects;
  
        %Skip ROIs that are narrower than 5 pixels
        [~,n2,~]=size(roiIm);     
        if n2<5
            %Mark as a row with no value
            K(k)=1;
            continue
        end 

        %Adjust the Y coordinate and hight
        %Y:
        roiLoc(1,2)=roiLoc(1,2)+(upperY-1);
        %hight:
        roiLoc(1,4)=roiLoc(1,4)-((upperY-1)+(m-lowerY));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%% ----- MEASURE EDGE PROPERTIES ----- %%%%%%%%%%%%%%% 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % ROI Size
        roiSize=size(roimask);

        % Radial Distance
        [y,x,~]=size(Im);
        normdist=RadialDist(roiLoc, [x,y]);

        % Save the Mask and edge paprameters in Cell Array
        ROIs {k,1} = roiIm;
        ROIs {k,4} = [];
        ROIs {k,8} = roiSize;
        ROIs {k,9} = roiLoc;
        ROIs {k,10} = normdist;

        % Pass control to the next iteration if there is no ROI
        if roiSize(1,1)==0
            continue
        end

        if PSt==1
            [ROIstretch, PXval, roiIm, roiCanny, roimask] = PVstretch(roiIm, roiCanny, roimask);
            % Pass control to the next iteration if ROIstretch=[] due to failed PVstretch
            emp=isempty(ROIstretch);
            if emp==1
                continue
            end
            ROIs {k,2} = ROIstretch;
        else
            % Edge Contrast and pixel value STD
            % Find the pixel values either side of the edge within the mask 
            % and take two median tones - to avoid taking the edge into 
            % account start 10% of ROI hight and end 90% ROI hight.
            [m,n] = size(roimask);
            m10=round(0.1*m);
            m90=round(0.9*m);
            mdiff=m90-m10;

            PXval=zeros(mdiff,2);

            roiImgrey=rgb2gray(roiIm);

            for M=m10:m90
                [~, J]=find(roimask(M,:)==1);
                Jmin=min(J);
                Jmax=max(J);

                if  Jmin<(n-4)
                    tone1=zeros(1,5);
                    tone1(1,1)=roiImgrey(M,Jmin);
                    tone1(1,2)=roiImgrey(M,Jmin+1);
                    tone1(1,3)=roiImgrey(M,Jmin+2);
                    tone1(1,4)=roiImgrey(M,Jmin+3);
                    tone1(1,5)=roiImgrey(M,Jmin+4);
                    Tone1=median(tone1);
                else 
                    tone1=zeros(1,5);
                    tone1(:)=nan;
                    for t=1:(n-Jmin)
                        tone1(1,t)=roiImgrey(M,Jmin+(t-1));
                    end
                    Tone1=nanmedian(tone1);
                end

                if Jmax>4
                    tone2=zeros(1,5);
                    tone2(1,1)=roiImgrey(M,Jmax);
                    tone2(1,2)=roiImgrey(M,Jmax-1);
                    tone2(1,3)=roiImgrey(M,Jmax-2);
                    tone2(1,4)=roiImgrey(M,Jmax-3);
                    tone2(1,5)=roiImgrey(M,Jmax-4);
                    Tone2=median(tone2);
                else
                    tone2=zeros(1,5);
                    tone2(:)=nan;
                    for t=1:Jmax
                        tone2(1,t)=roiImgrey(M,Jmax-(t-1));
                    end
                    Tone2=nanmedian(tone2);
                end

                PXval(M,1)=Tone1;
                PXval(M,2)=Tone2;
            end
            ROIstretch=[];
            ROIs {k,2} = ROIstretch;
        end 
        [~, ~, pvSTD]=RoIContrast(PXval);

        % Composit both the mask and the canny into a 2x1 cell
        BWs=zeros(2,1);
        BWs=num2cell(BWs);
        BWs{1,1}=roiCanny;
        BWs{2,1}=roimask;
        ROIs {k,3} = BWs;             

        ROIs {k,5} = [];
        ROIs {k,6} = [];
        ROIs {k,7} = pvSTD;
        ROIs {k,11} = [];

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% ----- DETERMINE WHETHER THE EDGE IS A STEP-EDGE ----- %%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Determine whether the edge has a Step-Edge profile
        StepEdge=isStepEdege(roiIm, Var2, 0.5); % 50% of the ROI

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%% ----- STORE DATA ----- %%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if StepEdge==1
            ROIs {k,12} = 1;
        else
            ROIs {k,12} = 3;
        end
    else 
            ROIs {k,1} = [];
            ROIs {k,2} = [];
            ROIs {k,3} = [];
            ROIs {k,4} = [];
            ROIs {k,5} = [];
            ROIs {k,6} = [];
            ROIs {k,7} = [];
            ROIs {k,8} = [];
            ROIs {k,9} = roiLoc;
            ROIs {k,10} = [];
            ROIs {k,11} = [];
            ROIs {k,12} = 6;
    end
end
%Remove the blank rows
removes=find(K==1);
ROIs (removes,:)=[];
end