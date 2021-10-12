function [ROI, ROIcanny, ROILoc]=findROI(bb, Im, BW, hight)
% ROI Split, splits the oversized ROI in question into smaller ROIs
% with a specified hight. These are then placed into the BB array,
% removing the large ROI. 
%
% Input:
%   bb:         Struct Array containing the BoundingBox coordinates
%   BW:         Edge Detection Binary Image
%   hight:      The hight of the ROI, defult is 128 (the minimum hight for
%               a ROI for the slanted-edge MTF method). 
%
% Output: 
%   ROI:         Cell array containing all ROI Crops
%   ROIcanny:    Cell array containing all Edge Detection Crops
%   ROILoc:      Cell array containing all ROI Locations
%
% Copyright (c) 2019 O. van Zwanenberg, University of Westminster
%--------------------------------------------------------------------------
switch nargin
    case 3
        hight=128; 
end

BB=struct2cell(bb);

oldlocs=zeros(length(bb),1);
oldlocs=num2cell(oldlocs);
BB2=BB';

K2=0;

for k = 1 : length(bb)
    
    thisBB=bb(k).BoundingBox;
    
    if thisBB(1,4)>hight

        K1=k+K2;
        
        % Extract the BoundingBox coordinats
        n=thisBB(1,1);
        m=thisBB(1,2);
        x=thisBB(1,3);
        y=thisBB(1,4);
        
        % Canny ROI:
        roi=imcrop(BW, thisBB);
        % Remove any 'non-main' edges in ROI Canny 
        l = bwlabel(roi);
        rois=regionprops(roi,'PixelIdxList');
        % Sort based on number of pixels in each connected component:
        d = cellfun('length',{rois(:).PixelIdxList}); 
        [~,order] = sort(d,'descend');
        % Select only longest edge
        canny = ismember(l,order(1,1)); 
        
        a=y/hight;
        Floor=floor(a);
        roinum=ceil(a);
        Overlap=a-Floor;
        Overlap=1-Overlap;
        Overlap=Overlap/Floor;
        Overlap=Overlap*hight;
        
        NewBBs=zeros(roinum,1);
        NewBBs=num2cell(NewBBs);
        
        for ROInum=1:roinum
            if ROInum==1
                M=0;
                N1=find(canny(1,:)==1);
                emp=isempty(N1);
                if emp==1
                    nn=2;
                    while emp==1
                        N1=find(canny(nn,:)==1);
                        nn=nn+1;
                        emp=isempty(N1);
                    end
                end
                N1=N1(1,1);
                N=N1;
                Y=hight;
                X1=find(canny(round(Y),:)==1);
                X=abs(N-X1(1,1));
                
                if N1>X1(1,1)
                    newbb=[(N+n)-X, M+m, X, Y];
                else
                    newbb=[N+n, M+m, X, Y];
                end
                
                NewBBs{1,1}=newbb; 
            else
                M=(M+Y)-Overlap;
                N1=find(canny(round(M),:)==1);
                if emp==1
                    nn=2;
                    while emp==1
                        N1=find(canny(nn,:)==1);
                        nn=nn+1;
                        emp=isempty(N1);
                    end
                end
                N=N1(1,1);
                Y=hight;
                X1=find(canny(round(M+Y),:)==1);
                X=abs(N-X1(1,1));
                
                if N>X1(1,1)
                    newbb=[(N+n)-X, M+m, X, Y];
                else
                    newbb=[N+n, M+m, X, Y];
                end
                NewBBs{ROInum,1}=newbb; 
            end   
        end
        
        % Incert the new ROI into BB cell array, removing the large ROI
        % Incert using insertrows (Copyright (c) 2016, Jos van der Geest)
        BB2 = insertrows(BB2, NewBBs, K1);
        oldlocs{K1,1}=thisBB;
        BB2{K1} = [];
        K2=K2+length(NewBBs);
    end
end

%--------------------------------------------------------------------------
ROI=zeros(length(BB2),1);
ROI=num2cell(ROI);
ROIcanny=zeros(length(BB2),1);
ROIcanny=num2cell(ROIcanny);
ROILoc=zeros(length(BB2),1);
ROILoc=num2cell(ROILoc);

for k = 1 : length(BB2)
    
    
    thisBB=BB2{k};
    emp=isempty(thisBB);
    if emp~=1
        % Expand ROI if width is under 20 pixels
        if thisBB(1,3)<20
            diff=20-thisBB(1,3);
            thisBB(1,1)=thisBB(1,1)-(0.5*diff);
            thisBB(1,3)=thisBB(1,3)+diff;
        end 
        %----------------------------------------------------------------------

        % Image ROI:
        roi=imcrop(Im, thisBB);
        ROI{k,1}=roi;

        %----------------------------------------------------------------------
        % Canny ROI:
        roi=imcrop(BW, thisBB);

        % Remove any 'non-main' edges in ROI Canny 
        l = bwlabel(roi);
        rois=regionprops(roi,'PixelIdxList');

        % Sort based on number of pixels in each connected component:
        d = cellfun('length',{rois(:).PixelIdxList}); %max number of diaginal pixels in each region
        [~,order] = sort(d,'descend');

        % Select only longest edge
        roiS = ismember(l,order(1,1)); 
        
        % If there are multible same length and the first one is on the edge
        % Move to next longest edge
        [~,x]=find(roiS==1);
        X=find(x~=1);
        emp=isempty(X);
        if emp==1
            if size(order,2)>=2
                roiS = ismember(l,order(1,2)); 
            else
                ROI{k,1}=[];
                ROIcanny{k,1}=[];
                ROILoc{k,1}=oldlocs{k,1};
            end
        end
        
        [~,x]=find(roiS==1);
        X=find(x~=(size(roiS,2)));
        emp=isempty(X);
        if emp==1
            if size(order,2)>=2
                roiS = ismember(l,order(1,2)); 
            else
                ROI{k,1}=[];
                ROIcanny{k,1}=[];
                ROILoc{k,1}=oldlocs{k,1};
            end
        end
        
        
        ROIcanny{k,1}=roiS;
        %----------------------------------------------------------------------
        % ROI Location
        ROILoc{k,1}=thisBB;
    else
        ROI{k,1}=[];
        ROIcanny{k,1}=[];
        ROILoc{k,1}=oldlocs{k,1};
    end
end
    
    