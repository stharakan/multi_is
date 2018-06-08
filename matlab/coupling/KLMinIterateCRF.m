function [ Qout ] = KLMinIterateCRF( crf,iters,Qin,seg,pflag )
%KLMINITERATECRF calculates iters number of iterations of the crf problem
%as solved by minimizing the KL divergence. crf is assumed to be a crf
%structure object. Qout is the final probability matrix, and pflag
%determines printing, while fflag is for figure generation. (defaults are
%false). 
%

sflag = true;
if nargin < 5
    pflag = true;
end

% if Qin isn't there, use unary probs
if isempty(Qin)
    Qin = crf.unary;
end

% if seg isn't there, can't compute qoi
if nargin <= 3
    sflag = false;
    qoi = -1;
elseif isempty(seg)
    sflag = false;
    qoi = -1;
end

Qcur = Qin;


if pflag
    PrintIterationInfo();
    [f0,g0] = crf.FunctionAndGradient(Qin);
    
    if sflag
        %qoi = sum(seg(:) == round(Qcur(:,1)))./numel(seg);
        qoi = ComputeDiceScore(seg(:),round(Qcur(:,1)),1);
    end
    
    PrintIterationInfo(0,g0,f0,g0,qoi);
end


% iteration loop
for ii = 1:iters
    % get message
    m = crf.PairwiseMessage(Qcur);
    
    % update
    Qcur = exp(-m) .* crf.unary;
    
    % normalize
    Qcur = NormalizeClassProbabilities(Qcur);
    
    % Compute qoi if possible
    if sflag
        %qoi = sum(seg(:) == round(Qcur(:,1)))./numel(seg);
        qoi = ComputeDiceScore(seg(:),round(Qcur(:,1)),1);
    end
    
    
    % spit out function stats
    if pflag
        [fc,gc] = crf.FunctionAndGradient(Qcur);
        PrintIterationInfo(ii,g0,fc,gc,qoi);
    end
end

Qout = Qcur;


end

