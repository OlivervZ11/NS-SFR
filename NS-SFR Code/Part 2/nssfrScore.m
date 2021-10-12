function [RadDist, NumData]=nssfrScore(RadDist, RDseg, NumData, O, Percentile, Percentile2)
% NSSFRSCORE rates the nssfrs according to the measured LSF FWHM
% 
% One or two Percentile Thresholds are used for this, all data that is
% above or inbetween these thresholds are marked with 1, otherwise 0
%
% INPUT:
%   RadDist         -       Cell array cotraining the divided NS-SFR data,
%                           edge perameters and the LSF Half Peak Width
%   RDseg           -       The number of radial segments ('Dohnuts')
%   NumData         -       The Array containing the number of usable ROIs
%   O               -       Orientation, 2 = Horizontal, 3 = Vertical
%   Percentile      -       The Percentile used as threshold
%   Percentile2     -       A second optional percentile threshold, in
%                           unrequired use [].
%
% OUTPUT:
%   RadDist         -       Cell array cotraining the rated NS-SFR data
%   NumData         -       The Array containing the number of usable ROIs
%
% O. van Zwanenberg (June. 2020)
% 
% UNIVERSITY OF WESTMINSTER 
%              - COMPUTATIONAL VISION AND IMAGING TECHNOLOGY RESEARCH GROUP
% Director of Studies:  S. Triantaphillidou
% Supervisory Team:     R. Jenkin & A. Psarrou

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for A=1:RDseg
    if size(RadDist{1,A},1)>1
        grads=zeros(size(RadDist{1,A},1),1);
        for B=1:size(RadDist{1,A},1)
            if isempty(RadDist{1,A}{B,6})
                continue
            end
            grads(B,1)=RadDist{1,A}{B,6};
        end
        p = sort(grads,'descend');
        p(p==0) = [];
        if size(p,1)<=1  
            emp3 = isempty(RadDist{1,A});
            if emp3==0 && sum(RadDist{1,A}{1,1}(:))~=0
                dat=RadDist{1,A}{1,1};
                val=dat(1,(size(dat,2)-1));
                emp2=isnan(val);
                if emp2==1
                    RadDist{1,A}{1,7}=0;
                    Num = 0;
                else
                    RadDist{1,A}{1,7}=1;
                    Num=1;
                end
            else
                RadDist{1,A}{1,7}=0;
                Num = 0;
            end
            continue
        end
        %Caculate a normal distribution that matches the Width distribution
        x=0:1:max(p);
        pd = fitdist(p,'Weibull');
        y=pdf(pd,x);

        P=prctile(p,Percentile);

        emp=isempty(Percentile2);
        if emp==0
            P2=prctile(p,Percentile2); 
        end
    %     s=2;
        Num=0;
    %     lobe=zeros(size(RadDist{1,A},1), 2);

        for B=1:size(RadDist{1,A},1)
            if ~isempty(RadDist{1,A}{B,1})
                if RadDist{1, A}{B, 9}==1  
                    if emp==1
                        if RadDist{1,A}{B,6}<=P
                            dat=RadDist{1,A}{B,1};
                            val=dat(1,(size(dat,2)-1));
                            emp2=isnan(val);
                            if emp2==1
                                RadDist{1,A}{B,7}=0;
                                continue;
                            else
                                RadDist{1,A}{B,7}=1;
                                Num=Num+1;
                            end
            %                 datI=interpsfr(dat);
            %                 SharpDatH{1,A}(:,s)=datI(:,2);
            %                 s=s+1;
                        else
                            RadDist{1,A}{B,7}=0;
                        end
                    elseif emp==0
                        if RadDist{1,A}{B,6}>=P && RadDist{1,A}{B,6}<=P2
                            dat=RadDist{1,A}{B,1};
                            val=dat(1,(size(dat,2)-1));
                            emp2=isnan(val);
                            if emp2==1
                                RadDist{1,A}{B,7}=0;
                                continue;
                            else
                                RadDist{1,A}{B,7}=1;
                                Num=Num+1;
                            end
            %                 datI=interpsfr(dat);
            %                 SharpDatH{1,A}(:,s)=datI(:,2);
            %                 s=s+1;
                        else
                            RadDist{1,A}{B,7}=0;
                        end
                    end
                end
            end
        end
    elseif size(RadDist{1,A},1)<=1  
        emp3 = isempty(RadDist{1,A});
        if emp3==0 && sum(RadDist{1,A}{1,1}(:))~=0
            dat=RadDist{1,A}{1,1};
            val=dat(1,(size(dat,2)-1));
            emp2=isnan(val);
            if emp2==1
                RadDist{1,A}{1,7}=0;
                Num = 0;
            else
                RadDist{1,A}{1,7}=1;
                Num=1;
            end
        else
            RadDist{1,A}{1,7}=0;
            Num = 0;
        end
    end
    NumData(A,O)=Num;
end