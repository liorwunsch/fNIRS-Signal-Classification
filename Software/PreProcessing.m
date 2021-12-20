function [ready_data] = PreProcessing(expdata, row_size, num_of_sections)
%% Child joint vs solo
num_of_pairs = length(expdata);

%% Delete all unnecessary data that has zero values in it or isn't children
num_of_channels = size(expdata(1).pair.child, 1);
non_zero_channel_inds = [4:8, 12:13, 15, 17:19, 22:24];

%% Find the channel with the biggest difference between joint and solo over all pairs
% in children, difference is calculated as the average distance
% between the same channels
channel_distance = zeros(num_of_channels, 1);

for channel_ind = non_zero_channel_inds
    for pair_ind = 1 : 2 : num_of_pairs
        channel_joint = expdata(pair_ind).pair.child(channel_ind,:);
        channel_solo = expdata(pair_ind + 1).pair.child(channel_ind,:);
        [dist] = sum((channel_joint - channel_solo).^2); % Euclidian Distance
        channel_distance(channel_ind) = channel_distance(channel_ind) + dist;
    end
end

channel_distance = channel_distance ./ num_of_pairs; % avg distance per channel over all its pairs
[~,imax1] = max(channel_distance);

%% Organize children data for maxdiff channel as categorized vectors
% each vector represents [num_of_sections] average values across the channel's
% sections
ready_data.data = zeros(num_of_pairs, num_of_sections);
ready_data.labels(num_of_pairs, 1) = -1;

i = 1;
for pair_ind = 1 : 2 : num_of_pairs
    joint_entry = expdata(pair_ind).pair.child(imax1,:);
    solo_entry = expdata(pair_ind + 1).pair.child(imax1,:);
    
    % organize as rows of 900 and get average for each section
    ready_data.data(i,:) = mean(reshape(joint_entry, row_size/num_of_sections, num_of_sections)', 2)';
    ready_data.data(i+1,:) = mean(reshape(solo_entry, row_size/num_of_sections, num_of_sections)', 2)';
    ready_data.labels(i) = 0;
    ready_data.labels(i+1) = 1;
    i = i + 2;
end

end
