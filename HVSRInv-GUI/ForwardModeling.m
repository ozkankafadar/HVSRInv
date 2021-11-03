function varargout = ForwardModeling(varargin)
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

function ForwardModeling_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
movegui(gcf,'center');

function varargout = ForwardModeling_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function computeHVSRBtn_Callback(hObject, eventdata, handles)
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
ylim([0 modely(end)]);
set(gca, 'YDir','reverse')
set(gca,'FontSize',11)
grid on

set(handles.uitable1,'Data',uitableData);
set(handles.saveHVSRBtn,'enable','on');
set(handles.saveGrpBtn,'enable','on');

function saveHVSRBtn_Callback(hObject, eventdata, handles)
global freqs;
global HVSR;

[file,path] = uiputfile('*.txt');
if isequal(file,0) || isequal(path,0)
else
    file=fullfile(path,file);
    f=fopen(file,'w+');
    fprintf(f,'%1.7f %1.7f\n',[freqs;HVSR']);   
    fclose(f);
end;

function saveGrpBtn_Callback(hObject, eventdata, handles)
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

function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function loadPrmBtn_Callback(hObject, eventdata, handles)
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
    
function savePrmBtn_Callback(hObject, eventdata, handles)
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
end;   
end;

function edit2_Callback(hObject, eventdata, handles)

function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton9_Callback(hObject, eventdata, handles)

function closeBtn_Callback(hObject, eventdata, handles)
close;

function pushbutton15_Callback(hObject, eventdata, handles)

function edit3_Callback(hObject, eventdata, handles)

function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit4_Callback(hObject, eventdata, handles)

function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_KeyPressFcn(hObject, eventdata, handles)

function edit2_KeyPressFcn(hObject, eventdata, handles)

function edit3_KeyPressFcn(hObject, eventdata, handles)

function edit4_KeyPressFcn(hObject, eventdata, handles)

function uitable1_CellEditCallback(hObject, eventdata, handles)
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


function checkbox1_Callback(hObject, eventdata, handles)

function edit5_Callback(hObject, eventdata, handles)

function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function computeHVSRBtn_CreateFcn(hObject, eventdata, handles)

function figure1_CreateFcn(hObject, eventdata, handles)