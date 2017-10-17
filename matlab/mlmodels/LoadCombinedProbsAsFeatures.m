function feature_mat = LoadCombinedProbsAsFeatures(brain,probs_dir,probtypes,idx)
% Loads a feature matrix of the specified brain by loading the probtypes 
% that correspond to that brain from probs_dir. If an idx is specified,
% it subselects that index. Also assumes SetPath, etc. have been called.

dd = length(probtypes);
feature_mat = [];	
idxflag = false;

if ~iscell(probs_dir)
	const_probs_dir = true;
	cur_probs_dir = probs_dir;
else
	d2 = length(probs_dir);
	if d2 ~= dd
		error('probs_dir and probtypes do not match!!');
	end
	const_probs_dir = false;
end


if nargin > 3
	% idx exists
	nn = length(idx);
	idxflag = true;
	feature_mat = zeros(nn,dd,'single');
end

% Loop over directories to get images
for di = 1:dd
	% pick out directory
	cur_prob_type = probtypes{di};

	if ~const_probs_dir
		cur_probs_dir = probs_dir{di};
	end
	
	% find file  
	ff = [brain,'.',cur_prob_type,'.nii.gz'];
	nii = load_untouch_nii([cur_probs_dir,ff]);
	cur_probs = single(nii.img(:));	
	
	% load into 
	if idxflag
		feature_mat( : , di) = cur_probs(idx);
	else
		feature_mat(: , di) = cur_probs;
	end
end






end 
