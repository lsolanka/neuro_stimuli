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
    end

    methods
        function ret = getValue(obj)
            ret = obj.value;
        end

    end

    methods(Static)
        function [x, y] = createCanvas(texsize, cyclesPerPixel)
            p = ceil(1/cyclesPerPixel);
            [x,y] = meshgrid(-texsize - p:texsize + 2*p, -texsize - p:texsize + 2*p);
        end
    end


    methods (Abstract)
        startTime = draw(obj, dstRect)
    end

end


