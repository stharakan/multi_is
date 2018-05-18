function [svals] = GetSegVals(blist)

svals = zeros(blist.tot_points,1);

for bi=1:blist.num_brains
    % extract relevant indices
    brain = blist.MakeBrain(bi);
    idx = blist.pt_inds{bi};

    % Read all modalities
    [seg] = brain.ReadSeg();

    % cur y extract
    cury = seg(idx);

    % load into full matrix
    svals(blist.WithinTotalIdx(bi)) = cury;
end


end
