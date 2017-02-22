function [spindles, spindleRatios, reconstructed, atomParams, scaledGabors] = ...
     getSpindles(EEG, channelNumbers, atomsPerSecond, atomFrequencies, atomScales, ...
                 baseThresholds, timeError, minLength, minTime, ...
                 onsetTolerance, intersectTolerance, expertEvents)
%% Calculate spindle events from different Gabor reconstructions

% Details: Spindle threshold adaptive matching pursuit (STAMP)-based detection of events.

% Usage:
% [events, output] = STAMP(EEG, channelList, numberAtoms, ...
%                                 freqBounds, atomScales, expertEvents)
% [events, output] = STAMP(EEG, channelList, numberAtoms, freqBounds, atomScales)
%   
%  Parameters:
%    EEG           Input EEG structure (EEGLAB format)
%    channelList   Vector of channel numbers to analyze
%  numberAtoms:    Total number of atoms to use in reconstruction. 
%                  (Scalar, positive integer)
%  freqBounds:     Frequency boundry to restrict reconstruction to. (1x2 vector with positive integers, e.g.,[6 14])
%  atomScales:     Scales of gabor atoms in a positive vector [0.5 1 2]
%  expertEvents:   Struct with expert-rated times and durations for spindles (scalar or vector of positive integers).
%
% Output:
%  events:         Matrix of detected events, with first column as start 
%                  time and second as end time (both in seconds).
%  spindles:       Struct containing MP info, and if relevant, performance.
%
%  Written by:     J. LaRocco, K. Robbins, UTSA 2016-2017


%% Calculate performance if expert event annotation has been provided
if nargin == 12 && ~isempty(expertEvents)
    doPerformance = true;
else
    doPerformance = false;
end

%% Generate the Gabor dictionary for the MP decomposition
gabors = getGabors(EEG.srate, atomFrequencies, atomScales);

%% Extract the channels and filter the EEG signal before MP
[numChans, numFrames] = size(EEG.data);
if max(channelNumbers) > numChans
    error('getSpindles:BadChannel', 'The EEG does not have channels needed');
end
EEG.data = EEG.data(channelNumbers, :);
EEG.nbchan = length(channelNumbers);
numChans = length(channelNumbers);
lowFreq = max(1, min(atomFrequencies));
highFreq = min(ceil(EEG.srate/2.1), max(atomFrequencies));
EEG = pop_eegfiltnew(EEG, lowFreq, highFreq);
dataSeconds = numFrames/EEG.srate;

%% Reconstruct the signal using MP with a Gabor dictionary
reconstructed = zeros(numChans, numFrames);
theAtoms = round(atomsPerSecond*dataSeconds);
maxAtoms = max(theAtoms);
atomParams = zeros(numChans, maxAtoms, 3);
R2Values = zeros(numChans, maxAtoms);
for k = 1:numChans
    [reconstructed(k, :),atomParams(k, :, :), scaledGabors, R2Values(k, :)] = ...
        temporalMP(squeeze(EEG.data(k, :)), gabors, false, maxAtoms); 
end

%% Set the voting scale
if numChans > 3
    vote = 1/3;
else
    vote = 1/numChans;   
end

%% Combine adjacent spindles and eliminate items that are too short.
padsize = size(scaledGabors, 1);
rgdelta  = 1:padsize;
rgdelta  = rgdelta - mean(rgdelta);
numFrames = size(EEG.data, 2);
yp = zeros(numChans, 2*padsize + numFrames);
numAtoms = length(theAtoms);
numThresholds = length(baseThresholds);
if doPerformance
   spindles(numAtoms*numThresholds) = ...
            struct('atomsPerSecond', NaN, 'numberAtoms', NaN, ...
                   'baseThreshold', NaN', 'numberSpindles', NaN, ...
                   'spindleTime', NaN, 'spindleTimeRatio', NaN, ...
                   'events', NaN, 'meanEventTime', NaN, 'r2', NaN, ...
                   'f1ModTime', NaN, 'f1ModHits', NaN, ...
                   'f1ModOnsets', NaN, 'f1ModInter', NaN, ...
                   'metricsTime', NaN, 'metricsHits', NaN, ...
                   'metricsOnsets', NaN, 'metricsInter', NaN);
else
   spindles(numAtoms*numThresholds) = ...
             struct('atomsPerSecond', NaN, 'numberAtoms', NaN, ...
                   'baseThreshold', NaN', 'numberSpindles', NaN, ...
                   'spindleTime', NaN, 'spindleTimeRatio', NaN, ...
                   'events', NaN, 'meanEventTime', NaN, 'r2', NaN);
end
atomsPerSecond = sort(atomsPerSecond);
currentAtom = 1;
spindleRatios = zeros(numThresholds, numAtoms);
for k = 1:numAtoms
    for m = currentAtom:theAtoms(k)
        for n = 1:numChans        
            theFrames = atomParams(n, m, 2) + rgdelta;
            yp(n, theFrames) = yp(n, theFrames) + ...
                atomParams(n, m, 3)*scaledGabors(:, atomParams(n, m, 1))';
        end
    end
    currentAtom = theAtoms(k) + 1;
    y = yp(:, padsize + 1:end-padsize);
    r2 = R2Values(:, theAtoms(k));
    fprintf('[%d] ', theAtoms(k));
    for j = 1:numThresholds
        fprintf('%d ', baseThresholds(j));
        p = (j - 1)*numAtoms + k;
        spindles(p) = spindles(end);
        spindles(p).r2 = r2;
        spindles(p).atomsPerSecond = atomsPerSecond(k);
        spindles(p).numberAtoms = theAtoms(k);
        spindles(p).baseThreshold = baseThresholds(j);
        events = applyVote(y, EEG.srate, baseThresholds(j), vote);
        events = combineEvents(events, minLength, minTime);
        spindles(p).events = events;
        eventTimes = cellfun(@double, events(:, 2:3));
        spindles(p).meanEventTime = mean(eventTimes(:,2) - eventTimes(:,1));
        [spindles(p).numberSpindles, spindles(p).spindleTime] = ...
                                                 getSpindleCounts(events);
        spindles(p).spindleTimeRatio = spindles(p).spindleTime/(EEG.pnts/EEG.srate);                                     
        %totalEventRatios(p) = spindles(p).spindleTimeRatio;
        spindleRatios(j, k) = spindles(p).spindleTime/length(events);
        if doPerformance
            [~, ~, timeInfo] = evaluateTimingErrors(EEG, expertEvents, events, ...
                timeError, EEG.srate);
            spindles(p).metricsTime = getPerformanceMetrics(timeInfo.agreement,...
                timeInfo.nullAgreement,timeInfo.falsePositive,timeInfo.falseNegative);
            hitInfo = evaluateHits(expertEvents, events);
            spindles(p).metricsHits = getPerformanceMetrics(hitInfo.tp, hitInfo.tn, ...
                hitInfo.fp, hitInfo.fn);
            onsetInfo = evaluateOnsets(expertEvents, events, onsetTolerance);
            spindles(p).metricsOnsets = getPerformanceMetrics( ...
                onsetInfo.tp, onsetInfo.tn, onsetInfo.fp, onsetInfo.fn);
            interInfo = evaluateIntersectHits(expertEvents, ...
                events, intersectTolerance);
            dataTime = size(EEG.data, 2)/EEG.srate;
            reverseTrue = reverseEvents(expertEvents, dataTime);
            reverseLabeled = reverseEvents(events, dataTime);
            interInfoReverse = evaluateIntersectHits(reverseTrue, ...
                                   reverseLabeled, intersectTolerance);
           
            interInfo.tn = interInfoReverse.tp;
            spindles(p).metricsInter = getPerformanceMetrics( ...
                interInfo.tp, interInfo.tn, interInfo.fp, interInfo.fn);
            spindles(p).f1ModTime = spindles(p).metricsTime.f1Mod;
            spindles(p).f1ModHits = spindles(p).metricsHits.f1Mod;
            spindles(p).f1ModOnsets = spindles(p).metricsOnsets.f1Mod;
            spindles(p).f1ModInter = spindles(p).metricsInter.f1Mod;         
        end
        
    %% select event mean time and min event ratio
%     spRange = totalEventRatios <= 0.15 ;
%     eM = meanEventTimes(1, spRange);
%     final = find(eM == min(eM));
%     finalEvents = spindles(final(1)).events;
        
    end
    fprintf('\n');
end

theError = sum(sum(abs(y-reconstructed)));
if theError > 1e-9
    fprintf('Warning: reconstruction error is %g\n', theError);
end
