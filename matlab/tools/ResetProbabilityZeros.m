function [ P ] = ResetProbabilityZeros( P )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
P(P == 0) = eps('single');
P(P == 1) = 1 - eps('single');

end

