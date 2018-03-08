function [ trn,tst ] = MakeTrnTstListsFromAll( bdir,bcell,outdir,psstr,ps1,ps2 )
%MAKETRNTSTLISTSFROMALL creates training (trn) and testing (tst)
%BrainPointLists. The brains are drawn from bdir, and the brains used are
%specified in bcell. The lists are saved to outdir. The method for
%selecting points is given by the string psstr and the params ps1 and ps2.

% make pointselector
if ~exist('ps2','var')
    ps = PointSelector(psstr,ps1);
else
	if isempty(ps2)
    ps = PointSelector(psstr,ps1);
	else
    ps = PointSelector(psstr,ps1,ps2);
	end
end

% handle bcell
if strcmp(bcell,'alltrn')
    bcell = BrainCellAllTrain();
end 
    
% make total list
fprintf('Computing all points ..\n');
blist = BrainPointList(bdir,bcell,ps,outdir);

% make splits, keep randomizer the same for same brains
fprintf('Splitting and rounding ..\n');
rng(2);
[trn,tst] = blist.SplitAndRound();

% save lists
fprintf('Saving to file ..\n');
trn.SaveList(outdir);
tst.SaveList(outdir);

fprintf('Training list: \n')
trn.PrintListInfo();

fprintf('Testing list: \n')
tst.PrintListInfo();


end

