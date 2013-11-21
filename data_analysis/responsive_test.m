% p = anova1(X) performs balanced one-way ANOVA for comparing the means of
% two or more columns of data in the matrix X, where each column represents 
% an independent sample containing mutually independent observations. 
% The function returns the p-value under the null hypothesis that 
% all samples in X are drawn from populations with the same mean. 

% so we need, for each neuron, to have a matrix with each row being a trial
% and each col to be firing rates per stimulus. Here goes!




sigNeurons = zeros(1,numNeurons);

for neuron = [3:numNeurons]
    anovaMatrix = zeros(length(stimTrials)+1,8);
    % get the spike train per trial
    for j = [1:length(stimTrials)]
        if j ~= length(stimTrials)
            trial = stimTrials(j);
            spikeTrainTrial = A{trial}.spikes(:,neuron);
        end

    %for each trial, get the total spikes per stim
        for i = [1:9]
            if i ~= 9
                xminIndex = 2*(i+1);
                xmaxIndex = xminIndex + 1;
                xmin = ceil(stimTimes(xminIndex));
                xmax = ceil(stimTimes(xmaxIndex));
                anovaMatrix(j,i) = sum(spikeTrainTrial([xmin : xmax]));   
            else % for the 9th, take a section a bit later (either grey or black)
                diff = 2*(xmax-xmin);
                xmax = xmax+diff;
                xmin = xmin+diff;
                anovaMatrix(j,i) = sum(spikeTrainTrial([xmin : xmax]));
            end
        end
    end
    
    %test significance, p < 0,05
    Neuron{neuron}.pvalue = anova1(anovaMatrix,[],'off');
    part1 = strcat('Neuron number ',num2str(neuron),' has p-value = ');
    part2 = num2str(Neuron{neuron}.pvalue);
    sprintf(strcat(part1, ' ', part2))
    if Neuron{neuron}.pvalue < 0.05
        sigNeurons(neuron) = neuron;
    end
end
    
sigNeurons = sigNeurons(sigNeurons>0)

% for neuron = [3:numNeurons]
%     figure
%     subplot(2,1,1)
%     plot([1:numFrames],Neuron{neuron}.mean,'-r'), 
%     title(sprintf('Transients, neuron %d',neuron)),
%     hold on
%     ymin = min(Neuron{neuron}.mean);
%     ymax = max(Neuron{neuron}.mean);
%     for i = [1:length(stimTimes)]
%         stim = stimTimes(i);
%         line([stim stim],[ymin ymax],'Color', 'black')
%     end
%     hold off
%     
%     subplot(2,1,2)
%     plot([1:numFrames],Neuron{neuron}.meanspikes), 
%     title(sprintf('Spikes, neuron %d',neuron)),
%     hold on
%     ymin = min(Neuron{neuron}.meanspikes);
%     ymax = max(Neuron{neuron}.meanspikes);
%     for i = [1:length(stimTimes)]
%         stim = stimTimes(i);
%         line([stim stim],[ymin ymax],'Color', 'black')
%     end
%     hold off
% end

% summary of prog: neurons 5, 19 are stat significant from the anova test.
% Ho Ko would call these 'Responsive neurons'.