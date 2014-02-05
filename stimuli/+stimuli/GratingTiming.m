%
%   Timing data of the moving grating stimulus.
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%

classdef (Abstract) GratingTiming < stimuli.TimingData

    properties (SetAccess = private)
        angle % Grating angle
    end

    methods
        function this = GratingTiming(angle)
            this.angle = angle;
        end
    end

end
