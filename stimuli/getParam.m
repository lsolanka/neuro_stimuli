%
%   Parse GUI parameters.
%
%   Copyright (C) 2013, NeuroAgile.
%       Authors: Paolo Puggioni <p.paolo321@gmail.com>
%

% Get all parameters set in the GUI
function par=getParam(handles)

    par.spatFreq = str2double(get(handles.spatFreq,'String'));
    par.cyclesPerSecond = str2double(get(handles.tempFreq,'String'));
    par.timeStatic = str2double(get(handles.staticTime,'String'));
    par.timeDrift = str2double(get(handles.driftTime,'String'));
    % 
    % % the button ones too....
    switch get(get(handles.numOrientationPanel,'SelectedObject'),'Tag')
        case 'numOrient8',  par.numOrient = 8;
        otherwise, par.numOrient = 16;
    end

    switch get(get(handles.gaborPanel,'SelectedObject'),'Tag')
        case 'gaborOn',  par.gabor = 1;
        otherwise, par.gabor = 0;
    end

    switch get(get(handles.stimStylePanel,'SelectedObject'),'Tag')
        case 'stimBW',  par.stimStyle = 0;
        otherwise, par.stimStyle = 1;
    end

    par.biDirectional = 0;
    par.movingReversal = 0;
    switch get(get(handles.movingModePanel,'SelectedObject'),'Tag')
        case 'biDirectional',  par.biDirectional = 1;
        case 'phaseReversal',  par.bidirectional = 0; par.movingReversal = 1;
        otherwise, par.biDirectional = 0;
    end

    switch get(get(handles.orientSeqPanel,'SelectedObject'),'Tag')
        case 'randomSeq',  par.randomOrder = 1;
        otherwise, par.randomOrder = 0;
    end


    % and those from the parameters box.....
    par.screenDist     = str2double(get(handles.distScreen,'String'));
    par.screenWidth    = str2double(get(handles.widthScreen,'String'));
    par.screenNumber   = str2double(get(handles.numberScreen,'String'));
    par.gaussStDev     = str2double(get(handles.stdevGauss,'String'));
    par.gaussTrim      = str2double(get(handles.trimGauss,'String'));
    par.timeIntro      = str2double(get(handles.introTime,'String'));
    par.waitForTrigger = get(handles.triggerWaitCheckBox, 'Value');
    par.splitScreen    = get(handles.splitScreenCheckBox, 'Value');

    % those for the chronic stim
    par.chronicOrient       = str2double(get(handles.chronicOrient,'String'));
    par.chronicTime         = str2double(get(handles.chronicTime,'String'));
    par.chronicReversal     = get(handles.phaseReversalCheckBox, 'Value');
    par.chronicReversalFreq = str2double(get(handles.reversalFreqEdit, 'String'));
    
    % those for Custom stim
    par.customSeq       = get(handles.customSeq, 'String');
    par.customGreyTime  = str2double(get(handles.customGreyTime, 'String'));
    par.customBlackTime = str2double(get(handles.customBlackTime, 'String'));
    
    % and the save path
    par.currentPath = get(handles.savePath,'String');
    par.fileSuffix =get(handles.fileSuffix,'String');

end


