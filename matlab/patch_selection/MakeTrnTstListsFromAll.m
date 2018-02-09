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
blist = BrainPointList(bdir,bcell,ps,outdir);

% make splits, keep randomizer the same for same brains
rng(2);
[trn,tst] = blist.SplitAndRound();
end

