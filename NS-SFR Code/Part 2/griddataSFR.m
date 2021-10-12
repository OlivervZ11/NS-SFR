function [Mq, sysSFR, Mdata] = griddataSFR(Mdata, ... 
    Angq, Conq, ROIhq, sysPar, AveW, iso, raw)
%    griddataSFR perfoms a two/three-dimensional interpolation of the 
%    NS-SFR data across the parameters Angle, Contrast and ROI height.
%    Producing a LUT of NS-SFRs at each parameter combination. Values 
%    outside the input parameter boundaries will be a NaN value. 
%    Co-ordinates with multible NS-SFR values will be averaged in the 
%    spatial domain, i.e. the LSFs will be registered and averaged, then 
%    the NS-SFR is caculated code adapted from sfrmat4 (Copyright (c) Burns  
%    Digital Imaging, 2020. Available at:
%    http://burnsdigitalimaging.com/software/sfrmat/. )
%    The NS-SFRs in the with the set parameter ranges are averaged in the
%    spatial domain to estimate the system SFR (sysSFR). 
%
% INPUT
%   Mdata    =    Cell Array containing the NS-SFR data, Edge Angle,
%                 Contrast, ROI height and ESF, this data is segmented per
%                 radial distance
%   Angq     =    The desired Edge Angle coordinates (created by ndgrid)
%   Conq     =    The desired Edge Contrast coordinates (created by ndgrid)
%   ROIhq    =    The desired ROI height coordinates (created by ndgrid)
%   sysPar   =    The parameters that used to measure sysSFR 
%                 [min Angle, max Angle; min Contrast, max Contrast; 
%                 min ROI height, max ROI height] (optional)
%                 Defult: sysPar=[2, 30; 0.55, 0.65; 120, 130];
%   AveW     =    The averaging weights for overall weighted mean sys-SFR 
%                 estimation. The number of values in array dictate number
%                 of radial distance segments, this number cannot exceed
%                 the radial distance segments within Mdata. Each values is  
%                 the weigting value for that perticular radial distance 
%                 segments (optional)
%                 Defult: AveW = [1.00, 0.75, 0.50] - three radial distance
%                 segments (Centure, Partway, Cornors) weighted 1.00, 0.75
%                 and 0.50 respectively
%   iso      =    Is the data from ISO12233 test chart, True=1, False=0
%   raw      =    Is the data RAW, True=1, False=0
%
% OUTPUT        
%   Mq       =    A Cell Array containing the interpolated NS-SFR LUTs
%                 segmented by spatial frequency and radial distance
%                 (Frequency increments = [[0:0.0333:0.5328]])
%   sysSFR   =    The system SFR estimation averaged (in the spatial
%                 domain) using sysPar
%   Mdata    =    Updated input Cell Array 
%
% Copyright (c) 2020 O. van Zwanenberg
% UNIVERSITY OF WESTMINSTER 
%              - COMPUTATIONAL VISION AND IMAGING TECHNOLOGY RESEARCH GROUP
% Director of Studies:  S. Triantaphillidou
% Supervisory Team:     R. Jenkin & A. Psarrou

% Set sysPar if variable does not exist
if exist('sysPar','var') == 0
    sysPar=[2     , 30    ; 0.55  , 0.65  ; 120    , 130    ];
    %      [minAng, maxAng; minCon, maxCon; minROIh, maxROIh];
end

% Set AveW if variable does not exist
if exist('AveW','var') == 0
    AveW=[1.00, 0.75, 0.50];
    %    [Cen , Ptwy, Cor ];
end

% Determin if ROIhq is empty
ROIhemp=isempty(ROIhq);

% Obtain the parameter increments
AngPar=(min(min(min(Angq)))):Angq(2,1,1):(max(max(max(Angq))));
ConPar=(min(min(min(Conq)))):Conq(1,2,1):(max(max(max(Conq))));
if ROIhemp==0
    ROIPar=(min(min(min(ROIhq)))):ROIhq(1,1,2)-ROIhq(1,1,1):(max(max(max(ROIhq))));
end

% Set the Cell Array up to fill with the data
Mq=cell(51,size(Mdata,2));

sysSFR=cell(4, (size(Mdata,2)+1));

ESF=zeros(1, (size(Mdata,2)));
ESF=num2cell(ESF);
EP=ESF;
E=0;
% For loop for each radial distance
rd=size(Mdata, 2);

% Obtain all combinations of values
if ROIhemp==1
     points=[Angq(:), Conq(:)];
else
    points=[Angq(:), Conq(:), ROIhq(:)];
end

% Set up AveLSF cell array
AveLSF = cell(1,rd+1); 

for RD=1:rd
    err = 0;
    % Coordinate cell array
    CO = NaN(size(Angq));
    CO = num2cell(CO);
    for A=1:size(Mdata{1,RD},1)
        if Mdata{1,RD}{A,7}==1
            err=err+1;
            % Extract the parameters from Mdata and round to closest
            % interger
            ang=interp1(AngPar,AngPar,abs(Mdata{1,RD}{A,3}),'nearest','extrap');
            con=interp1(ConPar,ConPar,Mdata{1,RD}{A,4},'nearest','extrap');
            if ROIhemp==0
                roih=interp1(ROIPar,ROIPar,Mdata{1,RD}{A,2}(1,4),'nearest','extrap');
            end
            
            % The index where all three desired values are true
            if ROIhemp==1
                Ia=find(points(:,1)==ang);
                Ic=find(points(:,2)==con);
                % Find coordinate index for these values
                Index=intersect(Ia,Ic);
            else
                Ia=find(points(:,1)==ang);
                Ic=find(points(:,2)==con);
                Ir=find(points(:,3)==roih);
                % Find coordinate index for these values
                Index=(intersect(intersect(Ia,Ic),Ir));
            end
            % Place the Mdata index number (A) into CO
            if isnan(CO{Index})
                CO{Index}=A;
            else
                % Add to previous
                pre=CO{Index};
                i=size(pre,2);
                pre(1,i+1)=A;
                CO{Index}=pre;
            end
        end
    end
    
    % If no data moce to next RD
    if err==0
        sysSFR{1,RD}=[];
        sysSFR{2,RD}=[];
        ESF{1,RD}=[];
        EP{1,RD}=[];
        continue
    end
    
    % Run through CO, select the NS-SFR data, interpolate it to the 51
    % spatal frequency incroments and save into the 51 arrays
    % If multible NS-SFRs obtain the same coordinate, their LSFs are
    % averaged and the average NS-SFR caulated.
    
    uq=[0:0.01:0.5]';
    
    % Create LUT arrays for each spatal frequency incroment for the SFR
    COu01 = NaN(size(Angq));
    COu   = cell(size(uq,1), 1);
    COuerr= COu;
    for U = 1:size(uq,1)
       COu{U,1} = COu01;
       % Create LUT arrays for each spatal frequency incroment for the error
       COuerr{U,1} = COu01;
    end
    
    % Set up AveLSF cell array
    aveLSF = cell(1,6); 
    
    for C=1:size(CO,3)
        for B=1:size(CO,2)
            for A=1:size(CO,1)
                i=CO{A,B,C};
                if isnan(i)
                    continue
                end
                if size(i,2)>1
                    esf=zeros(size(i,2),2);
                    esf=num2cell(esf);
                    for D=1:size(i,2)
                        esf{D,1}=Mdata{1, RD}{i(1,D), 5}';
                        esf{D,2}=Mdata{1, RD}{i(1,D), 10};
                    end
                    [avesfr, aveLSF{1,RD}]=aveSFR(esf, 1, raw);
                    if isempty(avesfr)
                        mq = NaN(size(uq,1),1);
                        errLim = mq;
                    else
                        m=avesfr(:,2);
                        u=avesfr(:,1);
                        mq=interp1(u, m, uq, 'pchip');
%                         errLim=interp1(u, abs(avesfr(:,3)), uq, 'pchip');
                    end
                else
                    sfr=Mdata{1, RD}{i, 1};
                    % Mistake in error code - correcttion
                    if ~isempty(sfr) && isnan(sfr(1,(size(sfr,2)))) 
                        roi=Mdata{1, RD}{i, 8};
                        [~, dat1, ~, ~, ~, ~, ~, ~, ~, ~] = sfrmat4(1, 1, 3, [.299, .587, .114], roi, 1);
                        Mdata{1, RD}{i, 1}=dat1;
                        sfr=dat1;
                    end
                    if isempty(sfr)
                        mq = NaN(size(uq,1),1);
                        errLim = mq;
                    else
                        m=sfr(:,(size(sfr,2)));
%                         m=sfr(:,(size(sfr,2)-1)); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if raw==1
                            % half frequecy to correct for CFA 
                            u=(sfr(:,1)/2); 
                        else
                            u=sfr(:,1);
                        end
                        mq=interp1(u, m, uq, 'pchip');
%                         errLim=interp1(u, abs(sfr(:,(size(sfr,2)))), uq, 'pchip');
                    end
                end
                 
                for U = 1:size(uq,1)
                   COu{U,1}(A,B,C)    = mq(U,1);
%                    COuerr{U,1}(A,B,C) = errLim(U,1);
                end
            end
        end
    end
    % Interplate the data using scatteredInterpolant
   if sum(sum(~isnan(COu{12, 1})))>1 % interopate if number of points is greater than 1
    if ROIhemp==1 
        for U = 1:size(uq,1)
            % SFR LUT
            I=~isnan(COu{U,1});
            F=scatteredInterpolant(Angq(I),Conq(I), COu{U,1}(I),...
                'linear','none');
            if ~isempty(F(Angq,Conq))
                COu{U,1} = F(Angq,Conq);
            end
%             % Error LUT
%             I=~isnan(COuerr{U,1});
%             F=scatteredInterpolant(Angq(I),Conq(I), COuerr{U,1}(I),...
%                 'linear','none');
%             COuerr{U,1} = F(Angq, Conq);
        end
    else
        for U = 1:size(uq,1)
            % SFR LUT
            I=~isnan(COu{U,1});
            F=scatteredInterpolant(Angq(I),Conq(I),ROIhq(I),COu{U,1}(I),...
                'linear','none');
            if ~isempty(F(Angq,Conq))
                COu{U,1} = F(Angq, Conq, ROIhq);
            end
%             % Error LUT
%             I=~isnan(COuerr{U,1});
%             F=scatteredInterpolant(Angq(I),Conq(I),ROIhq(I),COuerr{U,1}(I),...
%                 'linear','none');
%             COuerr{U,1} = F(Angq, Conq, ROIhq);
        end
    end
   end
    % Add to Mq
    for U = 1:size(uq,1)
        % SFR
        Mq{U,RD}=COu{U,1};
%         % Positive confidence limits
%         Mq{2,1}{U,RD}=COu{U,1}+COuerr{U,1};
%         % Negative confidence limits
%         Mq{3,1}{U,RD}=COu{U,1}-COuerr{U,1};
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%% Estimate the system SFR %%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Take the coordinates that are within the dersired ISO12233 boundaries,
    % defined by sysPar
    
    if ROIhemp==1 && iso==1 
        I=zeros(size(CO));
        for A=1:size(CO,1)
            for B=1:size(CO,2)
                i=CO{A,B};
                inan=isnan(i);
                if inan==0
                    I(A,B)=1;
                end
            end
        end
        Index=find(I==1);
    elseif ROIhemp==1 && iso==0
        Ia=find(points(:,1)>=sysPar(1,1) & points(:,1)<=sysPar(1,2));
        Ic=find(points(:,2)>=sysPar(2,1) & points(:,2)<=sysPar(2,2));
        % Find coordinate index for these values
        Index=(intersect(Ia,Ic));
    elseif ROIhemp==0 && iso==0
        Ia=find(points(:,1)>=sysPar(1,1) & points(:,1)<=sysPar(1,2));
        Ic=find(points(:,2)>=sysPar(2,1) & points(:,2)<=sysPar(2,2));
        Ir=find(points(:,3)>=sysPar(3,1) & points(:,3)<=sysPar(3,2));
        % Find coordinate index for these values
        Index=(intersect(intersect(Ia,Ic),Ir));
    end
    
    % List all ESFs that come under these coordinates
    esf=zeros(1, 2);
    esf=num2cell(esf);
    e=1;
    ep=zeros(1, 3);
    for A=1:size(Index,1)
        i=CO{Index(A)};
        if ~isnan(i)
            if size(i,2)>1
                for D=1:size(i,2)
                    esf{e+(D-1),1}=Mdata{1, RD}{i(1,D), 5}';
                    esf{e+(D-1),2}=Mdata{1, RD}{i(1,D), 10}; 
                    ep(e+(D-1),1) =Mdata{1, RD}{i(1,D), 3}; 
                    ep(e+(D-1),2) =Mdata{1, RD}{i(1,D), 4}; 
                    ep(e+(D-1),3) =Mdata{1, RD}{i(1,D), 2}(1,4); 
                end
                e=e+D;
            else
                esf{e,1}=Mdata{1, RD}{i, 5}';
                esf{e,2}=Mdata{1, RD}{i, 10}; 
                ep(e,1) =Mdata{1, RD}{i, 3}; 
                ep(e,2) =Mdata{1, RD}{i, 4}; 
                ep(e,3) =Mdata{1, RD}{i, 2}(1,4); 
                e=e+1;
            end
        else
            continue
        end
    end
    if esf{1} ==0
        sysSFR{1,RD}=[];
        sysSFR{2,RD}=[];
        ESF{1,RD}=[];
        EP{1,RD}=[];
    else
        E=E+e;
        [sysSFR{1,RD}, AveLSF{1,RD}]=aveSFR(esf, 1, raw);
        Aveep(1,1)=mean(abs(ep(:,1)));
        Aveep(1,2)=mean(ep(:,2));
        Aveep(1,3)=mean(ep(:,3));
        sysSFR{2,RD}=Aveep;
        ESF{1,RD}=esf;
        EP{1,RD}=ep;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Take a Weigted Mean sys-SFR estimation %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if no edges detect Retern
if E==0
    return
end

Mid = zeros(rd,1);
Len = zeros(rd,1);
for RD=1:rd
    if isempty(AveLSF{1,RD})
        Mid(RD,1)=NaN;
        Len(RD,1)=NaN;
        continue
    end
    Mid(RD,1)=find(AveLSF{1,RD}==max(AveLSF{1,RD}));
    Len(RD,1)=size(AveLSF{1,RD},2);
end

% Find max length
[MaxLen, inxL] = max(Len);
[maxMid, inxM] = max(Mid);
if inxL~=inxM
    m=Mid(inxL,1);
    dif=maxMid-m;
    MaxLen=MaxLen+dif;
end

% Intervals of the Radial distances
int = 1/rd;
I = zeros(1,rd);
for RD=1:rd
    I(1,RD)=int*RD;
end

% Register the LSFs
% maxMid=max(Mid);
LSFrd=zeros(size(AveW,2),1);
LSFrd=num2cell(LSFrd);
LSFreg=zeros(1,MaxLen);
for A=1:size(AveW,2)
    LSFrd{A,1}=LSFreg;
end
% AveW increments
i=1/size(AveW,2);
i1=0;
i2=i;
for A=1:size(AveW,2)        
    l=0;
    for B=1:size(AveLSF,2)-1
        if  I(1,B)>i1 && I(1,B)<=i2
            l=l+1;
            m=Mid(B,1);
            if isnan(m)
                l=l-1;
                continue
            end
            dif=maxMid-m;
            ld=MaxLen;
            if dif~=0
%                 ld=length(AveLSF{1,B})+(dif-1);
%                 if ld>MaxLen
% %                     MaxLen=ld;
%                 end
            else
%                 ld=length(AveLSF{1,B});
                dif=1;
            end
            % Normalise the Area of the LSFs
            lsf = AveLSF{1,B};
            if lsf==0 
                l=l-1;
            else
                Area=trapz(1:size(lsf,2),lsf);
                normLSF=lsf./Area;
                LSFrd{A,1}(l,dif+1:length(normLSF))=normLSF(1:length(normLSF)-dif);
            end
        end
    end
    i1=i1+i;
    i2=i2+i;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Take the weighted mean LSF across all ditance segments
WeightedVals=zeros(size(AveW,2),MaxLen);

for A=1:size(AveW,2)  
    if size(LSFrd{A,1},1)~=1
        WeightedVals(A,1:(size(LSFrd{A,1},2)))=(mean(LSFrd{A,1}))*AveW(A);
    else
        WeightedVals(A,:)=(LSFrd{A,1}).*AveW(A);
    end
end
MeanTotal=sum(AveW);

if size(AveW,2)==1 && AveW==1
    fAveLSF=WeightedVals;
else
    fAveLSF=(sum(WeightedVals))/MeanTotal;
end

AveLSF{1,rd+1} = fAveLSF;

% Take the SFR from the mean LSF (fAveLSF) 
%                - Adapted from sfrmat4 (Copyright (c) 2020 Peter D. Burns)

% % % delfac = cos(atan(vslope));    
% % % del = 1*delfac;  % input pixel sampling normal to the edge
% % % del2 = del/4;   % Supersampling interval normal to edge
del2=1/4; % (del/nbin)
nn= length(fAveLSF);% floor(npix *nbin);
sfr =  zeros(nn, 1);
nn2 =  floor(nn/2) + 1;
% frequency 
freq = zeros(nn, 1);
for n=1:nn   
    freq(n) = (n-1)/(del2*nn);
end
if raw==1
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
if ~isempty(fAveLSF)
    temp = abs(fft(fAveLSF, nn));
    sfr(1:nn2, 1) = temp(1:nn2)/temp(1);
    sfr(1:nn2, 1) = sfr(1:nn2, 1).*dcorr(1:nn2);
% % %     [sfr, err] = SFRconlim(fAveLSF, freq, nn, dcorr);
else
    sfr=[];
%     err=[];
end
if ~isempty(sfr)
    uq=[0:0.01:0.51]';
    mq=interp1(freq, sfr, uq, 'pchip');
    Favesfr(:,1)=uq;
    Favesfr(:,2)=mq;
%     Favesfr(:,3)=abs(err);
else
    Favesfr=[];
end
 sysSFR{1,rd+1} = Favesfr;
 
% Weighted Average edge peramteres
i=1/size(AveW,2);
i1=0;
i2=i;
allEP = zeros(rd,4);
for A=1:size(AveW,2)        
    for B=1:(size(AveLSF,2)-1)
        if isempty(sysSFR{2,B})
            allEP(B, 1) = NaN;
            allEP(B, 2) = NaN;
            allEP(B, 3) = NaN;
            allEP(B, 4) = NaN;
            continue
        end
        if  I(1,B)>i1 && I(1,B)<=i2
            allEP(B, 1) = sysSFR{2,B}(1,1)*AveW(1,A);
            allEP(B, 2) = sysSFR{2,B}(1,2)*AveW(1,A);
            allEP(B, 3) = sysSFR{2,B}(1,3)*AveW(1,A);
            allEP(B, 4) = AveW(1,A);
        end
    end
    i1=i1+i;
    i2=i2+i;
end
Wsum=nansum(allEP(:,4));
Aveallep(1,1)=(nansum(allEP(:,1)))/Wsum;
Aveallep(1,2)=(nansum(allEP(:,2)))/Wsum;
Aveallep(1,3)=(nansum(allEP(:,3)))/Wsum;
sysSFR{2,rd+1}=Aveallep;

sysSFR(4, :) = AveLSF;
end 