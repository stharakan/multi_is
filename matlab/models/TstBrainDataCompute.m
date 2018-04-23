function [  ] = TstBrainDataCompute( bdir,bname,outdir, pstr, ps1, psize, ftype, stype, fkeep,target)

% make lists
fprintf('\n\n--------- MAKING BRAIN ------------\n\n');
brain = BrainReader(bdir,bname);

% compute features
fprintf('\n\n--------- FEATURE COMPUTE ------------\n\n');
GetBrainPatchFeatureData( brain,ftype,psize,outdir );

% select features
fprintf('\n\n--------- FEATURE SELECT ------------\n\n');
SelectTestFeatures( brain,bdir,outdir,ftype,psize,pstr,ps1,stype,fkeep,target );

end
