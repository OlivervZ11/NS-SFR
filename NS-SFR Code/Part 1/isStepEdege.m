function [StepEdge]=isStepEdege(ROI, NL, SEnum, Mask)
% isStepEdege (Confirmation Step-Edge) confirms if the edge within the masked 
% area of the ROI is infact a step edge. This is achived via taking the 
% gradient at each row. 
%
% Input:
%   ROI:        The Region of Interest, a crop of a edge from the image. 
%   NL:         (Optional) Noise Level threshold, the threshold for noise  
%               (0-1), defult = 0.02 (aprox 5 pixel values for a 8-bit 
%               image).
%   SEnum:      (Optional) Number of confirmed Step-Edges (a % of the hight 
%               of the ROI, decribed as  a value between 0-1). Defult is 
%               0.75 (75%).
%   Mask:       (Optional) A binay image indecating where the edge 
%               transition is located.
%
% Output:
%   StepEdge:   Either 1 or 0, where 1 is confimation of a step edge and 0
%               is not. 
%
% Copyright (c) 2019 O. van Zwanenberg, University of Westminster

switch nargin
    case 1
        [m,n,~]=size(ROI);
        NL=0.02;
        SEnum=0.75;
        Mask=(zeros(m,n)+1);
        Mask=imbinarize(Mask);
    case 2
        [m,n,~]=size(ROI);
        SEnum=0.75;
        Mask=(zeros(m,n)+1);
        Mask=imbinarize(Mask);
    case 3
        [m,n,~]=size(ROI);
        Mask=(zeros(m,n)+1);
        Mask=imbinarize(Mask);
    case 4
        [m,n,~]=size(ROI);
    otherwise
     disp('Incorrect number or arguments. There should be 1 -4');
     return 
end

% Determin if Mask and ROI is the same size
[mm,nm]=size(Mask);
if m~=mm || n~=nm
    disp('The Region of Interest and Mask must be the same size');
     return 
end

% Measutre the Row gradients
ROI=rgb2gray(ROI);
ROI=im2double(ROI);
% [~,grad] = gradient(ROI);

%Add a de-noising to assist in the Step-Edge determination
% ROI= wiener2(ROI);

% Step Edge yes/no array
stepedge=zeros(1,m);

% Take each row of the ROI gradient where the the mask = 1. 
for M=1:m
    % Take masked row
    Maskarea = Mask(M,:);
%     Maskarea=imbinarize(Maskarea);
    % Take the single largest masked area in the row
    Maskarea = bwpropfilt(Maskarea,'Area',1);
    % Take the index of the masked area
    [~,x]=find(Maskarea==1);
    % Extract the gradent for these coordiantes
    currentroi=ROI(M,x);
    currentGrad=gradient(currentroi);
    [~,g]=size(currentGrad);
    
    % Determin if a Step-Edge is present, Step-Edge = only one +/- gradient
    % Highligh a increse/decrese of gradient above NL with 1 or -1
    Grouping=zeros(1,g);
    for G=1:g
        if currentGrad(1,G)>NL
            Grouping(1,G)=1;
        elseif currentGrad(1,G)<-NL 
            Grouping(1,G)=-1;
        end
    end
    
    Groupingpos=zeros(size(Grouping));
    proxpos=find(Grouping==1);
    Groupingpos(1,proxpos)=1;
    [~, gpos] = bwlabel(Groupingpos); 

    proxneg=find(Grouping==-1);
    Groupingneg=zeros(size(Grouping));
    Groupingneg(1,proxneg)=1;
    [~, gneg] = bwlabel(Groupingneg); 

    if gpos==1 && gneg==0 %&& Emppos==0 && Empneg==1
        stepedge(1,M)=1;
    elseif gneg==1 && gpos==0 %&& Empneg==0 &&  Emppos==1
        stepedge(1,M)=1;
    else
        stepedge(1,M)=0;
    end
end 

% Detemine the minimum number of confermed Step-Edges within the ROI
SEnum=SEnum*m;

% Sum of number of confiermed step edges withi nthe ROI
stepedgetotal=sum(stepedge);

if stepedgetotal>=SEnum
    StepEdge=1;
else
    StepEdge=0;
end