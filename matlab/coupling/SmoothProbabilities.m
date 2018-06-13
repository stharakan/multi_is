function [ output_args ] = SmoothProbabilities( probs,smoothing_bw )
%SmoothProbabilities smooths given probs by a gaussian filter of bandwidth
%bw.

probs = imgaussfilt(probs,smoothing_bw);

probs = max(probs,0);
probs = min(probs,1);


end

