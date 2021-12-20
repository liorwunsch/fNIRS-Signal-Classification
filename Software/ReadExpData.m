function [expdata] = ReadExpData(path_to_data, row_size)
%%
if ~isfolder(path_to_data)
    error([path_to_data, ' Not Found']);
end

files_list = dir(path_to_data); % list of files in data folder
files_list = files_list(3:end); % first 2 entries are not feasible

%% List files' paths
num_of_files = length(files_list);
files_paths(num_of_files,1) = string;

num_of_csvs = 0; % relevant csvs counter
for i = 1 : num_of_files
    files_paths(i) = fullfile(path_to_data, files_list(i).name);
    if endsWith(files_paths(i), '.csv')
        num_of_csvs = num_of_csvs + 1;
    end
end

%% Read or load files
expdata(num_of_csvs,1) = struct; % database of csv data by pairs and channels

csv_ind = 1;
for i = 1 : num_of_files
    curr_file_path = char(files_paths(i));
    found_mat = false;
    
    if endsWith(curr_file_path, 'Solo.csv')
        category = 'Solo';
    elseif endsWith(curr_file_path, 'Joint.csv')
        category = 'Joint';
    else
        continue; % filter not-relevant csvs
    end
    
    % Check if csv was already saved as a mat file - to lower runtime
    mat_to_search = [curr_file_path(1:end-4), '.mat'];
    x = find(strcmp(files_paths, mat_to_search), 1);
    if ~isempty(x)
        found_mat = true;
    end
    
    % If saved as mat already, just load
    if found_mat
        load(mat_to_search, 'T_struct');
        expdata(csv_ind).pair = T_struct;
        csv_ind = csv_ind + 1;
        continue;
    end
    
    % Otherwise read and identify mother data and child data and save
    T = readtable(curr_file_path);
    T = T(:,1:row_size+1);
    
    % Organize data per channel
    [T_struct] = OrganizeData(T, row_size+1);
    T_struct.sp = files_list(i).name(1:7);
    T_struct.category = category; % 'Solo' or 'Joint'
    
    save(mat_to_search, 'T_struct');
    expdata(csv_ind).pair = T_struct;
    csv_ind = csv_ind + 1;
end

end

%%
function [T_struct] = OrganizeData(T, row_size)
%%
T_headers = T(:,1);

% Find the first entry for child - for distinguishing between child and
% mother entries
[first_child_ind] = FindFirstChildEntry(T_headers);
if first_child_ind == -1
    error('Could not find child data in a file');
end

mother_inds = 1 : first_child_ind - 1;
T_child_headers = T_headers(first_child_ind : end,1);

num_of_channels = 0;
if startsWith(string(T_headers{1,1}), 'sp02205')
    num_of_channels = 2; % compensate on missing data
end

for i = mother_inds
    curr_channel_name = char(T{i,1});
    [j] = FindChildEntryByChannel(T_child_headers, curr_channel_name);
    if j == -1
        num_of_channels = num_of_channels + 1;
        continue;
    end
    
    j = j + first_child_ind - 1;
    
    % Save entries for mother and child with fitting channel indices
    num_of_channels = num_of_channels + 1;
    T_struct.mother(num_of_channels,1:row_size-1) = table2array(T(i,2:row_size));
    T_struct.child(num_of_channels,1:row_size-1) = table2array(T(j,2:row_size));
    
    if strcmp(curr_channel_name, 'sp02205_LAB-PC_Pz')
        num_of_channels = num_of_channels + 2; % compensate on missing data
    end
    if strcmp(curr_channel_name, 'sp02208_LAB-PC_T7')
        num_of_channels = num_of_channels + 1; % compensate on missing data
    end
end

end

%%
function [ind] = FindFirstChildEntry(T_headers)
%%
ind = -1;
num_of_rows = size(T_headers,1);
for j = 1 : num_of_rows
    if startsWith(string(T_headers{j,1}), 'sp202')
        ind = j;
        break;
    end
end

end

%%
function [ind] = FindChildEntryByChannel(T_child_headers, channel_name)
%%
ind = -1;
num_of_rows = size(T_child_headers,1);
for j = 1 : num_of_rows
    if endsWith(string(T_child_headers{j,1}), channel_name(end-2:end))
        ind = j;
        break;
    end
end

end
