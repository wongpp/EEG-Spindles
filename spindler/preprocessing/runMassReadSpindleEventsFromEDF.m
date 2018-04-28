%% Convert expert event annotations from .edf format to .mat format

%% Set up the locations
inDir = 'D:\TestData\Alpha\spindleData\massNew\eventsEDF\expert1';
outDir = 'D:\TestData\Alpha\spindleData\massNew\events\expert1';
% inDir = 'E:\MASS\SS2\annotations\spindle_e2_edf';
% outDir = 'D:\TestData\Alpha\spindleData\mass\annotations\spindlesE2';

%% Make sure output directory exists
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Get the list of EYE filenames from level 0
fileNames = getFiles('FILES', inDir, '.edf');
numberFiles = length(fileNames);

%% Process the files
for k = 1:numberFiles
    [data, header] = readEDFAnnotations(filename);
    %% See if the file has events
    if ~isfield(header, 'events') || isempty(header.events)
        warning('%s has no spindles', fileNames{k});
        continue;
    end
    theEvents = header.events;
    %% Convert the events to an array
    [thePath, theName, theExt] = fileparts(fileNames{k});
    numberEvents = length(theEvents.POS);
    srate = round(header.samplingrate);
    startTimes = double(cell2mat({theEvents.POS}) - 1)./srate;
    endTimes = startTimes + double(cell2mat({theEvents.DUR}))./srate;
    events = [startTimes(:), endTimes(:)];
    save([outDir filesep theName '.mat'], 'events', '-v7.3');
end