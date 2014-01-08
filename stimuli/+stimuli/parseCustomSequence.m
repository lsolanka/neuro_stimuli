%
%   Create a list of CustomSequence objects from a string input.
%       The sequence string is a comma separated list of these values:
%           * 'b' - Blank black screen as a stimulus
%           * 'g' - Blank grey screen as a stimulus
%           * Number - Grating stimulus, with grating angle specified by the
%               number
%
%   Parameters:
%       seqStr A string containing the sequence of colors and angles
%   Returns:
%       An array of customSequence objects
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%
function returnSequence = parseCustomSequence(seqStr)

    if ~isa(seqStr, 'char')
        id = 'stimuli:parseCustomSequence:InvalidValue';
        msg = 'Stimuli sequence must be a string';
        throw(MException(id, msg));
    end


    try
        parsedStrings = textscan(seqStr, '%s', 'delimiter', ',');
        parsedStrings = parsedStrings{1};
    catch e
        throwEmpty();
    end

    returnSequence = [];

    for idx = 1:length(parsedStrings)
        s = parsedStrings{idx};
        angle = str2double(s);
        if (isnan(angle))
            % Uniform stimulus
            if (strcmp(s, 'b') || strcmp(s, 'g'))
                returnSequence = [returnSequence stimuli.UniformStimulus(s)];
            else
                throwInvalidCharValue(s);
            end
        else
            % Grating stimulus specified by an angle
            returnSequence = [returnSequence stimuli.MovingGratingStimulus(angle+90)];
        end
    end
    


function throwInvalidCharValue(s)
    id = 'stimuli:parseCustomSequence:InvalidValue';
    msg = 'Cannot parse "%s": it must be one of "b", "g", or a number specifying an angle!';
    throw(MException(id, sprintf(msg, s)));
    
function throwEmpty()
    id = 'stimuli:parseCustomSequence:InvalidValue';
    msg = 'Custom sequence cannot be empty!';
    throw(MException(id, msg));
