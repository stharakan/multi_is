function [ Pf ] = CRFSingleBrain( brain,pdir,pstr,dsfac,bws,crfmethod )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

% params
crfiters = 10;

% load brain images + seg
[flair,t1,t1ce,t2,seg] = brain.ReadAll;
im1 = size(flair,1);im2 = size(flair,2);
slices = size(flair,3);
slice_list = 1:slices;
slices = 1;
slice_list = 78;

% load brain probabilities
probs = brain.ReadProbs(pdir,pstr);

% initialize zero stuff
curim = zeros(im1,im2,4);
Pf = zeros(im1, im2,slices);

% loop over slices 
for si = 1:slices
    slice = slice_list(si);
    fprintf('Slice %d of %d\n',si,slices);
    
    % load images
    curim(:,:,1) = flair(:,:,slice);
    curim(:,:,2) = t1(:,:,slice);
    curim(:,:,3) = t1ce(:,:,slice);
    curim(:,:,4) = t2(:,:,slice);
    imseg= single(seg(:,:,slice) == 2);
    unary = single(probs(:,:,slice));
    
    % downsample
    downim = imresize(curim,dsfac,'bilinear');
    downseg = imresize(imseg,dsfac,'bilinear');
    downseg = round(downseg);
    downun = imresize(unary,dsfac,'nearest');
    [d1,d2] = size(downseg);
    downun = [downun(:),1 - downun(:)];
    
    % initial dice
    dice = ComputeDiceScore(downseg(:),round(downun(:,1)),1);
    fprintf('Initial dice %4.2f\n',dice);

    % initialize crf
    crf = DenseCRFExact(downim,bws,[],downun);
    
    % run iterations based on method choice
    switch crfmethod
        case 'klmin'
            Qf = KLMinIterateCRF(crf,crfiters,[],downseg);
        case 'quasi'
            Qf = QuasiIterateCRF(crf,crfiters,[],downseg);
    end
    
    % upsample probs, load into full mat
    dice = ComputeDiceScore(downseg(:),round(Qf(:,1)),1);
    fprintf('Final dice %4.2f\n',dice);
    upprobs = imresize( reshape(Qf(:,1),d1,d2), 1/dsfac, 'bilinear');
    acc = sum( round(upprobs(:)) == imseg(:) )/(im1*im2);
    fprintf('Slice accuracy: %3.2f\n',acc);
    fprintf('---------------------\n');
    Pf(:,:,si) = upprobs;
end

% save final probs with pstr + crfmethod
newpstr = [pstr,'.',crfmethod,'.'];
brain.SaveProbs(Pf,pdir,newpstr);

end

