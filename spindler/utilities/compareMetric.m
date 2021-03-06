function figHan = compareMetric(results, metricName, algorithmNames, ...
              theColors, theTitle)
%% Parameters plot the comparison of first algorithm against the rest.
%
%  Parameters:
%     results = files x methods x algorithms results for a metric
%     metricName  string specifying metric
%     algorithmNames  cell array with algorithm names for legend
%     colors for the different algorithsm
%     theTitle   string for title
theTitle = [theTitle ': ' metricName];
methodNames = {'C', 'H', 'I', 'O', 'T'};
methodMarkers = {'+', 'o', 's', '^', 'v'};
figHan = figure('Name', theTitle);
hold on
legendStrings = cell(1, length(methodNames)*(length(algorithmNames) - 1));
baseResults = squeeze(results(:, :, 1));
lCount = 0;
for k = 2:length(algorithmNames)
   theseResults = squeeze(results(:, :, k));
   for j = 1:length(methodNames)
       lCount = lCount + 1;
       legendStrings{lCount} = [methodNames{j} ': ' algorithmNames{k}];
       plot(baseResults(:, j), theseResults(:, j), 'Marker', methodMarkers{j}, ...
            'LineStyle', 'None', 'LineWidth', 2, 'MarkerSize', 10, 'Color', theColors(k - 1, :));
   end 
end

line([0, 1], [0, 1], 'Color', [0.7, 0.7, 0.7]);
hold off
legend(legendStrings, 'Location', 'EastOutside', 'Interpreter', 'None');
box on
xlabel([metricName ' ' algorithmNames{1}])
ylabel([metricName ' other algorithms'])
title(theTitle)