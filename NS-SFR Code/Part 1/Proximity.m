function [Proximity, ProximityCoordinates]=Proximity(Im ,Coordinates, orientation, lowerLimit, upperLimit)

% PROXIMITY A proximity filter that takes either the coordinates from the
% vertical or horizontal edges, then measures and limits the proximity of 
% the detected edges.
% Any edges between the proximity of lowerLimit and upperLimit are removed 
% from the Vertical/Horizontal Coordinate list. 
%
% Input: 
%    Im: Greyscale Image
%    Coordinates:   List of Vertical/Horizontal Coordinates
%    orientation:   Can be either 'Vertical' or 'Horizontal'. If 'Vertical',
%                   the code will take proximity measurements using the 
%                   Rows, if 'Horizontal', the measurements will be made  
%                   through the columns. 
%    lowerLimit:    The lower threshold, any edges above this threshold are
%                   eliminated (as long as the proximity does not exceed 
%                   the upperLimit).
%    upperLimit:    The upper threshold, any edges bellow this threshold 
%                   are eliminated (as long as as the proximity is above  
%                   that of the lowerLimit).   
%
% Output:
%    Proximity:                 A new binary image, where the edges that 
%                               are within a set proximity are removed.
%    ProximityCoordinates:      A list of coordinates from the Proximity
% 
% Copyright (c) 2019 O. van Zwanenberg, University of Westminster


%--------------------------------------------------------------------------
%Determine if the Coordinates are Verical or Horizontal edges:



switch orientation
    case 'Horizontal'
        
        Max=max(Coordinates(:,1));
        coordinates=(Coordinates(:,1));
        Proximity=zeros(size(Im(:,:,1)));
        
         for B=1:Max
            [row, ~] = find(coordinates == B);
            CUT=Coordinates(row, :);
         
            %Determine if HCECxcut is empty - 1=true, 0=false
            Emp=isempty(CUT);
         
            if Emp==0
         
            CUT = sort(CUT);
            [e, ~]=size(CUT);
            f=e-1;
         
            for E=1:f
              
                y1=CUT(E,2);
                %(x=B)
           
                G=E+1;
                y2=CUT(G,2);
                      
                proximity=(y2-y1);
                 
                %create a new Horizoantal Canny Edge Detection 
                %- with proximity reduction 
                 
                if proximity>=upperLimit || proximity<=lowerLimit
                    Proximity(y1, B)=1;
                    Proximity(y2, B)=1;
                else
                    Proximity(y1, B)=0;
                    Proximity(y2, B)=0;
                end
            end
         
            else
             %Else if HCECxcut is empty, nothing happens (Emp==1).
            end
         end
    
    case 'Vertical'
        
        Max=max(Coordinates(:,2));
        coordinates=(Coordinates(:,2));
        Proximity=zeros(size(Im(:,:,1)));
        
        for C=1:Max
            [row, ~] = find(coordinates == C);
            CUT=Coordinates(row, :);
         
            %Determine if HCECxcut is empty - 1=true, 0=false
            Emp=isempty(CUT);
         
            if Emp==0
         
                CUT=sort(CUT);
                [e, ~]=size(CUT);
                f=e-1;
         
                for E=1:f
              
                    x1=CUT(E,1);
                    %(y=C)
              
                    G=E+1;
                    x2=CUT(G,1);
                      
                    proximity=(x2-x1);
                 
                    %create a new Horizoantal Canny Edge Detection 
                    %- with proximity reduction 
                 
                    if proximity>=upperLimit || proximity<=lowerLimit
                        Proximity(C, x1)=1;
                        Proximity(C, x2)=1;
                    else
                        Proximity(C, x1)=0;
                        Proximity(C, x2)=0;
                    end
             
                end
         
            else
                %Else if VCECxcut is empty, nothing happens (Emp==1).
            end
        end
        
    otherwise 
        warning('Unexpected orientation, only Horizontal or Vertical')
end 

Proximity=logical(Proximity);


%Take the Coordinates of the Proximity
%From the new binary image, detect the non-zero values and take their
%coordinate values. 

[Y,X] = find(Proximity(:,:) ~= 0);
    
[p,~]=size(X);
ProximityCoordinates=zeros(p,2);

for P=1:p
    ProximityCoordinates(P,1)=X(P,1);
    ProximityCoordinates(P,2)=Y(P,1);
end