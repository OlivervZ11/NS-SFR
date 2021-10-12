function [Grad]=gradGenerator(roimask, roiCanny, indices)
%Gradient Genatator (gradGenerator) creates a non-linear gradient beased
%upon a power function and the ROI edge mask.
%Input:
%   roimask:    The binary image indercating the loction of the edge
%               transition.
%   roiCanny:   The edge location (Canny Detector)
%   indices:    The power function indices to describe the gradient
%Output:
%   Grad:       A gradient map (gor blurring)

%The power function
x=20;
X=0:x;
Y=X.^indices;
Y=Y/(max(Y));
%--------------------------------------------------------------------------
%Create the XX array
[m,n,~] = size(roimask);
XX=zeros(m,n);
for M=1:m
    for N=1:n
        if roiCanny(M,N)==1
            %If edge location is far left of ROI, there is no Left edge pixel value:
            if N==1 %min value
                Px=roimask(M,N);
                A=N;
                Lim=0;
                while (Px==1)
                    A=A+1;
                    Px=roimask(M,A);
                    if A==n
                        Lim=1;
                        break
                    end
                end
                if  Lim~=1
                    %Caculate distance
                    dis=n-A;
                    disval=x/dis;
                    dis=0:disval:x;

                    %Use interpolation to caulate the range value (from 0-1) to
                    %the power function
                    range=0;
                    range = interp1(X,Y,dis);
                    XX(M,A:n)=range;
                end
                
            %If edge location is far right of ROI, there is no Right edge pixel value:
            elseif N==n %max value 
                Px=roimask(M,N);
                A=N;
                Lim=0;
                while (Px==1)
                    A=A-1;
                    Px=roimask(M,A);
                    if A==1
                        Lim=1;
                        break
                    end
                end
                if  Lim~=1
                    %Caculate distance  
                    dis=A-1;
                    disval=x/dis;
                    dis=0:disval:x;

                    %Use interpolation to caulate the range value (from 0-1) to
                    %the power function
                    range=0;
                    range = interp1(X,Y,dis);
                    range=flip(range,2);
                    XX(M,1:A)=range;
                end

            else
                %Determin the left Pixel value
                Px=roimask(M,N);
                A=N;
                Lim=0;
                while (Px==1)
                    A=A-1;
                    Px=roimask(M,A);
                    if A==1
                        Lim=1;
                        break
                    end
                end
                if  Lim~=1
                
                    %Caculate distance  
                    dis=A-1;
                    disval=x/dis;
                    dis=0:disval:x;

                    %Use interpolation to caulate the range value (from 0-1) to
                    %the power function
                    range=0;
                    range = interp1(X,Y,dis);
                    range=flip(range,2);
                    XX(M,1:A)=range;

                end
                %Detemin the right Pixel value
                Px=roimask(M,N);
                A=N;
                Lim=0;
                while (Px==1)
                    A=A+1;
                    Px=roimask(M,A);
                    if A==n
                        Lim=1;
                        break
                    end
                end
                if  Lim~=1
                
                    %Caculate distance
                    dis=n-A;
                    disval=x/dis;
                    dis=0:disval:x;

                    %Use interpolation to caulate the range value (from 0-1) to
                    %the power function
                    range=0;
                    range = interp1(X,Y,dis);
                    XX(M,A:n)=range;

                end
            end
        end
    end
end 
%--------------------------------------------------------------------------
%Create the YY array
roiCanny=rot90(roiCanny);
roimask=rot90(roimask);
[m,n, ~] = size(roimask);
YY=zeros(m,n);
for M=1:m
    for N=1:n
        if roiCanny(M,N)==1
            %If edge location is far left of ROI, there is no Left edge pixel value:
            if N==1 %min value
                Px=roimask(M,N);
                A=N;
                Lim=0;
                while (Px==1)
                    A=A+1;
                    Px=roimask(M,A);
                    if A==n
                        Lim=1;
                        break
                    end
                end
                if  Lim~=1

                    %Caculate distance
                    dis=n-A;
                    disval=x/dis;
                    dis=0:disval:x;

                    %Use interpolation to caulate the range value (from 0-1) to
                    %the power function
                    range=0;
                    range = interp1(X,Y,dis);
                    YY(M,A:n)=range;
                end
                
            %If edge location is far right of ROI, there is no Right edge pixel value:
            elseif N==n %max value 
                Px=roimask(M,N);
                A=N;
                Lim=0;
                while (Px==1)
                    A=A-1;
                    Px=roimask(M,A);
                    if A==1
                        Lim=1;
                        break
                    end
                end
                if  Lim~=1
                
                    %Caculate distance  
                    dis=A-1;
                    disval=x/dis;
                    dis=0:disval:x;

                    %Use interpolation to caulate the range value (from 0-1) to
                    %the power function
                    range=0;
                    range = interp1(X,Y,dis);
                    range=flip(range,2);
                    YY(M,1:A)=range;
                end

            else
                %Determin the left Pixel value
                Px=roimask(M,N);
                A=N;
                Lim=0;
                while (Px==1)
                    A=A-1;
                    Px=roimask(M,A);
                    if A==1
                        Lim=1;
                        break
                    end
                end
                if  Lim~=1
                
                    %Caculate distance  
                    dis=A-1;
                    disval=x/dis;
                    dis=0:disval:x;

                    %Use interpolation to caulate the range value (from 0-1) to
                    %the power function
                    range=0;
                    range = interp1(X,Y,dis);
                    range=flip(range,2);
                    YY(M,1:A)=range;

                end
                %Detemin the right Pixel value
                Px=roimask(M,N);
                A=N;
                Lim=0;
                while (Px==1)
                    A=A+1;
                    Px=roimask(M,A);
                    if A==n
                        Lim=1;
                        break
                    end
                end
                if  Lim~=1
                
                    %Caculate distance
                    dis=n-A;
                    disval=x/dis;
                    dis=0:disval:x;

                    %Use interpolation to caulate the range value (from 0-1) to
                    %the power function
                    range=0;
                    range = interp1(X,Y,dis);
                    YY(M,A:n)=range;

                end
            end
        end
    end
end 
% Fill the Rows with no Canny
for M=1:m
    Ones=find(YY(M, :)==1);
    onesemp=isempty(Ones);
    if onesemp==1
        YY(M, :)=1;
    end
end
YY=rot90(YY, -1);
Grad=XX.*YY;

%Remove Black Border
[m,n]=size(Grad);
for N=1:n
    Grad(m,N)=Grad(m-1,N);
end
for M=1:m
    Grad(M,n)=Grad(M,n-1);
end 