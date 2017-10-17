function [ GF ] = GetIntDiffFeatures( varargin )
%GETINTDIFFFEATURES produces features by taking the difference between each
%pair of modalities given in varargin. GF is N X (m(m-1)/2).
%
% ----- HOW TO USE  ----
% Suppose we have already extracted flair, t1, t1ce, and t2 from a given
% set of brains. In order to get the features, we simply call the function
% as shown below:
%
% GF = GetIntDiffFeatures(flair,t1,t1ce,t2);
%


mods = length(varargin);
cc = 0; % counter var
%GF = zeros(numel(varargin{1}),( mods*(mods +1)/2 ));
GF = zeros(numel(varargin{1}),( mods*(mods - 1)/2 )); % no self feature

for mm = 1:mods
    % pull current image
    imm = varargin{mm};
    
		% normalize
		imm = single(imm./max(imm(:)));

    % include basic intensities? noo
    %cc = cc + 1;
    %GF(:,cc) = imm(:);
    
    
    for nn = (mm+1):mods
        % pull image to compare
        imn = varargin{nn};
				imn = single(imn./max(imn(:)));
        
        % compute diff and load
        cc = cc + 1;
        GF(:,cc) = imm(:) - imn(:) ;
    end
end

end

