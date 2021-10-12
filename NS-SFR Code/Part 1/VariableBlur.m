function blurred=VariableBlur(inputimage, BlurParamMatr)
% Applies blur filter on the inputmage with different parameters at each 
% individual pixels.
% inputimage: the image/matrix to be blurred
% BlurParamMatr: the matrix containing the blur parameter for each pixel,
% must be the same size as inputimage
%Zoltan - https://www.mathworks.com/matlabcentral/fileexchange/26879-variable-blur-gradient-blur
BlurParamClasses = unique(BlurParamMatr(:));
BlurParamClasses(BlurParamClasses == 0) = [];
blurred = inputimage;
for i = 1 : numel(BlurParamClasses)
   PSF =  fspecial('disk', BlurParamClasses(i));
   BlurLayer = imfilter(inputimage, PSF, 'replicate');     
   blurred(BlurParamMatr == BlurParamClasses(i)) = BlurLayer(BlurParamMatr == BlurParamClasses(i));
end
