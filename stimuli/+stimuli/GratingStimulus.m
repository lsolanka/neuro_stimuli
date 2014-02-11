%
%   Grating stimulus abstract base class.
%       This class defines methods for drawing grating stimuli. Do not use this
%       class for drawing - subclass it, e.g. as is done in
%       MovingGratingStimulus.
%   
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%

classdef GratingStimulus < stimuli.CustomStimulus

    properties (Access = protected)
        orientation     % Orientation of the grating (degrees)
        orientationRad  % Orientation of the gratin in radians
        maskTextureId   % OpenGL gabor mask texture ID
        cyclesPerPixel  % Grating cycles per texture pixels
        p               % Pixels per cycle (1/cyclesPerPixel)
        cosBaseLine     % Baseline color for cosine gratings
    end

    methods

        function setDrawingParameters(obj, par)
            % Set the commong drawing parameters (by calling the super-class
            % constructor) and drawing parameters for gratings.
            % 
            % par has to contain these properties:
            %   screenWidth
            %   screenDist
            %   spatFreq
            %   imageSizeX
            %   imageSizeY
            %   gabor
            %   stimStyle

            setDrawingParameters@stimuli.CustomStimulus(obj, par);

            %------------------ CALCULATE THE SPATIAL FREQUENCY IN PIXELS--------------
            % if the mouse is looking forward, the angle from the centre of the screen
            % to the edge is:
            theta = atand(obj.par.screenWidth*0.5/obj.par.screenDist);
            totalCycles = obj.par.spatFreq*2*theta;         % total cycles on the screen width
            obj.cyclesPerPixel = totalCycles/obj.par.imageSizeX; % cycles per pixel

            % Alpha blending for a Gabor patch
            if par.gabor == 1
                Screen('BlendFunction', obj.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            end
            
            % Translate requested speed of the grating (in cycles per second) into
            % a shift value in "pixels per frame", for given waitduration: This is
            % the amount of pixels to shift our srcRect "aperture" in horizontal
            % direction at each redraw:
            obj.p = 1 / obj.cyclesPerPixel;  % pixels/cycle    

            obj.cosBaseLine = obj.white - obj.grey;

            obj.createGaussianMask();
        end



        function textureId = createGratingTexture(obj, phase)
            % Create the actual grating texture.
            % First, a canvas is created which defines the X and Y coordinates.
            % Then, based on par.stimStyle draw a black and white grating
            % (stimTyle == 0) or a sinusoidal grating (stimStyle == 1).
            %
            % Parameters:
            %   phase - phase of the grating, in radians.
            % 
            % This method returns the texture ID

            [x, y] = stimuli.CustomStimulus.createCanvas(obj.texsize, obj.cyclesPerPixel);
            fr = obj.cyclesPerPixel*2*pi; % frequency (per pixel) in radians
            
            orientRad = obj.orientation * 2*pi/360;
            canvas = x * cos(orientRad) + y * sin(orientRad);

            if obj.par.stimStyle == 0
                % Black and White
                grating = obj.white*round(0.5 + 0.5*cos(fr*canvas + phase));
            else
                % sinusoidal
                grating = obj.grey + obj.cosBaseLine * cos(fr*canvas + phase);
            end

            textureId = Screen('MakeTexture', obj.w, grating);
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


        
        function drawGrating(obj, srcRect, dstRect, textureId)
            % Draw the grating with a specified texture identifier into the
            % object's window.  If par.gabor == 1, also draw the Gaussian mask
            % created in createGaussianMask

            Screen('DrawTexture', obj.w, textureId, srcRect, dstRect);
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

    end % methods
end
