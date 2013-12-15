%
%   GratingTiming.m
%
%   Timing data of the moving grating stimulus.
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%

classdef GratingTiming < stimuli.TimingData

    properties (SetAccess = private)
        angle
        staticStartT
        forwardStartT
        backwardStartT
        bidirectional
    end

    methods
        function this = GratingTiming(angle, staticStartT, forwardStartT, ...
                bidirectional, backwardStartT)
            this.angle = angle;
            this.staticStartT = staticStartT;
            this.forwardStartT = forwardStartT;
            this.bidirectional = bidirectional;
            this.backwardStartT = backwardStartT;
        end
    end

end
