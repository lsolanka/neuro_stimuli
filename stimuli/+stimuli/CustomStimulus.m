%
%   CustomStimulus.m
%
%   Custom stimulus base class
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Lukas Solanka, <lsolanka@gmail.com>
%


%
% Custom stimulus base class
%
classdef (Abstract) CustomStimulus < matlab.mixin.Heterogeneous & handle

    properties (Access = protected)
        value

        par
        w
        texsize
        visiblesize
        white
        black
        grey
        ifi
        waitframes
        waitduration
    end

    methods
        function ret = getValue(obj)
            ret = obj.value;
        end

        function setDrawingParameters(obj, par)
            obj.par = par;
            obj.w = par.w;

            % Define Half-Size of the grating image.
            obj.texsize = obj.par.imageSize / 2;
            % This is the visible size of the grating. It is twice the half-width
            % of the texture plus one pixel to make sure it has an odd number of
            % pixels and is therefore symmetric around the center of the texture:
            obj.visiblesize = 2*obj.texsize+1;

            
            [obj.white, obj.black, obj.grey] = ...
                    stimuli.CustomStimulus.getColors(obj.par.screenNumber);
            %if obj.grey == obj.white
            %    obj.grey = obj.white / 2;
            %end

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
            p = ceil(1/cyclesPerPixel);
            [x,y] = meshgrid(-texsize - p:texsize + 2*p, -texsize - p:texsize + 2*p);
        end

        function [white, black, grey] = getColors(screenNumber)
            white = WhiteIndex(screenNumber);
            black = BlackIndex(screenNumber);
            grey  = round((white+black)/2);        % round it to avoid fraction errors
        end
    end


    methods (Abstract)
        startTime = draw(obj, dstRect)
    end

end


