function [ figh ] = PlotGaborT1ceBrain( brain_dir,brain,gabors, buf, slices )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% read brain
[~,~,t1ce,~] = ReadIdxBratsBrain(brain_dir,brain);
%t1ce = round(256*rand(240,240,155));

% other info
%seg_slices = seg(:,:,slices);
ss = length(slices);
brn_slices = t1ce(:,:,slices);
gs = length(gabors);
d1 = size(t1ce,1);
d2 = size(t1ce,2);

% get gabor feats
GG = GetSpecificGaborFeatures(gabors,brn_slices);
%GG = rand(d1*d2*ss,gs);
GG = reshape(GG,d1,d2,ss,gs);

% plot, w/loops over ss + gs
figh = figure;

% handle first column
for gi = 1:gs
    si = 0;
    cur_im = real(gabors(gi).SpatialKernel);
    lam = gabors(gi).Wavelength;
    sig = GetBwFromOthers(gabors(gi).SpatialFrequencyBandwidth,lam);
    subplot('Position',SubplotPosititionVector(buf,si,gi-1,ss+1,gs+1))
    imshow(cur_im,[]);
    title(sprintf('\\lambda = %d, \\sigma = %2.1f',lam, sig));
end

% handle first row 
for si = 1:ss
    gi = gs;
    cur_im = brn_slices(:,:,si);
    subplot('Position',SubplotPosititionVector(buf,si,gi,ss+1,gs+1))
    imshow(cur_im,[0 256]);
    title(sprintf('slice = %d',slices(si) ));
end

% loop over rest
for si = 1:ss
    for gi = 1:gs
        cur_im = GG(:,:,si,gi);
        subplot('Position',SubplotPosititionVector(buf,si,gi-1,ss+1,gs+1))
        imshow(cur_im,[]);
    end
end


end

