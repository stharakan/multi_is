function [fmat,fcell] = DNNFeatures(dnn_blist,feature_type)
%Function to extract specific DNN features based on a dnn blist

% initialize fmat, fcell
fcell = dnn_blist.FeatureCell(feature_type); 
dd = length(fcell);
fmat = zeros(dnn_blist.tot_points,dd);
print_skip = 1;

for bi=1:dnn_blist.num_brains
    % extract relevant indices
    brain = dnn_blist.MakeBrain(bi);
    idx = dnn_blist.pt_inds{bi};
    
    % log where we are
    if mod(bi,print_skip) == 0
        fprintf(' proc brain %s, %d of %d\n',brain.bname,...
            bi,dnn_blist.num_brains);
    end
    
    if strcmp(feature_type,'tissue') || strcmp(feature_type,'all')
        % load the tissue features, continue if done
        healthy_feats = brain.ReadTissueFeatures2D(); 
        healthy_feats = healthy_feats(idx,:);
        
        d_cur = size(healthy_feats,2);
        if d_cur == dd
            % we're done! load into fmat
            fmat(dnn_blist.WithinTotalIdx(bi),:) = healthy_feats;
            continue
        end
    end
    
    if strcmp(feature_type,'tumor') || strcmp(feature_type,'all')
        % load the tumor features, continue if done
        tumor_feats = brain.ReadTumorFeatures2D(); 
        tumor_feats = tumor_feats(idx,:);

        d_cur = size(tumor_feats,2);
        if d_cur == dd
            % we're done! load into fmat
            fmat(dnn_blist.WithinTotalIdx(bi),:) = tumor_feats;
            continue
        end
    end
    
    % if we get here, that means means feature type all, combine and load
    fmat(dnn_blist.WithinTotalIdx(bi),:) = [healthy_feats,tumor_feats];
    
end

end

