function dice = ComputeDiceScore(guess,truth,target)

if nargin < 3
	target = 1;
end

if target
    inter = sum(guess(:) == target & truth(:) == target);
    denom =  sum(guess(:) == target) + sum(truth(:) == target);
else
    inter = sum(guess(:) ~= target & truth(:) ~= target);
    denom =  sum(guess(:) ~= target) + sum(truth(:) ~= target);
end

if inter == 0 & denom == 0
    dice = 1.0;
else
    dice = inter*2/denom;
end
end

