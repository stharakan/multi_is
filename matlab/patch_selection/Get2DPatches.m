function patches = Get2DPatches(im,psize,inds)
%GET2DPATCHES takes a given image and a patch size 
% and outputs the prescribed patches at the given 
% indices.

[d1,d2,d3,d4] = size(im);
mat_size = psize*psize*length(inds);

if 0
	% can we do some sort of filtering if num_inds is high?
else
	% explicitly extract all indices at once
  [ ~,p_inds] = PatchIdx2D( psize,d1,d2,d3,d4,inds);
	patches = im(p_inds);
end


end
