clearvars
close all

% Form test list
bdir = '~/Documents/data/trainingdata/';
bcell = GetBrnList(bdir);
bcell = bcell(2);
ps = PointSelector('sliceedemamax',1);
blist = BrainPointList(bdir,bcell,ps,'');

% params
imsz1 = 240;
conf = 0.4;
ntr = blist.tot_points;
abs_noise = [0.55 0.50 0.25];
spatial_bw = 3;
app_sp = 10; app_feat = 10;
appearance_bw = [app_sp * ones(2,1); app_feat * ones(4,1)];
%appearance_bw = app_feat;
target = 2;
crf_iters = 5;

% Calculate patch probs, y vec
y_true = GetSegVals(blist,target);
fprintf(' Getting synth patch probabilities \n');
y0(:,1) = conf.*((y_true == 0)+1) + min(abs_noise).*randn(ntr,1);
y0(:,2) = conf.*((y_true == 1)+1) + min(abs_noise).*randn(ntr,1);
sumy = sum(y0,2);
sumy(sumy == 0) = 1;
y0 = bsxfun(@rdivide,y0,sumy);
y0 = min(max(y0,0),1);

% location kernel
%fprintf(' Training location one shot');
fprintf(' Feature compute\n');
Glf = LocFeatures2D(blist);
Gint = IntFeatures(blist);
loc_filter = fspecial('gaussian',[spatial_bw*3 spatial_bw*3],spatial_bw);

% appearance kernel
if length(appearance_bw) == 1
    Gapp = [whiten(Gint)];
else
    Gapp = [Glf,whiten(Gint)];
end
med_dist_int = FindMedianDistance(whiten(Gint))
med_dist_spa = FindMedianDistance(Glf)

fprintf(' Training Intesities one shot\n');
[U_app,l_app] = one_shot(Gapp,256,@(x,y) gaussiankerneldiag(x,y,appearance_bw));
[abs_error, rel_error] = matvec_errors(Gapp,U_app,l_app,appearance_bw,500,10)
app_ones = U_app * (bsxfun(@times,(l_app(:)),U_app' * ones(size(U_app,1),1) ) );

ml_pot = -log(y0);
y0 = rand(size(y0));
y0 = bsxfun(@rdivide,y0,sum(y0,2));
yg = y0;

% set up figure
fprintf(' Setting up figure for runs\n');
slice1 = figure;
subplot(1,3,1);
imshow(reshape(round(y0(:,2)),imsz1,imsz1),[]);
title('Orig Guess');
subplot(1,3,2);
imshow(reshape(round(y0(:,2)),imsz1,imsz1),[]);
title('Iter 0');
subplot(1,3,3); % truth on the left
imshow(reshape(y_true(1:(imsz1^2)),imsz1,imsz1),[]); 
title('Ground truth');
pause(2)


fprintf('Iter %d accuracy: %f\n',0,sum(round(yg(:,2)) == y_true(1:imsz1^2))./imsz1^2);

% iterate
for ii = 1:crf_iters
    % kernel multiply for messages
    yim = reshape(yg,imsz1,imsz1,[]);
    m_loc = imfilter(yim,loc_filter,'same');
    m_loc = reshape(m_loc,size(yg))-yg;
    m_app = (U_app * (bsxfun(@times,(l_app(:)),U_app' * yg) )) -yg;
    m_app = bsxfun(@rdivide,max(m_app,0),app_ones);
    %m = m_loc;
    m = m_app + m_loc;
    
    % label compatibility
    m = m*[0 1 ;1 0];
    
    figure;
    subplot(2,6,1)
    imshow(reshape(yg(:,1),imsz1,imsz1),[0 1])
    ylabel('Class 1');
    title('Old')
    
    subplot(2,6,2)
    imshow(reshape(m_loc(:,1), imsz1,imsz1) ,[]);
    title('Location');
    
    subplot(2,6,3)
    imshow(reshape(m_app(:,1), imsz1,imsz1) ,[]);
    title('Appearance');
    
    subplot(2,6,4)
    imshow(reshape(m(:,1),imsz1,imsz1),[]);
    title('Message');
    
    subplot(2,6,5)
    imshow(reshape(ml_pot(:,1), imsz1,imsz1) ,[]);
    title('Unary')

    subplot(2,6,7)
    imshow(reshape(yg(:,2),imsz1,imsz1),[0 1])
    ylabel('Class 2');
    
    subplot(2,6,8)
    imshow(reshape(m_loc(:,2), imsz1,imsz1) ,[]);
    title('Location');
    
    subplot(2,6,9)
    imshow(reshape(m_app(:,2), imsz1,imsz1) ,[]);
    title('Appearance');
    
    subplot(2,6,10)
    imshow(reshape(m(:,2),imsz1,imsz1),[]);
    title('Message');
    
    subplot(2,6,11)
    imshow(reshape(ml_pot(:,2), imsz1,imsz1) ,[]);
    title('Unary')
    
    % exp w/ y0
    yg = exp(-ml_pot./10 - m);
    
    % normalize
    sumy = sum(yg,2);
    sumy(sumy == 0) = 1;
    yg = bsxfun(@rdivide,yg,sumy);
    
    subplot(2,6,6)
    imshow(reshape(yg(:,1),imsz1,imsz1),[0 1])
    title('New')
    
    subplot(2,6,12)
    imshow(reshape(yg(:,2),imsz1,imsz1),[0 1])
    
    % plot
    figure(slice1);
    subplot(1,3,2);
    imshow(reshape(round(yg(:,2)),imsz1,imsz1),[]);
    title(['Iter ',num2str(ii)]);
    fprintf('Iter %d accuracy: %f\n',ii,sum(round(yg(:,2)) == y_true(1:imsz1^2))./imsz1^2);
    pause(1)
end





