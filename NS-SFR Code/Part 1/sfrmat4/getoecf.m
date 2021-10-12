function [array, status] = getoecf(array, oepath,oename);
% [array, status] = getoecf(array, oepath,oename)  Read and apply oecf
% Reads look-up table and applies it to a data array
%   array = data array (nlin, pnix, ncolor)
%   oepath = table pathname, e.g. /home/sfr/dat
%   oename = tab-delimited text file for table (256x1, 256,3)
%   array = returns transformed array
%   status = 0  OK, 
%          = 1 bad table file
%Author: Peter Burns, pdburns@ieee.org
%Copyright 2005 by Peter D. Burns. All rights reserved.

status = 0;
stuff = size(array);
nlin = stuff(1);
npix = stuff(2);
if size(stuff)==[1 2];
   ncol = 1;
else;
   ncol = stuff(3);
end;

temp = [oepath,oename];
oedat =load(temp);
%oedat = oename;
dimo = size(oedat);
if dimo(2) ~=ncol;
   status = 1;
   return;
end;

klass = class(array);
array = double(array);

if ncol==1;
   for i=1: nlin;
      for j = 1: npix;
        array(i,j) = oedat( array(i,j)+1, ncol);
      end;
   end;
else;
   for i=1: nlin;
      for j = 1: npix;
         for k=1:ncol;
            array(i,j,k) = oedat( array(i,j,k)+1, k);
         end;
      end;
   end;
end;
                 
 if klass(1:5) == 'uint8';         % uint8
  array = uint8(array);
 elseif klass(1:5) == 'uint1';      % uint16 check
  array = uint16(array);
 end

return

