%
%   Custom stimulus abstract base class.
%       Contains methods and attributes that will be used to set up the
%       appropriate drawing parameters for any kind of specific drawing
%       example.
%       
%       Inherit from this class in order to build your own stimulus.
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%                Paolo Puggioni <p.paolo321@gmail.com>
%       This code has been adopted from Tom Mayo (University of Edinburgh),
%       however it has been fully rewritten.
%


classdef (Abstract) CustomStimulus < matlab.mixin.Heterogeneous & handle

    properties (Access = protected)
        % Specific value of the stimulus, this will be filled by a subclass.
        % This member attribute might be deprecated in the future.
        value

        par             % Parameter structure
        w               % PsychoToolbox window pointer, use this for drawing
        texsize         % Half-Size of the grating image.

        % This is the visible size of the grating. It is twice the half-width
        % of the texture plus one pixel to make sure it has an odd number of
        % pixels and is therefore symmetric around the center of the texture:
        visiblesizeX
        visiblesizeY
        white           % Color value for white
        black           % Color value for black
        grey            % Color value for grey
        ifi             % Inter-frame interval (seconds)
        waitframes      % Number of frames to  wait between screen redraws (flips)
        waitduration    % Duration (s) between 2 consecutive redraws (flips)
    end

    methods
        function ret = getValue(obj)
            % Get value of the object (might be deprecated in the future).

            ret = obj.value;
        end


        function setDrawingParameters(obj, par)
            % Extract the appropriate drawing parameters (see definition of
            % member attributes for their meaning.

            obj.par = par;
            obj.w = par.w;

           
            obj.texsize = obj.par.imageSizeX / 2;
            
            obj.visiblesizeX = obj.par.imageSizeX+1;
            obj.visiblesizeY = obj.par.imageSizeY+1;
            
            [obj.white, obj.black, obj.grey] = ...
                    stimuli.CustomStimulus.getColors(obj.par.screenNumber);

            % Query maximum useable priorityLevel on this system:
            priorityLevel = MaxPriority(obj.w);
            Priority(priorityLevel);
            

            % Query duration of one monitor refresh interval:
            % Translate that into the amount of seconds to wait between screen
            % redraws/updates:
            obj.ifi          = Screen('GetFlipInterval', obj.w);
            obj.waitframes   = 1;
            obj.waitduration = obj.waitframes * obj.ifi;
            
        end

    end

    methods(Static)
        function [x, y] = createCanvas(texsize, cyclesPerPixel)
            % Create the X and Y positions for the texture. These can be used
            % in sub-classes to draw a texture.
            
            p = ceil(1/cyclesPerPixel);
            [x,y] = meshgrid(-texsize - p:texsize + 2*p, -texsize - p:texsize + 2*p);

        end

        function [white, black, grey] = getColors(screenNumber)
            % Determine appropriate colors for drawing. This has to do with
            % color calibration of the monitor for the particular screen
            % number.

            white = WhiteIndex(screenNumber);
            black = BlackIndex(screenNumber);
            grey  = round((white+black)/2);   % round it to avoid fraction errors
        end
    end


    methods (Abstract)
        % Draw the texture for duration specified in parameters passed to the
        % object.
        startTime = draw(obj, dstRect)
    end

end


