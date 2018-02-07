function [ nns,ids,nn_ids,nn_dists ] = KNNReader( fname )
%KNNREADER reads the output of a knn file fname. nns is the number of
%nearest neighbors stored in the file, ids is the id of each particular
%point, nn_ids is a list of the points neighbors, and nn_dists shows the
%actual distances to the neighbors.

if ~exist(fname)
    error(sprintf('Error: %s knn file does not exist',fname));
end


fid = fopen(fname,'r');

nns = fread(fid,1,'int32');

if nargout > 1
    % we read everything and then sort
    all_mat = fread(fid,Inf,'double');
    all_mat = reshape(all_mat,nns + 1,[]);
    
    % each column corresponds to a dif point now -- rows have info we want
    ids = all_mat(1,:)';
    
    if nargout > 2
        % extract the big stuff only if we need to
        id_idx = 3:2:(nns+1);
        
        nn_ids = all_mat(id_idx,:)';
        
        dd_idx = id_idx - 1;
        nn_dists = all_mat(dd_idx,:)';
        
        clear all_mat
    end
end
        
    
fclose(fid);

end

