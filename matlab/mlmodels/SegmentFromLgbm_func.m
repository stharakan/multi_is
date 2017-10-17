function [] = SegmentFromLgbm_func(section,tot_sections)

% params
mdl_type = 'ENvNE';
mdl_type = 'EDvTC';
mdl_type = 'NOvWT'; 
feature_type = 'gabor';
classes = {mdl_type(1:2), mdl_type(4:5)};

% directory info
addpath([getenv('BRATSREPO'),'/matlab/general/'])
SetPath;
SetVariablesTACC;
save_dir = [getenv('SCRATCH'),'/meanrenormTst_results/',classes{1},'v',classes{2},'.lgbmrenorm.',feature_type,'/'];
if ~exist(save_dir,'dir')
	system(['mkdir ',save_dir]);
end
idx_dir = [brats,'/classification/meanrenorm/meanrenormTst/'];
prob_dir = [getenv('SCRATCH'),'/meanrenormTst_results/'];
brain_dir = [brats,'/preprocessed/augTestData/meanrenorm/'];
brain_list = GetBrnList(brain_dir);
%hgg_brain_dir = [brats,'/preprocessed/trainingdata/HGG/pre-norm-aff/'];
%hgg_brain_list = GetBrnList(hgg_brain_dir);
%lgg_brain_dir = [brats,'/preprocessed/trainingdata/LGG/pre-norm-aff/'];
%lgg_brain_list = GetBrnList(lgg_brain_dir);
%brain_list = hgg_brain_list;
%brain_list = lgg_brain_list;


brns = length(brain_list);
bpsect = floor(brns/tot_sections);
%if section == tot_sections
%	section_idx = (1 + (section - 1)*bpsect):brns;
%else
%	section_idx = (1:bpsect) + (section - 1)*bpsect;
%end
section_idx = GetSectionIdx(section,tot_sections,brns);

brain_list = brain_list(section_idx);

for bi = 1:length(brain_list)
	cur_brn = brain_list{bi};
	disp(['Saving probabilities for brain ', cur_brn, ' and model ',mdl_type]);

	% make sure it is a brain
	if ~strcmp(cur_brn( (end-2):end ),'.sh') && ~strcmp(cur_brn, 'Brats17_2013_10_1')
		% prob file name
		prob_file = [cur_brn,'.probs.lgbmrenorm.',mdl_type,'.',feature_type,'.bin'];
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
		%SaveProbs(save_dir,cur_brn,probs1,classes(2),image_idx,feature_type);
		SaveProbs_untouch(save_dir,cur_brn,probs1,classes(2),image_idx,feature_type);

	end

end

%all_nts = all_nts ./ sum(all_nts);
%tot_dice = sum(all_dices .* all_nts);
%disp(['Overall dice: ', num2str(tot_dice)])





end
