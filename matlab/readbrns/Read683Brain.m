function [ im,sg ] = Read683Brain( nf,slc_idx,plotter )
%READ683BRAIN mimics the actions of readfiles, but as a function. nf
%specifies the number of brains we will choose, and from each brain we will
%pick the slices corresponding to slc_idx. The output is two 4-D matrices,
%im and sg, for the image and the segmentation respectively. The dimensions
%correspond to [mri dim1, mri dim2, slices, brains]. 

if nargin < 3
    plotter = false;
end
slcs = length(slc_idx);
    

startup; % get brn_dir

% create an array with file names. 
[~,files]=system(['cd ',brn_dir,' && ls -1 *segmented*.hdr']);
m = 22;  % record length for a single file.
nf_tot = size(files,2)/m;  % number of files.


segnames = reshape(files, m,nf_tot)';
label_length = 7;
labels= segnames(:,(1:label_length));
segnames = segnames(:,(1:(m-5)));
imglabel = '_cbq_n3';

mri_dim = 256; % assume 
nf = min(nf,nf_tot/2);
if slcs
    sg = zeros(mri_dim,mri_dim,slcs,nf);
    im = sg;
else
    slcs = 124;
    slc_idx = 1:124;
end

for k=(1:nf)*2
    sgk = extract_slice(brn_dir, segnames(k,:),slc_idx);
    sg(:,:,:,k/2) = sgk;
    imk = extract_slice(brn_dir, [labels(k,:),imglabel],slc_idx);
    im(:,:,:,k/2) = imk;
    if plotter
        ss = slc_idx(ceil(size(sgk,3)/2));
        
        
        figure; 
        subplot(1,2,1), imshow( imk(:,:,ceil(end/2)) );
        title(['True Image, brn ',num2str(k/2),' sl ',num2str(ss)]);
        
        subplot(1,2,2), imshow( sgk(:,:,ceil(end/2)) );
        title(['Segmentation, brn ',num2str(k/2),' sl ',num2str(ss)]);

    end
end

end



function slices=extract_slice(data_dir,hdr,varargin)
% hdr: hdr name without extension
% slices_index: the slices to extract in z direction; optional
%               if not given, it extracts the middle;
%               if empty, it returns the image. 


info = analyze75info([data_dir,hdr,'.hdr']);
img = analyze75read([data_dir,hdr]);

N = info.Dimensions; % image resolution nx,ny,nz,nt

if nargin<3
    %slices_index = 58:62; 
    slices_index = 60; 
else
    slices_index = varargin{1};
end
if isempty(slices_index), slices_index=1:N(3); end

slices = img(:,:,slices_index,1);

end
