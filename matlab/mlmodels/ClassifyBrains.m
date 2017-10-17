SetPath;
SetVariables;
compute_probabilities = true;

feature_type = feature_types{2};  % 1: int, 2: gabor
modellabels5M={'NOvWT_random_forest_5M', 'ALvED_random_forest_5M'};
modellabels50M={'NOvWT_random_forest_50M', 'NOvWT_naive_bayes_50M'};
modellabelsSC = {'EDvTC_random_forest_25M','ENvNE_random_forest_25M'};
%modellabel = modellabels50M{1};
modellabel= modellabelsSC{2};
%classes = {'NO','WT'};
%classes = {'AL','ED'};
%classes = {'TC','ED'};
classes = {'NE','EN'};
%classes = {'TC1','ED1'};


% directories
feature_dir = brats17val_features_dir;
save_dir = './results/'; % directory where images should be saved to

%%
% Trained model file
modelfile = [modellabel,'.',feature_type,'.mat'];
modelfile = [training_model_dir,modelfile];

% Run on test brain
brains = {brats17val_brains{[6:3,13:16,21:21,30:32,end-2,end-1,end]}};

for j=1:length(brains)
  br = brains{j};

  fprintf('Processing  brain %2 out of %d subjects, named %s\n',j,length(brains),br);
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
