function [ sfb ] = GetSFBFromOthers( ww,sig )
%GETFREQFROMOTHERS calculates what sfb to specify for matlab's gabor
%filters in order to generate the appropriate window size corresponding to
%a gaussian of width 1 sig, for the given wavelength w. 

sfb = log2( ( (sig/ww)*pi + sqrt(log(2)/2) )/ ( (sig/ww)*pi - sqrt(log(2)/2) ) );

end