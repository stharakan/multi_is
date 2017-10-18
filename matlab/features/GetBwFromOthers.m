function [ bw ] = GetBwFromOthers( sfb,ww )
%GETFREQFROMOTHERS calculates what ww to specify for matlab's gabor
%filters in order to generate the appropriate window size corresponding to
%a gaussian of width 1 sig, for the given sfb. 

% l = sig * pi * sqrt(2/ln2) * (2^sfb - 1)/(2^sfb + 1)
bw = (ww/pi) * sqrt(log(2)/2) * (2^sfb + 1) / (2^sfb - 1);

end