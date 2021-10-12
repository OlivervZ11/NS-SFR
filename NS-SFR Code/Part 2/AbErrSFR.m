function [sysSFR]=AbErrSFR(sysSFR, ISOSFR)
% AbErrSFR caulates the Absolute Error between the estimated system SFR and
% the ISO SFR ground truth
%
% INPUT:
%   sysSFR  =   Cell array contraining the estimated system SFR per radial
%               distance
%   ISOSFR  =   The ISO SFR
% OUTPUT:
%   sysSFR  =   An updated Cell array contraining the estimated system SFR 
%               and the Absolute Error per radial distance
%
% O. van Zwanenberg (Sep. 2020)
% 
% UNIVERSITY OF WESTMINSTER 
%              - COMPUTATIONAL VISION AND IMAGING TECHNOLOGY RESEARCH GROUP
% Director of Studies:  S. Triantaphillidou
% Supervisory Team:     R. Jenkin & A. Psarrou

uq = [0:0.01:0.51]';
for A = 1:size(sysSFR,2)
    % ISO data
    if isempty(ISOSFR{1, A})
        Mq1 = [];
    else
        u1  = ISOSFR{1, A}(:,1);
        M1  = ISOSFR{1, A}(:,2);
        Mq1 = interp1(u1, M1, uq, 'pchip');
    end
    % NSSFR
    if isempty(sysSFR{1, A})
        Mq2 = [];
    elseif sysSFR{1, A}(1,2)==0
        Mq2 = [];
    else
        u2  = sysSFR{1, A}(:,1);
        M2  = sysSFR{1, A}(:,2);
        Mq2 = interp1(u2, M2, uq, 'pchip');
    end
    
    if isempty(Mq1) || isempty(Mq2)
        sysSFR{3,A} = [];
    else
        AE  = abs(Mq1-Mq2);
        sysSFR{3,A} = uq;
        sysSFR{3,A}(:,2) = AE;
    end
end