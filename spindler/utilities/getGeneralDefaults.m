function defaults = getGeneralDefaults()
% Returns the defaults for spindle detection
%
% Parameters:
%
%     defaults     a structure with the parameters for the default types
%                  in the form of a structure that has fields
%                     value: default value
%                     classes:   classes that the parameter belongs to
%                     attributes:  attributes of the parameter
%                     description: description of parameter
%

defaults = struct( ...
    'eventOverlapMethod', ...
    getRules('union', {'char'}, {}, ...
    ['How to combine spindle events when they overlap ' ...
    'union (default)uses the union, while largest chooses the longest.']), ...
    'figureClose', ...
    getRules(true, ...
    {'logical'}, {}, ... 
    'If true, closes the figures after generating.'), ...
    'figureFormats', ...
    getRules({'png'}, ...
    {'cell'}, {}, ... 
    'Cell array specifying formats for saving figures.'), ...
    'intersectTolerance', ...
    getRules(0.2, ...
    {'numeric'}, {'scalar', 'positive'}, ... 
    'Timing tolerance in seconds for intersect method of determining spindle match.'), ...
    'minSpindleLength', ...
    getRules(0.25, ...
    {'numeric'}, {'scalar', 'positive'}, ... 
    'Minimum spindle length in seconds.'), ...
    'minSpindleSeparation', ...
    getRules(0.25, ...
    {'numeric'}, {'scalar', 'positive'}, ... 
    'Minimum time separating spindles before they are considered distinct.'), ...
    'onsetTolerance', ...
    getRules(0.5, ...
    {'numeric'}, {'scalar', 'positive'}, ... 
    'Timing tolerance in seconds for onset method of determining spindle match.'), ...
    'samplingRateTarget', ...
    getRules(128, ...
    {'numeric'}, {'scalar', 'positive'}, ... 
    'Target sampling rate for downsampling (usually will do integral amount).'), ...
    'spindleSecondsDuration', ...
    getRules(1.0, ...
    {'numeric'}, {'scalar', 'positive'}, ... 
    'Assumed spindle duration in seconds for computing true negatives.'), ...
    'timingTolerance', ...
    getRules(0.2, ...
    {'numeric'}, {'scalar', 'positive'}, ... 
    'Timing tolerance in seconds on either side for timing method of matching spindles.')...
    ); 
end

function s = getRules(value, classes, attributes, description)
% Construct the default structure
s = struct('value', [], 'classes', [], ...
    'attributes', [], 'description', []);
s.value = value;
s.classes = classes;
s.attributes = attributes;
s.description = description;
end