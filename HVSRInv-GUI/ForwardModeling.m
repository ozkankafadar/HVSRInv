function varargout = ForwardModeling(varargin)
% SYNTHETICAPP MATLAB code for SyntheticApp.fig
%      SYNTHETICAPP, by itself, creates a new SYNTHETICAPP or raises the existing
%      singleton*.
%
%      H = SYNTHETICAPP returns the handle to a new SYNTHETICAPP or the handle to
%      the existing singleton*.
%
%      SYNTHETICAPP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SYNTHETICAPP.M with the given input arguments.
%
%      SYNTHETICAPP('Property','Value',...) creates a new SYNTHETICAPP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SyntheticApp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SyntheticApp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SyntheticApp

% Last Modified by GUIDE v2.5 20-Mar-2021 20:57:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ForwardModeling_OpeningFcn, ...
                   'gui_OutputFcn',  @ForwardModeling_OutputFcn, ...
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


% --- Executes just before SyntheticApp is made visible.
function ForwardModeling_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SyntheticApp (see VARARGIN)

% Choose default command line output for SyntheticApp
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SyntheticApp wait for user response (see UIRESUME)
% uiwait(handles.figure1);
%set(handles.uitable1,'ColumnName', {'<html>Thickness(m)<sup> </sup></html>','<html>S-Wave Velocity(ms<sup>-1</sup>)</html>','<html>Density(gcm<sup>-3</sup>)</html>)','<html>Damping Coefficient<sup> </sup></html>'});
movegui(gcf,'center');

% --- Outputs from this function are returned to the command line.
function varargout = ForwardModeling_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%movegui(gcf,'center');


% --- Executes on button press in computeHVSRBtn.
function computeHVSRBtn_Callback(hObject, eventdata, handles)
% hObject    handle to computeHVSRBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global uitableData;
global freqs;
global HVSR;
global modelx;
global modely;
global Vs;

Vs=[];
modelx=[];
modely=[];
HVSR=[];
freqs=[];

S = get(handles.edit1, 'String');
if ~isempty(S)
    if ~all(ismember(S, '1234567890'))
        set(handles.edit1,'String','');  
    else
        if str2double(S)<2
            msgbox('Number of layers must be greater than 1');
            return;
        else
            layerNum=str2double(S);
            set(handles.uitable1,'Data',cell(layerNum,4))
        end;
    end;
else
    msgbox('Please, enter the number of layers');
    return;
end;

if layerNum>1
    %Check number of sample textbox    
    S = get(handles.edit2, 'String');
    if ~isempty(S)
        if ~all(ismember(S, '1234567890'))
            set(handles.edit2,'String','');
            msgbox('Number of samples must be integer');
            return;
        else
            sampleNum=str2double(S);
            if sampleNum<=0
               msgbox('Number of samples must be integer that is greater than 0');
               return;
            end;
        end;
    else
        msgbox('Please, enter the number of samples');
        return;
    end;
end;

cb_value = get(handles.checkbox1, 'Value');
if cb_value==1
    S=get(handles.edit5,'String');
    if ~isempty(S)
        if ~all(ismember(S, '.1234567890'))
            msgbox('Noise percentage must be numeric');
            return;
        else            
        end;
    else
        msgbox('Please, enter the noise percentage');
        return;
    end;    
end;

for i=1:layerNum
    S=uitableData(i,:);        
    if (isempty(S(1))) || (isempty(S(2))) || (isempty(S(3))) || (isempty(S(4)))
       msgbox('Please, enter all parameters');
       return;
    end;
end;

for i=1:layerNum
    S=uitableData(i,:);        
    H(i)=S(1);
    Vs(i)=S(2);
    Den(i)=S(3);
    Damp(i)=S(4);
end;

H=H';Vs=Vs';Den=Den';Damp=Damp';

depthmax=sum(uitableData(:,1))+sum(uitableData(:,1))*10./100;

[modelx,modely]=SetArray(H,Vs,depthmax);

freqs=linspace(0,50,sampleNum);
HVSR=CalcHVSR(Vs,H,Den,Damp,freqs);

if cb_value==1
    S=get(handles.edit5,'String');
    Noise=randn(length(freqs),1)*max(HVSR)*str2double(S)/100;
    HVSR=HVSR+Noise;
end;

cla(handles.axes2);

axes(handles.axes2);
semilogx(freqs,HVSR,'linewidth',1.5,'color','k'),hold on;
xlabel('Frequency (Hz)');
ylabel('Amplitude');
set(gca,'FontSize',11)
xlim([min(freqs) max(freqs)]);
grid on



axes(handles.axes1);
plot(modelx,modely,'linewidth',4,'color','k');
xlabel('Velocity (ms^{-1})');
ylabel('Depth (m)');
xlim([0 max(modelx)+(max(modelx)-min(modelx))*5/100]);
%ylim([0 modely(end)]);
ylim([0 modely(end)]);
set(gca, 'YDir','reverse')
set(gca,'FontSize',11)
grid on

set(handles.uitable1,'Data',uitableData);

set(handles.saveHVSRBtn,'enable','on');
set(handles.saveGrpBtn,'enable','on');

% --- Executes on button press in saveHVSRBtn.
function saveHVSRBtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveHVSRBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global freqs;
global HVSR;

% freq=freqs';
[file,path] = uiputfile('*.txt');
if isequal(file,0) || isequal(path,0)

else
    file=fullfile(path,file);
    f=fopen(file,'w+');
    fprintf(f,'%1.7f %1.7f\n',[freqs;HVSR']);   
    fclose(f);
end;


% --- Executes on button press in saveGrpBtn.
function saveGrpBtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveGrpBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global freqs;
global HVSR;
global modelx;
global modely;
global Vs;

[file,path] = uiputfile('*.png');
if isequal(file,0) || isequal(path,0)

else
    file=fullfile(path,file);
    
    fig=figure(1);
    semilogx(freqs,HVSR,'linewidth',1.5,'color','k'),hold on;
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    xlim([min(freqs) max(freqs)]);
    set(gca,'FontSize',14)
    grid on

    saveas(fig,file);
    close(fig);    
end;

[file,path] = uiputfile('*.png');
if isequal(file,0) || isequal(path,0)

else
    file=fullfile(path,file);
    
    fig2=figure(2);
    plot(modelx,modely,'linewidth',4,'color','k');
    xlabel('Velocity (m/s)');
    ylabel('Depth (m)');
    xlim([min(Vs(:))-(max(Vs(:))-min(Vs(:)))*5/100 max(Vs(:))+(max(Vs(:))-min(Vs(:)))*5/100]);
    ylim([0 modely(end)]);
    set(gca, 'YDir','reverse')
    set(gca,'FontSize',14)
    grid on

    saveas(fig2,file);
    close(fig2);    
end;

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
global uitableData;

S = get(handles.edit1, 'String');
if ~isempty(S)
    if ~all(ismember(S, '.1234567890'))
        msgbox('Number of layers must be numeric');
        set(handles.edit1,'String','');  
    else
        if str2double(S)<2
            msgbox('Number of layers must be greater than 1');
            set(handles.edit1,'String','');
        else
            set(handles.uitable1,'Data',cell(str2double(S),4))
            uitableData=repmat(0,str2double(S),4);
            set(handles.uitable1,'Data',uitableData);
            set(handles.uitable1,'enable','on');
            set(handles.savePrmBtn,'enable','on');
            set(handles.computeHVSRBtn,'enable','on');
        end;
    end;
else
   msgbox('Please, enter the number of layers');
   return;
end;

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadPrmBtn.
function loadPrmBtn_Callback(hObject, eventdata, handles)
% hObject    handle to loadPrmBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global uitableData;

[file,path] = uigetfile('*.txt');
if isequal(file,0) || isequal(path,0)
else
   file=fullfile(path,file);
   f=fopen(file);
   data1 = textscan(f,'%s%d',1,'Delimiter',' ');
   data2 = textscan(f,'%s%d',1,'Delimiter',' ');
   uitableData=[];
   for i=1:cell2mat(data1(2))
       data = textscan(f,'%s%d',1,'Delimiter',' ');
       data = textscan(f,'%d%d%f%f',1,'Delimiter',' ');
       uitableData(i,1)=cell2mat(data(1));
       uitableData(i,2)=cell2mat(data(2));
       uitableData(i,3)=cell2mat(data(3));
       uitableData(i,4)=cell2mat(data(4));
   end;   
   fclose(f);
   set(handles.edit1,'String',cell2mat(data1(2)));
   set(handles.edit2,'String',cell2mat(data2(2)));
   
   set(handles.uitable1,'Data',cell(cell2mat(data1(2)),4))
   set(handles.uitable1,'Data',uitableData);
   set(handles.uitable1,'enable','on');
   set(handles.savePrmBtn,'enable','on');
   set(handles.computeHVSRBtn,'enable','on');
end;
    

% --- Executes on button press in savePrmBtn.
function savePrmBtn_Callback(hObject, eventdata, handles)
% hObject    handle to savePrmBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Check number of layers textbox
global uitableData;

layerNum=0;
sampleNum=0;

S = get(handles.edit1, 'String');
if ~isempty(S)
    if ~all(ismember(S, '1234567890'))
        set(handles.edit1,'String','');  
    else
        if str2double(S)<2
            msgbox('Number of layers must be greater than 1');
            return;
        else
            layerNum=str2double(S);
            set(handles.uitable1,'Data',cell(layerNum,4))
        end;
    end;
else
    msgbox('Please, enter the number of layers');
    return;
end;

if layerNum>1
    %Check number of samples textbox    
    S = get(handles.edit2, 'String');
    if ~isempty(S)
        if ~all(ismember(S, '1234567890'))
            set(handles.edit2,'String','');
            msgbox('Number of samples must be integer');
            set(handles.uitable1,'Data',uitableData);
            return;
        else
            sampleNum=str2double(S);
            if sampleNum<=0
               msgbox('Number of samples must be integer that is greater than 0');
               set(handles.uitable1,'Data',uitableData);
               return;
            end;
        end;
    else
        msgbox('Please, enter the number of samples');
        set(handles.uitable1,'Data',uitableData);
        return;
    end;
    
    for i=1:layerNum
        S=uitableData(i,:);        
        if (isempty(S(1))) || (isempty(S(2))) || (isempty(S(3))) || (isempty(S(4)))
            msgbox('Please, enter all parameters');
            return;
        end;
    end;

[file,path] = uiputfile('*.txt');
if isequal(file,0) || isequal(path,0)
   
else
    file=fullfile(path,file);
    f=fopen(file,'wt');
    fprintf(f,'Number_of_Layers: %d\n',layerNum);
    fprintf(f,'Number_of_Samples: %d\n',sampleNum);
    for i=1:layerNum
        S=uitableData(i,:);
        fprintf(f,'Layer_No: %d\n',i);
        fprintf(f,'%d %d %1.3f %1.3f\n',S(1),S(2),S(3),S(4));
    end;
    fclose(f);
    
    set(handles.uitable1,'Data',uitableData);
end
   
end;


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in closeBtn.
function closeBtn_Callback(hObject, eventdata, handles)
% hObject    handle to closeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;

% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on key press with focus on edit1 and none of its controls.
function edit1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on key press with focus on edit2 and none of its controls.
function edit2_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on key press with focus on edit3 and none of its controls.
function edit3_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on key press with focus on edit4 and none of its controls.
function edit4_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
global uitableData;
uitableData=get(handles.uitable1,'Data');
id=eventdata.Indices;

%Damping Ratio
if id(2)==2
    if uitableData(id(1),2)<=1000
        uitableData(id(1),4)=1/(2*0.06*uitableData(id(1),2));
    end;
    if  uitableData(id(1),2)>1000 && uitableData(id(1),2)<2000
        uitableData(id(1),4)=1/(2*0.04*uitableData(id(1),2));
    end;
    if uitableData(id(1),2)>=2000
        uitableData(id(1),4)=1/(2*0.16*uitableData(id(1),2));
    end;
end;

%Density
if id(2)==2
    uitableData(id(1),3)=0.85*uitableData(id(1),2)^0.14;    
end;


set(handles.uitable1,'Data',uitableData);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function computeHVSRBtn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to computeHVSRBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to computeHVSRBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
