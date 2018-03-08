function [file1s fileyy] = GeneratePotentialFiles(pfile,ftype,bw)

suffix = ['h.',num2str(bw),'.pot'];
potfile = strrep(pfile,'bin',suffix);
file1s = strrep(potfile,'ppv',['trn.',ftype,'.1s']);
fileyy = strrep(potfile,'ppv',['trn.',ftype,'.yy']);




end
