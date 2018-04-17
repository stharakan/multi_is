function [ Pn ] = NormalizeClassProbabilities( P )
%NORMALIZECLASSPROBABILITIES normalizes an n x c matrix P of n points'
%probabilities in c classes so that each row sums to 1.

P = ResetProbabilityZeros(P);
psums = sum(P,2);
Pn = bsxfun(@rdivide,P,psums);

end

