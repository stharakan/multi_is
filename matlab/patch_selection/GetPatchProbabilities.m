function ppvec = GetPatchProbabilities(blist,psize,target,outdir)
%GETPATCHPROBABILITIES loops over blist to generate patch probabilities
% of the target for square patches of size psize. 

% set up outdir flag, check for existing file
if nargin < 4 | strcmp(outdir,'')
	outdir = '';
	save_flag = false;
else
	save_flag = true;

	% check if file exists, if it does, load old
	sfile = blist.MakePPvecFile(psize,target);
	if exist([outdir,sfile],'file')
		% load existing ppvec and exit
		fprintf(' ppvec found, loading from %s\n',[outdir,sfile]);
		fid = fopen([outdir,sfile],'r');
		ppvec = fread(fid,Inf,'double');
		fclose(fid);
		return
	end
end

% set up ppvec
ppvec = zeros(blist.tot_points,1);

% Loop over blist
for bi = 1:blist.num_brains
	% Load seg
	cur_brain = blist.MakeBrain(bi); 
	seg = cur_brain.ReadSeg();
	ppb = length(blist.pt_inds{bi});

	% Get patches
	if ppb*psize*psize < 1e7 %Check what is optimal value?
		seg_patches = Get2DPatches(seg,psize,blist.pt_inds{bi});
		clear seg

		% Output probability averages
		seg_tots = sum(seg_patches == target,2)./(psize*psize);
	else
		im = double(seg == target);
		seg_tots = AveragePatchValues(im,psize,blist.pt_inds{bi}); 
	end

	% Load into large vec
	cur_idx = blist.WithinTotalIdx(bi); 
	ppvec(cur_idx) = seg_tots;
end 

if save_flag
	sfile = blist.MakePPvecFile(psize,target);
	%write binary??
	fprintf(' ppvec made, saving to %s\n',[outdir,sfile]);
	sfile = [outdir,sfile];
	fid = fopen(sfile,'w');
	fwrite(fid,ppvec,'double');
	fclose(fid);
end



end
