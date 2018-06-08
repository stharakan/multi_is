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
    qoi = sum(seg(:) == round(Qcur(:,1)))./numel(seg);
    dice = ComputeDiceScore(seg(:),round(Qcur(:,1)),1);
end

if pflag
    fprintf('Accuracy start: %4.2f\n',qoi);
    fprintf('Dice start: %4.2f\n',dice);
end

% options w/ gradient check
%options = optimoptions(@fminunc,'MaxIterations',iters,'CheckGradients',true,'Display','iter');
%options = optimoptions(@fminunc,'MaxIterations',iters,'Display','iter-detailed','SpecifyObjectiveGradient',true,'OptimalityTolerance',1e-10,'DerivativeCheck','on','FiniteDifferenceType','central');

% options w/o gradient check

% function and gradient
fun = @(Q) crf.FunctionAndGradient(Q);
fun = @(Q) TestFunc(Q,crf);

% unc
%options = optimoptions(@fminunc,'MaxIterations',iters,'Display','iter-detailed','SpecifyObjectiveGradient',false,'OptimalityTolerance',1e-10,'FiniteDifferenceType','central');
options = optimoptions(@fminunc,'MaxIterations',iters,'Display','iter-detailed','SpecifyObjectiveGradient',true,'OptimalityTolerance',1e-10,'FiniteDifferenceType','central');
Qcur = NormalizeClassProbabilities(Qcur);
Qcur = fminunc(fun,double(Qcur),options);

% con
%nn = size(Qcur,1);
%options = optimoptions(@fmincon,'Algorithm','sqp','MaxIterations',iters,'Display','iter-detailed','SpecifyObjectiveGradient',true,'OptimalityTolerance',1e-10);
%Qcur = fmincon(fun,double(Qcur),[],[],[speye(nn),speye(nn)] ,ones(nn,1),zeros(nn*2,1),ones(nn*2,1),[], options);

% Reset probs
Qcur = NormalizeClassProbabilities(Qcur);

% qoi compute if possible
if sflag
    qoi = sum(seg(:) == round(Qcur(:,1)))./numel(seg);
    dice = ComputeDiceScore(seg(:),round(Qcur(:,1)),1);
end

% print if needed
if pflag
    fprintf('Accuracy final: %4.2f\n',qoi);
    fprintf('Dice final: %4.2f\n',dice);
end

% set up output
Qout = Qcur;


end

function [f,g] = TestFunc(bla,crf)
  [f,g] = crf.FunctionAndGradient(bla);
  %f = -f;
  %g = -g;

end
