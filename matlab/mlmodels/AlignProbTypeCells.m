function [dir_out,type_out] = AlignProbTypeCells(prob_dirs,type_dirs)

tt = length(type_dirs);
pp = length(prob_dirs);

if tt ~= pp, error('Cell arrays do not match'); end;

nn = sum(cellfun('length',type_dirs));

dir_out = cell(1,nn);
type_out = cell(1,nn);;
counter = 1;

for pi = 1:pp
	cur_prob_dir = prob_dirs{pi};
	cur_type_cell = type_dirs{pi};

	for bi = 1:length(cur_type_cell)
		bi;
		type_out{counter} = cur_type_cell{bi};
		dir_out{counter} = cur_prob_dir;
		counter = counter + 1;
	end
end


end
