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
        reversalFreq; % This will be double of the number in the GUI - request
                      % from the Rochefort lab. One cycle is both phases.
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
            obj.reversalFreq = par.chronicReversalFreq * 2.;

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
            xdim = round(obj.visiblesizeX./(obj.par.nCols));
            ydim = round(obj.visiblesizeY./(obj.par.nRows));
            srcRect = [0 0 xdim ydim];
            timingData = {};

            % ----------------------------------------------------------------
            % Static grating
            obj.drawGrating(srcRect, dstRect, obj.textureId);
            startTime = Screen('Flip', obj.w);
            

            % ----------------------------------------------------------------
            % Phase reversal
            flipTime = 1 / obj.reversalFreq;
            numReversals = floor(obj.par.timeDrift * obj.reversalFreq);

            obj.drawGrating(srcRect, dstRect, obj.reversedTextureId);
            phaseRevTime = Screen('Flip', obj.w, startTime + obj.par.timeStatic);
            lastTime=phaseRevTime;
            

            for reversalIdx = 2:numReversals
                if mod(reversalIdx, 2) == 0
                    currentId = obj.textureId;
                else
                    currentId = obj.reversedTextureId;
                end

                obj.drawGrating(srcRect, dstRect, currentId);
                lastTime = Screen('Flip', obj.w, lastTime + flipTime);

                if KbCheck
                    return;
                end
            end

            % One more flip with the last currentId; do not save
            obj.drawGrating(srcRect, dstRect, currentId);
            Screen('Flip', obj.w, lastTime + flipTime);
            % Export timing data
            staticStartTime = startTime;
            forwardStartTime=phaseRevTime;
            backwardStartTime = nan;
            timingData = stimuli.MovingGratingTiming(obj.orientation, ...
                    staticStartTime, forwardStartTime, obj.par.biDirectional, ...
                    backwardStartTime)
        end % draw()

    end
end
