function ppvec = GetPatchProbabilities(blist,psize,target,outdir)
%GETPATCHPROBABILITIES loops over blist to generate patch probabilities
% of the target for square patches of size psize. 

% set up outdir flag
if nargin < 4
	outdir = '';
	save_flag = false;
else
	save_flag = true;
end

% set up ppvec
ppvec = zeros(blist.tot_points,1);

% Loop over blist
for bi = 1:blist.num_brains
	% Load seg
	cur_brain = blist.MakeBrain(bi); 
	seg = cur_brain.LoadSeg();

	% Get patches
	seg_patches = Get2DPatches(seg,psize,blist.pt_inds{bi});
	clear seg

	% Output probability averages
	seg_tots = sum(seg_patches == target,2)./(psize*psize);

	% Load into large vec
	cur_idx = blist.WithinTotalIdx(bi); 
	ppvec(cur_idx) = seg_tots;
end

if save_flag
	sfile = blist.MakePPvecFile(psize,target);
	%write binary??
	sfile = [outdir,sfile];
	fid = fopen(sfile,'w');
	fwrite(fid,ppvec,'double');
	fclose(fid);
end



end
