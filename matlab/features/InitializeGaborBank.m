function [gb] = InitializeGaborBank(bw,nangs)

if nargin == 1
  nangs = 8;
end

no = nangs; 
ang_max = 180 - ( (180)/no );
angles = linspace(0,ang_max,no);
for gi = 1:5 % leave as hardcoded max for now
    wv = 2^gi;
    if wv < (bw * pi / sqrt(log(2)/2 ) )
        gi_idx = (1:length(angles) ) + length(angles) * (gi-1);
	gb(gi_idx) = gabor(wv,angles,'SpatialFrequencyBandwidth',...
      	    GetSFBFromOthers(wv,bw),'SpatialAspectRatio',1.0);
    end

end


end
