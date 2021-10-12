function [LFsegsV, LFsegsH]=FrameSeg16(MTF_Results)
% Location Frame Segmentation - 16 segments
% Segmements the Frame into 16 sections for San & Tan MTF estimation
% process.
% 
% INPUT:
%   MTF_Results = The results cell array containing the NS-SFRs - used here
%                 to obtain size of original image. 
% 
% OUTPUT:
%   LFsegs      = A array containing 1-16 the same size as the image of
%                 interest. Used top classify ROIs for San & Tan MTF 
%                 estimation
%
% % O. van Zwanenberg (Jan. 2020)
% UNIVERSITY OF WESTMINSTER 
%              - COMPUTATIONAL VISION AND IMAGING TECHNOLOGY RESEARCH GROUP

    %The size of the imges, assuming all images are the same size
    [y,x,~]=size(MTF_Results{1, 2}); 
    
    if y>x
        LFsegs=zeros(y,y);
        x1=0;
        x2=y/4;
        x3=x2*2;
        x4=x2*3;
        x5=y;
        y1=0;
        y2=y/4;
        y3=y2*2;
        y4=y2*3;
        y5=y;
    else
        LFsegs=zeros(x,x);
        x1=0;
        x2=x/4;
        x3=x2*2;
        x4=x2*3;
        x5=x;
        y1=0;
        y2=x/4;
        y3=y2*2;
        y4=y2*3;
        y5=x;
    end
    
    % Coordinates to segment the frame into 16
    
    X1=[x1; x1; x3];
    Y1=[y3; y2; y3];
    X2=[x1; x1; x3];
    Y2=[y1; y2; y3];
    X3=[x1; x2; x3];
    Y3=[y1; y1; y3];
    X4=[x2; x3; x3];
    Y4=[y1; y1; y3];
    X5=[x3; x4; x3];
    Y5=[y1; y1; y3];
    X6=[x4; x5; x3];
    Y6=[y1; y1; y3];
    X7=[x5; x5; x3];
    Y7=[y1; y2; y3];
    X8=[x5; x5; x3];
    Y8=[y2; y3; y3];
    X9=[x5; x5; x3];
    Y9=[y3; y4; y3];
    X10=[x5; x5; x3];
    Y10=[y4; y5; y3];
    X11=[x5; x4; x3];
    Y11=[y5; y5; y3];
    X12=[x4; x3; x3];
    Y12=[y5; y5; y3];
    X13=[x3; x2; x3];
    Y13=[y5; y5; y3];
    X14=[x2; x1; x3];
    Y14=[y5; y5; y3];
    X15=[x1; x1; x3];
    Y15=[y5; y4; y3];
    X16=[x1; x1; x3];
    Y16=[y4; y3; y3];
    
    seg1=boundary(X1,Y1);
    seg2=boundary(X2,Y2);
    seg3=boundary(X3,Y3);
    seg4=boundary(X4,Y4);
    seg5=boundary(X5,Y5);
    seg6=boundary(X6,Y6);
    seg7=boundary(X7,Y7);
    seg8=boundary(X8,Y8);
    seg9=boundary(X9,Y9);
    seg10=boundary(X10,Y10);
    seg11=boundary(X11,Y11);
    seg12=boundary(X12,Y12);
    seg13=boundary(X13,Y13);
    seg14=boundary(X14,Y14);
    seg15=boundary(X15,Y15);
    seg16=boundary(X16,Y16);
    
    seg1=poly2mask(X1(seg1),Y1(seg1),y5,x5);
    seg2=poly2mask(X2(seg2),Y2(seg2),y5,x5);
    seg3=poly2mask(X3(seg3),Y3(seg3),y5,x5);
    seg4=poly2mask(X4(seg4),Y4(seg4),y5,x5);
    seg5=poly2mask(X5(seg5),Y5(seg5),y5,x5);
    seg6=poly2mask(X6(seg6),Y6(seg6),y5,x5);
    seg7=poly2mask(X7(seg7),Y7(seg7),y5,x5);
    seg8=poly2mask(X8(seg8),Y8(seg8),y5,x5);
    seg9=poly2mask(X9(seg9),Y9(seg9),y5,x5);
    seg10=poly2mask(X10(seg10),Y10(seg10),y5,x5);
    seg11=poly2mask(X11(seg11),Y11(seg11),y5,x5);
    seg12=poly2mask(X12(seg12),Y12(seg12),y5,x5);
    seg13=poly2mask(X13(seg13),Y13(seg13),y5,x5);
    seg14=poly2mask(X14(seg14),Y14(seg14),y5,x5);
    seg15=poly2mask(X15(seg15),Y15(seg15),y5,x5);
    seg16=poly2mask(X16(seg16),Y16(seg16),y5,x5);
    
    for S=1:y5
        for D=1:x5
            if seg1(S,D)==1
                LFsegs(S,D)=1;
            elseif seg2(S,D)==1
                LFsegs(S,D)=2;
            elseif seg3(S,D)==1
                LFsegs(S,D)=3;
            elseif seg4(S,D)==1
                LFsegs(S,D)=4;
            elseif seg5(S,D)==1
                LFsegs(S,D)=5;
            elseif seg6(S,D)==1
                LFsegs(S,D)=6;
            elseif seg7(S,D)==1
                LFsegs(S,D)=7;
            elseif seg8(S,D)==1
                LFsegs(S,D)=8;
            elseif seg9(S,D)==1
                LFsegs(S,D)=9;
            elseif seg10(S,D)==1
                LFsegs(S,D)=10;
            elseif seg11(S,D)==1
                LFsegs(S,D)=11;
            elseif seg12(S,D)==1
                LFsegs(S,D)=12;
            elseif seg13(S,D)==1
                LFsegs(S,D)=13;
            elseif seg14(S,D)==1
                LFsegs(S,D)=14;
            elseif seg15(S,D)==1
                LFsegs(S,D)=15;
            elseif seg16(S,D)==1
                LFsegs(S,D)=16;
            end
        end
    end
    if y>x
        dif=y-x;
        dif=dif/2;
        LFsegsV=LFsegs(:, dif:y-dif);
        LFsegsH=LFsegs(dif:y-dif,:);
    else
        dif=x-y;
        dif=dif/2;
        LFsegsV=LFsegs(dif:x-dif,:);
        LFsegsH=LFsegs(:, dif:x-dif);
    end
end