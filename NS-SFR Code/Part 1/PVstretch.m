function  [ROIstretch, PXval, ROI, Canny, Mask] = PVstretch(ROI, Canny, Mask)
% PVstretch, Pixel Value stertch, takes the ROI, the edge location (Canny)
% and the edge mask to from a new ROI, where a pixel values for each row
% either side of the edge mask are stretched to fill the entire row. The
% pixel value is determend using a 'T'shaped medien value. 
%
% Input:    
%   ROI:            The Region of Interest (ROI)
%   Canny:          The canny edge detection within that ROI
%   Mask:           The Masked region where the edge is located
% Output: 
%   ROIstretch:     The ROI that has been pixel stretched
%   PXval:          List of Pixel Values
%   ROI:            The ROI with any cropping applied
%   Canny:          The canny edge detection with any cropping applied
%   Mask:           The Mask with any cropping applied
%
% % Copyright (c) 2019 O. van Zwanenberg
% UNIVERSITY OF WESTMINSTER 
%              - COMPUTATIONAL VISION AND IMAGING TECHNOLOGY RESEARCH GROUP
% Director of Studies:  S. Triantaphillidou
% Supervisory Team:     R. Jenkin & A. Psarrou

% Split the RGB ROI into the indervidual channels R G and B
[~,~,a]=size(ROI);
if a==3
    roiR=ROI(:,:,1);
    roiG=ROI(:,:,2);
    roiB=ROI(:,:,3);
    rgbTF=1;
    
elseif a==1
    roiR=ROI(:,:,1);
    roiG=ROI(:,:,1);
    roiB=ROI(:,:,1);
    rgbTF=0;
    ROI = cat(3, ROI, ROI, ROI);
end

[m,n] = size(Canny);
PXval=zeros(m,2);

for M=1:m
    for N=1:n
        if Canny(M,N)==1
            emp=isempty(find(Mask(M,:), 1));
            if emp==1
                % If edge location is far left of ROI with  *no  
                % mask*, no Left edge pixel value:
                if N==1 % min value
                    % T-Shaped Median
                    pxvalR(1,1)=ROI(M,N+1,1);
                    pxvalG(1,1)=ROI(M,N+1,2);
                    pxvalB(1,1)=ROI(M,N+1,3);

                    pxvalR(1,2)=ROI(M,N+2,1);
                    pxvalG(1,2)=ROI(M,N+2,2);
                    pxvalB(1,2)=ROI(M,N+2,3);

                    if M~=1
                        pxvalR(1,3)=ROI(M-1,N+2,1);
                        pxvalG(1,3)=ROI(M-1,N+2,2);
                        pxvalB(1,3)=ROI(M-1,N+2,3);
                    else
                        pxvalR(1,3)=NaN;
                        pxvalG(1,3)=NaN;
                        pxvalB(1,3)=NaN;
                    end

                    if M~=m
                        pxvalR(1,4)=ROI(M+1,N+2,1);
                        pxvalG(1,4)=ROI(M+1,N+2,2);
                        pxvalB(1,4)=ROI(M+1,N+2,3);
                    else
                        pxvalR(1,4)=NaN;
                        pxvalG(1,4)=NaN;
                        pxvalB(1,4)=NaN;
                    end

                    pxval(1,1)=nanmedian(pxvalR);
                    pxval(1,2)=nanmedian(pxvalG);
                    pxval(1,3)=nanmedian(pxvalB);

                    % Pixel Value List
                    PXval(M,1,1)=NaN;
                    PXval(M,2,1)=im2double(pxval(1,1));
                    PXval(M,1,2)=NaN;
                    PXval(M,2,2)=im2double(pxval(1,2));
                    PXval(M,1,3)=NaN;
                    PXval(M,2,3)=im2double(pxval(1,3));

                    % Place this pixel value to all values 
                    % right of roiIm(M,N+1)
                    for F=(N+1):n
                        roiR(M,F)=pxval(1,1);
                        roiG(M,F)=pxval(1,2);
                        roiB(M,F)=pxval(1,3);
                    end

                % If edge location is far right of ROI with *no 
                % mask*, no Right edge pixel value:
                elseif N==n %max value 
                    % T-Shaped Median
                    pxvalR(1,1)=ROI(M,N-1,1);
                    pxvalG(1,1)=ROI(M,N-1,2);
                    pxvalB(1,1)=ROI(M,N-1,3);

                    pxvalR(1,2)=ROI(M,N-2,1);
                    pxvalG(1,2)=ROI(M,N-2,2);
                    pxvalB(1,2)=ROI(M,N-2,3);

                    if M~=1
                        pxvalR(1,3)=ROI(M-1,N-2,1);
                        pxvalG(1,3)=ROI(M-1,N-2,2);
                        pxvalB(1,3)=ROI(M-1,N-2,3);
                    else
                        pxvalR(1,3)=NaN;
                        pxvalG(1,3)=NaN;
                        pxvalB(1,3)=NaN;
                    end

                    if M~=m
                        pxvalR(1,4)=ROI(M+1,N-2,1);
                        pxvalG(1,4)=ROI(M+1,N-2,2);
                        pxvalB(1,4)=ROI(M+1,N-2,3);
                    else
                        pxvalR(1,4)=NaN;
                        pxvalG(1,4)=NaN;
                        pxvalB(1,4)=NaN;
                    end

                    pxval(1,1)=nanmedian(pxvalR);
                    pxval(1,2)=nanmedian(pxvalG);
                    pxval(1,3)=nanmedian(pxvalB);

                    % Pixel Value List
                    PXval(M,1,1)=im2double(pxval(1,1));
                    PXval(M,2,1)=NaN;
                    PXval(M,1,2)=im2double(pxval(1,2));
                    PXval(M,2,2)=NaN;
                    PXval(M,1,3)=im2double(pxval(1,3));
                    PXval(M,2,3)=NaN;

                    % Place this pixel value to all values left 
                    % of roiIm(M,N-1)
                    for F=1:(N-1)
                        roiR(M,F)=pxval(1,1);
                        roiG(M,F)=pxval(1,2);
                        roiB(M,F)=pxval(1,3);
                    end
                end
            else 
                % If edge location is far left of ROI, there is 
                % no Left edge pixel value:
                if N==1 %min value
                    Px=Mask(M,N);
                    A=N;
                    Lim=0;
                    while (Px==1)
                        A=A+1;
                        Px=Mask(M,A);
                        if A==n
                            Lim=1;
                            break
                        end
                    end
                    if  Lim~=1

                        pxvalR(1,1)=ROI(M,A,1);
                        pxvalG(1,1)=ROI(M,A,2);
                        pxvalB(1,1)=ROI(M,A,3);

                        pxvalR(1,2)=ROI(M,A+1,1);
                        pxvalG(1,2)=ROI(M,A+1,2);
                        pxvalB(1,2)=ROI(M,A+1,3);

                        if M~=1
                            pxvalR(1,3)=ROI(M-1,A+1,1);
                            pxvalG(1,3)=ROI(M-1,A+1,2);
                            pxvalB(1,3)=ROI(M-1,A+1,3);
                        else
                            pxvalR(1,3)=NaN;
                            pxvalG(1,3)=NaN;
                            pxvalB(1,3)=NaN;
                        end

                        if M~=m
                            pxvalR(1,4)=ROI(M+1,A+1,1);
                            pxvalG(1,4)=ROI(M+1,A+1,2);
                            pxvalB(1,4)=ROI(M+1,A+1,3);
                        else
                            pxvalR(1,4)=NaN;
                            pxvalG(1,4)=NaN;
                            pxvalB(1,4)=NaN;
                        end

                        pxval(1,1)=nanmedian(pxvalR);
                        pxval(1,2)=nanmedian(pxvalG);
                        pxval(1,3)=nanmedian(pxvalB);

                        % Pixel Value List
                        PXval(M,1,1)=NaN;
                        PXval(M,2,1)=im2double(pxval(1,1));
                        PXval(M,1,2)=NaN;
                        PXval(M,2,2)=im2double(pxval(1,2));
                        PXval(M,1,3)=NaN;
                        PXval(M,2,3)=im2double(pxval(1,3));

                        % Place this pixel value to all values 
                        % right of roiIm(M,A)
                        for F=A:n
                            roiR(M,F)=pxval(1,1);
                            roiG(M,F)=pxval(1,2);
                            roiB(M,F)=pxval(1,3);
                        end
                    end

                % If edge location is far right of ROI, there 
                % is no Right edge pixel value:
                elseif N==n %max value 
                    Px=Mask(M,N);
                    A=N;
                    Lim=0;
                    while (Px==1)
                        A=A-1;
                        if A==1
                            Lim=1;
                            break
                        end
                        Px=Mask(M,A);
                    end
                    if  Lim~=1

                        pxvalR(1,1)=ROI(M,A,1);
                        pxvalG(1,1)=ROI(M,A,2);
                        pxvalB(1,1)=ROI(M,A,3);

                        pxvalR(1,2)=ROI(M,A-1,1);
                        pxvalG(1,2)=ROI(M,A-1,2);
                        pxvalB(1,2)=ROI(M,A-1,3);

                        if M~=1
                            pxvalR(1,3)=ROI(M-1,A-1,1);
                            pxvalG(1,3)=ROI(M-1,A-1,2);
                            pxvalB(1,3)=ROI(M-1,A-1,3);
                        else
                            pxvalR(1,3)=NaN;
                            pxvalG(1,3)=NaN;
                            pxvalB(1,3)=NaN;
                        end

                        if M~=m
                            pxvalR(1,4)=ROI(M+1,A-1,1);
                            pxvalG(1,4)=ROI(M+1,A-1,2);
                            pxvalB(1,4)=ROI(M+1,A-1,3);
                        else
                            pxvalR(1,4)=NaN;
                            pxvalG(1,4)=NaN;
                            pxvalB(1,4)=NaN;
                        end

                        pxval(1,1)=nanmedian(pxvalR);
                        pxval(1,2)=nanmedian(pxvalG);
                        pxval(1,3)=nanmedian(pxvalB);

                        % Pixel Value List
                        PXval(M,1,1)=im2double(pxval(1,1));
                        PXval(M,2,1)=NaN;
                        PXval(M,1,2)=im2double(pxval(1,2));
                        PXval(M,2,2)=NaN;
                        PXval(M,1,3)=im2double(pxval(1,3));
                        PXval(M,2,3)=NaN;

                        % Place this pixel value to all values 
                        % left of roiIm(M,A)
                        for F=1:A
                            roiR(M,F)=pxval(1,1);
                            roiG(M,F)=pxval(1,2);
                            roiB(M,F)=pxval(1,3);
                        end
                    end
                else
                    % Determin the left Pixel value
                    Px=Mask(M,N);
                    A=N;
                    Lim=0;
                    while (Px==1)
                        A=A-1;
                        if A==1
                            Lim=1;
                            break
                        end
                        Px=Mask(M,A);
                    end
                    if  Lim~=1

                        pxvalR(1,1)=ROI(M,A,1);
                        pxvalG(1,1)=ROI(M,A,2);
                        pxvalB(1,1)=ROI(M,A,3);

                        pxvalR(1,2)=ROI(M,A-1,1);
                        pxvalG(1,2)=ROI(M,A-1,2);
                        pxvalB(1,2)=ROI(M,A-1,3);

                        if M~=1
                            pxvalR(1,3)=ROI(M-1,A-1,1);
                            pxvalG(1,3)=ROI(M-1,A-1,2);
                            pxvalB(1,3)=ROI(M-1,A-1,3);
                        else
                            pxvalR(1,3)=NaN;
                            pxvalG(1,3)=NaN;
                            pxvalB(1,3)=NaN;
                        end

                        if M~=m
                            pxvalR(1,4)=ROI(M+1,A-1,1);
                            pxvalG(1,4)=ROI(M+1,A-1,2);
                            pxvalB(1,4)=ROI(M+1,A-1,3);
                        else
                            pxvalR(1,4)=NaN;
                            pxvalG(1,4)=NaN;
                            pxvalB(1,4)=NaN;
                        end

                        pxval(1,1)=nanmedian(pxvalR);
                        pxval(1,2)=nanmedian(pxvalG);
                        pxval(1,3)=nanmedian(pxvalB);

                        % Pixel Value List
                        PXval(M,1,1)=im2double(pxval(1,1));
                        PXval(M,1,2)=im2double(pxval(1,2));
                        PXval(M,1,3)=im2double(pxval(1,3));

                       % Place this pixel value to all values 
                       % left of roiIm(M,A)
                        for F=1:A
                            roiR(M,F)=pxval(1,1);
                            roiG(M,F)=pxval(1,2);
                            roiB(M,F)=pxval(1,3);
                        end 
                    else
                        PXval(M,1,1)=nan;
                        PXval(M,1,2)=nan;
                        PXval(M,1,3)=nan;
                    end
                    % Detemin the right Pixel value
                    Px=Mask(M,N);
                    A=N;
                    Lim=0;
                    while (Px==1)
                        A=A+1;
                        if A==n 
                            Lim=1;
                            break
                        end
                        Px=Mask(M,A);
                    end
                    if  Lim~=1

                        pxvalR(1,1)=ROI(M,A,1);
                        pxvalG(1,1)=ROI(M,A,2);
                        pxvalB(1,1)=ROI(M,A,3);

                        pxvalR(1,2)=ROI(M,A+1,1);
                        pxvalG(1,2)=ROI(M,A+1,2);
                        pxvalB(1,2)=ROI(M,A+1,3);

                        if M~=1
                            pxvalR(1,3)=ROI(M-1,A+1,1);
                            pxvalG(1,3)=ROI(M-1,A+1,2);
                            pxvalB(1,3)=ROI(M-1,A+1,3);
                        else
                            pxvalR(1,3)=NaN;
                            pxvalG(1,3)=NaN;
                            pxvalB(1,3)=NaN;
                        end

                        if M~=m
                            pxvalR(1,4)=ROI(M+1,A+1,1);
                            pxvalG(1,4)=ROI(M+1,A+1,2);
                            pxvalB(1,4)=ROI(M+1,A+1,3);
                        else
                            pxvalR(1,4)=NaN;
                            pxvalG(1,4)=NaN;
                            pxvalB(1,4)=NaN;
                        end

                        pxval(1,1)=nanmedian(pxvalR);
                        pxval(1,2)=nanmedian(pxvalG);
                        pxval(1,3)=nanmedian(pxvalB);

                        % Pixel Value List
                        PXval(M,2,1)=im2double(pxval(1,1));
                        PXval(M,2,2)=im2double(pxval(1,2));
                        PXval(M,2,3)=im2double(pxval(1,3));

                        % Place this pixel value to all values 
                        % right of roiIm(M,A)
                        for F=A:n
                            roiR(M,F)=pxval(1,1);
                            roiG(M,F)=pxval(1,2);
                            roiB(M,F)=pxval(1,3);
                        end 
                    else
                        PXval(M,2,1)=nan;
                        PXval(M,2,2)=nan;
                        PXval(M,2,3)=nan;
                    end
                end
            end                        
        end
    end
end

% If there is a row(s) with two average pixel values of zero, 
% due to a gap in the canny edge detector, take the value from 
% above or below, usally this is a problem at the top/bottom 
% of the ROI. 

[i,~,~] = find(PXval~=0);
Imin=min(i);
Imax=max(i);
if Imax-Imin<3 %stop there being single pixel ROIs
    ROIstretch=[];
    PXval=[];
    ROI=[];
    Canny=[];
    Mask=[];
    return
else
    roiR=roiR(Imin:Imax,:);
    roiG=roiG(Imin:Imax,:);
    roiB=roiB(Imin:Imax,:); 
    ROI=ROI(Imin:Imax,:,:); 
    Mask=Mask(Imin:Imax,:); 
    Canny=Canny(Imin:Imax,:); 
end
%----------------------------------------------------------
% Blur the roiIm
GradMask=gradGenerator(Mask, Canny, 0.5);

blurredR=VariableBlur(roiR, GradMask*5);
blurredG=VariableBlur(roiG, GradMask*5);
blurredB=VariableBlur(roiB, GradMask*5);

if rgbTF==1
    ROIstretch = cat(3, blurredR, blurredG, blurredB);
else
    ROIstretch = blurredR;
end