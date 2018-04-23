function [means,stds] = GetTrnDataMeansStds(trnlist,psize,ftype,outdir)

% load training data
[ trndata ] = GetBlistPatchFeatureData( trnlist,psize,ftype,outdir );

% whiten
[~,means,stds] = whiten(trndata);
end 
