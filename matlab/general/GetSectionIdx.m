function [tidx] = GetSectionIdx(task_id,tot_tasks,nbrns)
% GETSECTIONIDX produces a list of the indices of brains 
% from a set of nbrns that would belong to a specific task 
% task_id in a set of tot_task tasks. task_id is assumed to 
% be in the range [1,tot_tasks].

full_idx = 1:nbrns;

mod_idx = mod(full_idx,tot_tasks);

if task_id == tot_tasks
	% handle differently since matlab mod returns 0
	tidx = full_idx(mod_idx == 0);
else
	tidx = full_idx(mod_idx == task_id);
end

end

