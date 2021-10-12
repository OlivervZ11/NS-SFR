function [RadDistH, RadDistV, ISORadDistH, ISORadDistV, ISORadDistS, ...
    ISORadDistT]=radseg(RDseg, namesIndex, ISO12233Charthv, ...
    ISO12233Chartst, path, Labels)
% RADSEG divides the MTF Results (the NS-SFRs) into segments according to
% the position of the ROI in the frame. 
%
% In addtion the LSF Half Peak Width is measured from the resampled ESF
%
% INPUT:
%   RDseg           -       The number of radial segments ('Dohnuts')\
%   namesIndex      -       The NS-SFR data to load
%   ISO12233Charthv -       The H & V SFR data from the test chart - 
%                           measured from the framework
%   ISO12233Chartst -       The S & T SFR data from the test chart - 
%                           measured from the framework
%   Path            -       Directory to the data
%   Lables          -       Array that is used to partition the database
%
% OUTPUT:
%   RadDistH        -       Cell array cotraining the divided NS-SFR data,
%                           edge perameters and the LSF Half Peak Width
%                           for the Horizontal edges
%   RadDistV        -       Cell array cotraining the divided NS-SFR data,
%                           edge perameters and the LSF Half Peak Width
%                           for the Vertical edges
%   ISORadDistH     -       Cell array cotraining the divided SFR data from
%                           the test chart - for the Horizontal edges
%   ISORadDistV     -       Cell array cotraining the divided SFR data from
%                           the test chart - for the Vertical edges
%   ISORadDistS     -       Cell array cotraining the divided SFR data from
%                           the test chart - for the Saggital edges
%   ISORadDistT     -       Cell array cotraining the divided SFR data from
%                           the test chart - for the Tangental edges
%
% O. van Zwanenberg (2020)
% 
% UNIVERSITY OF WESTMINSTER 
%              - COMPUTATIONAL VISION AND IMAGING TECHNOLOGY RESEARCH GROUP
% Director of Studies:  S. Triantaphillidou
% Supervisory Team:     R. Jenkin & A. Psarrou
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Is RGB?
Load_Result=[path '/' namesIndex{1,1}];
load(Load_Result, 'MTF_Results');
if size(MTF_Results,1)==1
    rgbC = 1;
else
    rgbC = 3;
end

% Load NS-SFR data into cell array - sedmented into the Radial Distances
RadDist=zeros(rgbC,RDseg);
RadDist=num2cell(RadDist);
data=zeros(1,10);
data=num2cell(data);
for RGB = 1:rgbC
    for a=1:RDseg
        RadDist{RGB,a}=data;
    end
end
RadDistH=RadDist;
RadDistV=RadDist;

Zeroindx=zeros(rgbC,RDseg);
ZeroindxH=num2cell(Zeroindx);
data=zeros(1,1);
data=num2cell(data);
for RGB = 1:rgbC
    for a=1:RDseg
        ZeroindxH{RGB,a}=data;
    end
end
ZeroindxV=ZeroindxH;

% Horizontal and Vertical counter
h=zeros(rgbC,RDseg);
v=zeros(rgbC,RDseg);

RDindex=1/RDseg; 

for A=1:size(namesIndex,1)
    % If the partition label is true, use image
    if Labels(A)==1
        nameIndex=namesIndex(A,1);
        Load_Result=[path '/' nameIndex{1,1}];
%         pause(0.5);
%         MTF_Results = parload(Load_Result, 'MTF_Results');
        load(Load_Result, 'MTF_Results');
        % Horizontal
        for RGB = 1:size(MTF_Results,1)
            if RGB~=3 && RGB~=4
                rgb = RGB;
            elseif RGB==3
                rgb = 2; % Double Green Channel
            elseif RGB==4
                rgb = 3;
            end
            for B=1:size(MTF_Results{RGB, 4},1)
                if MTF_Results{RGB, 4}{B, 12} == 1 && ~isempty(MTF_Results{RGB, 4}{B, 11})
                    RD=MTF_Results{RGB, 4}{B, 10};
                    a=0;
                    b=RDindex;
                    for C=1:RDseg
                        if RD>=a && RD<b
                            h(rgb,C)=h(rgb,C)+1;
                            RadDistH{rgb, C}{h(rgb,C),1}=MTF_Results{RGB, 4}{B, 11}{1,1}; % NS-SFR
                            RadDistH{rgb, C}{h(rgb,C),2}=MTF_Results{RGB, 4}{B, 9}; % Boundary Box
                            RadDistH{rgb, C}{h(rgb,C),3}=MTF_Results{RGB, 4}{B, 4}; % Edge Angle
                            RadDistH{rgb, C}{h(rgb,C),4}=MTF_Results{RGB, 4}{B, 5}; % Edge Contrast
                            RadDistH{rgb, C}{h(rgb,C),5}=MTF_Results{RGB, 4}{B, 11}{1,2}; % ESF

                            RadDistH{rgb, C}{h(rgb,C),8}=MTF_Results{RGB, 4}{B, 2}; % ROI 
                            RadDistH{rgb, C}{h(rgb,C),9}=1;
                            RadDistH{rgb, C}{h(rgb,C),10}=RD;
                            % LSF Half Peak Width measure
                            LSFHPW=LSFfwhm(MTF_Results{RGB, 4}{B, 11}{1,2});
                            RadDistH{rgb, C}{h(rgb,C),6}=LSFHPW; % LSF width
                            % Check for zero ESF widths & remove - due to NAN grey 
                            % SFR or flat grey ESF
                            if LSFHPW==0
                                ZeroindxH{rgb,C}{h(rgb,C),1}=1;
                            else 
                                ZeroindxH{rgb,C}{h(rgb,C),1}=0;
                            end
                        end
                        a=a+RDindex;
                        b=b+RDindex;
                    end 
                end  
            end 
        end
        % Vertical
        for RGB = 1:size(MTF_Results,1)
            if RGB~=3 && RGB~=4
                rgb = RGB;
            elseif RGB==3
                rgb = 2; % Double Green Channel
            elseif RGB==4
                rgb = 3;
            end
            for B=1:size(MTF_Results{RGB, 5},1)
                if MTF_Results{RGB, 5}{B, 12} == 1 && ~isempty(MTF_Results{RGB, 5}{B, 11})
                    RD=MTF_Results{RGB, 5}{B, 10};
                    a=0;
                    b=RDindex;
                    for C=1:RDseg
                        if RD>=a && RD<b
                            v(rgb,C)=v(rgb,C)+1;
                            RadDistV{rgb, C}{v(rgb,C),1}=MTF_Results{RGB, 5}{B, 11}{1,1}; % NS-SFR
                            RadDistV{rgb, C}{v(rgb,C),2}=MTF_Results{RGB, 5}{B, 9}; % Boundary Box
                            RadDistV{rgb, C}{v(rgb,C),3}=MTF_Results{RGB, 5}{B, 4}; % Edge Angle
                            RadDistV{rgb, C}{v(rgb,C),4}=MTF_Results{RGB, 5}{B, 5}; % Edge Contrast
                            RadDistV{rgb, C}{v(rgb,C),5}=MTF_Results{RGB, 5}{B, 11}{1,2}; % ESF

                            RadDistV{rgb, C}{v(rgb,C),8}=MTF_Results{RGB, 5}{B, 2}; % ROI
                            RadDistV{rgb, C}{v(rgb,C),9}=1;
                            RadDistV{rgb, C}{v(rgb,C),10}=RD;
                            % LSF Half Peak Width measure
                            LSFHPW=LSFfwhm(MTF_Results{RGB, 5}{B, 11}{1,2});
                            RadDistV{rgb, C}{v(rgb,C),6}=LSFHPW; % LSF width
                            % Check for zero ESF widths & remove - due to NAN grey 
                            % SFR or flat grey ESF
                            if LSFHPW==0
                                ZeroindxV{rgb,C}{v(rgb,C),1}=1;
                            else 
                                ZeroindxV{rgb,C}{v(rgb,C),1}=0;
                            end
                        end
                        a=a+RDindex;
                        b=b+RDindex;
                    end 
                end
            end   
        end
    end
end
% Remove erros
for RGB = 1:rgbC
    for A=1:RDseg
        err=find([ZeroindxH{RGB,A}{:}]==1);
        emp=isempty(err);
        if emp==0
            ZeroindxH{RGB,A}(err,:)=[];
            RadDistH{RGB,A}(err,:)=[];
        end

        err=find([ZeroindxV{RGB,A}{:}]==1);
        emp=isempty(err);
        if emp==0
            ZeroindxV{RGB,A}(err,:)=[];
            RadDistV{RGB,A}(err,:)=[];
        end
    end
end
% Repeat for the results from the ISO test chart (passed through our
% framework)
% Horizontal
A=~isempty(ISO12233Charthv);
if A==1 
    ISOh=zeros(rgbC,RDseg);
    ISOv=zeros(rgbC,RDseg);
    ISORadDistH=RadDist;
    ISORadDistV=RadDist;
    for RGB = 1:size(ISO12233Charthv,1)
        if RGB~=3 && RGB~=4
            rgb = RGB;
        elseif RGB==3
            rgb = 2; % Double Green Channel
        elseif RGB==4
            rgb = 3;
        end
        for B=1:size(ISO12233Charthv{RGB, 4},1)
            if ISO12233Charthv{RGB, 4}{B, 12} == 1
                RD=ISO12233Charthv{RGB, 4}{B, 10};
                a=0;
                b=RDindex;
                for C=1:RDseg
                    if RD>=a && RD<b
                        ISOh(rgb,C)=ISOh(rgb,C)+1;
                        ISORadDistH{rgb, C}{ISOh(rgb,C),1}=ISO12233Charthv{RGB, 4}{B, 11}{1,1}; % NS-SFR
                        ISORadDistH{rgb, C}{ISOh(rgb,C),2}=ISO12233Charthv{RGB, 4}{B, 9}; % Boundary Box
                        ISORadDistH{rgb, C}{ISOh(rgb,C),3}=ISO12233Charthv{RGB, 4}{B, 4}; % Edge Angle
                        ISORadDistH{rgb, C}{ISOh(rgb,C),4}=ISO12233Charthv{RGB, 4}{B, 5}; % Edge Contrast
                        ISORadDistH{rgb, C}{ISOh(rgb,C),5}=ISO12233Charthv{RGB, 4}{B, 11}{1,2}; % ESF

                        ISORadDistH{rgb, C}{ISOh(rgb,C),7}=1;
                        ISORadDistH{rgb, C}{ISOh(rgb,C),8}=ISO12233Charthv{RGB, 4}{B, 1}; % ROI 
                        ISORadDistH{rgb, C}{ISOh(rgb,C),9}=1;
                        ISORadDistH{rgb, C}{ISOh(rgb,C),10}=RD;
                        % LSF Half Peak Width measure
                        LSFHPW=LSFfwhm(ISO12233Charthv{RGB, 4}{B, 11}{1,2});
                        ISORadDistH{rgb, C}{ISOh(rgb,C),6}=LSFHPW; % LSF width
                    end
                    a=a+RDindex;
                    b=b+RDindex;
                end
            end 
        end 

        % Vertical 
        for B=1:size(ISO12233Charthv{RGB, 5},1)
            if ISO12233Charthv{RGB, 5}{B, 12} == 1
                RD=ISO12233Charthv{RGB, 5}{B, 10}; 
                a=0;
                b=RDindex;
                for C=1:RDseg
                    if RD>=a && RD<b
                        ISOv(rgb,C)=ISOv(rgb,C)+1;
                        ISORadDistV{rgb, C}{ISOv(rgb,C),1}=ISO12233Charthv{RGB, 5}{B, 11}{1,1}; % NS-SFR
                        ISORadDistV{rgb, C}{ISOv(rgb,C),2}=ISO12233Charthv{RGB, 5}{B, 9}; % Boundary Box
                        ISORadDistV{rgb, C}{ISOv(rgb,C),3}=ISO12233Charthv{RGB, 5}{B, 4}; % Edge Angle
                        ISORadDistV{rgb, C}{ISOv(rgb,C),4}=ISO12233Charthv{RGB, 5}{B, 5}; % Edge Contrast
                        ISORadDistV{rgb, C}{ISOv(rgb,C),5}=ISO12233Charthv{RGB, 5}{B, 11}{1,2}; % ESF

                        ISORadDistV{rgb, C}{ISOv(rgb,C),7}=1;
                        ISORadDistV{rgb, C}{ISOv(rgb,C),8}=ISO12233Charthv{RGB, 5}{B, 1}; % ROI 
                        ISORadDistV{rgb, C}{ISOv(rgb,C),9}=1;
                        ISORadDistV{rgb, C}{ISOv(rgb,C),10}=RD;
                        % LSF Half Peak Width measure
                        LSFHPW=LSFfwhm(ISO12233Charthv{RGB, 5}{B, 11}{1,2});
                        ISORadDistV{rgb, C}{ISOv(rgb,C),6}=LSFHPW; % LSF width
                    end
                    a=a+RDindex;
                    b=b+RDindex;
                end
            end
        end
    end
else
    ISORadDistH=[];
    ISORadDistV=[];
end
% Saggital
A=~isempty(ISO12233Chartst);
if A==1 
    ISOh=zeros(rgbC,RDseg);
    ISOv=zeros(rgbC,RDseg);
    ISORadDistS=RadDist;
    ISORadDistT=RadDist;
    for RGB = 1:size(ISO12233Chartst,1)
        if RGB~=3 && RGB~=4
            rgb = RGB;
        elseif RGB==3
            rgb = 2; % Double Green Channel
        elseif RGB==4
            rgb = 3;
        end

        for B=1:size(ISO12233Chartst{RGB, 4},1)
            if ISO12233Chartst{RGB, 4}{B, 12} == 1
                RD=ISO12233Chartst{RGB, 4}{B, 10};
                a=0;
                b=RDindex;
                for C=1:RDseg
                    if RD>=a && RD<b
                        ISOh(rgb,C)=ISOh(rgb,C)+1;
                        ISORadDistS{rgb, C}{ISOh(rgb,C),1}=ISO12233Chartst{RGB, 4}{B, 11}{1,1}; % NS-SFR
                        ISORadDistS{rgb, C}{ISOh(rgb,C),2}=ISO12233Chartst{RGB, 4}{B, 9}; % Boundary Box
                        ISORadDistS{rgb, C}{ISOh(rgb,C),3}=ISO12233Chartst{RGB, 4}{B, 4}; % Edge Angle
                        ISORadDistS{rgb, C}{ISOh(rgb,C),4}=ISO12233Chartst{RGB, 4}{B, 5}; % Edge Contrast
                        ISORadDistS{rgb, C}{ISOh(rgb,C),5}=ISO12233Chartst{RGB, 4}{B, 11}{1,2}; % ESF

                        ISORadDistS{rgb, C}{ISOh(rgb,C),7}=1;
                        ISORadDistS{rgb, C}{ISOh(rgb,C),8}=ISO12233Chartst{RGB, 4}{B, 1}; % ROI 
                        ISORadDistS{rgb, C}{ISOh(rgb,C),9}=1;
                        ISORadDistS{rgb, C}{ISOh(rgb,C),10}=RD;
                        % LSF Half Peak Width measure
                        LSFHPW=LSFfwhm(ISO12233Chartst{RGB, 4}{B, 11}{1,2});
                        ISORadDistS{rgb, C}{ISOh(rgb,C),6}=LSFHPW; % LSF width
                    end
                    a=a+RDindex;
                    b=b+RDindex;
                end
            end 
        end 

        % Tangental  
        for B=1:size(ISO12233Chartst{RGB, 5},1)
            if ISO12233Chartst{RGB, 5}{B, 12} == 1
                RD=ISO12233Chartst{RGB, 5}{B, 10}; 
                a=0;
                b=RDindex;
                for C=1:RDseg
                    if RD>=a && RD<b
                        ISOv(rgb,C)=ISOv(rgb,C)+1;
                        ISORadDistT{rgb, C}{ISOv(rgb,C),1}=ISO12233Chartst{RGB, 5}{B, 11}{1,1}; % NS-SFR
                        ISORadDistT{rgb, C}{ISOv(rgb,C),2}=ISO12233Chartst{RGB, 5}{B, 9}; % Boundary Box
                        ISORadDistT{rgb, C}{ISOv(rgb,C),3}=ISO12233Chartst{RGB, 5}{B, 4}; % Edge Angle
                        ISORadDistT{rgb, C}{ISOv(rgb,C),4}=ISO12233Chartst{RGB, 5}{B, 5}; % Edge Contrast
                        ISORadDistT{rgb, C}{ISOv(rgb,C),5}=ISO12233Chartst{RGB, 5}{B, 11}{1,2}; % ESF

                        ISORadDistT{rgb, C}{ISOv(rgb,C),7}=1;
                        ISORadDistT{rgb, C}{ISOv(rgb,C),8}=ISO12233Chartst{RGB, 5}{B, 1}; % ROI 
                        ISORadDistT{rgb, C}{ISOv(rgb,C),9}=1;
                        ISORadDistT{rgb, C}{ISOv(rgb,C),10}=RD;
                        % LSF Half Peak Width measure
                        LSFHPW=LSFfwhm(ISO12233Chartst{RGB, 5}{B, 11}{1,2});
                        ISORadDistT{rgb, C}{ISOv(rgb,C),6}=LSFHPW; % LSF width
                    end
                    a=a+RDindex;
                    b=b+RDindex;
                end
            end
        end
    end
else
    ISORadDistS=[];
    ISORadDistT=[];
end

