function [sfrstd] = SFRstd(Mdata, sysPar, TC)
% SFRstd caculates the standard deviation of the e-SFR/NS-SFR enverlope
%    
% INPUT
%   Mdata    =    Cell Array containing the e-SFR/NS-SFR data
%   sysPar   =    The edge and ROI parameter ranges  that sys e-SFR is 
%                 estimated from
%   TC       =    Is Test Chart, 1=True, 0=False 
%
% OUTPUT 
%   sfrstd   =    The standard deviation of the SFR envelope for each 
%                 radial diostance and the entire frame  
%
% 2021, O. van Zwanenberg
% UNIVERSITY OF WESTMINSTER 
%              - COMPUTATIONAL VISION AND IMAGING TECHNOLOGY RESEARCH GROUP
% Director of Studies:  S. Triantaphillidou
% Supervisory Team:     R. Jenkin & A. Psarrou

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PROCESS DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[rgb, rd] = size(Mdata);
if TC==1
    rgb=1;
end
sfrstd = cell(rgb, rd+1);
uq=[0:0.01:0.51]';
for RGB=1:rgb
    Alldat=NaN(52, 1);
    ad=0;
    for RD=1:rd
            sfrs = NaN(52, 1);
            b=0;
            for B = 1:size(Mdata{RGB,RD},1)
                if Mdata{RGB, RD}{B, 7}==1 
                    if TC==0
                        if abs(Mdata{RGB, RD}{B, 3})<=sysPar(1,1) ||... %Min Ang
                        abs(Mdata{RGB, RD}{B, 3})>=sysPar(1,2) || ... %Max Ang 
                        Mdata{RGB, RD}{B, 4}<=sysPar(2,1) || ... %Min Con
                        Mdata{RGB, RD}{B, 4}>=sysPar(2,2) %Max Con
%                         Mdata{1, RD}{B, 2}(1,4)>=sysPar(2,1) %Min height
                            continue
                        end
                    end
                    dat = Mdata{RGB, RD}{B, 1};
                    if isempty(dat)
                        continue
                    end
                    ad=ad+1;
                    b=b+1;
%                     if TC==1
%                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         m=dat(:,(size(dat,2)-1));
%                     else
                        m=dat(:,(size(dat,2)));
%                     end
                    u=dat(:,1);
                    sfrs(:,b)=interp1(u, m, uq, 'pchip');
                    Alldat(:,ad)=sfrs(:,b);
                else
                    continue
                end    
            end
            if sum(~isnan(sfrs))~=0
                sfrs2=rmmissing(sfrs);
                s = std(sfrs2,0,2);
                Dat(:,1)=uq;
                Dat(:,2)=s;
                sfrstd{RGB, RD} = Dat;
            end
    end
    % Total 
    Alldat2=rmmissing(Alldat);
    s = std(Alldat2,0,2);
    if isempty(s)
        continue
    end
    Dat(:,1)=uq;
    Dat(:,2)=s;
    sfrstd{RGB, rd+1} = Dat;
end