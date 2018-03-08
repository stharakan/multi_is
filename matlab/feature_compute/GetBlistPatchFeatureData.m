function [ fmat,fcell ] = GetBlistPatchFeatureData( blist,psize,feature_type,outdir )
%GETBLISTPATCHFEATUREDATA gets the feature data for a given list of points in
%blist, for the given patch size psize. feature_type specifies the type of
%features to compute. outdir, if given, will be the location where the data
%matrix is saved.

% deal with outdir
sflag = nargin > 3;

if sflag
    if ~strcmp(outdir,'')
        [dstr] = blist.MakeFeatureDataString(feature_type,psize);
        
        sfile = [outdir,dstr];
        if exist(sfile, 'file')
            % load file
            fid = fopen(sfile,'r');
            fmat = fread(fid,Inf,'single');
            
            % get info and reshape
            fcell = blist.FeatureCell(feature_type,psize);
            dd = length(fcell);
            fmat = reshape(fmat,blist.tot_points,dd);
            return
        end
    else
        sflag = false;
    end
else
    outdir = '';
end

% deal with ftype
switch feature_type
    case 'patchstats'
        [fmat,fcell] = PatchStatsFeatures(blist,psize); 
    case 'patchgabor'
        [fmat,fcell] = PatchGaborFeatures(blist,psize);
    case 'patchgstats'
        [fmat,fcell] = PatchGStatsFeatures(blist,psize,outdir);
    otherwise 
        error('Feature type not found');
end

% save if necessary 
if sflag
    [dstr] = blist.MakeFeatureDataString(feature_type,psize); 
    
    sfile = [outdir,dstr];
    fid = fopen(sfile,'w');
    fwrite(fid,single(fmat),'single');
    fclose(fid);
end

end

