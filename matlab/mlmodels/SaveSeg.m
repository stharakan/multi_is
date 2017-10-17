 function [] = SaveSeg(save_dir,val_brn,Yte,image_idx,feature_type)
% INPUT
% save_dir - string: directory to store the file
% val_brn - string with brain name
% Yte - array with classificaiton results
% image_idx - array features to voxels maps
% feature_type - string: type of feature to annotate output file
%
% OUTPUT - save file save_dir/cur_brn.feature_type.seg.nii.gz


if strcmp(val_brn(1:4),'Brat')
    d1 = 240;
    d2 = 240;
    d3 = 155;
else
    d1 = 256;
    d2 = 256;
    d3 = 256;
end

% make zeros for seg img
img = zeros(d1,d2,d3);

% load yte in, rotate
img(image_idx) = Yte;
img = rot90(img,2);

% make nii,, save
nii = make_nii(img);
sfile = [save_dir,val_brn,'.',feature_type, '.seg.nii.gz'];
save_nii(nii,sfile);

end
