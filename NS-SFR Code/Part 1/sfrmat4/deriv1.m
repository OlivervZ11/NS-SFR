function  [b] = deriv1(a, nlin, npix, fil)
% [b] = deriv1(a, nlin, npix, fil)
%  Computes first derivative via FIR (1xn) filter
%  Edge effects are suppressed and vector size is preserved
%  Filter is applied in the npix direction only
%   a = (nlin, npix) data array
%   fil = array of filter coefficients, eg [-0.5 0.5]
%   b = output (nlin, npix) data array
%  Author: Peter Burns, 1 Oct. 2008
%                       27 May 2020 updated to use 'same' conv option
%  Copyright (c) 2020 Peter D. Burns
%
 b = zeros(nlin, npix);
 nn = length(fil);

 for i=1:nlin
%      size(conv(a(i,:),fil,'same'))
%      size( b(i, :))
     
  b(i, :) = squeeze(conv(a(i,:),fil,'same'));
  b(i,1) = b(i,2);
  b(i,npix) = b(i,npix-1);
 end

