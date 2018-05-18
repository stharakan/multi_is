function [ Qout ] = QuasiIterateCRF( crf,iters,Qin,seg,pflag )
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

if sflag
    tp = sum(seg(:) == round(Qcur(:,1)));
    qoi = sum(seg(:) == round(Qcur(:,1)))./numel(seg);
    dice = 2*tp/(sum(seg(:)) + sum(round(Qcur(:,1))));
end

if pflag
    fprintf('Accuracy start: %4.2f\n',qoi);
    fprintf('Dice start: %4.2f\n',dice);
end

% options w/ gradient check
%options = optimoptions(@fminunc,'MaxIterations',iters,'CheckGradients',true,'Display','iter');
%options = optimoptions(@fminunc,'MaxIter',iters,'DerivativeCheck','on','Algorithm','quasi-newton','Display','iter');

% options w/o gradient check
options = optimoptions(@fminunc,'MaxIterations',iters,'Display','iter');
%options = optimoptions(@fminunc,'MaxIter',iters,'Algorithm','quasi-newton','Display','iter');

% function and gradient
fun = @(Q) double(crf.FunctionAndGradient(Q));
Qcur = fminunc(fun,double(Qcur),options);

% Post process
Qcur = NormalizeClassProbabilities(Qcur);

% qoi compute if possible
if sflag
    tp = sum(seg(:) == round(Qcur(:,1)));
    qoi = sum(seg(:) == round(Qcur(:,1)))./numel(seg);
    dice = 2*tp/(sum(seg(:)) + sum(round(Qcur(:,1))));
end

% print if needed
if pflag
    fprintf('Accuracy final: %4.2f\n',qoi);
    fprintf('Dice final: %4.2f\n',dice);
end

% set up output
Qout = Qcur;


end

