function [all_bws] = FindBwsFromMedian(med_dist)

% scaling factor
min_bw = med_dist/20;
max_bw = med_dist/2;

% num bws 
num_bws = 20;

% linspace
all_bws = linspace(min_bw,max_bw,num_bws);
all_bws = logspace(log10(min_bw),log10(max_bw),num_bws);
all_bws = round(all_bws,2);


end
