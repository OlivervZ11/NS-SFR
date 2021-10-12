function [ROI2]=EdgeShapeSplit(Im, ROI, Thresh0, ROImin)
% EdgeShapeSplit is a function that ensures the ROI edge shapes are 
% sutible for the slanted-edge MTF measure. 
%
% Inupt:
%   Im          =   Original Image
%   ROI         =   The ROI cell array from the ROIisolate function.
%   Thresh0     =   The threshold of the number of pixels that remian at 0
%                   degree angle (raimain on the same row/column)
%                   (defult = 20 pixels)
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
        Thresh0 = 20;
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
        [m,~] = size(testROI);
        
        % Mask
        mask=ROI{A,3}{2,1};
        
        %Canny
        canny=ROI{A,3}{1,1};
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% -- CONVERT CANNY INTO XY COORDINATES -- %%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Take the coordinate list in order of row (x) and order of column 
        % (y), take the ordered x and orded y columns into one matrix.
        co1=BW2Co(canny,2);
        co2=BW2Co(canny,2);
        Co=co2(:,1);
        Co(:,2)=co1(:,2);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%% -- MEASURE THE DERIVATIVE OF CO -- %%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Dif=diff(Co);
        
        % If the value of the differnce is > 1 / < -1, change the value to
        % 1/-1 respectively, to indercage that there is a change.
        for B=1:size(Dif,1)
            if Dif(B,1)>1
                Dif(B,1)=1;
            elseif Dif(B,1)<-1
                Dif(B,1)=-1;
            end
            if Dif(B,2)>1
                Dif(B,2)=1;
            elseif Dif(B,2)<-1
                Dif(B,2)=-1;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%% -- ROI ADJUSTMENTS -- %%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 1). Invert the Diff and remove sections of the ROI with edges 
        % that remain on the same row/column for more than Thresh
        % 2). Use original Diff, fill in zeros with closes neighbour
        % non-zero value, and segment the ROI.
        
        % Create new ROIs from the segmented ROI, if ROI hight > ROImin
               
        %------------------------------------------------------------------
        % 1). 
        % Invert the Diff
        % X
        Dif2=imcomplement(abs(Dif));
        Dif2Ob1=bwconncomp(Dif2(:,1));
        numDif2Ob1=Dif2Ob1.NumObjects;
        numDif2px1=Dif2Ob1.PixelIdxList;
        Remove_x=[];
        if numDif2Ob1~=0
            b=0;   
            for B=1:numDif2Ob1
                B2=B+b;
                flatarea=numDif2px1{B};
                [S, ~]=size(flatarea);
                if S<Thresh0
                    b=b-1;
                else
                    minIndexY=min(flatarea);
                    maxIndexY=max(flatarea);
                    Remove_x(B2, 1)=minIndexY;
                    Remove_x(B2, 2)=maxIndexY;
                end
            end
        end
        % Y
        Dif2=imcomplement(abs(Dif));
        Dif2Ob1=bwconncomp(Dif2(:,2));
        numDif2Ob1=Dif2Ob1.NumObjects;
        numDif2px1=Dif2Ob1.PixelIdxList;
        Remove_y=[];
        if numDif2Ob1~=0
            b=0;   
            for B=1:numDif2Ob1
                B2=B+b;
                flatarea=numDif2px1{B};
                [S, ~]=size(flatarea);
                if S<Thresh0
                    b=b-1;
                else
                    minIndexY=min(flatarea);
                    maxIndexY=max(flatarea);
                    Remove_y(B2, 1)=minIndexY;
                    Remove_y(B2, 2)=maxIndexY;
                end
            end
        end
        
        %------------------------------------------------------------------
        % 2).
        % Replace zeros with nearest non-zero value
        [zeroValsX, ~]=size(find(Dif(:,1)));
        [zeroValsY, ~]=size(find(Dif(:,2)));
        if zeroValsX<=1 || zeroValsY<=1
           % The ROI is not usable 
            ROI{A,12}=3;
        else
            dif=Dif(:,1);
            Dif3=zeros(length(Dif), 2);
            nearestfun = @(dif) interp1(find(dif),dif(dif~=0),(1:length(dif))','nearest','extrap');
            Dif3(:,1) = 0.5*(nearestfun(dif) + flip(nearestfun(flip(dif))));
            dif=Dif(:,2);
            nearestfun = @(dif) interp1(find(dif),dif(dif~=0),(1:length(dif))','nearest','extrap');
            Dif3(:,2) = 0.5*(nearestfun(dif) + flip(nearestfun(flip(dif))));

            % Place zeros in the areas found in 1) - indercating areas to
            % remove from ROI

            Vx = isempty(Remove_x);
            Vy = isempty(Remove_y);
            if Vx==0
                [b,~]=size(Remove_x);
                for B=1:b
                    Dif3(Remove_x(B,1):Remove_x(B,2), 1)=0;
                end 
            end

            if Vy==0
                [b,~]=size(Remove_x);
                for B=1:b
                     Dif3(Remove_y(B,1):Remove_y(B,2),2)=0;
                end 
            end

            % X - determine the ROI areas
            uvals = unique(Dif3(:,1));
            accumulated_listX = struct('label', {}, 'props', {});
            for K = 1 : length(uvals)
                   U = uvals(K);
                   accumulated_listX(K).label = U;
                   BW = Dif3(:,1) == U;
                   BW2 = bwareafilt(BW, [ROImin, inf]);  %discard areas that are too small (ROImin)
                   theseprops = regionprops(BW2, 'PixelList', 'Orientation');
                   accumulated_listX(K).props = theseprops;
             end

            % Y - determine the ROI areas
            uvals = unique(Dif3(:,2));
            accumulated_listY = struct('label', {}, 'props', {});
            for K = 1 : length(uvals)
                   U = uvals(K);
                   accumulated_listY(K).label = U;
                   BW = Dif3(:,2) == U;
                   BW2 = bwareafilt(BW, [ROImin, inf]);  %discard areas that are too small (ROImin)
                   theseprops = regionprops(BW2, 'PixelList', 'Orientation');
                   accumulated_listY(K).props = theseprops;
            end
            %------------------------------------------------------------------
            % Combine 1) and 2) into on mapping Segmants array
            SegmantsX=zeros(m,1);
            SegmantsY=zeros(m,1);
            Segmants=zeros(m,1);

            [~, xx]=size(accumulated_listX);
            [~, yy]=size(accumulated_listY);

            for XX=1:xx
                emp=isempty(accumulated_listX(XX).props);
                if emp==0
                    pixellist=accumulated_listX(XX).props.PixelList; 
                    pixellist=pixellist(:,2);

                    MinIndex=min(pixellist);
                    MaxIndex=max(pixellist);

                    % If the pixel list is the entire length of the original
                    % ROI, the entire ROI (for x-axis) is usable. 
                    if MinIndex==1 && MaxIndex==(m-1) % m-1 as the diff function is the defence between pixels, thus length is one pixel shorter
                        SegmantsX(:,1)=1;
                        UX=1;
                    else 
                        % Zero out the areas of 'good-ROI'
                        SegmantsX(MinIndex:MaxIndex, 1)=1;
                        UX=0;
                    end
                else
                    UX=0;
                end
            end
            for YY=1:yy
                emp=isempty(accumulated_listY(YY).props);
                if emp==0
                    pixellist=accumulated_listY(YY).props.PixelList; 
                    pixellist=pixellist(:,2);

                    MinIndex=min(pixellist);
                    MaxIndex=max(pixellist);

                    % If the pixel list is the entire length of the original
                    % ROI, the entire ROI (for x-axis) is usable. 
                    if MinIndex==1 && MaxIndex==(m-1) % m-1 as the diff function is the defence between pixels, thus length is one pixel shorter
                        SegmantsY(:,1)=1;
                        UY=1;
                    else 
                        % Zero out the areas of 'good-ROI'
                        SegmantsY(MinIndex:(MaxIndex-1), 1)=1; % Subtract 1 from max index to keep objects seperate
                        UY=0;
                    end
                else
                    UY=0;
                end
            end

            % If both the x and y axis are continuous from 1 to m, no ROI
            % cropping/secmentation is requred. 
            if UX==1 && UY==1
                Segmants(:,1)=1;
            else
                for B=1:m
                    if SegmantsX(B,1)==0 || SegmantsY(B,1)==0
                        Segmants(B,1)=0;
                    elseif SegmantsX(B,1)==1 && SegmantsY(B,1)==1
                        Segmants(B,1)=1;
                    end
                end
            end

            %------------------------------------------------------------------
            ROIZeros=find(Segmants==0);
            empZeros=isempty(ROIZeros);
            % Devide the ROIs if needed
            if empZeros==0
                Segobjects=bwconncomp(Segmants);
                numSegobjects=Segobjects.NumObjects;
                numSegpx=Segobjects.PixelIdxList;
                b=0;
                NewROIs=[];
                for B=1:numSegobjects
                    B2=B+b;
                    roi=numSegpx{B};
                    [S, ~]=size(roi);
                    if S<ROImin
                        b=b-1;
                    else
                        minIndexY=min(roi);
                        maxIndexY=(max(roi));
                        minvalY= Co(minIndexY, 2);
                        maxvalY= Co(maxIndexY, 2);

                        cannynew1=canny(minvalY:maxvalY, :, :);
                        [~,Xaxis]=find(cannynew1==1);
                        minIndexX=min(Xaxis);
                        maxIndexX=max(Xaxis);

                        OROInew=OROI(minvalY:maxvalY, :, :);
                        testROInew=CROI(minvalY:maxvalY, :, :, :);
                        masknew=mask(minvalY:maxvalY, :, :, :);
                        cannynew=canny(minvalY:maxvalY, :, :, :);

                        newroi=zeros(8,1);
                        newroi=num2cell(newroi);
                        newroi{1,1}=OROInew;
                        newroi{2,1}=testROInew;
                        newroi{3,1}=masknew;
                        newroi{4,1}=cannynew;
                        newroi{5,1}=minvalY;
                        newroi{6,1}=maxvalY;
                        newroi{7,1}=minIndexX;
                        newroi{8,1}=maxIndexX;

                        NewROIs{B2,1}=newroi;
                    end
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
                    % The ROI is not usable
                    ROI{A,12}=3;
                end 
            else
                % ROI is sutible with no alterations
            end
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