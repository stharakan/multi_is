function [Xtr, Ytr] = subsample_data_from_rank(Xtrain,Ytrain,rank)

rank_adjustment = 10; % output datasize is at most rank * 10
nsub = rank * rank_adjustment;

% Get index
idx = get_subsample_idx(Ytrain,nsub);

% subsample
Xtr = Xtrain(idx,:);
Ytr = Ytrain(idx);


end