function [  ] = SaveProbsNii( P,brns,hdr,feat_select,dir )
%SAVEPROBSNII saves probability maps from P into nii files. Each brain and
%class (column of P) defines a different .nii.gz file. The files are saved
%into dir, which defaults to penn_out_dir. hdr is used to pass in voxel
%dimension info, as well as origin info. If it is not present, the defaults
%are used. 

if nargin < 5
    startup;
    dir = penn_out_dir;
end

if nargin < 4
	feat_select = 'na';
end

hflag = true;
dims = [192 256 192];
if nargin < 3
    % no header file
    hflag = false;
elseif isempty(hdr)
    % no header file
    hflag = false;
else
    % have a header
    dims = hdr.dime.dim(2:4);
end

[tot_nn,cc] = size(P);
bb = length(brns); % should be cell array with name of each brain
im3dsize = tot_nn/bb;
vsize = hdr.dime.pixdim(1:3);
orig = hdr.hist.originator(1:3);



for bi = 1:bb
    % indx to pick out portion of brain
    bidx = (1:im3dsize)' + (bi-1)*im3dsize;
    cur_brn = brns{bi};
    fbase = [dir,cur_brn,'_',feat_select,'_pmap_'];
    
    for ci = 1:cc
        % get img, loc
        sv_file = [fbase,num2str(ci-1),'.nii.gz'];
        img = reshape(single(P(bidx,ci)),dims);
        img = rot90(img,2);
        
        % make nii
        if hflag
            nii = make_nii(img,vsize,orig);
        else
            nii = make_nii(img);
        end
        
        % save nii
        save_nii(nii,sv_file);
    end

		fbase_seg = [dir,cur_brn,'_',feat_select,'_seg.nii.gz'];
		fbase_probs = [dir,cur_brn,'_',feat_select,'_probs.nii.gz'];
		[maxP,idxP] = max(P(bidx,:),[],2);
		maxP = rot90(reshape(maxP,dims),2);
		maxP = single(maxP);

		idxP = rot90(reshape(idxP,dims),2);
		idxP = Idx2Seg_MyPenn(idxP);
		% make nii
		if hflag
			nii = make_nii(maxP,vsize,orig);
			nii2 = make_nii(idxP,vsize,orig);
		else
			nii = make_nii(maxP);
			nii2 = make_nii(idxP);
		end
		
		save_nii(nii,fbase_probs);
		save_nii(nii2,fbase_seg);
end

end

