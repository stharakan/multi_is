function [gb,gc] = InitializeGaborBank(bw,nangs)

if nargin == 1
  nangs = 8;
end

if nangs == 0
    outflag = 1;
    no = 1;
else
    outflag = 0;
    no = nangs;
end
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


if nargout > 1
    gc = cell(length(gb),1);
    
    for gi = 1:length(gb)
        if outflag
            gc{gi} = sprintf('w.%d.f.%3.2f',gb(gi).Wavelength,...
                gb(gi).SpatialFrequencyBandwidth);
        else
            ang_diff = angles(2) - angles(1);
            gc{gi} = sprintf('w.%d.o.%d.f.%3.2f',gb(gi).Wavelength,...
                gb(gi).Orientation/ang_diff,gb(gi).SpatialFrequencyBandwidth);
        end
    end
end
end
