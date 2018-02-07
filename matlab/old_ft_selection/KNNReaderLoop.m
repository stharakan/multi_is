function [ nns,ids,nn_ids,nn_dists ] = KNNReaderLoop( fname,ntot )
%KNNREADER reads the output of a knn file fname. nns is the number of
%nearest neighbors stored in the file, ids is the id of each particular
%point, nn_ids is a list of the points neighbors, and nn_dists shows the
%actual distances to the neighbors.

if ~exist(fname)
    error(sprintf('Error: %s knn file does not exist',fname));
else
    fprintf(' Reading file loop style -- %d lines\n ',ntot);
end


fid = fopen(fname,'r');

nns = fread(fid,1,'int32');

if nargout > 1
    id_idx = 3:2:((2*nns)+1);
    dd_idx = id_idx - 1;
    ids = zeros(ntot,1);

    if nargout > 2
	nn_ids = zeros(ntot,nns);
	nn_dists = zeros(ntot,nns);
    
        for ni=1:ntot
	    if mod(ni,100000) == 0, fprintf('.'); end
	    cur_pt = fread(fid,2*nns + 1,'double');
            cur_pt = cur_pt(:);
            ids(ni) = cur_pt(1);

            nn_ids(ni, :) = cur_pt(id_idx)';
            nn_dists(ni, :) = cur_pt(dd_idx)';
	    if mod(ni,1000000) == 0, fprintf('%dM\n ',ni/1000000); end
        end
    end
end
        
    
fclose(fid);

end

