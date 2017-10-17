function [ GF ] = GetSelectWindowFeatures( psize,ridx, varargin )
%GETWINDOWFEATURES produces in GF a matrix of stats around each pixel.
%Specially, for each modality, the mean, median, variance, skew, & kurtosis of
%a 5x5x5 patch and its log are computed. For pixels at the edge of the
%image, 0's are appended. Furthermore, features are stored in the order
%they are passed in. Further, ridx is used to select a subset of pixels.
%
% ----- HOW TO USE  ----
% Suppose we have already extracted flair, t1, t1ce, and t2 from a given
% set of brains. In order to get the features, we simply call the function
% as shown below:
%
% GF = GetWindowFeatures(flair,t1,t1ce,t2);
%

if isempty(psize)
    psize = 5;
end


% initialize stuff
phalf = (psize-1)/2;% window size is 5x5x5
mods = length(varargin);
[vert,horz,slc_per_brn,brns] = size(varargin{1});
tot_vox = slc_per_brn* brns * vert * horz;  
feats_per_mod = 2; % mean,median,variance,skewness,kurtosis

% values w/zero padding
vertpd = vert + phalf*2;
horzpd = horz + phalf*2;
slcpd= slc_per_brn + phalf*2;

% index to remove zero pads
d1_idx = (phalf + 1):(vert + phalf);
d2_idx = (phalf + 1):(horz + phalf);
d3_idx = (phalf + 1):(slc_per_brn + phalf);
[ii,jj,kk] = meshgrid(d1_idx,d2_idx,d3_idx);
ii = ii(:);
jj = jj(:);
kk = kk(:);
lin_ext_ind = sub2ind([vertpd, horzpd, slcpd, brns],jj,ii,kk);
clear ii jj kk
lin_ext_ind = lin_ext_ind(:);

% add for however many brains we need
if brns == 1
	lin_ext_ind = lin_ext_ind(ridx);
else
	%lin_ext_ind = repmat(lin_ext_ind,1,brns) + repmat(0:(brns - 1),length(lin_ext_ind),1 );
	dummy = [];
	for bi = 1:bb
		dummy = [dummy;(lin_ext_ind(ridx{bi}) + (bi - 1)*(vertpd * horzpd))];
	end
	lin_ext_ind = dummy;
end

% Get extraction indices
[~,patch_pp_vec] = PatchIdx(psize,vertpd,horzpd,slcpd,brns,lin_ext_ind);

% Initialize two feature matrices
GF = zeros(length(lin_ext_ind),mods*feats_per_mod*2);

% loop over modalities 
for mm = 1:mods
    % load cur image
    im = varargin{mm};
		im = single(im./max(im(:)));
    im = padarray(im,[phalf phalf phalf]);
    
    % loading index
    ld_idx = (1:feats_per_mod) + (mm-1)*feats_per_mod;
    
    % cur extraction, pull index out
    GFn = im(patch_pp_vec);
		%[mea,vvv,med,ske,kur] = PatchStats(GFn);
		[mea,vvv] = PatchStats(GFn);
    
    % load into matrix
    %GF(:,ld_idx) = [mea,med,vvv,ske,kur];
    GF(:,ld_idx) = [mea,vvv];
    
    % log extraction
    GFn = log(GFn + eps); % use log, but take away zeros
		%[mea,vvv,med,ske,kur] = PatchStats(GFn);
		[mea,vvv] = PatchStats(GFn);
    
    % load into mat
    ld_idx = ld_idx + mods*feats_per_mod;
    %GF(:,ld_idx) = [mea,med,vvv,ske,kur];
    GF(:,ld_idx) = [mea,vvv];
end

GF(isnan(GF) ) = 0;

end

