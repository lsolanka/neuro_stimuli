
% to illustrate that spike and transients give same polar plots, plot the
% first arbitrary n plots
fntsze = 20;
% format for the polar plots
stimAnglesPolar = stimAngles*2*pi/360;
% to make the polar plot join up
stimAnglesPolar(9) = 2*pi;
stimAngles(9) = 360;

% to make the polar join up
for neuron = [3:numNeurons]
    Neuron{neuron}.integral(9) = Neuron{neuron}.integral(1);
    Neuron{neuron}.spikeRate(9) = Neuron{neuron}.spikeRate(1);
end

% to find the average vector

% full 360 plot
% for i = [1:length(sigNeurons)]
%     figure
%     neuron = sigNeurons(i);
%     maxRate = max(Neuron{neuron}.spikeRate360);
%     maxCalc = max(Neuron{neuron}.integral360);
%     polar([pi/180:pi/180:2*pi], Neuron{neuron}.spikeRate360/maxRate,'og'),
%     hold on
%     polar([pi/180:pi/180:2*pi], Neuron{neuron}.integral360/maxCalc,'r-')
%     title(strcat('Neuron #', num2str(neuron-1)))
% end

for i = [1:length(sigNeurons)]
    figure
    neuron = sigNeurons(i);
    maxRate = max(Neuron{neuron}.spikeRate);
    maxCalc = max(Neuron{neuron}.integral);
    polar(stimAnglesPolar, Neuron{neuron}.spikeRate/maxRate,'r-'),
    set(gca,'FontSize',fntsze)
    hold on
    polar(stimAnglesPolar, Neuron{neuron}.integral/maxCalc,'b-')
    title(strcat('Neuron #', num2str(neuron-1)),'FontSize',fntsze)        
%     legend('Spike Rate (Hz)','Calcium Transients dF/F', 'Location', 'NorthEastOutside')

    
    th = findall(gcf,'Type','text');

    for i = 1:length(th),
        set(th(i),'FontSize',fntsze)
    end
end

% create list of sig but not responsive neurons
% sigUnrespNeurons = zeros(1, length(sigNeurons));
% for i = [1:length(sigNeurons)]
%     neuron = sigNeurons(i);
%     if any(responsiveNeurons==neuron)==0
%         sigUnrespNeurons(neuron) = neuron;
%     end
% end


% sigUnrespNeurons= sigUnrespNeurons(sigUnrespNeurons>0);
% 
% figure
% for i = [1:length(sigUnrespNeurons)]
%     neuron = sigUnrespNeurons(i);
%     subplot(1,length(sigUnrespNeurons),i),polar(stimAnglesPolar, Neuron{neuron}.spikeRate),
%     title(strcat('Neuron #', num2str(neuron)))
% end