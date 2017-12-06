function [ counts,centers ] = histpdf( samples,nbins )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

[counts,edges] = histcounts(samples,nbins,'Normalization',...
    'probability');
centers = edges(1:(end-1)) + (diff(edges)./2);
end

