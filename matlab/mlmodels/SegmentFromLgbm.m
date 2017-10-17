% params
mdl_type = 'ENvNE';
feature_type = 'gabor';
classes = {mdl_type(1:2), mdl_type(4:5)};

% directory info
addpath('./../general/')
SetPath;
SetVariables;
save_dir = [brats,'/userbrats/BRATS17tharakan/augTestData_results/',classes{1},'v',classes{2},'.lgbm.',feature_type,'/'];
save_dir = [brats,'/userbrats/BRATS17tharakan/trainingfeatures_results/',classes{1},'v',classes{2},'.lgbm.',feature_type,'/'];
if ~exist(save_dir,'dir')
	system(['mkdir ',save_dir]);
end
%idx_dir = [brats,'/classification/augTestData/'];
%prob_dir = [brats,'/userbrats/BRATS17tharakan/augTestData_results/lgbm_results/'];
%brain_dir = [brats,'/augTestData/'];
%brain_list = GetBrnList(brain_dir);


idx_dir = [brats,'/classification/trainingfeatures/'];
prob_dir = [brats,'/userbrats/BRATS17tharakan/trainingfeatures_results/lgbm_results/'];
hgg_brain_dir = [brats,'/preprocessed/trainingdata/HGG/pre-norm-aff/'];
hgg_brain_list = GetBrnList(hgg_brain_dir);
lgg_brain_dir = [brats,'/preprocessed/trainingdata/LGG/pre-norm-aff/'];
lgg_brain_list = GetBrnList(lgg_brain_dir);
%brain_list = hgg_brain_list;
brain_list = lgg_brain_list;

brain_list;

for bi = 1:length(brain_list)
	cur_brn = brain_list{bi};
	disp(['Saving probabilities for brain ', cur_brn, ' and model ',mdl_type]);

	% make sure it is a brain
	if ~strcmp(cur_brn( (end-2):end ),'.sh')
		% prob file name
		prob_file = [cur_brn,'.probs.lgbm.',mdl_type,'.',feature_type,'.bin'];
		disp(prob_file)

		% recover probabilities, create matrix
		ff = fopen([prob_dir,prob_file],'r');
		probs1 = fread(ff,Inf,'single');
		fclose(ff);
		probs1 = probs1(:); probs0 = 1 - probs1;
		probs = [probs0,probs1];

		% load index file
		[~,bb] = system(['cd ',idx_dir,' && ls ./',cur_brn,'*idx.bin -1']);
		idx_file = strtrim(bb);
		ff = fopen([idx_dir,idx_file],'r');
		image_idx = fread(ff,Inf,'single');
		fclose(ff);

		if 0
		% Print accuracies?
		[~,bb] = system(['cd ',idx_dir,' && ls ./',cur_brn,'*labs.bin -1']);
		labs_file = strtrim(bb);
		ff = fopen([idx_dir,labs_file],'r');
		Ytest = fread(ff,Inf,'single');
		fclose(ff);

		Ygues = probs1 > 0.5;
		Ytest = Ytest ~= 0;

		D = confusionmat(Ytest,Ygues);
		dices = (2*D(end)) / (2 * D(end) + D(2) + D(3) );
		all_dices(bi) = dices;
		all_nts(bi) = length(Ytest);
		disp(['Cur dice WT: ',num2str(dices)]);
		end



		% Save probabilities
		SaveProbs(save_dir,cur_brn,probs1,classes(2),image_idx,feature_type);

	end

end

%all_nts = all_nts ./ sum(all_nts);
%tot_dice = sum(all_dices .* all_nts);
%disp(['Overall dice: ', num2str(tot_dice)])

