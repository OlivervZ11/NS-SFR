function [ROI2]=GradYaxis(Im, ROI, gradThresh, ROImin)

% GradYaxis peforms gradient anlysis to ensure that the ROIs are as 
% required for the slanted MTF mesure. This function takes each of the 
% isolated ROIs from a natural scene and applies two sets of gradient
% testing:
%  1). Either side of the ROI edge mask
%  2). and Vertical columns at 10% from each side of the ROI
% These are both used to check each of the ROIs to ensire a uniform tone 
% eiter side of the edge. Otherwise the ROIs are croped, segmented or 
% dropped acording to these gradients.
%
% Inupt:
%   Im          =   Original Image
%   ROI         =   The ROI cell array from the ROIisolate function.
%   gradThresh  =   The threshold of tollrence for a excepted uniform tone,
%                   should be within the range of 0-1.
%                   (defult = 0.025 (normialised pixel value), aproximaly 
%                   equal to +/-6 pixel value for 8 bit image).
%   ROImin      =   The minimum hight of a ROI (defult = 30 pixels)
% Output:
%   ROI2        =   The same ROI cell array with adjusted ROIs (croped, 
%                   segmented or dropped). 
%
% Copyright (c) 2019 O. van Zwanenberg
% UNIVERSITY OF WESTMINSTER 
%              - COMPUTATIONAL VISION AND IMAGING TECHNOLOGY RESEARCH GROUP
% Director of Studies:  S. Triantaphillidou
% Supervisory Team:     R. Jenkin & A. Psarrou

%--------------------------------------------------------------------------
switch nargin
    case 2
        gradThresh = 0.025;
        ROImin = 30;
    case 3
        ROImin = 30;
    case 4
        
    otherwise
        disp('Incorrect number or arguments');
        return 
end
%--------------------------------------------------------------------------
a=0;
[aa,~]=size(ROI);

for A=1:aa
    %Only use ROIs that have been shown to be StepEdges
    SE=ROI{A,12};
    
    if SE==1
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%% -- READ IN THE REQUIRED DATA -- %%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % OROI = original ROI (non-streteched)
        OROI=ROI{A,1};
        %CROI = Coloured stretched ROI
        CROI=ROI{A,2};
        % testROI = stretched ROI 
        testROI=ROI{A,2};
        % convert to greyscale
        if size (testROI, 3)>1
            testROI=rgb2gray(testROI);
        end
        % Normalise according to bitdepth 
        className = class(testROI);
        if isequal(className,'uint8')
            testROI=double(testROI);
            testROI=testROI/(2^8);
        elseif isequal(className ,'uint16')
            testROI=double(testROI);
            testROI=testROI./(2^16);
        end 
        
        %size of testROI
        [m,n] = size(testROI);
        
        % Mask
        mask=ROI{A,3}{2,1};
        
        %Canny
        canny=ROI{A,3}{1,1};
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%% -- 1). MASK UNIFORM GRADIENTS -- %%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %Create mask pixel value results array
        Mpv=zeros(m, 2);
        
        %take the pixel value either isde of the masked area
        for M=1:m
            maskedArea=find(mask(M,:)== 1);
            emp=isempty(maskedArea);
            if emp==0
                rowmin=min(maskedArea);
                rowmax=max(maskedArea);
                
                Mpv(M,1)=testROI(M,rowmin);
                Mpv(M,2)=testROI(M,rowmax);
            else
                Mpv(M,1)=NaN;
                Mpv(M,2)=NaN;
            end
        end
        
        %take the Y gradient
        [~,Mgrad] = gradient(Mpv);
        Mgrad=abs(Mgrad);
        % Set all gradients above the set threshold to one, otherwise zero
        Mgrad2=zeros(m, 2);
        Mgrad2(Mgrad>=gradThresh) = 1;
        
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%% -- 2). Y-AXIS UNIFORM GRADIENTS -- %%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Create y-axis pixel value results array
        Ypv=zeros(m, 2);
        
        %take the 10% and 90% columns
        n10=round(0.1*n);
        n90=round(0.9*n);
        
        Ypv(:,1)=testROI(:,n10);
        Ypv(:,2)=testROI(:,n90);
        
        %take the Y gradient
        [~,Ygrad] = gradient(Ypv);
        Ygrad=abs(Ygrad);
        % Set all gradients above the set threshold to one, otherwise zero
        Ygrad2=zeros(m, 2);
        Ygrad2(Ygrad>=gradThresh) = 1;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%% -- ROI ADJUSTMENTS -- %%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % 1). MASK UNIFORM GRADIENTS should be uniform.
        % 2). Y-AXIS UNIFORM GRADIENTS should have maximum of a single
        %     gradient peak, due to passing through the mask at some point 
        %     in the higher or lower regions of the ROI.
        
        %Count number of gradient peaks in Y-axis grads
        ya=Ygrad2(:,1);
        ya = ~bwareaopen(~ya, 2);
        yaobjects=bwconncomp(ya);
        numGradPeaksA=yaobjects.NumObjects;
        
        yb=Ygrad2(:,2);
        yb = ~bwareaopen(~yb, 2);
        ybobjects=bwconncomp(yb);
        numGradPeaksB=ybobjects.NumObjects;
        
        % If there are peakes within the y-axis grads., determine in if 
        % they are part of the edge gradent or masking error, using the
        % canny edge location.
        % If the object passes throught the canny edge, it is deemed part
        % of the edge grad., otherwise its masking error. 
        
        if numGradPeaksA>0
            Ca=canny(:,n10);
            co=find(Ca==1);
            coemp=isempty(co);
            if coemp==0
                ob=ya(co(1,1));
                if ob==1
                    Ob = bwselect(ya,1,co(1,1));
                    %remove this object
                    ya(Ob==1) = 0;
                end
            end
        end
        if numGradPeaksB>0
            Cb=canny(:,n90);
            co=find(Cb==1);
            coemp=isempty(co);
            if coemp==0
                ob=yb(co(1,1));
                if ob==1
                    Ob = bwselect(yb,1,co(1,1));
                    %remove this object
                    yb(Ob==1) = 0;
                end
            end
        end
        
        % The grad. either side of the edge
        ma=Mgrad2(:,1);
        mb=Mgrad2(:,2);
        
        % Combine these gradient peaks
        grad=ya+ma+yb+mb;
                
        for G=1:length(grad)
            if grad(G)>=1 || grad(G)<=-1
                grad(G)=1;
            end
        end
        
        % Does the ROI need to be croped, segmented or dropped?
        % - If not, continue to the next ROI
        gradpeaks=find(grad==1);
        gradpeaks=isempty(gradpeaks);
        NewROIs=[];
        UsableROI=0;
        if gradpeaks==0
          
            %Invert the grad, so that rows that have unwanted frateants are
            %zeros and rows to be kwept are one
            grad=imcomplement(grad);
            gradobjects=bwconncomp(grad);
            numGradobjects=gradobjects.NumObjects;
            numGradpx=gradobjects.PixelIdxList;

            % Devide the ROIs
            b=0;
            
            for B=1:numGradobjects
                B2=B+b;
                roi=numGradpx{B};
                [S, ~]=size(roi);
                if S<ROImin
                    b=b-1;
                else
                    minIndexY=min(roi);
                    maxIndexY=max(roi);
                    
                    cannynew1=canny(minIndexY:maxIndexY, :, :);
                    [~,Xaxis]=find(cannynew1==1);
                    minIndexX=min(Xaxis);
                    maxIndexX=max(Xaxis);
                    
                    OROInew=OROI(minIndexY:maxIndexY, :, :);
                    testROInew=CROI(minIndexY:maxIndexY, :, :, :);
                    masknew=mask(minIndexY:maxIndexY, :, :, :);
                    cannynew=canny(minIndexY:maxIndexY, :, :, :);

                    newroi=zeros(8,1);
                    newroi=num2cell(newroi);
                    newroi{1,1}=OROInew;
                    newroi{2,1}=testROInew;
                    newroi{3,1}=masknew;
                    newroi{4,1}=cannynew;
                    newroi{5,1}=minIndexY;
                    newroi{6,1}=maxIndexY;
                    newroi{7,1}=minIndexX;
                    newroi{8,1}=maxIndexX;

                    NewROIs{B2,1}=newroi;
                end
            end
        else 
            % ROI is usable as is
            UsableROI=1;
        end
        emp=isempty(NewROIs);
        if emp==0
            %Reconstruct the Edge data 
            newdata=zeros(1,12);
            newdata=num2cell(newdata);
            maskcannycell=zeros(2,1);
            maskcannycell=num2cell(maskcannycell);

            newdata{1,3}=maskcannycell;
            
            [b,~]=size(NewROIs);
            for B=1:b
                 a=a+1;
                
                newdata{1,1}=NewROIs{B,1}{1,1};
                newdata{1,2}=NewROIs{B,1}{2,1};
                newdata{1,3}{2,1}=NewROIs{B,1}{3,1};
                newdata{1,3}{1,1}=NewROIs{B,1}{4,1};
                % For each new ROI re-measure the edge parameters:
                % 1) Edge Angle X
                newdata{1,4}=[];
                
                % 2) Contrast X, 3) Clipping X 4) & Pixel value STD
                [m,n] = size(NewROIs{B,1}{2,1});
                m10=round(0.1*m);
                m90=round(0.9*m);
                mdiff=m90-m10;

                PXval=zeros(mdiff,2);

                roiImgrey=NewROIs{B,1}{2,1};

                for M=m10:m90
                    [~, J]=find(NewROIs{B,1}{3,1}(M,:)==1);
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

                [~, ~, pvSTD]=RoIContrast(PXval);

                % 2)
                newdata{1,5}=[];
                % 3) 
                newdata{1,6}=[];
                % 4)
                newdata{1,7}=pvSTD;
                % 5) ROI Size
                roiSize=size(NewROIs{B,1}{2,1});
                newdata{1,8}=roiSize;
                % 9) Boundary Box
                oldBB=ROI{A,9};
                newBB=zeros(1,4);
                newBB(1,1)=oldBB(1,1); % x
                newBB(1,2)=oldBB(1,2)+(newroi{5,1}-1); % y
                newBB(1,3)=oldBB(1,3);% width
                newBB(1,4)=newroi{6,1}-newroi{5,1}; % hight
                newdata{1,9}=newBB;
                % 10) Radial Distance
                [y,x,~]=size(Im);
                normdist=RadialDist(newBB, [x,y]);
                newdata{1,10}=normdist;
                % Colour code = 1
                newdata{1,12}=1;

                % Add into the ROI2 cell array
                for C=1:12
                    roi2{a,C}=newdata{1,C};
                end  
            end
            % Change colour-code value of oringal ROI to show its a ROI 
            % that has been devied up.
            ROI{A,12}=6;
        else
            % If NewROIs is empty and UsableROI=0, the ROI is shown to be
            % unusable 
            if UsableROI==0
                % Change colour-code value of oringal ROI to show its an  
                % unusable ROI
                ROI{A,12}=3;
            end
            % ROI is usable as is
            UsableROI=1;
        end
    end 
end

% If there are cropped/segmented ROIs (roi2), add to the end of the ROI array
var = exist('roi2', 'var');
if var==1
    ROI2= insertrows(ROI, roi2, length(ROI));  
else
    ROI2=ROI;
end
end  