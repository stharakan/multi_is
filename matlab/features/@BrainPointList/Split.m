function [ trn_blist,tst_blist ] = Split( obj,perc )
%SPLIT splits a given blist into two based on brains. Specifically, it
%chooses perc percentage of brains and extracts the indices from those
%brains to return in trn_blist. The rest of the points are returned in
%tst_blist


if nargin < 2
    perc = 0.8;
end

% set number of brains
nb = obj.num_brains;
nb_trn = round(nb*perc);

% extract indices
trn_idx = randperm(nb,nb_trn);
tst_idx = setdiff(1:nb,trn_idx);

% Go get blists
trn_blist = obj.BlistSubsetFromIdx(trn_idx);
tst_blist = obj.BlistSubsetFromIdx(tst_idx);



end

