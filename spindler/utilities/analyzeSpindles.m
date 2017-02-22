function [] = analyzeSpindles(theFile, outDir, doPerformance, verbose)


%% Make sure the outDir exists
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Load the data
load(theFile)
numberAtoms = length(atomsPerSecond); 
numberThresholds = length(baseThresholds);
spindleHits = cellfun(@double, {spindles.numberSpindles});
spindleHits  = reshape(spindleHits, numberAtoms, numberThresholds);
spindleTime = cellfun(@double, {spindles.spindleTime});
spindleTime  = reshape(spindleTime, numberAtoms, numberThresholds);

if isfield(spindles, 'f1ModTime')
    f1ModTime = cellfun(@double, {spindles.f1ModTime});
    f1ModTime  = reshape(f1ModTime, numberAtoms, numberThresholds);
    f1ModHits = cellfun(@double, {spindles.f1ModHits});
    f1ModHits  = reshape(f1ModHits, numberAtoms, numberThresholds);
    f1ModOnsets = cellfun(@double, {spindles.f1ModOnsets});
    f1ModOnsets  = reshape(f1ModOnsets, numberAtoms, numberThresholds); 
    f1ModInter = cellfun(@double, {spindles.f1ModOnsets});
    f1ModInter  = reshape(f1ModInter, numberAtoms, numberThresholds); 
else
    f1ModTime = NaN;
    f1ModHits = NaN;
    f1ModOnsets = NaN;
    doPerformance = false;
end
theColors = jet(numberThresholds);

%% Show the spindle values for each dataset individually
[~, theName] = fileparts(theFile);
legendStrings = cell(1, numberThresholds);
for k = 1:numberThresholds
    legendStrings{k} = num2str(baseThresholds(k));
end
totalSeconds = frames./srate;
spindleHits = spindleHits/totalSeconds;
spindleTime = spindleTime/totalSeconds;

%% Spindle time/spindle hits versus atoms/second
xAll = spindleTime./spindleHits;
frameMask = atomsPerSecond > 0.1 & atomsPerSecond < 0.35;
x = xAll(frameMask, :);
frameMask = atomsPerSecond(frameMask);
legends = cell(numberThresholds, 1);
for k = 1:numberThresholds
   p = polyfit(frameMask(:), x(:, k), 1); 
   legends{k} = [legendStrings{k} ':' num2str(p(1))];
end
xMedianRatio = median(xAll, 2);
xMadRatio = mad(xAll, 1, 2);
xMeanRatio = mean(xAll, 2);
xStdRatio = std(xAll, 0, 2);
[iMedianMinAtoms, xMedianMin] = ...
                     findMinAfterMax(atomsPerSecond', xMedianRatio);
[iMeanMinAtoms, xMeanMin] = ...
                     findMinAfterMax(atomsPerSecond', xMeanRatio);
theTitle = {'Spindle time/spindle hits vs atoms/second'; ...
            theName; ...
            ['MedMin=' num2str(xMedianMin) ' at ' num2str(iMedianMinAtoms) ',' ...
            'MeanMin=' num2str(xMeanMin) ' at ' num2str(iMeanMinAtoms) ]};
h5 = figure('Name', [theName ':Spindle time/spindle hits vs atoms/second']);
hold on
for j = 1:numberThresholds
   plot(atomsPerSecond, spindleTime(:, j)./spindleHits(:, j), 'LineWidth', 2, ...
     'Color', theColors(j, :));
end

plot(atomsPerSecond', xMeanRatio, 'LineWidth', 3, 'Color', [0.6, 0.6, 0.6]);
plot(atomsPerSecond', xMeanRatio+xStdRatio, 'LineWidth', 2, ...
    'Color', [0.6, 0.6, 0.6], 'LineStyle', '--');
plot(atomsPerSecond', xMeanRatio-xStdRatio, 'LineWidth', 2, ...
    'Color', [0.6, 0.6, 0.6], 'LineStyle', '--');
plot(atomsPerSecond', xMedianRatio, 'LineWidth', 3, 'Color', [0.75, 0.75, 0.75]);
plot(atomsPerSecond', xMedianRatio+xMadRatio, 'LineWidth', 2, ...
    'Color', [0.75, 0.75, 0.75], 'LineStyle', '--');
plot(atomsPerSecond', xMedianRatio-xMadRatio, 'LineWidth', 2, ...
    'Color', [0.75, 0.75, 0.75], 'LineStyle', '--');

summaryLegends = {'Mean', 'Mean+std', 'Mean-std', ...
                  'Median', 'Median+mad', 'Median-mad'};
allLegends = [legends', summaryLegends];
legend(allLegends);
yLimits = get(gca, 'YLim');
if ~isempty(iMeanMinAtoms)
   line([iMeanMinAtoms, iMeanMinAtoms], yLimits, 'Color', [0, 0, 0]);
end
ylabel('Spindle time/spindle hits');
xlabel('Atoms/second');
box on
hold off
title(theTitle, 'Interpreter', 'None');
saveas(h5, [outDir filesep theName 'SpindleTimeDivHits.png'], 'png');  

%% Spindle hits/spindle time hits versus atoms/second
spindleRatio = spindleHits./spindleTime;
xMedianRatio = median(spindleRatio, 2);
xMadRatio = mad(spindleRatio, 1, 2);
xMeanRatio = mean(spindleRatio, 2);
xStdRatio = std(spindleRatio, 0, 2);
[iMedianMaxAtoms, xMedianMax] = findMaxAfterMin(atomsPerSecond', xMedianRatio);
[iMeanMaxAtoms, xMeanMax] = findMaxAfterMin(atomsPerSecond', xMeanRatio);
plotType = 'Spindle hits/spindle time vs atoms/second';
theTitle = { plotType; theName; ...
            ['MedMin=' num2str(xMedianMax) ' at ' num2str(iMedianMaxAtoms) ',' ...
            'MeanMin=' num2str(xMeanMax) ' at ' num2str(iMeanMaxAtoms) ]};
h6 = figure('Name', [theName ':' plotType]);

hold on
for j = 1:numberThresholds
    plot(atomsPerSecond, spindleRatio(:, j), 'LineWidth', 2, ...
        'Color', theColors(j, :));
end

plot(atomsPerSecond', xMeanRatio, 'LineWidth', 3, 'Color', [0.6, 0.6, 0.6]);
plot(atomsPerSecond', xMeanRatio+xStdRatio, 'LineWidth', 2, ...
    'Color', [0.6, 0.6, 0.6], 'LineStyle', '--');
plot(atomsPerSecond', xMeanRatio-xStdRatio, 'LineWidth', 2, ...
    'Color', [0.6, 0.6, 0.6], 'LineStyle', '--');
plot(atomsPerSecond', xMedianRatio, 'LineWidth', 3, 'Color', [0.75, 0.75, 0.75]);
plot(atomsPerSecond', xMedianRatio+xMadRatio, 'LineWidth', 2, ...
    'Color', [0.75, 0.75, 0.75], 'LineStyle', '--');
plot(atomsPerSecond', xMedianRatio-xMadRatio, 'LineWidth', 2, ...
    'Color', [0.75, 0.75, 0.75], 'LineStyle', '--');
hold off
summaryLegends = {'Mean', 'Mean+std', 'Mean-std', ...
                  'Median', 'Median+mad', 'Median-mad'};
allLegends = [legends', summaryLegends];
yLimits = get(gca, 'YLim');
if ~isempty(iMeanMaxAtoms)
   line([iMeanMaxAtoms, iMeanMaxAtoms], yLimits, 'Color', [0, 0, 0]);
end
hold off
box on
ylabel('Spindle hits/spindle time')
xlabel('Atoms/second')
title(theTitle, 'Interpreter', 'None');
legend(allLegends);
saveas(h6, [outDir filesep theName 'SpindleHitsDivTime.png'], 'png');

%% Spindle time/second versus atoms/second
if verbose
    theTitle = [theName ': Spindle time/second vs atoms/second'];
    h1 = figure('Name', theTitle);
    hold on
    for j = 1:numberThresholds
        plot(atomsPerSecond, spindleTime(:, j), 'LineWidth', 2, ...
            'Color', theColors(j, :));
    end
    hold off
    ylabel('Spindle time/second')
    xlabel('Atoms/second')
    title(theTitle, 'Interpreter', 'None');
    legend(legendStrings, 'Location', 'NorthWest');
    box on;
    saveas(h1, [outDir filesep theName 'SpindleTime.png'], 'png');
end

%% Spindle hits/second versus atoms/second
if verbose
    theTitle = [theName ': Spindle hits/second vs atoms/second'];
    h2 = figure('Name', theTitle);
    hold on
    for j = 1:numberThresholds
        plot(atomsPerSecond, spindleHits(:, j), 'LineWidth', 2, ...
            'Color', theColors(j, :));
    end
    hold off
    ylabel('Spindles/second')
    xlabel('Atoms/second')
    title(theTitle, 'Interpreter', 'None');
    legend(legendStrings, 'Location', 'NorthWest');
    box on;
    saveas(h2, [outDir filesep theName 'SpindleHits.png'], 'png');
end
%% Spindle hits STD vs atoms/second
if verbose
    spindleSTD = std(spindleHits, 0, 2);
    theTitle = [theName ': STD of spindleHits'];
    h3 = figure('Name', theTitle);
    plot(atomsPerSecond, spindleSTD, 'LineWidth', 2);
    ylabel('STD spindle hits/second')
    xlabel('Atoms/second')
    title(theTitle, 'Interpreter', 'None');
    box on;
    saveas(h3, [outDir filesep theName 'SpindleSTD.png'], 'png');
end

%% Log of spindle hits STD vs atoms/second
if verbose
    spindleSTD = std(spindleHits, 0, 2);
    theTitle = [theName ': Log STD of spindle hits'];
    h4 = figure('Name', theTitle);
    semilogy(atomsPerSecond, spindleSTD, 'LineWidth', 2);
    ylabel('Log STD spindle hits/second')
    xlabel('Atoms/second')
    title(theTitle, 'Interpreter', 'None');
    box on;
    saveas(h4, [outDir filesep theName 'SpindleLogSTD.png'], 'png');
end

%% Spindle hits versus spindle time
if verbose
    theTitle = [theName ': Spindle hits vs spindle time'];
    frameMask = atomsPerSecond >= 0.1 & atomsPerSecond <= 0.35;
    numSpins = spindleHits(frameMask, :);
    spinTime = spindleTime(frameMask, :);
    corrB = zeros(numberThresholds, 1);
    legendCorr = cell(1, numberThresholds);
    for j = 1:numberThresholds
        corrB(j) = corr(spinTime(:, j), numSpins(:, j));
        legendCorr{j} = [legendStrings{j} ':'  num2str(corrB(j))];
    end
    h7 = figure('Name', theTitle);
    hold on
    for j = 1:numberThresholds
        plot(spindleHits(:, j), spindleTime(:, j), 'Color', theColors(j, :), ...
            'Marker', 'o', 'MarkerSize', 10)
    end
    hold off
    box on;
    legend(legendCorr, 'Location', 'SouthEast')
    ylabel('Spindle time/second');
    xlabel('Number spindles/second')
    title(theTitle, 'Interpreter', 'None');
    hold off
    saveas(h7, [outDir filesep theName 'SpindleHitsVsTime.png'], 'png');
end
%% Do the performance
if ~doPerformance
    return;
end

%% F1Mod time vs atoms/second
if verbose
    theTitle = [theName ': F1Mod time vs atoms/second'];
    h8 = figure('Name', theTitle);
    hold on
    for j = 1:numberThresholds
        plot(atomsPerSecond, f1ModTime(:, j), 'LineWidth', 2, ...
            'Color', theColors(j, :));
    end
    hold off
    ylabel('F1Mod time')
    xlabel('Atoms/second')
    title(theTitle, 'Interpreter', 'None');
    legend(legendStrings, 'Location', 'SouthEast');
    box on;
    saveas(h8, [outDir filesep theName 'F1ModTime.png'], 'png'); 
end

%% F1Mod hits vs atoms/second
if verbose
    theTitle = [theName ': F1Mod hits vs atoms/second'];
    h9 = figure('Name', theTitle);
    hold on
    for j = 1:numberThresholds
       plot(atomsPerSecond, f1ModHits(:, j), 'LineWidth', 2, ...
           'Color', theColors(j, :));
    end
    hold off
    ylabel('F1Mod hits')
    xlabel('Atoms/second')
    title(theTitle, 'Interpreter', 'None');
    legend(legendStrings, 'Location', 'SouthEast');
    box on;
    saveas(h9, [outDir filesep theName 'F1ModHits.png'], 'png'); 
end

%% F1Mod onsets vs atoms/second
if verbose
    theTitle = [theName ': F1Mod onsets vs atoms/second'];
    h8 = figure('Name', theTitle);
    hold on
    for j = 1:numberThresholds
        plot(atomsPerSecond, f1ModOnsets(:, j), 'LineWidth', 2, ...
            'Color', theColors(j, :));
    end
    hold off
    ylabel('F1Mod onsets')
    xlabel('Atoms/second')
    title(theTitle, 'Interpreter', 'None');
    legend(legendStrings, 'Location', 'SouthEast');
    box on;
    saveas(h8, [outDir filesep theName 'F1ModOnsets.png'], 'png'); 
end

%% F1Mod inter vs atoms/second
if verbose
    theTitle = [theName ': F1Mod inter vs atoms/second'];
    h8 = figure('Name', theTitle);
    hold on
    for j = 1:numberThresholds
        plot(atomsPerSecond, f1ModInter(:, j), 'LineWidth', 2, ...
            'Color', theColors(j, :));
    end
    hold off
    ylabel('F1Mod intersect')
    xlabel('Atoms/second')
    title(theTitle, 'Interpreter', 'None');
    legend(legendStrings, 'Location', 'SouthEast');
    box on;
    saveas(h8, [outDir filesep theName 'F1ModInter.png'], 'png'); 
end

%% F1Mod all measures vs atoms/second
legendBoth = cell(1, 2*numberThresholds);
for k = 1:numberThresholds
    legendBoth{4*k - 3} = [legendStrings{k} ' H'];
    legendBoth{4*k - 2} = [legendStrings{k} ' T'];
    legendBoth{4*k - 1} = [legendStrings{k} ' O'];
    legendBoth{4*k} = [legendStrings{k} ' I'];
end
theTitle = [theName ': F1Mod hits vs atoms/second'];
h10 = figure('Name', theTitle);
hold on
newColors = jet(numberThresholds);
for j = 1:numberThresholds
    plot(atomsPerSecond, f1ModHits(:, j), 'LineWidth', 2, ...
        'Color', newColors(j, :));
    plot(atomsPerSecond, f1ModTime(:, j), 'LineWidth', 2, 'LineStyle', '-.', ...
        'Color', newColors(j, :));
    plot(atomsPerSecond, f1ModOnsets(:, j), 'LineWidth', 2, 'LineStyle', ':', ...
        'Color', newColors(j, :));
    plot(atomsPerSecond, f1ModInter(:, j), 'LineWidth', 2, 'LineStyle', '--', ...
        'Color', newColors(j, :));
end
plot(atomsPerSecond', xMeanRatio, 'LineWidth', 3, 'Color', [0.6, 0.6, 0.6]);
legend(legendBoth, 'Location', 'SouthEast');
line([iMeanMaxAtoms, iMeanMaxAtoms], [0, 1], 'Color', [0, 0, 0]);
hold off
ylabel('Performance')
xlabel('Atoms/second')
title(theTitle, 'Interpreter', 'None');
legend(legendBoth, 'Location', 'SouthEast');
box on;
saveas(h10, [outDir filesep theName 'F1ModBoth.png'], 'png');

%% Calculate ROC curves   
if verbose
    fpr = zeros(numberAtoms*numberThresholds, 1);
    tpr = zeros(numberAtoms*numberThresholds, 1);
    precisionTime = zeros(numberAtoms*numberThresholds, 1);
    precisionHits = zeros(numberAtoms*numberThresholds, 1);
    precisionInter = zeros(numberAtoms*numberThresholds, 1);
    recallTime = zeros(numberAtoms*numberThresholds, 1);
    recallHits = zeros(numberAtoms*numberThresholds, 1);
    recallInter = zeros(numberAtoms*numberThresholds, 1);
    for k = 1:length(spindles)
        fpr(k) = spindles(k).metricsTime.fpr;
        tpr(k) = spindles(k).metricsTime.tpr;
        precisionTime(k) = spindles(k).metricsTime.precision;
        recallTime(k) = spindles(k).metricsTime.recall;
        precisionHits(k) = spindles(k).metricsHits.precision;
        recallHits(k) = spindles(k).metricsHits.recall;
        precisionInter(k) = spindles(k).metricsInter.precision;
        recallInter(k) = spindles(k).metricsInter.recall;
    end
    fpr = reshape(fpr, numberAtoms, numberThresholds);
    tpr = reshape(tpr, numberAtoms, numberThresholds);
    precisionTime = reshape(precisionTime, numberAtoms, numberThresholds);
    recallTime = reshape(recallTime, numberAtoms, numberThresholds);
    precisionHits = reshape(precisionHits, numberAtoms, numberThresholds);
    recallHits = reshape(recallHits, numberAtoms, numberThresholds);
    precisionInter = reshape(precisionInter, numberAtoms, numberThresholds);
    recallInter = reshape(recallInter, numberAtoms, numberThresholds);
 
    %% Plot traditional ROC curve
    theTitle = [theName ': ROC'];
    h11 = figure('Name', theTitle);
    hold on
    for j = 1:numberThresholds
       plot(fpr(:, j), tpr(:, j), 'LineWidth', 2, ...
           'Color', theColors(j, :));
    end
    hold off
    xlabel('False positive rate')
    ylabel('True positive rate')
    legend(legendStrings, 'Location', 'SouthWest')
    title(theTitle, 'Interpreter', 'None')
    box on;
    saveas(h11, [outDir filesep theName 'FPRvsTPR.png'], 'png'); 
    
    %% Plot precision-recall using time measures
    theTitle = [theName ': Precision-recall time'];
    h12 = figure('Name', theTitle);
    hold on
    for j = 1:numberThresholds
      plot(recallTime(:, j), precisionTime(:, j), 'LineWidth', 2, ...
          'Color', theColors(j,:));
    end
    hold off
    xlabel('Recall')
    ylabel('Precision')
    legend(legendStrings, 'Location', 'SouthWest')
    title(theTitle, 'Interpreter', 'None')
    box on;
    saveas(h12, [outDir filesep theName 'RecallVsPercisionTime.png'], 'png'); 
    
    %% Plot precision recall using hit measures
    theTitle = [theName ': Precision-recall hits'];
    h13 = figure('Name', theTitle);
    hold on
    for j = 1:numberThresholds
      plot(recallHits(:, j), precisionHits(:, j), 'LineWidth', 2, ...
          'Color', theColors(j, :));
    end
    hold off
    xlabel('Recall')
    ylabel('Precision')
    legend(legendStrings, 'Location', 'SouthEast')
    title(theTitle, 'Interpreter', 'None')
    box on;
    saveas(h13, [outDir filesep theName 'RecallVsPercisionHits.png'], 'png');
    
    %% Plot precision-recall using Inter measures
    theTitle = [theName ': Precision-recall inter'];
    h13 = figure('Name', theTitle);
    hold on
    for j = 1:numberThresholds
      plot(recallInter(:, j), precisionInter(:, j), 'LineWidth', 2, ...
          'Color', theColors(j, :));
    end
    hold off
    xlabel('Recall')
    ylabel('Precision')
    legend(legendStrings, 'Location', 'SouthEast')
    title(theTitle, 'Interpreter', 'None')
    box on;
    saveas(h13, [outDir filesep theName 'RecallVsPercisionInter.png'], 'png');
end
