function [] = run_covariance_spectrum(num_vectors, varargin)

% load data lcoatins
data_locations;

% get covariance
[Q,S] = covariance_spectrum(num_vectors, varargin{:});

% save to result dir
klr_base = generate_klr_filename(varargin{:});
cov_base = sprintf('spectrum_n%d',num_vectors);
results_file = [results_dir,cov_base,klr_base,'.mat'];
save(results_file,'Q','S');

end

