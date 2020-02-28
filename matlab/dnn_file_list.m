function brnlist = dnn_file_list(dir_to_search)

list_of_files = dir(dir_to_search);
cc = 1;

for ii = 1:length(list_of_files)
    dotflag = strcmp(list_of_files(ii).name(1),'.');
    
    if ~dotflag
        filename = list_of_files(ii).name;
        split_cell = split(filename,'.');
        split_name = split_cell{1};
        
        if contains(split_name,'feature')
            brn_name = split_name(1:end-8);
        elseif contains(split_name,'prob')
            brn_name = split_name(1:end-5);
        elseif contains(split_name,'seg')
            brn_name = split_name(1:end-4);
        end
        
        
        brnlist{cc} = brn_name;
		cc = cc + 1;
    end
end

brnlist = uniquecell(brnlist);

end


function [Au, idx ,idx2] = uniquecell(A)
    %function [Au, idx, idx2] = uniquecell(A)
    %For A a cell array of matrices (or vectors), returns 
    %Au, which contains the unique matrices in A, idx, which contains
    %the indices of the last appearance of each such unique matrix, and
    %idx2, which contains th indices such that Au(idx2) == A
    %
    %Example usage:
    %
    %A = {[1,2,3],[0],[2,3,4],[2,3,1],[1,2,3],[0]};
    %[Au,idx,idx2] = uniquecell(A);
    %
    %Results in:
    %idx = [6,5,4,3]
    %Au  = {[0],[1,2,3],[2,3,1],[2,3,4]}
    %idx2 = [2,1,4,3,2,1]
    %
    %Algorithm: uses cellfun to translate numeric matrices into strings
    %           then calls unique on cell array of strings and reconstructs
    %           the initial matrices
    %
    %See also: unique
    B = cellfun(@(x) num2str(x(:)'),A,'UniformOutput',false);
    if nargout > 2
        [~,idx,idx2] = unique(B);
        Au = A(idx);
    else
        [~,idx] = unique(B);
        Au = A(idx);
    end
end
  