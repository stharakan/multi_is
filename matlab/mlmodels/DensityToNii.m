function [] = DensityToNii(density_file,density_dir,brn_name,brn_feature_dir) 


%brn_name = ''; Should be the name of the brain
%brn_feature_dir = ''; Where features are located
%density_file = ''; Output density file from kde
%density_dir = ''; Location of density file

% make save_file from density file ('.bin' -> '.nii.gz')
save_file = [density_file(1:(end-3)),'.nii.gz'];
save_dir = density_dir;

% load in density file
fid = fopen([density_dir,density_file],'r');
D = fread(fid,'double'); % idx vector
fclose(fid);

% Load idx
[~,bb] = system(['cd ', brn_feature_dir,' && ls -1 *',...
	brn_name,'*idx*']);
idx_file = bb(1:(end-1));
[fid,message] = fopen([brn_feature_dir,idx_file],'r');
brnidx = fread(fid,'single');
fclose(fid);

% Dimension of images
if strcmp(brn_name(1:4),'Brat')
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
img(brnidx) = D;
img = rot90(img,2);

% make nii,, save
nii = make_nii(img);
sfile = [save_dir,save_file];
save_nii(nii,sfile);

end
