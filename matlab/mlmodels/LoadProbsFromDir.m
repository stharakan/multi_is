function cur_im_cell = LoadProbsFromDir(brain,cur_dir,cur_prob_types)

pp = length(cur_prob_types);
cur_im_cell = cell(1,pp); 


for pi = 1:pp
% get file name
filenm = [cur_dir,brain,'.',cur_prob_types{pi},'.nii.gz'];

% and image
im_nii = load_untouch_nii(filenm);

cur_im_cell{pi} = im_nii.img;
end

end



