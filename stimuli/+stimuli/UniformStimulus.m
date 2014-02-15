%
%   A uniform stimulus definition.
%       Draws a blank screen with a specified color (black or grey), for a
%       specified time duration.
%       
%       This class uses PsychoToolbox for drawing.
%
%       See also UniformTiming
%
%   Copyright (C) 2013
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%
classdef UniformStimulus < stimuli.CustomStimulus

    properties (Access = protected)
        textureId   % Uniform texture identifier
        duration    % Duration of the stimulus (seconds)
    end

    methods
        function obj = UniformStimulus(val)
            % Fill in CustomStimulus.value. Don't check whether the value is
            % valid (i.e. 'b' or 'g') This has to be done by the user.

            if (~isa(val, 'char') || numel(val) ~= 1)
                msg = 'A color definition for a uniform stimulus must be a char';
                id = 'stimuli:UniformStimulus:InvalidValue';
                throw(MException(id, msg));
            end
            
            obj.value = val;
        end


        function setDrawingParameters(obj, par)
            % Parse the parameter structure (par) and extract the duration of
            % the stimulus.

            setDrawingParameters@stimuli.CustomStimulus(obj, par);
            switch obj.value
                case 'b'
                    obj.duration = par.customBlackTime;
                case 'g'
                    obj.duration = par.customGreyTime;

            end
            obj.createTexture();
        end


        function createTexture(obj)
            % Create the texture object and store the ID of the texture. In
            % this case, the texture is just 1 pixel, since everything will be
            % repeated accordingly when calling DrawTexture.

            if (obj.value == 'b')
                texture = obj.black;
            else
                texture = obj.grey;
            end
            obj.textureId = Screen('MakeTexture', obj.w, texture);
        end


        function timing = draw(obj, dstRect)
            % Draw the texture. use two flips: one to display the texture
            % initially, the other one to keep the texture on for a specified
            % amount of time.
            %
            % Return the timing information: UniformTiming

            srcRect = [0 0 obj.visiblesizeX obj.visiblesizeY];
            Screen('DrawTexture', obj.w, obj.textureId, srcRect, dstRect);
            if obj.par.splitScreen
                copyDstRect = dstRect;
                copyDstRect(1) = copyDstRect(1) + obj.par.imageSizeX;
                copyDstRect(3) = copyDstRect(3) + obj.par.imageSizeX;
                Screen('DrawTexture', obj.w, obj.textureId, srcRect, copyDstRect);
            end
            startTime   = Screen('Flip', obj.w, 0)
            endTime     = startTime + obj.duration;
            % Redraw to avoid any glitches
            Screen('DrawTexture', obj.w, obj.textureId, srcRect, dstRect);
            if obj.par.splitScreen
                Screen('DrawTexture', obj.w, obj.textureId, srcRect, copyDstRect);
            end
            flipEndTime = Screen('Flip', obj.w, endTime)

            timing = stimuli.UniformTiming(startTime, flipEndTime);
        end
    end
end
