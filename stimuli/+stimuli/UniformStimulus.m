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

    properties (Access = protected)
        textureId
        duration
    end

    methods
        function obj = UniformStimulus(val)
            if (~isa(val, 'char') || numel(val) ~= 1)
                msg = 'A color definition for a uniform stimulus must be a char';
                id = 'stimuli:UniformStimulus:InvalidValue';
                throw(MException(id, msg));
            end
            
            obj.value = val;
        end


        function setDrawingParameters(obj, par)
            setDrawingParameters@stimuli.CustomStimulus(obj, par);
            switch obj.value
                case 'b'
                    obj.duration = par.customBlackTime;
                case 'g'
                    obj.duration = par.customGreyTime;

            end
            obj.createTexture();
        end


        function createTexture(obj)
            if (obj.value == 'b')
                texture = obj.black;
            else
                texture = obj.grey;
            end
            obj.textureId = Screen('MakeTexture', obj.w, texture);
        end


        function timing = draw(obj, dstRect)
            srcRect = [0 0 obj.visiblesize obj.visiblesize];
            Screen('DrawTexture', obj.w, obj.textureId, srcRect, dstRect);
            startTime   = Screen('Flip', obj.w, 0)
            endTime     = startTime + obj.duration;
            flipEndTime = Screen('Flip', obj.w, endTime)

            timing = stimuli.UniformTiming(startTime, flipEndTime);
        end
    end
end
