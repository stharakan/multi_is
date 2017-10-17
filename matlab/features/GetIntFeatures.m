function [ GF ] = GetIntFeatures( varargin )
%GETINTFEATURES produces GF, a matrix of N x m data points and the
%corresponding m intensities in each modality. The number of modalities can
%be varied. To use the script, we assume you have previously loaded the
%modalities. 
%
% ----- HOW TO USE  ----
% Suppose we have already extracted flair, t1, t1ce, and t2 from a given
% set of brains. In order to get the features, we simply call the function
% as shown below:
%
% GF = GetIntFeatures(flair,t1,t1ce,t2);
%

mods = length(varargin);

GF = zeros(numel(varargin{1}),mods);

for mm = 1:mods
    im = varargin{mm};
		
		%im = single(im./max(im(:)));
    
    GF(:,mm) = im(:);
end


end

