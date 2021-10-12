function [ROIs, perctile, errors]=nssfr(ROIs, errors)
% NSSFR is a function that takes the predetermined isolated ROIs from 
% natural scenes and caculated the 'Natural-Scene derived SFR' (i.e. NS-SFR)
% This has been acived by impleneting P. Burns sfrmat4 MATLAB code 
% (Burns Digital Imaging, 2019. [Online]. 
% Available: http://burnsdigitalimaging.com/software/sfrmat/.)
%
% Input:
%   ROIs        -        The cell array containing the ROI data for a
%                        particular orientation (i.e. horizontal or 
%                        vertical)
%   errors      -        Continuation of errors (or start at 0)
% Output: 
%   ROIs        -        The same input cell array, but now with the NS-SFR
%                        data
%   prctile     -        The 5th and 95th Percentiles of the NS-SFR data
%   errors      -        The count of errors from sfrmat4 - sfrmat4 is 
%                        designed for ideal ROI from test charts, when the
%                        ROIs come from images of natural scenes they may 
%                        contain artifacts that cause errors within 
%                        sframt4, thus sfrmat4 has been adjusted at the 
%                        points of error  to stop and give an error for 
%                        such a ROI.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% ----- CALCULATE MTFs ----- %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
for A=1:length(ROIs(:,1))
    if ROIs{A,12}==1
        roi=ROIs{A,2};
        [~, dat, ~, ~, esf, ~, ~, Con, Angle, Clip] = sfrmat4(1, 1, 3, [.299, .587, .114], roi, A);
        empdat=isempty(dat);
        BadMTF=[];
        % Add the Edge Parameters
        ROIs{A, 5}=Con;
        ROIs{A, 4}=Angle;
        ROIs{A, 6}=Clip;
        if Clip==1
            ROIs{A, 12}=2;
        end
        if empdat==1
            ROIs{A, 12}=3;
            ROIs{A, 11}=[];
            errors=errors+1;
        else
            %Data Fitting - Remove noisy SFRs
            u=dat(:,1);
            NFu=find(u<0.5);
            u=u(NFu,1);
            M=dat(NFu,(size(dat,2)-1));
            % Fitting 4th Order Polynomial
            p = polyfit(u,M,4);
            f = polyval(p,u);
            %Fitting Error
            FE=abs(M-f);
            BadMTF=find(FE>0.1); % Fitting Thresh
            emp=isempty(BadMTF);
            if emp==1
                Dat=zeros(1,2);
                Dat=num2cell(Dat);
                Dat{1,1}=dat;
                Dat{1,2}=esf;
                ROIs{A, 11}=Dat;
            else
                ROIs{A, 12}=5;    
                ROIs{A, 11}=[];
            end  
        end
    else 
         ROIs{A, 11}=[];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% ----- 5th & 95th PERCENTILE ----- %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Horizontal
% Interp Data
uq=[0:0.0333:0.5328]';
Mq=[];
perctile(:,1)=uq;
a=length(ROIs(:,1));
j=0;
for A=1:a
    if ROIs{A,12}==1
        dat=ROIs{A,11}{1,1};
        u=dat(:,1);
        M=dat(:,(size(dat,2)-1));
        n=isnan(M(1,1));
        if n==1
            j=j+1;
        else
            Mq(:,(A-j))=interp1(u, M, uq, 'pchip');
        end
    else       
        j=j+1;
    end
end

emp=isempty(Mq);
if emp==0
    for k=1:17
        dataVals=Mq(k,:);
        dataVals=sort(dataVals);
        K05 = prctile(dataVals,5);
        K95 = prctile(dataVals,95);
        perctile(k,2)=K05;
        perctile(k,3)=K95;
    end
else
    perctile=[];
end