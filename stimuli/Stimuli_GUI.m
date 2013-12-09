function varargout = Stimuli_GUI(varargin)
% STIMULI_GUI MATLAB code for Stimuli_GUI.fig
%      STIMULI_GUI, by itself, creates a new STIMULI_GUI or raises the existing
%      singleton*.
%
%      H = STIMULI_GUI returns the handle to a new STIMULI_GUI or the handle to
%      the existing singleton*.
%
%      STIMULI_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIMULI_GUI.M with the given input arguments.
%
%      STIMULI_GUI('Property','Value',...) creates a new STIMULI_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Stimuli_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Stimuli_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Stimuli_GUI

% Last Modified by GUIDE v2.5 08-Jul-2013 13:59:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Stimuli_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Stimuli_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Stimuli_GUI is made visible.
function Stimuli_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Stimuli_GUI (see VARARGIN)

% Choose default command line output for Stimuli_GUI
handles.output = hObject;


%------------------------TOM-CODE HERE-------------------------

% moving grating section
set(handles.driftTime,'String','2');
set(handles.staticTime,'String','0.5');
set(handles.spatFreq,'String','0.03');
set(handles.tempFreq,'String','1');

% push buttons

% retinotopy

% Parameters section
set(handles.distScreen,'String','30');
set(handles.widthScreen,'String','34');
set(handles.numberScreen,'String','1');
set(handles.sizeImage,'String','800');
set(handles.stdevGauss,'String','40');
set(handles.trimGauss,'String','0.05');
set(handles.introTime,'String','0.5');

% save path
set(handles.savePath,'String','./');

% for the chronic stim
set(handles.chronicOrient,'String','0');




%---------------------END TOM-CODE------------------------------ 

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Stimuli_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Stimuli_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function driftTime_Callback(hObject, eventdata, handles)
% hObject    handle to driftTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of driftTime as text
%        str2double(get(hObject,'String')) returns contents of driftTime as a double
timeDrift = str2double(get(hObject,'string'));
if isnan(timeDrift)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
	return
end


% --- Executes during object creation, after setting all properties.
function driftTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to driftTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function staticTime_Callback(hObject, eventdata, handles)
% hObject    handle to staticTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of staticTime as text
%        str2double(get(hObject,'String')) returns contents of staticTime as a double
timeStatic = str2double(get(hObject,'string'));
if isnan(timeStatic)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
	return
end


% --- Executes during object creation, after setting all properties.
function staticTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to staticTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spatFreq_Callback(hObject, eventdata, handles)
% hObject    handle to spatFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spatFreq as text
%        str2double(get(hObject,'String')) returns contents of spatFreq as a double
spatFreq = str2double(get(hObject,'string'));
if isnan(spatFreq)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
	return
end



% --- Executes during object creation, after setting all properties.
function spatFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spatFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tempFreq_Callback(hObject, eventdata, handles)
% hObject    handle to tempFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tempFreq as text
%        str2double(get(hObject,'String')) returns contents of tempFreq as a double
cyclesPerSecond = str2double(get(hObject,'string'));
if isnan(cyclesPerSecond)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
	return
end


% --- Executes during object creation, after setting all properties.
function tempFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tempFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- the function get all parameters set in the GUI
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

    switch get(get(handles.movingModePanel,'SelectedObject'),'Tag')
        case 'biDirectional',  par.biDirectional = 1;
        otherwise, par.biDirectional = 0;
    end

    switch get(get(handles.orientSeqPanel,'SelectedObject'),'Tag')
        case 'randomSeq',  par.randomOrder = 1;
        otherwise, par.randomOrder = 0;
    end


    % and those from the parameters box.....
    par.screenDist = str2double(get(handles.distScreen,'String'));
    par.screenWidth = str2double(get(handles.widthScreen,'String'));
    par.screenNumber = str2double(get(handles.numberScreen,'String'));
    par.imageSize = str2double(get(handles.sizeImage,'String'));
    par.gaussStDev = str2double(get(handles.stdevGauss,'String'));
    par.gaussTrim = str2double(get(handles.trimGauss,'String'));
    par.timeIntro = str2double(get(handles.introTime,'String'));

    par.chronicOrient=str2double(get(handles.chronicOrient,'String'));

    
    % and the save path
    par.currentPath = get(handles.savePath,'String');



% --- Executes on button press in runGratings.
function runGratings_Callback(hObject, eventdata, handles)
% hObject    handle to runGratings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % initialise the variables
    par=getParam(handles);

    par.nCols = 1
    par.nRows = 1
    par.chronicOrient=0;
    showStimuli(par)



% --- Executes on button press in runRetinotopy.
function runRetinotopy_Callback(hObject, eventdata, handles)
    % hObject    handle to runRetinotopy (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    par = getParam(handles);
    par.chronicOrient=0;
    ret4x3State = get(handles.retinotopy4x3, 'Value')
    if ret4x3State == 1
        par.nCols = 4
        par.nRows = 3
    else
        par.nCols = 6
        par.nRows = 4
    end 

    showStimuli(par)


% --- Executes on button press in retinotopy4x3.
function retinotopy4x3_Callback(hObject, eventdata, handles)
% hObject    handle to retinotopy4x3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of retinotopy4x3


% --- Executes on button press in retinotopyOther.
function retinotopy6x4_Callback(hObject, eventdata, handles)
% hObject    handle to retinotopyOther (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of retinotopyOther


% --- Executes when selected object is changed in numOrientationPanel.
function numOrientationPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in numOrientationPanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'numOrient8'
        numOrient=8;% Code for when radiobutton1 is selected.
    case 'numOrient16'
        numOrient=16;
        % Code for when radiobutton2 is selected.
end


% --- Executes on button press in gaborOn.
function gaborOn_Callback(hObject, eventdata, handles)
% hObject    handle to gaborOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gaborOn
if (get(hObject,'Value') == get(hObject,'Max'))
    gabor=1;
	% Radio button is selected-take appropriate action
end


% --- Executes on button press in gaborOff.
function gaborOff_Callback(hObject, eventdata, handles)
% hObject    handle to gaborOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gaborOff
if (get(hObject,'Value') == get(hObject,'Max'))
	% Radio button is selected-take appropriate action
    gabor=0;
end


% --- Executes when selected object is changed in orientSeqPanel.
function orientSeqPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in orientSeqPanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'randomSeq'
        randomOrder=1;% Code for when radiobutton1 is selected.
    case 'fixedSeq'
        randomOrder=0;
        % Code for when radiobutton2 is selected.
end

% --- Executes when selected object is changed in movingModePanel.
function movingModePanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in movingModePanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'uniDirectional'
        biDirectional=0;% Code for when radiobutton1 is selected.
    case 'biDirectional'
        biDirectional=1;
        % Code for when radiobutton2 is selected.
end

% --- Executes when selected object is changed in stimStylePanel.
function stimStylePanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in stimStylePanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'stimBW'
        stimStyle=0;% Code for when radiobutton1 is selected.
    case 'stimSin'
        stimStyle=1;
        % Code for when radiobutton2 is selected.
end


% --- Executes when selected object is changed in gaborPanel.
function gaborPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in gaborPanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'gaborOn'
        gabor=1;% Code for when radiobutton1 is selected.
    case 'gaborOff'
        gabor=0;
        % Code for when radiobutton2 is selected.
end

function distScreen_Callback(hObject, eventdata, handles)
% hObject    handle to distScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of distScreen as text
%        str2double(get(hObject,'String')) returns contents of distScreen as a double
screenDist = str2double(get(hObject,'string'));
if isnan(user_entry)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
	return
end



% --- Executes during object creation, after setting all properties.
function distScreen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to distScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function widthScreen_Callback(hObject, eventdata, handles)
% hObject    handle to widthScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of widthScreen as text
%        str2double(get(hObject,'String')) returns contents of widthScreen as a double
screenWidth = str2double(get(hObject,'string'));
if isnan(user_entry)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
	return
end


% --- Executes during object creation, after setting all properties.
function widthScreen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to widthScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numberScreen_Callback(hObject, eventdata, handles)
% hObject    handle to numberScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numberScreen as text
%        str2double(get(hObject,'String')) returns contents of numberScreen as a double
screenNumber = str2double(get(hObject,'string'));
if isnan(user_entry)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
	return
end


% --- Executes during object creation, after setting all properties.
function numberScreen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numberScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sizeImage_Callback(hObject, eventdata, handles)
% hObject    handle to sizeImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sizeImage as text
%        str2double(get(hObject,'String')) returns contents of sizeImage as a double
imageSize = str2double(get(hObject,'string'));
if isnan(user_entry)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
	return
end


% --- Executes during object creation, after setting all properties.
function sizeImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sizeImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stdevGauss_Callback(hObject, eventdata, handles)
% hObject    handle to stdevGauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stdevGauss as text
%        str2double(get(hObject,'String')) returns contents of stdevGauss as a double
gaussStDev = str2double(get(hObject,'string'));
if isnan(user_entry)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
	return
end


% --- Executes during object creation, after setting all properties.
function stdevGauss_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stdevGauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trimGauss_Callback(hObject, eventdata, handles)
% hObject    handle to trimGauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trimGauss as text
%        str2double(get(hObject,'String')) returns contents of trimGauss as a double
gaussTrim = str2double(get(hObject,'string'));
if isnan(user_entry)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
	return
end


% --- Executes during object creation, after setting all properties.
function trimGauss_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trimGauss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in retinotopyOptionsPanel.
function retinotopyOptionsPanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in retinotopyOptionsPanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)



function introTime_Callback(hObject, eventdata, handles)
% hObject    handle to introTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of introTime as text
%        str2double(get(hObject,'String')) returns contents of introTime as a double
timeIntro = str2double(get(hObject,'string'));
if isnan(user_entry)
  errordlg('You must enter a numeric value','Bad Input','modal')
  uicontrol(hObject)
	return
end


% --- Executes during object creation, after setting all properties.
function introTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to introTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function savePath_Callback(hObject, eventdata, handles)
% hObject    handle to savePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of savePath as text
%        str2double(get(hObject,'String')) returns contents of savePath as a double


% --- Executes during object creation, after setting all properties.
function savePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to savePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in runChronic.
function runChronic_Callback(hObject, eventdata, handles)
% hObject    handle to runChronic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


par=getParam(handles);

par.numOrient=1;
par.timeDrift=900;  
par.nCols=1;
par.nRows=1;


showStimuli(par);
%showChronicStim(cyclesPerSecond, spatFreq, gabor, ...
%    imageSize, stimStyle, timeIntro, timeStatic, timeDrift, biDirectional,...
%    screenNumber, screenDist, gaussStDev, gaussTrim, screenWidth,...
%    currentPath, orient)



function chronicOrient_Callback(hObject, eventdata, handles)
% hObject    handle to chronicOrient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chronicOrient as text
%        str2double(get(hObject,'String')) returns contents of chronicOrient as a double


% --- Executes during object creation, after setting all properties.
function chronicOrient_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chronicOrient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
