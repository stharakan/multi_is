function [filename] = generate_is_results_filename(tst_brn_idx, is_runs, klr_file_name)

filename = sprintf('b%d_i%d_%s',tst_brn_idx,is_runs,klr_file_name);

end

