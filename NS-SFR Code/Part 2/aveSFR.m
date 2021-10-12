function [avesfr, AveLSF]=aveSFR(ESF, RD, RAW)
% aveSFR takes a mean Spatial Frequency Response (SFR) through registering 
% the LSFs (from the supersampled ESFs) and then taking the modulas Fourier
% Transform of the mean LSF
%
% The SFR has been caculated using code from sfrmat4  
% (Copyright (c) Burns Digital Imaging, 2020. [Online]. 
% Available: http://burnsdigitalimaging.com/software/sfrmat/.)
% 
%
% Input: 
%       ESF       -    Cell Array of Edge Spread Functions (ESFs) to be 
%                      used and their corresponding radial distances. 
%                      The array should have column 1 being ESFs and column
%                      2 being the radial distance. 
%       RD        -    This the radial distance array. The number of
%                      elements in the array refers to the number of radial
%                      distance segments. Each element should be the
%                      weighting of the mean for that radial distance
%                      segment, e.g. splitting the frame into three parts,
%                      centure, partway and cornors with weightings of
%                      1.00, 0.75 and 0.50 respectively would be shown as
%                      [1, 0.75, 0.5]. The defult is RD=[1], i.e. no radial
%                      distance segmentation and no weighting
%       RAW       -    Is the data RAW, True=1, False=0. If True frequency
%                      is halfed.
% Output: 
%       avesfr    -    The output mean SFR
%       AveLSF    -    The output mean LSF
%
% 2020, O. van Zwanenberg
% UNIVERSITY OF WESTMINSTER 
%              - COMPUTATIONAL VISION AND IMAGING TECHNOLOGY RESEARCH GROUP
% Director of Studies:  S. Triantaphillidou
% Supervisory Team:     R. Jenkin & A. Psarrou

%--------------------------------------------------------------------------
switch nargin
    case 1
        RD=1; % Defult RD
        RAW = 0;
    case 2
        if size(RD,2)==1 && RD~=1
          disp('If there is only one Radial Segment (RD) then the weighting value should equal 1.00, i.e. RD=[1]');
        return   
        end
        RAW =0;
    case 3
        if size(RD,2)==1 && RD~=1
          disp('If there is only one Radial Segment (RD) then the weighting value should equal 1.00, i.e. RD=[1]');
        return   
        end
    otherwise
        disp('Incorrect number or arguments');
        return 
end
%--------------------------------------------------------------------------
% LSF Conversion - Adapted from sfrmat4 (Copyright (c) 2020 Peter D. Burns)
LSF=zeros(1,1);
Mid=LSF;
LSF=num2cell(LSF);
L=0;
a=0; 
Index=zeros(1,1);
for A=1:size(ESF,1)
    esf=ESF{A,1};
    if size(esf,1)>size(esf,2)
        esf=esf';
    end
    nn = length(esf); 
    if nn <10
        continue
    else
        a=a+1;
        Index(a,1)=A;
    end
    %%%%%%%%%%%%%%%%%%%%%%%
    fil = [0.5 0 -0.5];
    % We Need 'positive' edge
    tleft  = sum(esf(1:5));
    tright = sum(esf(nn-5:nn));
    if tleft>tright
        fil = [-0.5 0 0.5];
    end
    % c = deriv1(esf', 1, nn, fil2); 
    lsf = zeros(1, nn);
    lsf(1, :) = squeeze(conv(esf(1,:),fil,'same'));
    lsf(1,1) = lsf(1,2);
    lsf(1,nn) = lsf(1,nn-1);

    if lsf(1) == 0
       lsf(1) = lsf(2);
    elseif lsf(end) == 0
       lsf(end) = lsf(end-1);
    end 
    
    n = length(lsf);
    mid = find(lsf==max(lsf));
    %%%%%%%%%%%%%%%%%%%%%%%
    % win = ahamming(nn, mid);   
    win = zeros(n,1);
    mid = mid+0.5;

    wid1 = mid-1;
    wid2 = n-mid;
    wid = max(wid1, wid2);
    pie = pi;
    for i = 1:n
        arg = i-mid;
        win(i) = cos( pie*arg/(wid) );
    end 
    win = 0.54 + 0.46*win;
    %%%%%%%%%%%%%%%%%%%%%%%

    lsf = win.*lsf';  
    lsf = lsf';
    if max(lsf) ==0
        Index(a,1)=0;
        a=a-1;
        continue
    end
    l=length(lsf);
    if l>L
        L=l;
    end
    LSF{a,1}=lsf;
    Mid(a,1)=find(lsf==max(lsf));
end

% Register the LSFs
maxMid=max(Mid);
LSFrd=zeros(1,size(RD,2));
LSFrd=num2cell(LSFrd);
LSFreg=zeros(1,L+maxMid);
for A=1:size(RD,2)
    LSFrd{A,1}=LSFreg;
end
% RD increments
i=1/size(RD,2);
i1=0;
i2=i;
for A=1:size(RD,2)        
    l=0;
    for B=1:size(LSF,1)
        b = Index(B);
        if b~=0 && ESF{b,2}>=i1 && ESF{b,2}<i2
            l=l+1;
            m=Mid(B,1);
            dif=maxMid-m;
            if dif~=0
                ld=length(LSF{B,1})+(dif-1);
            else
                ld=length(LSF{B,1});
                dif=1;
            end
            % Normalise the Area of the LSFs
            lsf = LSF{B,1};
            if lsf==0
                l=l-1;
            else
                Area=trapz(1:size(lsf,2),lsf);
                normLSF=lsf./Area;
                LSFrd{A,1}(l,dif:ld)=normLSF;
            end
        end
    end
    i1=i1+i;
    i2=i2+i;
end

% Take the weighted mean LSF across all ditance segments
WeightedVals=zeros(size(RD,2),L+maxMid);

for A=1:size(RD,2)
    if size(LSFrd{A,1},1)~=1
        WeightedVals(A,:)=(mean(LSFrd{A,1}))*RD(A);
    else
        WeightedVals(A,:)=(LSFrd{A,1})*RD(A);
    end
end
MeanTotal=sum(RD);

if size(RD,2)==1 && RD==1
    AveLSF=WeightedVals;
else
    AveLSF=(sum(WeightedVals))/MeanTotal;
end

if ~isempty (AveLSF)

    % Take the SFR from the mean LSF (AveLSF) 
    %                - Adapted from sfrmat4 (Copyright (c) 2020 Peter D. Burns)

    % % % delfac = cos(atan(vslope));    
    % % % del = 1*delfac;  % input pixel sampling normal to the edge
    % % % del2 = del/4;   % Supersampling interval normal to edge
    del2=1/4; % (del/nbin)
    nn= length(AveLSF);% floor(npix *nbin);
    sfr =  zeros(nn, 1);
    nn2 =  floor(nn/2) + 1;
    % frequency 
    freq = zeros(nn, 1);
    for n=1:nn   
        freq(n) = (n-1)/(del2*nn);
    end
    if RAW==1
        freq=freq/2;
    end

    % [correct] = fir2fix(n, m);
    % Correction for MTF of derivative (difference) filter
     % dcorr corrects SFR for response of FIR filter
    dcorr = ones(nn2, 1);
    m=3-1;
    scale = 1;
    for i = 2:nn2
        dcorr(i) = abs((pi*i*m/(2*(nn2+1))) / sin(pi*i*m/(2*(nn2+1))));
        dcorr(i) = 1 + scale*(dcorr(i)-1);
      if dcorr(i) > 10  % Note limiting the correction to the range [1, 10]
        dcorr(i) = 10;
      end
    end

    % % % temp = abs(fft(AveLSF, nn));
    % % % sfr(1:nn2, 1) = temp(1:nn2)/temp(1);
    % % % sfr(1:nn2, 1) = sfr(1:nn2, 1).*dcorr;
    % % % if ~isempty(AveLSF)
    % % %     [sfr, err] = SFRconlim(AveLSF, freq, nn, dcorr);
    % % % else
    % % %     sfr=[];
    % % %     err=[];
    % % % end
    temp = abs(fft(AveLSF, nn));
    sfr(1:nn2, 1) = temp(1:nn2)/temp(1);
    sfr(1:nn2, 1) = sfr(1:nn2, 1).*dcorr(1:nn2);

    if ~isempty(sfr)
        uq=[0:0.01:0.51]';
        mq=interp1(freq, sfr, uq, 'pchip');
        avesfr(:,1)=uq;
        avesfr(:,2)=mq;
    %     avesfr(:,3)=abs(err);
    else
        avesfr=[];
    end
else 
    avesfr=[];
end  