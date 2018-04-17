function [ yy ] = GetSegVals( blist,target,outdir )
%GETSEGVALS computes the seg values of each point in the blist. If target
%is specified, this is computed so that points that = target get a value of
%1 and those that do not are assigned -1. Specifying outdir ensures the
%values are saved. 

tflag = true;
if nargin < 2
    % check if target exists
    tflag = false; 
elseif nargin < 3 | strcmp(outdir,'')
    % set up outdir flag, check for existing file
	outdir = '';
	save_flag = false;
else
	save_flag = true;

	% check if file exists, if it does, load old
	sfile = blist.MakePPvecFile(psize,target);
    sfile = strrep(sfile,'ppv','yy');
	if exist([outdir,sfile],'file')
		% load existing ppvec and exit
		fprintf(' yyvec found, loading from %s\n',[outdir,sfile]);
		fid = fopen([outdir,sfile],'r');
		yy = fread(fid,Inf,'double');
		fclose(fid);
		return
	end
end


% set up ppvec
yy = zeros(blist.tot_points,1);

% Loop over blist
for bi = 1:blist.num_brains
	% Load seg
	cur_brain = blist.MakeBrain(bi); 
	seg = cur_brain.ReadSeg();
    im_idx = blist.pt_inds{bi};
    seg_cur = seg(im_idx);
    
    % transform to target if necessary
    if tflag
        tidx = seg_cur == target;
        oidx = seg_cur ~= target;
        
        if target == 0
            seg_cur(tidx) = 0;
            seg_cur(oidx) = 1;
        else
            seg_cur(tidx) = 1;
            seg_cur(oidx) = 0;
        end
    end
    
    % Load into large vec
	cur_idx = blist.WithinTotalIdx(bi); 
	yy(cur_idx) = seg_cur;
end

if save_flag
	sfile = blist.MakePPvecFile(psize,target);
    sfile = strrep(sfile,'ppv','yy');
	%write binary??
	fprintf(' yyvec made, saving to %s\n',[outdir,sfile]);
	sfile = [outdir,sfile];
	fid = fopen(sfile,'w');
	fwrite(fid,ppvec,'double');
	fclose(fid);
end
end

