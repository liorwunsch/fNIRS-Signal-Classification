function [accuracy] = AnalyzeReadyData(ready_data, training_percent, num_of_sections)
%% Joint = 0, Solo = 1
num_of_entries = length(ready_data.labels);
num_of_train_entries = floor(training_percent * num_of_entries);
XTrain = ready_data.data(1:num_of_train_entries,:);
YTrain = ready_data.labels(1:num_of_train_entries);
XTest = ready_data.data(num_of_train_entries+1:num_of_entries,:);
YTest = ready_data.labels(num_of_train_entries+1:num_of_entries);

%% My classification model consists of saving vectors of averages over all children for joint and for solo, in that order
avg_vectors = zeros(2, num_of_sections);

% training
for i = 1 : num_of_train_entries
    avg_vectors(YTrain(i)+1,:) = avg_vectors(1,:) + XTrain(i,:);
end
avg_vectors = avg_vectors / num_of_train_entries;

% testing
num_of_test_entries = size(XTest,1);
YPredicted = zeros(num_of_test_entries, 1);
for i = 1 : num_of_test_entries
    dists_to_joint = abs(XTest(i,:) - avg_vectors(1,:));
    dists_to_solo = abs(XTest(i,:) - avg_vectors(2,:));
    correctness_vec = (dists_to_joint >= dists_to_solo); % predict each section if it is closer to being joint or to being solo
    YPredicted(i) = mean(correctness_vec) > 0.5;
end

accuracy = mean(YPredicted == YTest);
disp(['Accuracy = ', num2str(accuracy * 100), ' %']);

end
