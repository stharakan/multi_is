function [nii,pfile] = SaveProbs(save_dir,cur_brn,probs,classes,image_idx,feature_type)
% SAVEPROBS saves probabilty maps for a current brain into 
% nii files.
%
% INPUT
% save_dir - string: directory to store the file
% cur_brn - string with brain name
% probs - array: with probability values
% classes - string: names for each class
% image_idx - array features to voxels maps
% feature_type - string: type of feature to annotate output file
%
% OUTPUT - save file save_dir/cur_brn.feature_type.probclassname.nii.gz


% mri dims 
if strcmp(cur_brn(1:4),'Brat')
    d1 = 240;
    d2 = 240;
    d3 = 155;
else
    d1 = 256;
    d2 = 256;
    d3 = 256;
end

pp = size(probs,2);

%
% handle probs
for pi = 1:pp
	cc = classes{pi};

	% initialize
	img = zeros(d1,d2,d3);
	img(image_idx) = probs(:,pi);
	img = rot90(img,2);

	% make nii, save
	nii = make_nii(img);
	pfile = [save_dir,cur_brn,'.',feature_type,...
		'.probs.',cc ,'.nii.gz'];
	save_nii(nii,pfile);
end

end
