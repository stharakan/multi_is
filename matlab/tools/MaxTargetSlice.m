function slice = MaxTargetSlice(brain,target)
% MAXTARGETSLICE picks out the slice of the brain with the 
% largest number of "target" pixels. Here target corresponds 
% to 
% 
% 0 - Means healthy, but returns slice with whole tumor
% 1 - Necrotic
% 2 - Edema
% 4 - Enhancing

if isa(brain,'BrainReader')
  % load seg
  ss = brain.ReadSeg();
else
  ss = brain;
end

% set target
if nargin == 1
  target = 2;
end

% reshape ss, assume 3d
[sz1,sz2,sz3] = size(ss);
ss = reshape(ss,[],sz3);

% find max target
if target
  [m,slice] = max( sum(ss == target,1) );
else
  [m,slice] = max( sum(ss ~= target,1) );
end


end
