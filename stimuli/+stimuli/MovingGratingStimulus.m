%
%   Moving grating stimulus drawer.
%       This class will set up parameters for drawing moving gratings for a
%       specified time interval. The drawing is composed of three stages:
%         1. Draw a static grating for a specified time interval
%         2. Move the grating (with appropriate parameters) for specified
%            duration
%         3. Move the grating backward (this is optional).
%       If movement is not bidirectional, the forward movement will take on the
%       whole time duration. If it is bidirectional, the forward and bacward
%       movement will take half the drift time each.
%   
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%

classdef MovingGratingStimulus < stimuli.CustomStimulus

    properties (Access = protected)
        orientation     % Orientation of the grating (degrees)
        orientationRad  % Orientation of the gratin in radians
        textureId       % OpenGL grating texture ID
        maskTextureId   % OpenGL gabor mask texture ID
        cyclesPerPixel  % Grating cycles per texture pixels
        p               % Pixels per cycle (1/cyclesPerPixel)
        shiftperframe   % Number of pixels to shift the grating per cycle
        cosBaseLine     % Baseline color for cosine gratings
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
        end



        function setDrawingParameters(obj, par)
            % Set the commong drawing parameters (by calling the super-class
            % constructor) and drawing parameters for gratings.
            % 
            % par has to contain these properties:
            %   screenWidth
            %   screenDist
            %   spatFreq
            %   imageSize
            %   gabor
            %   cyclesPerSecond
            %   stimStyle

            setDrawingParameters@stimuli.CustomStimulus(obj, par);

            %------------------ CALCULATE THE SPATIAL FREQUENCY IN PIXELS--------------
            % if the mouse is looking forward, the angle from the centre of the screen
            % to the edge is:
            theta = atand(obj.par.screenWidth*0.5/obj.par.screenDist);
            totalCycles = obj.par.spatFreq*2*theta;         % total cycles on the screen
            obj.cyclesPerPixel = totalCycles/obj.par.imageSize; % cycles per pixel

            % Alpha blending for a Gabor patch
            if par.gabor == 1
                Screen('BlendFunction', obj.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            end
            
            % Translate requested speed of the grating (in cycles per second) into
            % a shift value in "pixels per frame", for given waitduration: This is
            % the amount of pixels to shift our srcRect "aperture" in horizontal
            % direction at each redraw:
            obj.p = 1 / obj.cyclesPerPixel;  % pixels/cycle    
            obj.shiftperframe = par.cyclesPerSecond * obj.p * obj.waitduration;

            obj.cosBaseLine = obj.white - obj.grey;

            obj.createGratingTexture();
            obj.createGaussianMask();
        end



        function createGratingTexture(obj)
            % Create the actual grating texture.
            % First, a canvas is created which defines the X and Y coordinates.
            % Then, based on par.stimStyle draw a black and white grating
            % (stimTyle == 0) or a sinusoidal grating (stimTyle == 1).
            % 
            % After calling this method, obj.textureId can be used to draw the
            % texture on the screen.

            [x, y] = stimuli.CustomStimulus.createCanvas(obj.texsize, obj.cyclesPerPixel);
            fr = obj.cyclesPerPixel*2*pi; % frequency (per pixel) in radians
            
            orientRad = obj.orientation * 2*pi/360;
            canvas = x * cos(orientRad) + y * sin(orientRad);

            if obj.par.stimStyle == 0
                % Black and White
                grating = obj.white*round(0.5 + 0.5*cos(fr*canvas));
            else
                % sinusoidal
                grating = obj.grey + obj.cosBaseLine * cos(fr*canvas);
            end

            obj.textureId = Screen('MakeTexture', obj.w, grating);
        end


        function createGaussianMask(obj)
            % Create a single gaussian transparency mask and store it to a
            % texture: The mask must have the same size as the visible size of
            % the grating to fully cover it. 
            %
            % We create a  two-layer texture: One unused luminance channel
            % which we just fill with the same color as the background color of
            % the screen 'grey'. The transparency (aka alpha) channel is filled
            % with a gaussian (exp()) aperture mask:

            texsize = obj.texsize;
            mask          = ones(2*texsize+1, 2*texsize+1, 2) * obj.grey;
            [x , y]       = meshgrid(-1*texsize:1*texsize, -1*texsize:1*texsize);
            mask(:, :, 2) = obj.white * (1 - exp(-((x/90).^2)-((y/90).^2)));
            obj.maskTextureId = Screen('MakeTexture', obj.w, mask);
        end


        
        function drawGrating(obj, srcRect, dstRect)
            % Draw the grating into the object's window.
            % If par.gabor == 1, also draw the Gaussian mask created in
            % createGaussianMask

            Screen('DrawTexture', obj.w, obj.textureId, srcRect, dstRect);
            if obj.par.gabor == 1
                Screen('DrawTexture', obj.w, obj.maskTextureId, srcRect, ...
                        dstRect);
            end
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
            obj.drawGrating(srcRect, dstRect);
            startTime = Screen('Flip', obj.w, lastEndTime + (obj.waitframes - 0.5) * obj.ifi);
            endTime = startTime + T;

            offIdx = startOffset;
            currTime = startTime;
            while(currTime < endTime)
                [xOffset, yOffset] = obj.calculateShiftOffset(offIdx);
                srcRect = [xOffset yOffset xOffset + obj.visiblesize ...
                        yOffset + obj.visiblesize];
                obj.drawGrating(srcRect, dstRect);
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
            srcRect = [0 0 obj.visiblesize obj.visiblesize];

            obj.drawGrating(srcRect, dstRect);
            startTime = Screen('Flip', obj.w);
            obj.drawGrating(srcRect, dstRect);
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
            timingData = stimuli.GratingTiming(obj.orientation, ...
                    staticStartTime, forwardStartTime, obj.par.biDirectional, ...
                    backwardStartTime)

        end % draw()
    end
end
