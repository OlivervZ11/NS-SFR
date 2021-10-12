% E-SFR Estimation from NS-SFR Data
% 
% Copyright (c) 2021 O. van Zwanenberg
% UNIVERSITY OF W1ESTMINSTER PhD Reserch
%              - COMPUTATIONAL VISION AND IMAGING TECHNOLOGY RESEARCH GROUP
% Director of Studies:  S. Triantaphillidou
% Supervisory Team:     R. Jenkin & A. Psarrou

clc; close all; clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PERAMETERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Number of Radial Distance Segemnts ('Radial Distance Dohnuts')
RDseg=6;
% Percentile of the LSF half peak width distribution to be used in the 
% sys-SFR estimation
Percentile = 10; % Top 10th percentile of sharpest edges per RDseg
Percentile2=[];

% Thresholds
% System e-SFR Estimaion parameter ranges
sysPar = [2,      35;     0.55,   0.65;   20,      130    ];
%        [minAng, maxAng; minCon, maxCon; minROIh, maxROIh];
% SFR mean Weights
AveW = [1.00,   0.75,     0.50   ];
%      [Centre, Part-Way, Corners];  - [1] = no weight
%                                    - [1,2,3,...,n] = more radal regions  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% OPEN DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Also Convert to ST?
answer = questdlg('Which Estimate e-SFRs Orentations?', ...
	'Data', ...
	'All', 'Horizontal & Vertical','Sagittal & Tangential', 'All');
switch answer
    case 'All' 
        O = 1;
    case 'Horizontal & Vertical'
        O = 2;
    case 'Sagittal & Tangential'
        O = 3;
end

mat = uigetdir([], 'Select folder conatining NS-SFR Data');
matemp=isempty(mat);
if matemp==0
    load([mat '/ImageNamesIndex.mat']); 
    nameIndex=namesIndex(1,1);
    Load_Result=[mat '/' nameIndex{1,1}];
    load(Load_Result); 
else
    disp('No Data in chosen Folder');
    return 
end

% Load first image to determin if RAW or TIFF
load([mat '/' namesIndex{1, 1}]); 
if size(MTF_Results,1) == 1
    raw = 0;
else
    raw = 1;
end

% Ask to use ISO12233 test chart data
if O==1 || O==2
    answer1 = questdlg('Load Test chart Horizontal & Vertical e-SFR Data?', ...
        'Data', ...
        'Yes','No', 'Yes');
    switch answer1
        case 'Yes' 
            HV = 1;
            rawiso = 0; %TIFF ISO12233 test chart captures
            % User selects the appropate H/V ISO mat file
            [file1,path1] = uigetfile('*.mat', 'SELECT H/V ISO .mat FILE');
    case 'No'
            HV = 0;
    end
else
    HV = 0;
end
if O ==1 || O==3
    answer2 = questdlg('Load Test chart Sagittal & Tangential e-SFR Data?', ...
        'Data', ...
        'Yes','No', 'Yes');
    switch answer2
        case 'Yes' 
            ST = 1;
            rawiso = 0; %TIFF ISO12233 test chart captures
            % User selects the appropate S/T ISO mat file
            [file2,path2] = uigetfile('*.mat', 'SELECT SAG/TAN ISO .mat FILE');
        case 'No'
            ST = 0;
    end
else
     ST = 0;
end
if HV==1
    load([path1 file1]);
    for o=4:5
        [a,~]=size(ISO12233Charthv{1, o});
        for B=1:a
            ISO12233Charthv{1,o}{B, 12}=1;
        end
    end
end
if ST==1
    load([path2 file2]);
    for o=4:5
        [a,~]=size(ISO12233Chartst{1, o});
        for B=1:a
            ISO12233Chartst{1,o}{B, 12}=1;
        end
    end         
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% SEGMENT NS-SFRS BY RD %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% No Label
label = zeros(size(namesIndex,1),1)+1;
% Segment
if HV==1 && ST==1
    [RadDistH, RadDistV, ISORadDistH, ISORadDistV,  ISORadDistS, ...
        ISORadDistT]=radseg(RDseg, namesIndex, ISO12233Charthv, ...
        ISO12233Chartst, mat, label);
elseif HV==1 && ST==0
    [RadDistH, RadDistV, ISORadDistH, ISORadDistV,  ~, ~]= ...
        radseg(RDseg, namesIndex, ISO12233Charthv, [], mat, label);
    ISORadDistS =[];
    ISORadDistT =[];
elseif HV==0 && ST==1
    [RadDistH, RadDistV, ~, ~,  ISORadDistS,ISORadDistT]= ...
        radseg(RDseg, namesIndex, [], ISO12233Chartst, mat, label);
    ISORadDistH =[];
    ISORadDistV =[];
else
    [RadDistH, RadDistV]=radseg(RDseg, namesIndex, [], [], mat, label);
    ISORadDistH =[];
    ISORadDistV =[];
    ISORadDistS =[];
    ISORadDistT =[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% THE DATA PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Amount of data
NumData = cell(size(RadDistH,1),1);
numdata=zeros(RDseg,4);
numdata(:,4)=Percentile;
numdata(:,1)=size(namesIndex,1);
for A = 1:size(RadDistH,1)
    NumData{A} = numdata;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if O ==1 || O==2
    % Obtain the strongest NS-SFRs    
    % Take a distribution of the range of LSF Half Peak Widths
    % Measure Area and hight of the NS-SFR lobes
    for RGB=1:size(RadDistH,1)
        % Horizontal Edges
        [RadDistH(RGB,:), NumData{RGB}]=nssfrScore(RadDistH(RGB,:), RDseg,...
            NumData{A}, 2, Percentile, Percentile2);
        % Vertical Edges
        [RadDistV(RGB,:), NumData{RGB}]=nssfrScore(RadDistV(RGB,:), RDseg,...
            NumData{RGB}, 3, Percentile, Percentile2);
    end
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if O ==1 || O==3
    % Convert the Horizontal and vertical Edges to Sagital and Tangential
    % Obtain 16 diagonal frame sections to classify the ROI edge angles
    [LFsegsV, LFsegsH]=FrameSeg16(MTF_Results);
    Sag  = cell(size(RadDistH,1), RDseg);
    Tang = cell(size(RadDistH,1), RDseg);

    for A=1:RDseg
        for RGB=1:size(RadDistH,1)    
            bs=0;
            bt=0;
            cs=0;
            ct=0;
            for B=1:size(RadDistH{RGB, A}, 1)
                Co=RadDistH{RGB, A}{B, 2};
                if isempty(Co)
                    Sag {RGB, A}=[];
                    Tang{RGB, A}=[];
                    continue
                end
                if Co==0
                    Sag{RGB, A}=[];
                    Tang{RGB, A}=[];
                else
                    Coy=Co(1,2)+(Co(1,4)/2);
                    Cox=Co(1,1)+(Co(1,3)/2);

                    if Cox>=size(LFsegsH,2) || Coy>=size(LFsegsH,1)
                        bs=bs+1;
                        bt=bt+1;
                        continue
                    end
                    SegsVAL=LFsegsH(round(Coy),round(Cox));
                    Angle=RadDistH{RGB, A}{B, 3};
                    SagTan=AngleSeg(SegsVAL, Angle, 4); %4 = Horizontal edge
                    if SagTan==1 || SagTan==2      
                         if SagTan==1
                             for st=1:9
                                Sag{RGB, A}{(B-bs),st}=RadDistH{RGB, A}{B, st};
                             end
                            Sag{RGB, A}{(B-bs),7}=0;
                            Sag{RGB, A}{(B-bs),11}=4;
                            Sag{RGB, A}{(B-bs),10}=RadDistH{RGB, A}{B, 10};
                            Sag{RGB, A}{(B-bs),3}=Angle;
                            bt=bt+1;
                         elseif SagTan==2
                             for st=1:9
                                Tang{RGB, A}{(B-bt),st}=RadDistH{RGB, A}{B, st};
                             end
                            Tang{RGB, A}{(B-bt),7}=0;
                            Tang{RGB, A}{(B-bt),11}=4;
                            Tang{RGB, A}{(B-bt),10}=RadDistH{RGB, A}{B, 10};
                            Tang{RGB, A}{(B-bt),3}=Angle;
                            bs=bs+1;
                         end
                    elseif SagTan==0
                        bs=bs+1;
                        bt=bt+1;
                    end
                end
            end
            for C=1:size(RadDistV{RGB, A}, 1)
                Co=RadDistV{RGB, A}{C, 2};
                if isempty(Co)
                    Sag {RGB, A}=[];
                    Tang{RGB, A}=[];
                    continue
                end
                if Co==0 
                    Sag {RGB, A}=[];
                    Tang{RGB, A}=[];
                else
                    Coy=Co(1,2)+(Co(1,4)/2);
                    Cox=Co(1,1)+(Co(1,3)/2);

                    if Cox>=size(LFsegsV,2) || Coy>=size(LFsegsV,1)
                        cs=cs+1;
                        ct=ct+1;
                        continue
                    end
                    SegsVAL=LFsegsV(round(Coy),round(Cox));
                    Angle=RadDistV{RGB, A}{C, 3};
                    SagTan=AngleSeg(SegsVAL, Angle, 5); %5 = Vertical edge
                    if SagTan==1 || SagTan==2      
                         if SagTan==1
                             for st=1:9
                                Sag{RGB, A}{((C+(B-bs)-cs)),st}= ...
                                    RadDistV{RGB, A}{C, st};
                             end
                            Sag{RGB, A}{((C+(B-bs)-cs)),7}=0;
                            Sag{RGB, A}{((C+(B-bs)-cs)),11}=5;
                            Sag{RGB, A}{((C+(B-bs)-cs)),10}=  ...
                                RadDistV{RGB, A}{C, 10};
                            Sag{RGB, A}{((C+(B-bs)-cs)),3}=Angle;
                            ct=ct+1;
                         elseif SagTan==2
                             for st=1:9
                                Tang{RGB, A}{((C+(B-bt))-ct),st}= ...
                                    RadDistV{RGB, A}{C, st};
                             end
                              Tang{RGB, A}{((C+(B-bt))-ct),7}=0;
                              Tang{RGB, A}{((C+(B-bt))-ct),11}=5;
                              Tang{RGB, A}{((C+(B-bt))-ct),10}= ...
                                  RadDistV{RGB, A}{C, 10};
                              Tang{RGB, A}{((C+(B-bt))-ct),3}=Angle;
                            cs=cs+1;
                         end
                    elseif SagTan==0
                        cs=cs+1;
                        ct=ct+1;
                    end
                end
            end
        end
    end

    % Number of Sag and Tan per Rad. Dist.
    s=zeros(size(RadDistH,1),14);
    t=zeros(size(RadDistH,1),14);
    for RGB=1:size(RadDistH,1)    
        for A=1:RDseg
            s(RGB,A)=length(Sag {RGB, A});
            t(RGB,A)=length(Tang{RGB, A});
        end
    end

    % Reaply the LSF how edge stregth scoring
    % Take a distribution of the range of LSF Half Peak Widths
    % Measure Area and hight of the NS-SFR lobes
    % Saggital Edges
    NumData2 = cell(size(NumData));
    for RGB=1:size(RadDistH,1)  
        [Sag(RGB,:), NumData2{RGB}]=nssfrScore(Sag(RGB,:), RDseg,...
            NumData{RGB}, 2, Percentile, Percentile2);
        % Tangential Edges
        [Tang(RGB,:), NumData2{RGB}]=nssfrScore(Tang(RGB,:), RDseg, ...
            NumData2{RGB}, 3, Percentile, Percentile2);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Multi-Dimensional Interpolation Mesh - Bin to coordinate system 
[Ang, Con] = ndgrid(0:0.25:45, 0:0.1:1.0);
ROIh=[];
[Angiso, Coniso] = ndgrid(0:0.25:45, 0:0.05:1.0);

if O==1 || O==2
    NSSFRdataLUTsH = cell(size(RadDistH,1),1);
    sysSFRH =  cell(size(RadDistH,1),1);
    
    NSSFRdataLUTsV =  cell(size(RadDistH,1),1);
    sysSFRV =  cell(size(RadDistH,1),1);
end
if HV == 1 
    SFRdataLUTsisoH =  cell(size(RadDistH,1),1);
    sysSFRisoH =  cell(size(RadDistH,1),1);
    
    SFRdataLUTsisoV =  cell(size(RadDistH,1),1);
    sysSFRisoV =  cell(size(RadDistH,1),1);
end
if O==1 || O==3
    NSSFRdataLUTsS =  cell(size(RadDistH,1),1);
    sysSFRS =  cell(size(RadDistH,1),1);
    
    NSSFRdataLUTsT =  cell(size(RadDistH,1),1);
    sysSFRT =  cell(size(RadDistH,1),1);
end
if ST==1
    SFRdataLUTsisoS =  cell(size(RadDistH,1),1);
    sysSFRisoS =  cell(size(RadDistH,1),1);
    
    SFRdataLUTsisoT =  cell(size(RadDistH,1),1);
    sysSFRisoT =  cell(size(RadDistH,1),1);
end

ErrH=zeros(size(RadDistH,1), RDseg+1);
ErrV=zeros(size(RadDistH,1), RDseg+1);
ErrS=zeros(size(RadDistH,1), RDseg+1);
ErrT=zeros(size(RadDistH,1), RDseg+1);

for RGB=1:size(RadDistH,1)  
    if O==1 || O==2
        % Horizontal NS-SFR Data
        [NSSFRdataLUTsH{RGB}, sysSFRH{RGB}, RadDistH(RGB,:)] = ...
            griddataSFR(RadDistH(RGB,:), Ang, Con, ROIh, sysPar, ...
            AveW, 0, raw);
        % Verical NS-SFR Data
        [NSSFRdataLUTsV{RGB}, sysSFRV{RGB}, RadDistV(RGB,:)] = ...
            griddataSFR(RadDistV(RGB,:), Ang, Con, ROIh, sysPar, ...
            AveW, 0, raw);
        % Determine RadSegs with missing edges
        for rd=1:RDseg+1
            emp=isempty(sysSFRH{RGB}{1, rd});
            if emp==0 
                Z  = size(sysSFRH{RGB}{1, rd},1);
                if Z > 1
                    ErrH(RGB,rd)=ErrH(RGB,rd)+1;
                end
            end
            emp=isempty(sysSFRV{RGB}{1, rd});
            if emp==0 
                Z  = size(sysSFRV{RGB}{1, rd},1);
                if Z > 1
                    ErrV(RGB,rd)=ErrV(RGB,rd)+1;
                end
            end
        end   
    end
    if HV == 1 
        % Horizontal ISO12233 Data
        [SFRdataLUTsisoH{RGB}, sysSFRisoH{RGB}, ISORadDistH(RGB,:)] =  ...
            griddataSFR(ISORadDistH(RGB,:), Angiso, Coniso, [], ...
            sysPar, AveW, 1, rawiso);
        % Verical ISO12233 Data
        [SFRdataLUTsisoV{RGB}, sysSFRisoV{RGB}, ISORadDistV(RGB,:)]= ...
            griddataSFR(ISORadDistV(RGB,:), Angiso, Coniso,[], ...
            sysPar, AveW, 1, rawiso);
    end 
    
    if O==1 || O==3
        % Sagittal NS-SFR Data
        [NSSFRdataLUTsS{RGB}, sysSFRS{RGB}, Sag(RGB,:)] =  ...
            griddataSFR(Sag(RGB,:), Ang, Con, ROIh, sysPar, ...
            AveW, 0, raw);
        % Tangental NS-SFR Data
        [NSSFRdataLUTsT{RGB}, sysSFRT{RGB}, Tang(RGB,:)] = ...
            griddataSFR(Tang(RGB,:), Ang, Con, ROIh, sysPar, ...
            AveW, 0, raw);
        % Determine RadSegs with missing edges
        for rd=1:RDseg+1
            emp=isempty(sysSFRS{RGB}{1, rd});
            if emp==0 
                Z  = size(sysSFRS{RGB}{1, rd},1);
                if Z > 1
                    ErrS(RGB,rd)=ErrH(RGB,rd)+1;
                end
            end
            emp=isempty(sysSFRT{RGB}{1, rd});
            if emp==0 
                Z  = size(sysSFRT{RGB}{1, rd},1);
                if Z > 1
                    ErrT(RGB,rd)=ErrT(RGB,rd)+1;
                end
            end
        end
    end
    
    if ST==1
        % Tangental ISO12233 Data
        [SFRdataLUTsisoT{RGB}, sysSFRisoT{RGB}, ISORadDistT(RGB,:)]= ...
            griddataSFR(ISORadDistT(RGB,:), Angiso, Coniso, [], ...
            sysPar, AveW, 1, rawiso);
        % Sagittal ISO12233 Data
        [SFRdataLUTsisoS{RGB}, sysSFRisoS{RGB}, ISORadDistS(RGB,:)] = ...
            griddataSFR(ISORadDistS(RGB,:), Angiso, Coniso, [], ...
            sysPar, AveW, 1, rawiso);
    end
    
    % Caculate the Absolute difference between the estimated SFR and ISO
    % SFR
    if HV == 1 
        % Horizontal
        [sysSFRH{RGB}]=AbErrSFR(sysSFRH{RGB}, sysSFRisoH{1});
        % Vertical
        [sysSFRV{RGB}]=AbErrSFR(sysSFRV{RGB}, sysSFRisoV{1});
    end
    if ST==1
        % Sagittal
        [sysSFRS{RGB}]=AbErrSFR(sysSFRS{RGB}, sysSFRisoS{1});
        % Tangental
        [sysSFRT{RGB}]=AbErrSFR(sysSFRT{RGB}, sysSFRisoT{1});
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Caculate the standered deviation of the SFR envelopes
if O==1 || O==2
    [sfrstdH] = SFRstd(RadDistH, sysPar,0);
    for a=1:size(sysSFRH,1)
        for b=1:size(sysSFRH{a,1},2)
            if ~isempty(sysSFRH{a,1}{1,b})
                sysSFRH{a,1}{1,b}(:,3)=sfrstdH{a, b}(:,2);
            end
        end
    end
    [sfrstdV] = SFRstd(RadDistV, sysPar,0);
    for a=1:size(sysSFRV,1)
        for b=1:size(sysSFRV{a,1},2)
            if ~isempty(sysSFRV{a,1}{1,b})
                sysSFRV{a,1}{1,b}(:,3)=sfrstdV{a, b}(:,2);
            end
        end
    end
end
if HV == 1 
    [sfrstdHiso] = SFRstd(ISORadDistH, sysPar,1);
    for b=1:size(sysSFRisoH{1,1},2)
        if ~isempty(sysSFRisoH{1,1}{1,b})
            sysSFRisoH{1,1}{1,b}(:,3)=sfrstdHiso{1, b}(:,2);
        end
    end
    [sfrstdViso] = SFRstd(ISORadDistV, sysPar,1);
    for b=1:size(sysSFRisoV{1,1},2)
        if ~isempty(sysSFRisoV{1,1}{1,b})
            sysSFRisoV{1,1}{1,b}(:,3)=sfrstdViso{1, b}(:,2);
        end
    end
end
if O==1 || O==3
    [sfrstdS] = SFRstd(Sag,  sysPar,0);
    for a=1:size(sysSFRS,1)
        for b=1:size(sysSFRS{a,1},2)
            if ~isempty(sysSFRS{a,1}{1,b})
                sysSFRS{a,1}{1,b}(:,3)=sfrstdS{a, b}(:,2);
            end
        end
    end
    [sfrstdT] = SFRstd(Tang, sysPar,0);
    for a=1:size(sysSFRT,1)
        for b=1:size(sysSFRT{a,1},2)
            if ~isempty(sysSFRT{a,1}{1,b})
                sysSFRT{a,1}{1,b}(:,3)=sfrstdT{a, b}(:,2);
            end
        end
    end
end
if ST==1
    [sfrstdSiso] = SFRstd(ISORadDistS, sysPar,1);
    for b=1:size(sysSFRisoS{1,1},2)
        if ~isempty(sysSFRisoS{1,1}{1,b})
            sysSFRisoS{1,1}{1,b}(:,3)=sfrstdSiso{1, b}(:,2);
        end
    end
    [sfrstdTiso] = SFRstd(ISORadDistT, sysPar,1);
    for b=1:size(sysSFRisoT{1,1},2)
        if ~isempty(sysSFRisoT{1,1}{1,b})
            sysSFRisoT{1,1}{1,b}(:,3)=sfrstdTiso{1, b}(:,2);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Missing Edges per Radial Seg
ErrH=sum(ErrH,1);
ErrV=sum(ErrV,1);
ErrS=sum(ErrS,1);
ErrT=sum(ErrT,1);
ERR=[ErrH;ErrV;ErrS;ErrT];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wrap the required variables up into Cell arrays
SFR_CO=zeros(2,4);
SFR_CO=num2cell(SFR_CO);
sysSFR=SFR_CO;

if O==1 || O==2
    SFR_CO{1,1} = NSSFRdataLUTsH;
    SFR_CO{1,2} = NSSFRdataLUTsV;
    sysSFR{1,1} = sysSFRH;
    sysSFR{1,2} = sysSFRV;
end
if HV == 1 
    SFR_CO{2,1} = SFRdataLUTsisoH;
    SFR_CO{2,2} = SFRdataLUTsisoV;
    sysSFR{2,1} = sysSFRisoH;
    sysSFR{2,2} = sysSFRisoV;
end
if O==1 || O==3
    SFR_CO{1,3} = NSSFRdataLUTsS;
    SFR_CO{1,4} = NSSFRdataLUTsT;
    sysSFR{1,3} = sysSFRS;
    sysSFR{1,4} = sysSFRT;
end
if ST==1
    SFR_CO{2,3} = SFRdataLUTsisoS;
    SFR_CO{2,4} = SFRdataLUTsisoT;
    sysSFR{2,3} = sysSFRisoS;
    sysSFR{2,4} = sysSFRisoT;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Save Data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save([mat '/eSFR_Estimation.mat'], 'sysSFR', 'SFR_CO', ...
    'Ang', 'Con', 'raw', 'HV', 'ST', 'O')
% clearvars
disp('Compleated System e-SFR Estimation');
clearvars 
beep
