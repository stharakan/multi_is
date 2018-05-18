function [file1s fileyy,filero,filecm] = GeneratePotentialFiles(pfile,ftype,bw)

suffix = ['h.',num2str(bw),'.pot'];
potfile = strrep(pfile,'bin',suffix);
file1s = strrep(potfile,'ppv',['trn.',ftype,'.1s']);
fileyy = strrep(potfile,'ppv',['trn.',ftype,'.yy']);

filero = strrep(potfile,'ppv',['trn.',ftype,'.ro']);
filecm = strrep(potfile,'ppv',['trn.',ftype,'.cm']);



end
