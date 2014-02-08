%
%   Timing data of the phase reversal grating stimulus.
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%

classdef PhaseReversalTiming < stimuli.GratingTiming

    properties (SetAccess = private)
        startT
        %lastT
        reversalFreq
    end

    methods
        %function this = PhaseReversalTiming(angle, startT, lastT, reversalFreq)
        function this = PhaseReversalTiming(angle, startT, reversalFreq)
            this@stimuli.GratingTiming(angle);

            this.startT = startT;
            %this.lastT  = lastT;
            this.reversalFreq = reversalFreq;
        end
    end

end
