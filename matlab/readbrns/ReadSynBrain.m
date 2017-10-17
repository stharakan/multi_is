function [ tot_im,tot_sg,figh] = ReadSynBrain(nf,slc_idx,nfb,slb, plotter )
%READSYNBRAINS mimics the actions of readfiles, but as a function. nf
%specifies the number of brains we will choose, and from each brain we will
%pick the slices corresponding to slc_idx. The output is two 4-D matrices,
%im and sg, for the image and the segmentation respectively. The dimensions
%correspond to [mri dim1, mri dim2, slices, brains].

if nargin < 5
    plotter = false;
end
if nargin < 4
    slb = 124;
elseif isempty(slb)
    slb = 124;
end
if nargin < 3
    nfb = 6;
elseif isempty(nfb)
    nfb = 6;
end
if nargout > 2
    plotter = true;
end

slcs = length(slc_idx);
if ~slcs
    slcs = 124;
    slc_idx = 1:124;
end

startup; % get syn_dir
fn_base = [syn_dir,'nf',num2str(nfb),'_sl',num2str(slb),'_br'];
tot_sg = zeros(mri_dim,mri_dim,slcs,nf);
tot_im = tot_sg;
% loop over nf, extract into im
for ii = 1:nf
    
    fi = [fn_base,num2str(ii),'.mat'];
    load(fi,'im','sg');
    
    tot_im(:,:,:,ii) = im(:,:,slc_idx);
    tot_sg(:,:,:,ii) = sg(:,:,slc_idx);
    
    if plotter
        ss = slc_idx(ceil(slcs/2));
        
        
        figh = figure;
        subplot(1,2,1), imshow( im(:,:,ceil(end/2)),[] );
        title(['True Image, brn ',num2str(ii),' sl ',num2str(ss)]);
        
        subplot(1,2,2), imshow( sg(:,:,ceil(end/2)),[] );
        title(['Segmentation, brn ',num2str(ii),' sl ',num2str(ss)]);
        
    end
end
end

