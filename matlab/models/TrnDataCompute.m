function [  ] = TrnDataCompute( bdir,bcell,outdir, pstr, ps1, psize, ftype, stype, fkeep,target)

% make lists
fprintf('\n\n--------- MAKING LISTS ------------\n\n');
MakeTrnTstListsFromAll( bdir,bcell,outdir,pstr,ps1,psize );

% compute features
fprintf('\n\n--------- FEATURE COMPUTE ------------\n\n');
ComputeFeatures(bdir,outdir,psize,ftype,pstr,ps1);

% select features
fprintf('\n\n--------- FEATURE SELECT ------------\n\n');
SelectFeatures( bdir,outdir,stype,psize,ftype,pstr,ps1,target );

% nn prepocess
fprintf('\n\n--------- PREP FOR KNN  ------------\n\n');
PreprocessForKNN(bdir,outdir,fkeep,stype,psize,ftype,pstr,ps1,target);

end
