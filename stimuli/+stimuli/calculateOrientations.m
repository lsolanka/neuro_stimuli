%
%   Create a list of stimuli drawers, based on number of orientations per
%   circle.
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Paolo Puggioni, <p.paolo321@gmail.com>
%                Lukas Solanka, <lsolanka@gmail.com>
%
function stimulusDrawers = calculateOrientations(numOrient, chronicOrient,...
    randomOrder)

    stimulusDrawers = [];

    incOrient = 360 / numOrient;
    %offset 90 deg to have zero up
    for orientation = 90 + [0:numOrient-1]*incOrient + chronicOrient;
        stimulusDrawers = [stimulusDrawers ...
                stimuli.MovingGratingStimulus(orientation)];
    end

    if randomOrder
        newOrder = randperm(numOrient);
        stimulusDrawers = stimulusDrawers(newOrder);
    end

end
