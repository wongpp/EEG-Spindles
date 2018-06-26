%% Extract the spindler unsupervised results
% collection = 'mass';
% dataDir = 'D:\TestData\Alpha\spindleData\massNew';
collection = 'dreams';
dataDir = 'D:\TestData\Alpha\spindleData\dreams';
algorithms = {'spindler'};
eventExts = {'combined', 'expert1', 'expert2'};
summaryDir = 'D:\TestData\Alpha\spindleData\summarySupervised';
metricName = 'fdr';
methodName = 'time';
split = 0.5;

%% Make summary directory if it doesn't exist
if ~exist(summaryDir, 'dir')
    mkdir(summaryDir);
end

%% Now read the data files and find the file parts
dataFiles = getFileListWithExt('FILES', [dataDir filesep 'data'], '.set');
numFiles = length(dataFiles);
fileNames = cell(numFiles, 1);
for k = 1:numFiles
    [~, fileNames{k}, ~] = fileparts(dataFiles{k});
end

%% Now extract the values
numAlgorithms = length(algorithms);
numExperts = length(eventExts);
for k = 1:numAlgorithms
   for n = 1:numExperts
       metrics = nan(numFiles, 1);
       dirName = [dataDir filesep 'results_' algorithms{k} '_' eventExts{n}];
       for m = 1:numFiles
           fileName = [dirName filesep fileNames{m} '.mat'];
           if ~exist(fileName, 'file')
               continue;
           end
           test = load(fileName);
           totalTime = (test.additionalInfo.endFrame - ...
                test.additionalInfo.startFrame)./ ...
                test.additionalInfo.srate;
            [spindleFraction(m), spindleLength(m), spindleRate(m)] = ...
                getEventProperties(events, totalTime);
            [expertFraction(m), expertLength(m), expertRate(m)] = ...
                getEventProperties(expertEvents, totalTime);
           
           allMetrics = getPerformanceMetricsOnInterval(test.expertEvents, ...
                          test.spindles, startTime, endTime, params)
           allMetrics = test.additionalInfo.allMetrics;
           atomInd = test.additionalInfo.spindlerCurves.bestEligibleAtomInd;
           threshInd = test.additionalInfo.spindlerCurves.bestEligibleThresholdInd;
           if isempty(allMetrics) || isempty(atomInd) || isempty(threshInd)
               warning('Algorithm: %s file %s has no metrics', ...
                   algorithms{k}, fileName);
               continue;
           end
           theMetric = allMetrics(atomInd, threshInd);
           metrics(m) = theMetric.(methodName).(metricName);
           allMetrics = getPerformanceOnInterval(expertEvents, ...
                          spindles, startTime, endTime, params)
       end
       outName = [collection '_' metricName '_' methodName '_' eventExts{n} '_' algorithms{k} '.mat'];
       save([summaryDir filesep outName], 'metrics', '-v7.3');
   end
end
           