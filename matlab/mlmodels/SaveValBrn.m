function [] = SaveValBrn(sv_dir,cur_brn,probs,yte,idx,feat)


% mri dims 
d1 = 240;
d2 = 240;
d3 = 150;
labs = [0 1 2 4];

% handle probs
for pi = 1:4
	cc = labs(pi);

	% initialize
	img = zeros(d1,d2,d3);
	img(idx) = probs(:,pi);
	img = rot90(img,2);

	% make nii, save
	nii = make_nii(img);
	pfile = [sv_dir,cur_brn,'/',cur_brn,'.',feat,...
		'.probs.',num2str(cc) ,'.nii.gz']
	save_nii(nii,pfile);
end




% make zeros for seg img
img = zeros(d1,d2,d3);

% load yte in, rotate
img(idx) = yte;
img = rot90(img,2);

% make nii,, save
nii = make_nii(img);
sfile = [sv_dir,cur_brn,'/',cur_brn,'.',feat, '.seg.nii.gz'];
save_nii(nii,sfile);


end
