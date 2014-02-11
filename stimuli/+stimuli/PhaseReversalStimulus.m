%
%   Phase reversal grating stimulus drawer.
%       This class will set up parameters for drawing static gratings for a
%       specified time interval. The drawing is composed of two alternating
%       stages:
%         1. Draw a static grating for a specified time interval
%         2. Reverse the phase of the stimulus and draw it again for the same
%            amount of time.
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%

classdef PhaseReversalStimulus < stimuli.GratingStimulus

    properties (Access = protected)
        reversalFreq;
        textureId;
        reversedTextureId;
    end

    methods
        function obj = PhaseReversalStimulus(val)
            % Check the appropriate grating stimulus angle and construct the
            % object.

            if (~isa(val, 'numeric') || numel(val) ~= 1)
                msg = 'An angle must be a numeric value with one element';
                e = MException('stimuli:AngleStimulus:InvalidValue', msg);
                throw(e);
            end

            obj.value = val;        
            obj.orientation = val; % Grating orientation
            obj.orientationRad = obj.orientation * 2*pi / 360;
        end



        function setDrawingParameters(obj, par)
            % Set the commong drawing parameters (by calling the super-class
            % constructor) and drawing parameters for gratings.
            % 
            % par has to contain these properties:
            %   gabor
            %   cyclesPerSecond
            % And also properties necessary in super-class (GratingStimulus).

            setDrawingParameters@stimuli.GratingStimulus(obj, par);
            obj.reversalFreq = par.chronicReversalFreq;

            obj.textureId = obj.createGratingTexture(0);
            obj.reversedTextureId = obj.createGratingTexture(pi);
        end


        function timingData = draw(obj, dstRect)
            % Set up and draw all the phases of the grating movement.
            % The total duration here is the par.timeDrift. We don't want to
            % make it even more confusing by introducing another timing
            % parameter.
            %
            % Parameters:
            %   dstRect - Destination rectangle (in the window).
            %
            % Returns:
            %   timingData - A GratingTiming object.

            srcRect = [0 0 obj.visiblesizeX obj.visiblesizeY];


            flipTime = 1 / obj.reversalFreq;
            numReversals = floor(obj.par.timeDrift * obj.reversalFreq);

            obj.drawGrating(srcRect, dstRect, obj.textureId);
            startTime = Screen('Flip', obj.w);
            lastTime=startTime
            timingData = {};
            timingData{1}= stimuli.PhaseReversalTiming(obj.orientation, ...
                    lastTime, obj.reversalFreq);
            for reversalIdx = 2:numReversals
                if mod(reversalIdx, 2) == 0
                    currentId = obj.reversedTextureId;
                else
                    currentId = obj.textureId;
                end

                obj.drawGrating(srcRect, dstRect, currentId);
                lastTime = Screen('Flip', obj.w, lastTime + flipTime);
                
                timingData{reversalIdx}= stimuli.PhaseReversalTiming(obj.orientation, ...
                    lastTime, obj.reversalFreq);

                if KbCheck
                    return;
                end
                
                
                
            end

            % ----------------------------------------------------------------
            % Export timing data
            %timingData = stimuli.PhaseReversalTiming(obj.orientation, ...
            %        startTime, lastTime, obj.reversalFreq);

        end % draw()
    end
end
