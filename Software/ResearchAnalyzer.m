function ResearchAnalyzer(path_to_data)
%%
row_size = 9000; % 10k columns of data throws an error
num_of_sections = 100; % the more sections the more precise the prediction over averages
training_percent = 0.6; % percentage of training data from all data

[expdata] = ReadExpData(path_to_data, row_size);
[ready_data] = PreProcessing(expdata, row_size, num_of_sections);
AnalyzeReadyData(ready_data, training_percent, num_of_sections);

% 0.7 is overfitting

end
