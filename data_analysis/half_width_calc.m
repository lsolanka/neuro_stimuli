% for i = [1:length(responsiveNeurons)]
%     figure
%     neuron = responsiveNeurons(i);
%     plot([1:360],Neuron{neuron}.spikeRate360)
% end

% for spikes
% 
% halfWidths = zeros(1, numNeurons);
% for neuron = [3:numNeurons]
%     [maxVal ind] = max(Neuron{neuron}.spikeRate360);
%     minVal = min(Neuron{neuron}.spikeRate360);
% 
%     halfVal = (maxVal+minVal)/2;
% 
%     % find closest to the halfval
%     distFromHalf = Neuron{neuron}.spikeRate360-halfVal;
%     %make sure greater than zero
%     distFromHalf = distFromHalf.*(distFromHalf >= 0);
% 
%     y = find(distFromHalf);
% 
%     placeUp = ind;
%     placeDown = ind;
% 
% 
%     while length(find(y == mod(placeUp,360)+1)) > 0 
%         %& length(find(y == mod(placeDown,360)-1)) > 0
%         placeUp = mod(placeUp,360)+1;
%         placeDown = placeDown-1;
%         if placeDown == 0
%             placeDown = 360;
%         end
%     end
% 
%     val1 = placeUp;
%     val2 = placeDown;
% 
%     if val1>val2
%         halfWidth = val1-val2;
%     else
%         halfWidth=360+val1-val2;
%     end
% 
%     Neuron{neuron}.halfWidth = halfWidth;
%     halfWidths(neuron) = halfWidth;
% end
%  
% for i = [1:length(sigNeurons)]
%     neuron = sigNeurons(i);
%     Neuron{neuron}.halfWidth;
% end

% for transients
% 
halfWidths = zeros(1, numNeurons);
for neuron = [3:numNeurons]
    [maxVal ind] = max(Neuron{neuron}.integral360);
    minVal = min(Neuron{neuron}.integral360);

    halfVal = (maxVal+minVal)/2;

    % find closest to the halfval
    distFromHalf = Neuron{neuron}.integral360-halfVal;
    %make sure greater than zero
    distFromHalf = distFromHalf.*(distFromHalf >= 0);

    y = find(distFromHalf);

    placeUp = ind;
    placeDown = ind;


    while length(find(y == mod(placeUp,360)+1)) > 0 
        %& length(find(y == mod(placeDown,360)-1)) > 0
        placeUp = mod(placeUp,360)+1;
        placeDown = placeDown-1;
        if placeDown == 0
            placeDown = 360;
        end
    end

    val1 = placeUp;
    val2 = placeDown;

    if val1>val2
        halfWidth = val1-val2;
    else
        halfWidth=360+val1-val2;
    end

    Neuron{neuron}.halfWidth = halfWidth;
    halfWidths(neuron) = halfWidth;
end
%  
% for i = [1:length(sigNeurons)]
%     neuron = sigNeurons(i);
%     Neuron{neuron}.halfWidth;
% end
