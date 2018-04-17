function [idx] = SelectSliceEdemaMax(ps,brain)
%SELECTRANDOM randomly selects ppb points from 
% all the points that have a nonzero 
% flair component for the given brain. 

% get params
slices = ps.ppb;

% read seg
seg = brain.ReadSeg();
imsize = size(seg,1) * size(seg,2);
target =2;
seg = reshape(seg,imsize,[]);
edema_per_slice = sum(seg == target);
tot_slices = size(seg,2);

% find top n slices
[~,edidx] = sort(edema_per_slice,'descend');
slc_idx = edidx(1:min(slices,tot_slices));
counter=0;
for si = 1:length(slc_idx)
    idx((counter+1):(counter+imsize)) = (slc_idx(si)-1)*imsize + (1:imsize);
    counter = counter + imsize;
end

end