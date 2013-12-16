%
%   Timing data for the UniformStimulus.
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%
classdef UniformTiming < stimuli.TimingData

    properties (SetAccess = private)
        startTime   % Start time of the first frame
        endTime     % End time (last frame)
    end

    methods
        function this = UniformTiming(startTime, endTime)
            % Simply fill in the data for the uniform stimulus

            this.startTime = startTime;
            this.endTime = endTime;
        end
    end
end
