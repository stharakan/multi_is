function [hb_idx, nnp] = FarTumorIdx(nnp,seg,flair)
% FARTUMORIDX is a function that pulls nnp randomly
% selected pixels from the area of the brain that is 
% healthy (according to seg) and not background 
% (according to flair).

% Full idx
healthy_brain = 1:numel(flair);

% Other indices
brain_idx = flair ~= 0;
notum_idx = seg == 0;

% No tumor + not bg 
healthy_brain = healthy_brain(brain_idx & notum_idx);
nnp = min(nnp,length(healthy_brain));

% Subsample
hb_idx = randsample(healthy_brain,nnp);

end
