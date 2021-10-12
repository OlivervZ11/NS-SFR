% Manually select ROIs from an image and measure the SFR

% Copyright (c) 2020 O. van Zwanenberg
% UNIVERSITY OF WESTMINSTER 
%              - COMPUTATIONAL VISION AND IMAGING TECHNOLOGY RESEARCH GROUP
% Director of Studies:  S. Triantaphillidou
% Supervisory Team:     R. Jenkin & A. Psarrou

clc; close all; clear all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select Image
imgPath = uigetdir;
images  = dir([imgPath '/*.tif']);
N = length(images);
IM{N,1} = [];
for idx = 1:N
    IM{idx} = imread([imgPath '/' images(idx).name]);
end
% Im=imread([list(x).name]);

% Data Cell Arrays - format matches the Framework output
ISO12233Chart = zeros (1,6);
ISO12233Chart=num2cell(ISO12233Chart);

Dat = zeros (1,12);
Dat=num2cell(Dat);

ISO12233Chart{1,4}=Dat;
ISO12233Chart{1,5}=Dat;

% -------------------------------------------------------------------------
% Select the ROIs from Im
ISO12233Chart=SelectROIs(IM, ISO12233Chart); 
% ISO12233Chart{1,1}=file;
ISO12233Chart{1,2}=IM;

% Save the ISO12233Chart.mat
answer = questdlg('Would you like a save the SFR data?', ...
	'Save data', ...
	'Yes', 'No', 'Yes');
% Handle response
switch answer
    case 'Yes'
        uisave('ISO12233Chart','ISO12233ChartData');
    case 'No'
        disp('SFR data is not saved to disk');
end
% -------------------------------------------------------------------------
% % % % Plot the SFR data in GUI
% % % answer = questdlg('Would you like a plot the SFR data?', ...
% % % 	'Plot data', ...
% % % 	'Yes','No');
% % % % Handle response
% % % switch answer
% % %     case 'Yes'
% % %         plotSFR(ISO12233Chart);
% % %     case 'No'
% % %         
% % % end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Selection GUI
function ISO12233Chart=SelectROIs(IM, ISO12233Chart)
    % Take first image
    i=1;
    Im=IM{i};
    imNum=size(IM,1);
    
    % ROI number indercator 
    roiNum=0;
    [y,x,~]=size(Im);
    ImS(1,1)=x;
    ImS(1,2)=y;
    
    % Orientation indercator 
    o=4;
    
%     [x,y,~] = size(Im);
    % Create UIFigure and hide until all components are created
    ROISelection = uifigure('Visible', 'off');
    ROISelection.Color = [0.651 0.651 0.651];
    ROISelection.Position = [100 100 1350 759];
    ROISelection.Name = 'ROI Selection';

    % Create Image
    Image = uiaxes(ROISelection);
    Image.Position = [59,16,862,575];
    Image.BackgroundColor = [0.651 0.651 0.651]; 
%     Image.XLim = [0 x];
%     Image.YLim = [0 y];
    set(Image,'visible','off');
    image(Im,'Parent', Image); 
    
    % Linearise the Image
    Im=rgb2lin(Im);
    
    % Create SelectButton
    SelectButton = uibutton(ROISelection, 'push');
    SelectButton.FontSize = 18;
    SelectButton.FontWeight = 'bold';
    SelectButton.Position = [1033,343,242,74];
    SelectButton.Text = 'Select';
    SelectButton.ButtonPushedFcn = @ROIselect;

    % Create NextButton
    NextButton = uibutton(ROISelection, 'push');
    NextButton.FontSize = 18;
    NextButton.FontWeight = 'bold';
    NextButton.Position = [1033 175 242 74];
    NextButton.Text = 'Next';
    NextButton.ButtonPushedFcn = @Next;
    N=1;
    
    % Create TitleLabel
    TitleLabel = uilabel(ROISelection);
    TitleLabel.HorizontalAlignment = 'center';
    TitleLabel.FontSize = 24;
    TitleLabel.Position = [59,692,862,44];
    TitleLabel.Text = 'Horizontal or Sagittal Selection';
        
    % Create ROILabel
    ROILabel = uilabel(ROISelection);
    ROILabel.HorizontalAlignment = 'center';
    ROILabel.FontSize = 20;
    ROILabel.Position = [59,629,862,39];
    ROILabel.Text = 'ROI Size: [100, 100, 128, 64]';

    % Create numLabel
    numLabel = uilabel(ROISelection); 
    numLabel.FontSize = 20;
    numLabel.Position = [1033,290,242,39];
    numLabel.Text = '0';
    
    % Create ROIheightSpinnerLabel
    ROIheightSpinnerLabel = uilabel(ROISelection);
    ROIheightSpinnerLabel.HorizontalAlignment = 'right';
    ROIheightSpinnerLabel.FontSize = 18;
    ROIheightSpinnerLabel.Position = [1033 591 91 23];
    ROIheightSpinnerLabel.Text = 'ROI height';

    % Create ROIheightSpinner
    ROIheightSpinner = uispinner(ROISelection);
    ROIheightSpinner.FontSize = 18;
    ROIheightSpinner.Position = [1139 590 136 24];
    ROIheightSpinner.Value = 128;
    ROIheightSpinner.ValueChangingFcn=@dispROIsize;

    % Create ROIWidthSpinnerLabel
    ROIWidthSpinnerLabel = uilabel(ROISelection);
    ROIWidthSpinnerLabel.HorizontalAlignment = 'right';
    ROIWidthSpinnerLabel.FontSize = 18;
    ROIWidthSpinnerLabel.Position = [1033 557 88 23];
    ROIWidthSpinnerLabel.Text = 'ROI Width';

    % Create ROIWidthSpinner
    ROIWidthSpinner = uispinner(ROISelection);
    ROIWidthSpinner.FontSize = 18;
    ROIWidthSpinner.Position = [1139 556 136 24];
    ROIWidthSpinner.Value = 64;
    ROIWidthSpinner.ValueChangingFcn=@dispROIsize;

    % Show the figure after all components are created
    ROISelection.Visible = 'on';
    
    rect = drawrectangle('Color',[1 0 0], 'Parent', Image, ...
        'Position', [100, 100, 128, 64]);    
    roiL = rect.Position;
    addlistener(rect,'ROIMoved',@(src, evt) roiChange(src,evt));
    
    uiwait(ROISelection);
    % ---------------------------------------------------------------------
    % GUI Functions:
    
    % ROI change via spinners
    function dispROIsize(~,~,~)
        h=get(ROIheightSpinner, 'Value');
        w=get(ROIWidthSpinner, 'Value');
        
        p=get(rect, 'Position');
        p(1,3)=h;
        p(1,4)=w;
        set(rect, 'Position', p);
        
        text=['ROI Size: [' num2str(p) ']' ];
        set (ROILabel, 'Text', text);
    end
    
    % ROI change
    function roiChange(~,~)
%         assignin('base',roi,evt.CurrentPosition);
%         roiL=evt.CurrentPosition;
        p=get(rect, 'Position');
        text=['ROI Size: [' num2str(p) ']' ];
        set (ROILabel, 'Text', text);
        
        set(ROIheightSpinner, 'Value', p(1,3));
        set(ROIWidthSpinner, 'Value', p(1,4));
    end
    
    % Select the ROI
    function ROIselect(~,~,~)
        % Mark ROI
        p=get(rect, 'Position');
        rectangle('Position', p,'Edgecolor', 'r', 'Parent', Image);
        
        roiNum=roiNum+1;
        
        % crop section
        ROI=imcrop(Im,p);
        
        % Caculate data and save
        
        normdist=RadialDist(p, ImS);
        [~, dat, ~, ~, esf, ~, ~, Con, Angle, Clip] = sfrmat4(1, 1, 3, [.299, .587, .114], ROI, 1);
        Data=zeros(1,2);
        Data=num2cell(Data);
        Data{1,1}=dat;
        Data{1,2}=esf;
        
        ISO12233Chart{1,o}{roiNum, 1}=ROI;
        ISO12233Chart{1,o}{roiNum, 4}=Angle;
        ISO12233Chart{1,o}{roiNum, 5}=Con;
        ISO12233Chart{1,o}{roiNum, 6}=Clip;
        ISO12233Chart{1,o}{roiNum, 9}=p;
        ISO12233Chart{1,o}{roiNum, 10}=normdist;
        ISO12233Chart{1,o}{roiNum, 11}=Data;
        
        % Add to the diplayed counter
        text=num2str(roiNum);
        set (numLabel, 'Text', text);
    end

    % Move to next image or orientation and then move to finish
    function Next(~,~,~)
        i=i+1;
        if i==imNum+1
            roiNum=0;
            switch N
                case 1 % move to Vertical
                    set(TitleLabel,'Text','Vertical or Tangential Selection');
                    o=5;
                    set (numLabel, 'Text', '0');
                case 2 % Finish GUI
                    uiresume (ROISelection);
                    delete(ROISelection);

            end
            if N==1
                N=N+1;
                p=get(rect, 'Position');
                i=1;
                Im=IM{i};
                [y,x,~]=size(Im);
                ImS(1,1)=x;
                ImS(1,2)=y;
                image(Im,'Parent', Image); 
                % Linearise the Image
                Im=rgb2lin(Im);
                rect = drawrectangle('Color',[1 0 0], 'Parent', Image, ...
                    'Position', p);   
                addlistener(rect,'ROIMoved',@(src, evt) roiChange(src,evt));
            end
        else
            p=get(rect, 'Position');
            Im=IM{i};
            [y,x,~]=size(Im);
            ImS(1,1)=x;
            ImS(1,2)=y;
            image(Im,'Parent', Image); 
            % Linearise the Image
            Im=rgb2lin(Im);
            rect = drawrectangle('Color',[1 0 0], 'Parent', Image, ...
                'Position', p);   
            addlistener(rect,'ROIMoved',@(src, evt) roiChange(src,evt));
            if i==imNum && o==5
               set(NextButton,'Text', 'Finish'); 
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SFR Plot GUI

