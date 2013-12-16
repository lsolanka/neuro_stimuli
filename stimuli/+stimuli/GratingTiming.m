%
%   Timing data of the moving grating stimulus.
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%

classdef GratingTiming < stimuli.TimingData

    properties (SetAccess = private)
        angle           % Grating angle
        staticStartT    % Time of the first frame of the static grating
        forwardStartT   % Time of the first frame of the forward moving grating
        backwardStartT  % Time of the first frame of the backward moving grating
        % Whether the grating movement is bidirectional. If this value is zero,
        % backwardStartT should be NaN
        bidirectional
    end

    methods
        function this = GratingTiming(angle, staticStartT, forwardStartT, ...
                bidirectional, backwardStartT)
            % Fill in the appropriate values

            this.angle = angle;
            this.staticStartT = staticStartT;
            this.forwardStartT = forwardStartT;
            this.bidirectional = bidirectional;
            this.backwardStartT = backwardStartT;
        end
    end

end
