function [ tree_mdl ] = TrainTreeModel(filenm, X,y )
%TRAINTREEMODEL trains a matlab model decision tree based on the parameters
%in tree_template. It also checks in the subfolder './models' to see if a
%model has been created on that date already for the specified task. If so, 
%it loads that. If not, it will train and save a new model.

% check if file exists
if nargin == 1

	if exist(filenm,'file')
    % load file
    load(filenm,'tree_mdl');
	else
		error('Model file not found');
	end
    
else
    if nargin < 3
        error('Not enough parameters passed to train model');
    else
        disp('Model untrained .. training in 5 sec');
        pause(5)
        disp('Training now');
        
        % get template
        tree_template = GenerateTreeTemplate();
        
        % train model
        tree_mdl = fitcecoc(X,y,'Coding','onevsall', 'FitPosterior',1, ...
					'Learners',tree_template);
        
        % save file
        save(filenm,'tree_mdl');
    end
end



end

