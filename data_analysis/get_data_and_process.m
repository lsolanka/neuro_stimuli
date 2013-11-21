%This is the main file. The min one just copies this and changes the
%baseline to minimum

% ---------------------LOAD JUST TRIALS 12 - 21---------------------


% An important issue is whether to allow for negative calcium
% transients.......control in the following variable, 1 is yes, 0 is no
allowNegTrans = 1;



part1 = '080420_A';

for i = [12:21]
    filename = strcat(part1, num2str(i),'.txt');    
    A{i} = importdata(filename);
    
    sprintf(strcat('Trial ',num2str(i),' has length ',num2str(length(A{i}.textdata))));
    
end

% the 12th trial has an extra column, so we delete the first (and they sync
% up). NOTE: the textdata etc will still be off.
A{12}.data = A{12}.data(:,[2:length(A{12}.data(1,:))]);


% to make it easy later, get some parameters in order
stimTrials = cat(2,[13:18],[20,21]);
numNeurons = length(A{12}.data(1,:));
numFrames = length(A{12}.data(:,1));
stimTimes = importdata('stimTimes.txt');
secsPerStim = 5;                             % 5 seconds per stimulus

% now turn the data into transients, NOTE: how is baseline,F_b, calculated?
for trial =[12:21]
    for neuron = [3:numNeurons]
        F_b = baseline_mode(A{trial}.data(:,neuron));
        A{trial}.data(:,neuron) = (A{trial}.data(:,neuron)-F_b)/F_b;
        if allowNegTrans == 0
            x = A{trial}.data(:,neuron)>=0;
            A{trial}.data(:,neuron) = x .* A{trial}.data(:,neuron);
        end
    end
end
   
% also calculate spikes
V.dt = 1/30.9;
for trial =[12:21]
    A{trial}.spikes = 0*A{trial}.data;
    for neuron = [3:numNeurons]
        A{trial}.spikes(:,neuron) = fast_oopsi(A{trial}.data(:,neuron),V);
    end
end

% plot one transient to see
% plot([1:length(A{12}.data(:,6))],A{12}.data(:,6)) 

% get averages per neuron of each trial, transient and spikes
for neuron = [3:numNeurons]
    trace = zeros(numFrames,1);
    for trial = stimTrials
        trace = trace + A{trial}.data(:,neuron);
    end
    Neuron{neuron}.mean = trace/length(stimTrials);
end

% also for spikes
for neuron = [3:numNeurons]
    spikes = zeros(numFrames,1);
    for trial = stimTrials
        spikes = spikes + A{trial}.spikes(:,neuron);
    end
    Neuron{neuron}.meanspikes = spikes/length(stimTrials);
end

% % example of the mean plot
% figure
% plot([1:numFrames],Neuron{8}.mean,'-r')
% hold on
% ymin = min(Neuron{8}.mean);
% ymax = max(Neuron{8}.mean);
% for i = [1:length(stimTimes)]
%     stim = stimTimes(i);
%     line([stim stim],[ymin ymax],'Color', 'black')
% end
% hold off

% calculate the integral of the mean transients
% NOTE: first moving stim is the 4th, and it is every two
% fourier interpolate to 360 degrees
for neuron = [3:numNeurons]
    % for each angle, find the appropriate frames
    integralByAngle = zeros(1,8);
    for i = [1:8]
        xminIndex = 2*(i+1);
        xmaxIndex = xminIndex + 1;
        xmin = ceil(stimTimes(xminIndex));
        xmax = ceil(stimTimes(xmaxIndex));
        integralByAngle(i) = trapz(Neuron{neuron}.mean([xmin : xmax]));
    end
    Neuron{neuron}.integral = integralByAngle;
    Neuron{neuron}.integral360 = interpft(integralByAngle,360);
end

% calculate the mean spike rate
for neuron = [3:numNeurons]
    % for each angle, find the appropriate frames
    totalSpikes = zeros(1,8);
    for i = [1:8]
        xminIndex = 2*(i+1);
        xmaxIndex = xminIndex + 1;
        xmin = ceil(stimTimes(xminIndex));
        xmax = ceil(stimTimes(xmaxIndex));
        totalSpikes(i) = sum(Neuron{neuron}.meanspikes([xmin : xmax]));
        
    end
    Neuron{neuron}.spikeRate = totalSpikes/secsPerStim;
    Neuron{neuron}.spikeRate360 = interpft(Neuron{neuron}.spikeRate,360);
end


stimAngles = [0,45,90,135,180,225,270,315];

% %test, by looking at neuron 8, which has clear peaks
% figure
% plot(stimAngles,Neuron{8}.integral);

% calculate OSI and DSI for each neuron
for neuron = [3:numNeurons]
    [Neuron{neuron}.maxval, maxValIndex] = max(Neuron{neuron}.integral);
    orthoIndex = 1 + mod(maxValIndex + 1, 8);           % this is finding the orthogonal, 2 later
    oppoIndex = 1 + mod(maxValIndex + 3, 8);           % this is finding the opposite, 4 later

    %store OSIs
    Neuron{neuron}.orthoval = Neuron{neuron}.integral(orthoIndex);
    Neuron{neuron}.OSI = (Neuron{neuron}.maxval - Neuron{neuron}.orthoval)...
        / (Neuron{neuron}.maxval + Neuron{neuron}.orthoval);
    
    %store DSIs
    Neuron{neuron}.oppoval = Neuron{neuron}.integral(oppoIndex);
    Neuron{neuron}.DSI = (Neuron{neuron}.maxval - Neuron{neuron}.oppoval)...
        / (Neuron{neuron}.maxval + Neuron{neuron}.oppoval);
end

% calculate the spike based OSI and DSI for each neuron
for neuron = [3:numNeurons]
    [Neuron{neuron}.maxSpikeVal, maxValIndex] = max(Neuron{neuron}.spikeRate);
    orthoIndex = 1 + mod(maxValIndex + 1, 8);           % this is finding the orthogonal, 2 later
    oppoIndex = 1 + mod(maxValIndex + 3, 8);           % this is finding the opposite, 4 later

    %store spikeOSIs
    Neuron{neuron}.orthoSpikeVal = Neuron{neuron}.spikeRate(orthoIndex);
    Neuron{neuron}.spikeOSI = (Neuron{neuron}.maxSpikeVal - Neuron{neuron}.orthoSpikeVal)...
        / (Neuron{neuron}.maxSpikeVal + Neuron{neuron}.orthoSpikeVal);

    %store spikeDSIs
    Neuron{neuron}.oppoSpikeVal = Neuron{neuron}.spikeRate(oppoIndex);
    Neuron{neuron}.spikeDSI = (Neuron{neuron}.maxSpikeVal - Neuron{neuron}.oppoSpikeVal)...
        / (Neuron{neuron}.maxSpikeVal + Neuron{neuron}.oppoSpikeVal);
end

% format for the polar plots
stimAnglesPolar = stimAngles*2*pi/360;
% to make the polar plot join up
stimAnglesPolar(9) = 2*pi;
stimAngles(9) = 360;

for neuron = [3:numNeurons]
    Neuron{neuron}.integral(9) = Neuron{neuron}.integral(1);
    Neuron{neuron}.spikeRate(9) = Neuron{neuron}.spikeRate(1);
end


% see what the OSIs are
 for neuron = [3:numNeurons]
    [Neuron{neuron}.OSI Neuron{neuron}.spikeOSI];
 end

