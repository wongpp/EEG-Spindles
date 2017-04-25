function metrics = getConfusionMetrics(tp, tn, fp, fn)
%% Compute performance metrics based on the confusion matrix
% 
%  Parameters:
%    tp       True positives  
%    tn       True negatives  
%    fp       False positives  
%    fn       False negatives  
%    metrics  (Output) Structure containing the following performance metrics
%      accuracy
%      precision
%      recall
%      sensitivity
%      specificity 
%      ppv
%      npv
%      tpr
%      fpr
%      roc
%      auc 
%      phi
%      f1
%      f2
%      G
%      kappa
%
%  Written by:  John La Rocco and Kay Robbins, UTSA, 2016-2017

%% Initialize the metrics structure
    metrics = struct('tp', tp, 'tn', tn, 'fn', fn, 'fp', fp, ...
                     'accuracy', NaN, 'precision', NaN, 'recall', NaN, ...
                     'sensitivity', NaN, 'specificity', NaN, ...
                     'ppv', NaN, 'npv', NaN, 'tpr', NaN, 'fpr', NaN, ...
                     'roc', NaN, 'auc', NaN, 'phi', NaN, ...
                     'f1', NaN, 'f2', NaN, 'G', NaN, 'kappa', NaN);

%% Compute auxillary variables
    checkSum = tp + tn + fn + fp;
    predPositives = tp + fp;
    predNegatives = tn + fn;
    truePositives = tp + fn;
    trueNegatives = fp + tn;

%% Compute the metrics
    metrics.accuracy = (tp + tn)/checkSum;
    metrics.sensitivity = tp/truePositives;
    metrics.specificity = tn/trueNegatives;
    metrics.ppv = tp/predPositives;
    metrics.npv = tn/predNegatives;
    metrics.tpr = metrics.sensitivity;
    metrics.fpr = 1 - metrics.specificity;
    metrics.roc= [metrics.fpr, metrics.tpr];
    metrics.auc = metrics.fpr*metrics.tpr;
    metrics.phi = 0;
    phi_denom = sqrt(truePositives*trueNegatives*predPositives*predNegatives);
    if ~isinf(phi_denom) && ~isnan(phi_denom) && phi_denom ~= 0
        metrics.phi = (tp*tn - fp*fn)/phi_denom;
    end
    metrics.precision = metrics.ppv;
    metrics.recall = metrics.sensitivity;
    if metrics.precision + metrics.recall == 0
        metrics.f1 = 0;
        metrics.f2 = 0;
    else
       metrics.f1 = 2*metrics.precision*metrics.recall/(metrics.precision + metrics.recall);
       metrics.f2 = 5.*metrics.precision*metrics.recall ...
        ./(4.*metrics.precision + metrics.recall);
    end
    metrics.G = sqrt(metrics.precision*metrics.recall);
    Po = metrics.accuracy;
    Pe = ((tp + tn)*(tp + fp) + (fp + tn)*(fn + tn))/checkSum;
    metrics.kappa = (Po - Pe)/(1 - Pe);
end