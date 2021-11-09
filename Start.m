function varargout = Start(varargin)
% Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Start_OpeningFcn, ...
                   'gui_OutputFcn',  @Start_OutputFcn, ...
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

function Start_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);

function varargout = Start_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;
    movegui(gcf,'center');

function pushbutton1_Callback(hObject, eventdata, handles)
    ForwardModeling();

function pushbutton2_Callback(hObject, eventdata, handles)
    InverseModeling();

function pushbutton3_Callback(hObject, eventdata, handles)
    opts.Interpreter = 'tex';
    opts.Default = 'NO';
    quest = 'Are you sure you want to close the program?';
    answ = questdlg(quest,'CLOSE','YES','NO',opts);
    switch answ
        case 'YES'
            close all;
    end