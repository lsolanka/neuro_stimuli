% Test for reliable responsiveness

% From each trial, we obtained one orientation tuning curve, and neurons
% were defined as reliably responsive if the mean cross- correlation
% between all pairs of curves obtained from different trials was
% greater than 0.1

% % STEPS:
% 1: take the significantly responsive neurons
% 2. calculate the orientation tuning curve per trial
% 3. find the cross correlation across all pairs - take the max value
% 4. test to see if all are greater than 0.1

%% Step1 - to do (and enclose in a for loop)

responsiveNeurons = zeros(1, numNeurons);

% start here
% for neuronIndex = [1:length(sigNeurons)]
%     neuron = sigNeurons(neuronIndex);

for neuron = [3:numNeurons]
    

%% Step 2- calculate the orientation tuning curve per trial

    % for each neuron, we will store the orientation curves in a matrix. Each 
    % row is a trial
    xcorrMatrix = zeros(length(stimTrials),8);

    for i = [1:length(stimTrials)]
        trial = stimTrials(i);
    %     caTransientTrial = A{trial}.data(:,neuron);   % if using transients
        spikeTrainTrial = A{trial}.spikes(:,neuron);    % if using spikes

        for j = [1:8]
            xminIndex = 2*(j+1);
            xmaxIndex = xminIndex + 1;
            xmin = ceil(stimTimes(xminIndex));
            xmax = ceil(stimTimes(xmaxIndex));

            %xcorrMatrix(i,j) = trapz(caTransientTrial(xmin:xmax)); % if using transients
            xcorrMatrix(i,j) = mean(spikeTrainTrial(xmin:xmax)); % if using transients
        end
    end

    %% STEP 3 - find cross correlations across all pairs

    % find all combinations
    comboList = combnk([1:length(stimTrials)],2);

    % create an empty list to populate
    xcorrVals = zeros(1,length(comboList));

    for combo = [1:length(comboList(:,1))]
        % find the cross correlation per pair
        i = comboList(combo,1);
        j = comboList(combo,2);
        xcorrPair = corr(xcorrMatrix(i,:)',xcorrMatrix(j,:)');

        % store the maximum value
        xcorrVals(combo) = max(xcorrPair);
    end
    mean(xcorrVals)

    %% STEP 4 - test if the mean is greater than 1

    if mean(xcorrVals)>0.1
        responsiveNeurons(neuron) = neuron;
    end

end

% outside of for loop
responsiveNeurons = responsiveNeurons(responsiveNeurons>0)

    