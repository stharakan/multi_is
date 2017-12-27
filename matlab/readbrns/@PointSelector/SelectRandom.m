function idx = SelectRandom(ps,brain,ppb)
%SELECTRANDOM randomly selects ppb points from 
% all the points that have a nonzero 
% flair component for the given brain. 


flair = brain.ReadFlair();
idx = find(flair);

if ppb & (ppb < length(idx)) 
	idx = randsample(idx,ppb);
end

end
