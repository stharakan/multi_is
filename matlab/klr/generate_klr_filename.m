function filename = generate_klr_filename(ka_type,rank,batches)

% if batches unspecified, lets specify it
if nargin < 3
    batches = 1;
end


filename = sprintf('klr_k%s_r%d_b%d',ka_type,rank,batches);

end