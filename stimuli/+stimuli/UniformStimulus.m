%
%   UniformStimulus.m
%
%   A uniform stimulus class identifier.
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%

%
% Uniform stimulus identifier.
% Accepts a single color specifier (one character)
%
classdef UniformStimulus < stimuli.CustomStimulus

    methods
        function obj = UniformStimulus(val)
            if (~isa(val, 'char') || numel(val) ~= 1)
                msg = 'A color definition for a uniform stimulus must be a char';
                id = 'stimuli:UniformStimulus:InvalidValue';
                throw(MException(id, msg));
            end
            
            obj.value = val;
        end

        function startTime = draw()
            startTime = nan;
        end
    end
end
