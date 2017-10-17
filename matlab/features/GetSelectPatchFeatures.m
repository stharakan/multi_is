function [ GF ] = GetSelectPatchFeatures( psize,ridx, varargin )
%GETSELECTPATCHFEATURES gets the 3^3 patch of intensities from each modality, and
%loads them into a feature vector. For any patch that extends off of the
%image, the additional values are generated periodically. This should not
%be an issue with brain images, as everything around the edge should be 0.
%It further selects the patches given in ridx
%
% ----- HOW TO USE  ----
% Suppose we have already extracted flair, t1, t1ce, and t2 from a given
% set of brains. In order to get the features, we simply call the function
% as shown below:
%
% GF = Get3DPatchFeatures(flair,t1,t1ce,t2);
%

if isempty(psize)
    psize = 3;
end

% zero padding sizes
mods = length(varargin);
phalf = (psize-1)/2;
[vert,horz,slc_per_brn,brns] = size(varargin{1});
tot_vox = vert*horz*slc_per_brn*brns;
vertpd = vert + phalf*2;
horzpd = horz + phalf*2;
slcpd= slc_per_brn + phalf*2;
patch_vol = psize^3;

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
[~,idx_vec2] = PatchIdx(psize,vertpd,horzpd,slcpd,brns,lin_ext_ind);

% Initialize
GF = zeros(length(lin_ext_ind), patch_vol*mods);

for mm = 1:mods
    % load cur image
    im = varargin{mm};
		im = single(im./max(im(:)));
    im = padarray(im,[phalf phalf phalf]);
    
    % loading index
    ld_idx = (1:patch_vol) + (mm-1)*patch_vol;
    
    % Pick out and load into GF
    GF(:,ld_idx) = im(idx_vec2);
end



end

