% get spontaneous spike rates from trials 12 and 19

% define the frame rate
frameRate = 30.9;

spontSpikeRates = zeros(1,numNeurons-4);

for neuron = [4:numNeurons-1]
    Neuron{neuron}.spontSpikeRate = (sum(A{12}.spikes(2:end,neuron))...
        +sum(A{19}.spikes(2:end,neuron)))*30.9/(2*numFrames-2);
    spontSpikeRates(neuron-3)= Neuron{neuron}.spontSpikeRate;
end
    
spontSpikeRates
meanSpontSpRate = mean(spontSpikeRates)
stdevSpontSPRate = std(spontSpikeRates)

figure
fntsze = 14;
hist(spontSpikeRates), title('Histogram of Spontaneous Spiking Rates (Hz)','FontSize',fntsze),
ylabel('Frequency','FontSize',fntsze), xlabel('Spike Rate (Hz)','FontSize',fntsze)