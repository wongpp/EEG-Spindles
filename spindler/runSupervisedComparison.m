resultsDir = 'D:\TestData\Alpha\spindleData\resultSummarySupervised';
%dreamsAlgs = {'Spindler', 'Asd', 'Tsanas_a7', 'Tsanas_a8', 'Wendt'};
drivingAlgs = {'Spindler', 'Sdar'};
algColors = [0.8, 0.8, 0.2; 0, 0.7, 0.9; 0, 0, 0.7; 0, 0.6, 0];
metricNames = {'F1', 'F2', 'G'};

%% Read in all of the summary data
% dreamsResults = cell(length(dreamsAlgs), 1);
% for k = 1:length(dreamsResults)
%     dreamsResults{k} = load([resultsDir filesep 'dreams_' dreamsAlgs{k} '_Summary.mat']);
%     dreamsResults{k}.algorithm = dreamsAlgs{k};
% end
drivingResults = cell(length(drivingAlgs), 1);
for k = 1:length(drivingAlgs)
    drivingResults{k} = load([resultsDir filesep 'bcit_Supervised' drivingAlgs{k} '_Summary.mat']);
    drivingResults{k}.algorithm = [drivingAlgs{k} '_bcit_Supervised'];
    
%     drivingResults{length(drivingAlgs) + k} = load([resultsDir filesep 'nctu_' drivingAlgs{k} '_Summary.mat']);
%     drivingResults{length(drivingAlgs) + k}.algorithm = [drivingAlgs{k} '_nctu'];
end

% %% Construct dreams summary matrix for plotting
% numberMethods = length(dreamsResults{1}.methodNames);
% numberFiles = length(dreamsResults{1}.dataNames);
% numberAlgs = length(dreamsAlgs);
% numberMetrics = 3;
% dreams = zeros(numberFiles - 2, numberMethods, numberAlgs, numberMetrics);
% for k = 1:numberAlgs
%     theseResults = dreamsResults{k}.results;
%     for n = 1:numberMetrics
%         for j = 1:numberFiles - 2
%             for m = 1:numberMethods
%                 dreams(j, m, k, n) = theseResults(m, n, j);
%             end
%         end
%     end
% end

% %% Plot the dreams summary
% theTitle = 'Dreams performance';
% for n = 1:numberMetrics
%     metricName = metricNames{n};
%     theseResults = squeeze(dreams(:, :, :, n));
%     figHan = compareMetric(theseResults, metricName, dreamsAlgs, algColors, theTitle, dreamsResults);
% end

%% Construct driving results
numberMethods = length(drivingResults{1}.methodNames);
numberFiles = length(drivingResults{1}.dataNames);
numberAlgs = length(drivingAlgs);
numberMetrics = length(metricNames);
driving1 = zeros(numberFiles, numberMethods, numberAlgs, numberMetrics);
driving1Optimal = zeros(numberFiles, numberMethods, numberAlgs, numberMetrics);
for k = 1:numberAlgs
    theseResults = drivingResults{k}.results;
    theseOptimal = drivingResults{k}.upperBounds;
    for n = 1:numberMetrics
        for j = 1:numberFiles
            for m = 1:numberMethods
                driving1(j, m, k, n) = theseResults(m, n, j);
                driving1Optimal(j, m, k, n) = theseOptimal(m, n, j);
            end
        end
    end
end
% drivingResults2 = drivingResults(numberAlgs + 1:end);
% numberMethods = length(drivingResults2{1}.methodNames);
% numberFiles = length(drivingResults2{1}.dataNames);
% numberAlgs = length(drivingAlgs);
% numberMetrics = 3;
% driving2 = zeros(numberFiles, numberMethods, numberAlgs, numberMetrics);
% for k = 1:numberAlgs
%     theseResults = drivingResults2{k}.results;
%     for n = 1:numberMetrics
%         for j = 1:numberFiles
%             for m = 1:numberMethods
%                 driving2(j, m, k, n) = theseResults(m, n, j);
%             end
%         end
%     end
% end
%driving = [driving1; driving2];
driving = driving1;
%% Plot the summary performance
theTitle = 'Driving performance';
for n = 1:numberMetrics
    metricName = metricNames{n};
    theseResults = squeeze(driving(:, :, :, n));
    figHan = compareMetric(theseResults, metricName, drivingAlgs, algColors, theTitle);
end
% 
% 
% figure
% hold on
% title('Dreams')
% plot(spindlerDreams.results(:),warbyDreams.results(:), 'sk', 'LineWidth', 2, 'MarkerSize', 10);
% plot(spindlerDreams.upperBounds(:), warbyDreams.results(:), 'or', 'LineWidth', 2, 'MarkerSize', 10);
% line([0, 1], [0, 1], 'Color', [0.7, 0.7, 0.7]);
% hold off
% legend('Normal', 'Upper', 'Location', 'NorthWest')
% box on
% xlabel('Performance Spindler')
% ylabel('Warby')
% 
% 
% figure
% hold on
% title('Dreams')
% plot(warbyDreams.results(:), spindlerDreams.results(:), 'sk', 'LineWidth', 2, 'MarkerSize', 10);
% plot(warbyDreams.results(:), spindlerDreams.upperBounds(:), 'or', 'LineWidth', 2, 'MarkerSize', 10);
% line([0, 1], [0, 1], 'Color', [0.7, 0.7, 0.7]);
% hold off
% legend('Normal', 'Upper', 'Location', 'NorthWest')
% box on
% ylabel('Performance Spindler')
% xlabel('Warby')
% 
% 
% %%
% figure
% hold on
% title('BCIT')
% plot(spindlerBCIT.results(:),sdarBCIT.upperBounds(:), 'sk', 'LineWidth', 2, 'MarkerSize', 10);
% plot(spindlerBCIT.upperBounds(:), sdarBCIT.upperBounds(:), 'or', 'LineWidth', 2, 'MarkerSize', 10);
% line([0, 1], [0, 1], 'Color', [0.7, 0.7, 0.7]);
% hold off
% legend('Normal', 'Upper', 'Location', 'NorthWest')
% box on
% xlabel('Performance Spindler')
% ylabel('SDAR')
% 
% %%
% figure
% hold on
% title('Dreams')
% %plot(spindlerDreams.results(:), sdarDreams.results(:), 'sk', 'LineWidth', 2, 'MarkerSize', 10);
% plot(spindlerDreams.upperBounds(:), sdarDreams.upperBounds(:), 'or', 'LineWidth', 2, 'MarkerSize', 10);
% line([0, 1], [0, 1], 'Color', [0.7, 0.7, 0.7]);
% hold off
% legend('Upper', 'Location', 'NorthWest')
% box on
% xlabel('Performance Spindler')
%ylabel('SDar')