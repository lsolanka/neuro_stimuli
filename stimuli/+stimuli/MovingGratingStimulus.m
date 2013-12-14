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
                grating = grey + inc*cos(fr*canvas);
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




        function startTime = draw(obj, dstRect)
            timeSeq = [];


            timeSeq(length(timeSeq)+1) = toc;

            angle    = obj.orientation;
            angleRad = angle*2*pi/360;      % angle in radians

            vbl           = Screen('Flip', obj.w);
            % We run at most 'timeStatic + timeDrift' seconds if user doesn't
            % abort via keypress.
            vblendtime    = vbl + obj.par.timeStatic + obj.par.timeDrift;
            vblhalftime   = vbl + obj.par.timeStatic + obj.par.timeDrift/2;
            vblStaticTime = vbl + obj.par.timeStatic;

            timerDrift = 0;

            % trick for keeping it smooth when rolling the other way
            count=0;

            j = 0;
            while(vbl < vblendtime)
                % Shift the grating by "shiftperframe" pixels per frame:
                if vbl >= vblStaticTime
                    if timerDrift == 0
                        timeSeq(length(timeSeq)+1) = toc;
                        timerDrift = 1;
                        j=0;
                    end
                    if obj.par.biDirectional == 1                

                        if vbl < vblhalftime
                            if angle ~= 90 & angle ~= 270
                                xOffset = mod(j*obj.shiftperframe/cos(angleRad),obj.p/abs(cos(angleRad)));
                                yOffset = 0;
                            else
                                yOffset = mod(j*obj.shiftperframe,obj.p);
                                xOffset = 0;
                            end
                        else
                            if count == 0                            
                                k = j;
                                j=0;
                                count = 1;
                                timeSeq(length(timeSeq)+1) = toc; %record time                             
                            end
                            if angle ~= 90 & angle ~= 270                    
                                xOffset = mod((k-j)*obj.shiftperframe/cos(angleRad),abs(obj.p/cos(angleRad)));
                                yOffset = 0;
                            else
                                yOffset = mod((k-j)*obj.shiftperframe,obj.p);
                                xOffset = 0;
                            end

                        end
                        j=j+1;
                    else
                        if vbl < vblendtime
                            if angle ~= 90 & angle ~= 270
                                xOffset = mod(j*obj.shiftperframe/cos(angleRad),obj.p/abs(cos(angleRad)));
                                yOffset = 0;
                            else
                                yOffset = mod(j*obj.shiftperframe,obj.p);
                                xOffset = 0;
                            end
                        end
                        j = j+1;
                    end
                end


                if vbl < vblStaticTime
                    srcRect = [0 0 obj.visiblesize obj.visiblesize];
                else               
                    srcRect = [xOffset yOffset xOffset + obj.visiblesize yOffset + obj.visiblesize];
                end

                Screen('DrawTexture', obj.w, obj.textureId, srcRect, dstRect);

                if obj.par.gabor==1
                    % Draw gaussian mask over grating:
                    Screen('DrawTexture', obj.w, obj.maskTextureId, [0 0 obj.visiblesize obj.visiblesize], dstRect);
                end;

                vbl = Screen('Flip', obj.w, vbl + (obj.waitframes - 0.5) * obj.ifi);

                % Abort demo if any key is pressed:
                if KbCheck
                    stop = true;
                    break;
                end
            end


        end % draw()
    end
end
