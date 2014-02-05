%
%   Timing data of the moving grating stimulus.
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%

classdef MovingGratingTiming < stimuli.GratingTiming

    properties (SetAccess = private)
        staticStartT    % Time of the first frame of the static grating
        forwardStartT   % Time of the first frame of the forward moving grating
        backwardStartT  % Time of the first frame of the backward moving grating
        % Whether the grating movement is bidirectional. If this value is zero,
        % backwardStartT should be NaN
        bidirectional
    end

    methods
        function this = MovingGratingTiming(angle, staticStartT, forwardStartT, ...
                bidirectional, backwardStartT)
            this@stimuli.GratingTiming(angle);

            this.staticStartT = staticStartT;
            this.forwardStartT = forwardStartT;
            this.bidirectional = bidirectional;
            this.backwardStartT = backwardStartT;
        end
    end

end
