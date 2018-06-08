function [ P ] = ResetProbabilityZeros( P )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
ep = eps('single');
%ep = eps;

P(P <= ep) = ep;
P(P >= (1 - ep) ) = 1 - ep;

end

