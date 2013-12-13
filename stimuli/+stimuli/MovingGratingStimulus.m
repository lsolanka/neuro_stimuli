%
%   MovingGratingStimulus.m
%
%   A stimulus class identifier for angles.
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%

classdef MovingGratingStimulus < stimuli.CustomStimulus

    methods
        function obj = MovingGratingStimulus(val)
            if (~isa(val, 'numeric') || numel(val) ~= 1)
                msg = 'An angle must be a numeric value with one element';
                e = MException('stimuli:AngleStimulus:InvalidValue', msg);
                throw(e);
            end
            obj.value = val;
        end

        function startTime = draw()
            startTime = nan;
        end
    end
end
