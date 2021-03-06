%
%   Moving grating stimulus drawer.
%       This class will set up parameters for drawing moving gratings for a
%       specified time interval. The drawing is composed of three stages:
%         1. Draw a static grating for a specified time interval
%         2. Move the grating (with appropriate parameters) for specified
%            duration
%         3. Move the grating backward (this is optional).
%       If movement is not bidirectional, the forward movement will take on the
%       whole time duration. If it is bidirectional, the forward and backward
%       movement will take half the drift time each.
%   
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%

classdef MovingGratingStimulus < stimuli.GratingStimulus

    properties (Access = protected)
        textureId       % OpenGL grating texture ID
        shiftperframe   % Number of pixels to shift the grating per cycle
    end

    methods
        function obj = MovingGratingStimulus(val)
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

            obj.textureId = nan;
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
            obj.shiftperframe = par.cyclesPerSecond * obj.p * obj.waitduration;

            obj.textureId = obj.createGratingTexture(0);
        end



        function [xOffset, yOffset] = calculateShiftOffset(obj, offIdx)
            % Calculate the shift offset pointers into the grating. This will
            % be recalculated every screen flip.
            %
            % TODO: This could potentially be avoided by using the
            % kPsychUseTextureMatrixForRotation parameter when drawing the
            % texture (see PsychoToolbox documentation for
            % Screen('DrawTexture').

            orientation = obj.orientation;
            orientationRad = obj.orientationRad;
            if orientation ~= 90 & orientation ~= 270
                xOffset = mod(offIdx*obj.shiftperframe/cos(orientationRad), ...
                        obj.p/abs(cos(orientationRad)));
                yOffset = 0;
            elseif orientation == 90
                yOffset = mod(offIdx*obj.shiftperframe,obj.p);
                xOffset = 0;
            elseif orientation == 270
                yOffset = mod(-offIdx*obj.shiftperframe,obj.p);
                xOffset = 0;
            end
        end


        function [startTime, endTime, endOffset] = ...
            moveGrating(obj, lastEndTime, startOffset, T, direction, srcRect, dstRect)
                % Move the grating for a specified amount of time.
                %
                % Parameters:
                %   lastEndTime - Time of the previous flip. This will be used
                %       for an initial flip.
                %   startOffset - Initial offset of the grating. Use zero when
                %       when calling this method for the first time (i.e. when
                %       drawing the forward moving grating).
                %   T - Duration of the grating (seconds).
                %   direction - 1: forward, -1: backward
                %   srcRect - Source rectangle (in the texture)
                %   dstRect - Destination rectangel (in the window)
                %
                % Returns:
                %   startTime - Time of the first frame of the grating
                %   endTime   - Time of the last frame of the grating
                %   endOffset - Offset index of the grating at the last frame.
                %       use this when drawing the backward movement.
                %   
            obj.drawGrating(srcRect, dstRect, obj.textureId);
            startTime = Screen('Flip', obj.w, lastEndTime + (obj.waitframes - 0.5) * obj.ifi);
            endTime = startTime + T;

            xdim=round(obj.visiblesizeX./(obj.par.nCols));
            ydim=round(obj.visiblesizeY./(obj.par.nRows));
            
            offIdx = startOffset;
            currTime = startTime;
            while(currTime < endTime)
                [xOffset, yOffset] = obj.calculateShiftOffset(offIdx);
                srcRect = [xOffset yOffset xOffset + xdim ...
                        yOffset + ydim];
                obj.drawGrating(srcRect, dstRect, obj.textureId);
                currTime = Screen('Flip', obj.w, currTime + (obj.waitframes - 0.5) * obj.ifi);


                % Abort if any key is pressed:
                if KbCheck
                    break;
                end

                offIdx = offIdx + direction;
            end

            endTime = currTime;
            endOffset = offIdx;
        end



        function timingData = draw(obj, dstRect)
            % Set up and draw all the phases of the grating movement.
            %
            % Parameters:
            %   dstRect - Destination rectangle (in the window).
            %
            % Returns:
            %   timingData - A GratingTiming object.


            % ----------------------------------------------------------------
            % Static grating
            xdim=round(obj.visiblesizeX./(obj.par.nCols));
            ydim=round(obj.visiblesizeY./(obj.par.nRows));
            srcRect = [0 0 xdim ydim];

            obj.drawGrating(srcRect, dstRect, obj.textureId);
            startTime = Screen('Flip', obj.w);
            obj.drawGrating(srcRect, dstRect, obj.textureId);
            staticEndTime = Screen('Flip', obj.w, startTime + obj.par.timeStatic);

            if KbCheck
                return;
            end

            % ----------------------------------------------------------------
            % Forward moving grating; duration depends on the biDirectional parameter
            if obj.par.biDirectional
                forwardTime = obj.par.timeDrift / 2;
            else
                forwardTime = obj.par.timeDrift;
            end
            direction = 1;
            [forwardStartTime, forwardEndTime, offIdx] = ...
                    obj.moveGrating(staticEndTime, 0, forwardTime, ...
                    direction, srcRect, dstRect);

            if KbCheck
                return;
            end

            % ----------------------------------------------------------------
            % Backward moving grating: if biDirectional
            if obj.par.biDirectional == 1                
                direction = -1;
                backwardTime = obj.par.timeDrift / 2;
                backwardStartTime = obj.moveGrating(forwardEndTime, offIdx, ...
                        backwardTime, direction, srcRect, dstRect);
            else
                backwardStartTime = nan;
            end


            if KbCheck
                return;
            end

            
            % ----------------------------------------------------------------
            % Export timing data
            staticStartTime = startTime;
            timingData = stimuli.MovingGratingTiming(obj.orientation, ...
                    staticStartTime, forwardStartTime, obj.par.biDirectional, ...
                    backwardStartTime)

        end % draw()
    end
end
