%
%   UniformTiming.m
%
%   Timing data for the uniform color stimulus.
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%

classdef UniformTiming < stimuli.TimingData

    properties (SetAccess = private)
        startTime
        endTime
    end

    methods
        function this = UniformTiming(startTime, endTime)
            this.startTime = startTime;
            this.endTime = endTime;
        end
    end
end
