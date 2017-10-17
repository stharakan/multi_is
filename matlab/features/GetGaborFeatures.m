function [ GF_tot ] = GetGaborFeatures( varargin )
%GETGABORFEATURES will get the given gabor features on possibly multimodal
%data. For each of the m modalities, it will run 72 different 2-D Gabor
%filters on each slice given. 
%
% ----- HOW TO USE  ----
% Suppose we have already extracted flair, t1, t1ce, and t2 from a given
% set of brains. In order to get the features, we simply call the function
% as shown below:
%
% GF = GetGaborFeatures(flair,t1,t1ce,t2);
%
% If we want to use filenames to call these features, see
% CreateGaborFeatures, which can also save features to a binary file.
%


modalities = length(varargin);

% Set up which filters to use, hard-coded
sfbs = single([0.7 1 2.5]); 
ws = single([2 4 8]);
no = single(8); 
ang_max = single(180 - ( (180)/no ));
os = single(linspace(0,ang_max,no));
bwtot = length(sfbs);
nw = length(ws);

% Initialize gaborfilter array
gaborfilts = repmat(gabor(ws,os,'SpatialFrequencyBandwidth',...
    sfbs(1)),1,bwtot);

for ss = 2:bwtot
    bw = single(sfbs(ss));
    gab_curr = gabor(ws,os,'SpatialFrequencyBandwidth',bw);
    
    gidx = (1:nw*no) + (ss-1)*nw*no;
    gaborfilts(gidx) = gab_curr;
end


[pps,~,slc_per_brn,brns] = size(varargin{1}); % should be the same across mods
tot_slcs = brns*slc_per_brn;
gg = length(gaborfilts);
wav_vec = zeros(1,1,gg);
for ii = 1:gg
	wav_vec(ii) = gaborfilts(ii).Wavelength;
end

GF_tot = zeros(pps*pps*tot_slcs,gg*modalities,'single');


% loop over modalities
for mm = 1:modalities
	im = varargin{mm};
	%im = single(im./max(im(:)));
	
	GF = zeros(pps,pps,gg,tot_slcs,'single');
	
	
	for ss = 1:tot_slcs
     % indexing
     cur_brn = ceil(ss/slc_per_brn);
     cur_slc = mod(ss,slc_per_brn);
     if cur_slc == 0
         cur_slc = slc_per_brn;
     end
     
     % pick out current image
     cur_im = im(:,:,cur_slc,cur_brn);


 		% check if im is all zeros?
 		sv_count = 0;
 		if norm(cur_im(:)) < eps
 			% dont need to compute
 			Gm = zeros(pps,pps,gg);
 			sv_count = sv_count + 1;
 		else
     	% Gabor business -> throw away phase, compensate for wav
     	[Gm,~] = imgaborfilt(cur_im,gaborfilts);
     	Gm = bsxfun(@rdivide, Gm,wav_vec.^2);
		end
     
		% Load into full mat
    GF(:,:,:,ss) = single(Gm);
 	end
				
	%disp(['Saved ',num2str(sv_count),' out of ',num2str(tot_slcs)]);
  
  % Reorganize GF, currently pps x pps x gg x tot_slcs
  % change to --> pps x pps x tot_slcs x gg
  GF = permute(GF,[1 2 4 3]);
  % change to --> (pps * pps * tot_slcs) x gg?
  GF = reshape(GF,[],size(GF,4));
  %GF = GF(im(:) ~= 0,:); % remove zeros
  
  
  % load into GF tot
  mm_idx = (1:gg) + (mm-1)*gg;
  GF_tot(:,mm_idx) = GF;
  
end

end

