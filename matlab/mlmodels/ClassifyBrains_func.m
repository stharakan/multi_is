function [] = ClassifyBrains_func(section,tot_sections)
addpath([getenv('BRATSREPO'),'/matlab/general/']);
SetPath;
SetVariables;
compute_probabilities = true;

feature_type = feature_types{2};  % 1: int, 2: gabor
modellabels5M={'NOvWT_random_forest_5M', 'ALvED_random_forest_5M'};
modellabels50M={'NOvWT_random_forest_50M', 'NOvWT_naive_bayes_50M'};
modellabelsSC = {'EDvTC_random_forest_25M','ENvNE_random_forest_25M'};
modellabel = modellabels50M{1};
%modellabel = modellabels5M{1};
%modellabel= modellabelsSC{2};
classes = {'NO','WT'};
%classes = {'AL','ED'};
%classes = {'TC','ED'};
%classes = {'NE','EN'};
%classes = {'TC1','ED1'};


% directories
feature_dir = brats17tst_features_dir;
feature_dir = [brats,'/classification/trainingfeatures/'];
save_dir = [brats,'/userbrats/BRATS17tharakan/trainingfeatures_results/',modellabel,'_',feature_type,'/']; % directory where images should be saved to

if ~exist(save_dir,'dir'), system(['mkdir ',save_dir]); end

%%
% Trained model file
modelfile = [modellabel,'.',feature_type,'.mat'];
modelfile = [training_model_dir,modelfile];

% Run on test brain
%brains = {brats17val_brains{[6:3,13:16,21:21,30:32,end-2,end-1,end]}};
%brats17tst_brains = GetBrnList(brats17tst_original_dir); 
brain_dir = [brats,'/preprocessed/trainingdata/LGG/pre-norm-aff/'];
brains = GetBrnList(brain_dir) ;

brns = length(brains);
section_idx = GetSectionIdx(section,tot_sections,brns);
brains = brains(section_idx);

for j=1:length(brains)
  br = brains{j};

  fprintf('Processing  brain %d out of %d subjects, named %s\n',j,length(brains),br);
  if compute_probabilities
    [ Yte,image_idx,probs ] = BinaryPredict( modelfile,feature_type,feature_dir,br );
    
    fprintf('Saving probs');
    SaveProbs(save_dir,br,probs,classes,image_idx,feature_type);
  else

    [ Yte,image_idx] = BinaryPredict( modelfile,feature_type,feature_dir,br );
    fprintf('Saving segmentation\n');
    SaveSeg(save_dir,br,Yte,image_idx,feature_type);
  end
  
  if j==1, modelfile = []; end;

end
end
