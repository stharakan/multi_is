function dice = ComputeDiceScore(guess,truth,target)

if nargin < 3
	target = 1;
end


inter = sum(guess(:) == target & truth(:) == target);
denom =  sum(guess(:) == target) + sum(truth(:) == target);

dice = inter*2/denom;

end

