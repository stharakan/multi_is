function [probability_matrix,segmented_matrix] = ...
    importance_sample_from_features(feature_matrix,klr_obj, samples)

% decompose W
train_probs = klr_obj.KLR_Prob([]);
[Q,D] = decomposeW(train_probs); 

% find mu
theta_mean = klr_hessian_inverse(klr_obj,Q,D); 
theta_hat  = klr_obj.theta;

% create final matrix
ntest = size(feature_matrix,1);
nclass= klr_obj.cc;
probability_matrix = zeros( ntest,nclass,samples);
segmented_matrix = zeros(ntest,samples);

% precompute kernel
Kt = klr_obj.KA.SKernel(feature_matrix);

for ss = 1:samples
    
    if mod(ss, 100) == 0
        fprintf(' finished %d samples..\n',ss);
    end
    
    % sample and scale to get delta theta
    delta_theta = getDeltaTheta(theta_mean,klr_obj,Q,D); 
    
    % move by main theta
    sampled_theta = delta_theta + theta_hat;
    
    % compute probabilities, seg
    probs = klr_obj.KLR_Prob(sampled_theta,Kt);
    [~,ycl] = max(probs,[],2);

    % store probs,segmentation
    probability_matrix(:,:,ss) = probs;
    segmented_matrix(:,ss) = ycl;
end

end
