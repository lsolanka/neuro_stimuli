%
%   Create a list of stimuli drawers, based on number of orientations per
%   circle.
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Paolo Puggioni, <p.paolo321@gmail.com>
%                Lukas Solanka, <lsolanka@gmail.com>
%
function stimulusDrawers = calculateOrientations(numOrient, chronicOrient,...
    randomOrder, type)
    import stimuli.StimulusType;

    stimulusDrawers = [];

    incOrient = 360 / numOrient;
    %offset 90 deg to have zero up
    for orientation = 90 + [0:numOrient-1]*incOrient + chronicOrient;
        if type == StimulusType.MovingGrating
            stimulusDrawers = [stimulusDrawers ...
                    stimuli.MovingGratingStimulus(orientation)];
        elseif type == StimulusType.PhaseReversal
            stimulusDrawers = [stimulusDrawers ...
                    stimuli.PhaseReversalStimulus(orientation)];
        else
            msg = strcat('Unknown stimulus type' + type.char());
            e = MException('stimuli:calculateOrientations:InvalidValue', msg);
            throw(e);
        end
    end

    if randomOrder
        newOrder = randperm(numOrient);
        stimulusDrawers = stimulusDrawers(newOrder);
    end

end
