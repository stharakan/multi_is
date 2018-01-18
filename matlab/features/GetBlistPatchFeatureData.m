function [ fmat,fcell ] = GetBlistPatchFeatureData( blist,psize,feature_type,outdir )
%GETBLISTPATCHFEATUREDATA gets the feature data for a given list of points in
%blist, for the given patch size psize. feature_type specifies the type of
%features to compute. outdir, if given, will be the location where the data
%matrix is saved. 

% deal with outdir
sflag = nargin > 3 & ~strcmp(outdir,'');

fcell = FeatureCell(feature_type,psize); %TODO
dd = length(fcell);
fmat = zeros(blist.tot_points,dd);

% loop over blist
for bi=1:blist.num_brains
    brain = blist.MakeBrain(bi);
    idx = blist.pt_inds{bi};
    
    switch feature_type
        case stats
            [curfeats] = BrainPatchStats(brain,psize,idx); %TODO
        case gabor
            [curfeats] = BrainPatchGaborStats(brain,psize,idx); %TODO
        case gstats
            [curfeats] = BrainPatchGaborStats(brain,psize,idx); %TODO
    end
    
    fmat(blist.WithinTotalIdx(bi),:) = curfeats;
    
end


end

