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
classdef (Abstract=true) CustomStimulus < matlab.mixin.Heterogeneous

    properties (Access = protected)
        value
    end

    methods
        function ret = getValue(obj)
            ret = obj.value;
        end
    end

end


