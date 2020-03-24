data_locations;

% load filenames
listings = dir(results_dir);
li_cell = {};
for li = 1:length(listings)
    li_name = listings(li).name;
    if length(strfind(li_name,'spectrum')) > 0
        li_cell{end + 1} = li_name;
    end
end


f1 = figure;

for li = 1:length(li_cell)
    filename = li_cell{li};
    load([results_dir,filename],'Q','S');
    
    % get label name 
    label_name = filename(10:(end-4));
    label_name = strrep(label_name,'_','-');
    
    plot(S(:)./S(1), 'DisplayName',label_name);
    hold on
end
legend()