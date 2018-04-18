function [ P ] = CreateDummyProbabilities( brain,target,noise )
%CREATEDUMMYPROBABILITIES outputs a probability matrix for a given brain by
%reading its seg file and adding noise to true (aka labeled) probabilities.
%The noise variable corresponds to the std dev of the noise distribution
%(distribution is N(0,noise) ). P is the same size as the image, and is 
%also set to max(min(P,1),0) and is of class single.

% get seg if needed
if isa(brain,'BrainReader')
    seg = brain.ReadSeg();
else
    seg = brain;
end

% find pixels == target
tseg = seg == target;

% add noise
P = tseg + noise.*randn(size(seg),'single');

% normalize
P = max( min(P,1), 0);
end

