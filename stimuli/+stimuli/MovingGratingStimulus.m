%
%   MovingGratingStimulus.m
%
%   A stimulus class identifier for angles.
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%

classdef MovingGratingStimulus < stimuli.CustomStimulus

    properties (Access = protected)
        orientation
        orientationRad
        texSize
        textureId
        maskTextureId
        cyclesPerPixel
        p
        shiftperframe

    end

    methods
        function obj = MovingGratingStimulus(val)
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
            % directionat each redraw:
            obj.p = 1 / obj.cyclesPerPixel;  % pixels/cycle    
            obj.shiftperframe = par.cyclesPerSecond * obj.p * obj.waitduration;

            obj.createGratingTexture();
            obj.createGaussianMask();
        end



        function createGratingTexture(obj)
            [x, y] = stimuli.CustomStimulus.createCanvas(obj.texsize, obj.cyclesPerPixel);
            fr = obj.cyclesPerPixel*2*pi; % frequency (per pixel) in radians
            
            % Compute actual cosine grating and rotate it by appropriate angle
            % in radians
            orientRad = obj.orientation * 2*pi/360;
            canvas = x * cos(orientRad) + y * sin(orientRad);

            if obj.par.stimStyle == 0
                % Black and White
                grating = obj.white*round(0.5 + 0.5*cos(fr*canvas));
            else
                % sinusoidal
                %inc=100;
                grating = obj.grey + inc*cos(fr*canvas); %inc does not exist. I tried obj.inc and still does not exist. If you put inc=100, seems reasonable.
            end

            obj.textureId = Screen('MakeTexture', obj.w, grating);
        end


        % Create a single gaussian transparency mask and store it to a texture:
        % The mask must have the same size as the visible size of the grating
        % to fully cover it. 
        %
        % We create a  two-layer texture: One unused luminance channel which we
        % just fill with the same color as the background color of the screen
        % 'grey'. The transparency (aka alpha) channel is filled with a
        % gaussian (exp()) aperture mask:
        function createGaussianMask(obj)
            texsize = obj.texsize;
            mask          = ones(2*texsize+1, 2*texsize+1, 2) * obj.grey;
            [x , y]       = meshgrid(-1*texsize:1*texsize, -1*texsize:1*texsize);
            mask(:, :, 2) = obj.white * (1 - exp(-((x/90).^2)-((y/90).^2)));
            obj.maskTextureId = Screen('MakeTexture', obj.w, mask);
        end


        
        function drawGrating(obj, srcRect, dstRect)
            Screen('DrawTexture', obj.w, obj.textureId, srcRect, dstRect);
            % Draw gaussian mask over grating if necessary
            if obj.par.gabor == 1
                Screen('DrawTexture', obj.w, obj.maskTextureId, srcRect, ...
                        dstRect);
            end
        end


        function [xOffset, yOffset] = calculateShiftOffset(obj, offIdx)
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
