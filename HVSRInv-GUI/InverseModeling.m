function varargout = InverseModeling(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @InverseModeling_OpeningFcn, ...
                   'gui_OutputFcn',  @InverseModeling_OutputFcn, ...
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

function InverseModeling_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
movegui(gcf,'center');

function varargout = InverseModeling_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function computeHVSRBtn_Callback(hObject, eventdata, handles)

function startForwardBtn_Callback(hObject, eventdata, handles)
global initModData;
global results;
global freqs;
global HVSR;
global freqs2;
global HVSR2;
global freqMin; 
global freqMax;
global invNum;
global par;

results=[];

set(handles.uitable2,'Data',results);

%Check popNum value
S = get(handles.edit9, 'String');
if ~isempty(S)
    if ~all(ismember(S, '1234567890'))
        msgbox('Number of Populations must be integer');
        set(handles.edit9,'String','');  
    else
        if str2double(S)<1
            msgbox('Number of Populations must be greater than 0');
            set(handles.edit9,'String','');
        else
            popNum=str2double(S);
        end;
    end;
else
   msgbox('Please, enter the number of Populations');
   return;
end;

%Check iterNum value
S = get(handles.edit6, 'String');
if ~isempty(S)
    if ~all(ismember(S, '1234567890'))
        msgbox('Number of Iterations must be integer');
        set(handles.edit6,'String','');  
    else
        if str2double(S)<1
            msgbox('Number of Iterations must be greater than 0');
            set(handles.edit6,'String','');
        else
            iterNum=str2double(S);
        end;
    end;
else
   msgbox('Please, enter the number of Iterations');
   return;
end;

%Check layerNum value
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
        end;
    end;
else
    msgbox('Please, enter the number of layers');
    return;
end;

if layerNum>1    
    %Check minimum frequency textbox
    S = get(handles.edit3, 'String');
    if ~isempty(S)
        if ~all(ismember(S, '.1234567890'))
            set(handles.edit3,'String','');
            msgbox('Minimum frequency must be numeric');
            return;
        else
            freqMin=str2double(S);
            if freqMin<0
                msgbox('Minimum frequency must be greater than 0');
                return;
            end;
        end;
    else
        msgbox('Please, enter the minimum frequency');
        return;
    end;
    
    %Check maximum frequency textbox
    S = get(handles.edit4, 'String');
    if ~isempty(S)
        if ~all(ismember(S, '.1234567890'))
            set(handles.edit4,'String','');
            msgbox('Maximum frequency must be numeric');
            return;
        else
            freqMax=str2double(S);
            if freqMax<=0
                msgbox('Maximum frequency must be greater than 0');
                return;
            end;
        end;
    else
       msgbox('Please, enter the maximum frequency');
       return;
    end; 
end;

%Check invNum value
S = get(handles.edit8, 'String');
if ~isempty(S)
    if ~all(ismember(S, '1234567890'))
       set(handles.edit4,'String','');
       msgbox('Number of inversion must be numeric');
       return;
    else
       invNum=str2double(S);
       if invNum<=0
          msgbox('Number of inversion must be greater than 0');
          return;
       end;
    end;
else
    msgbox('Please, enter the number of inversion');
    return;
end; 

%Check gene values
for i=1:layerNum
    S=initModData(i,:);        
    if isempty(S(:))
       msgbox('Please, enter all parameters');
       return;
    end;
    if S(3)<1 || S(6)<1 || S(9)<1 || S(12)<1
            msgbox('Number of Genes can not be less than 1');
            set(handles.uitable1,'Data',initModData);
            return;
    end;
end;

%Check HVSR data 
if isempty(freqs) || isempty(HVSR)
    msgbox('Please, load HVSR data');
    return;
end;

%Check freqMin value 
if freqs(1)>freqMin
    msgbox(sprintf('The minimum frequency can not be less than %g',freqs(1)));
    return;
end;

%Check freqMax value
if freqs(end)<freqMax
    msgbox(sprintf('The maximum frequency can not be greater than %g',freqs(end)));
    return;
end;

Vs=[];

cla(handles.axes1);
cla(handles.axes2);

axes(handles.axes2);
semilogx(handles.axes2,freqs,HVSR,'k','linewidth',2),hold on
xlabel('Frequency (Hz)');
ylabel('HVSR');
xlim([min(freqs) max(freqs)]);
set(gca,'FontSize',11);
grid on;
zoom on;

[minValue,closestIndex1] = min(abs(freqs-freqMin));
[minValue,closestIndex2] = min(abs(freqs-freqMax));
sampleNum=closestIndex2-closestIndex1+1;

par=Inversion( layerNum,invNum,iterNum,popNum,freqs,HVSR,freqMin,freqMax,sampleNum,initModData,handles.axes1);
    
sz=size(par);
for i=1:sz(2)
   hMean(1,i)=mean(par(:,i));
end;
    
j=1;i=1;
while i<sz(2)
   H(j)=round(hMean(i));i=i+1;
   Vs(j)=round(hMean(i));i=i+1;
   Den(j)=round(hMean(i),3);i=i+1;
   Damp(j)=round(hMean(i),3);i=i+1;
   j=j+1;
end;

depthmax=sum(initModData(:,2));

[modelx,modely]=SetArray(H,Vs,depthmax);
   
axes(handles.axes1);
plot(modelx,modely,'linewidth',4,'color','r');
set(gca,'FontSize',11)

for i=1:layerNum
    if i<layerNum
        results(i,1)=H(i);
    else
        results(i,1)=0;
    end;
    results(i,2)=Vs(i);
    results(i,3)=Den(i);
    results(i,4)=Damp(i);    
end;
    
set(handles.uitable2,'Data',results);
    
frecInt=freqMax/sampleNum;
f1=freqMin;f2=freqMax;
freqs2=(f1:frecInt:f2);
HVSR2=CalcHVSR(Vs',H',Den',Damp',freqs2);
    
cla(handles.axes2);    
   
axes(handles.axes2);
semilogx(handles.axes2,freqs,HVSR,'k','linewidth',1.5),hold on
semilogx(handles.axes2,freqs2,HVSR2,'--r','linewidth',2),hold off
xlabel('Frequency (Hz)');
ylabel('Amplitude');
xlim([freqMin,freqMax]);
set(gca,'FontSize',11);
if invNum>1
    legend('HVSR','Estimated Mean HVSR','Location','northwest');
else
    legend('HVSR','Estimated HVSR','Location','northwest');
end;
grid on;
zoom on;

set(handles.pushbutton23,'enable','on');

function saveGrpBtn_Callback(hObject, eventdata, handles)

function edit1_Callback(hObject, eventdata, handles)
global initModData;
global HVSR;

S = get(handles.edit1, 'String');
if ~isempty(S)
    if ~all(ismember(S, '.1234567890'))
        f=msgbox('Number of layers must be numeric');
        set(handles.edit1,'String','');  
    else
        if str2num(S)<2
            f=msgbox('Number of layers must be greater than 1');
            set(handles.edit1,'String','');
        else
            set(handles.uitable1,'Data',cell(str2num(S),12))
            initModData=repmat(0,str2num(S),12);
            initModData(:,3)=9;
            initModData(:,6)=9;
            initModData(:,9)=9;
            initModData(:,12)=9;
            
            set(handles.uitable1,'Data',initModData);
            set(handles.uitable1,'enable','on');
            
            set(handles.pushbutton21,'enable','on');
            
            if ~isempty(initModData) && ~isempty(HVSR)
                set(handles.startForwardBtn,'enable','on');
            end;   
        end;
    end;
else
   f=msgbox('Please, enter the number of layers');
   return;
end;

function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function loadPrmBtn_Callback(hObject, eventdata, handles)
    
function savePrmBtn_Callback(hObject, eventdata, handles)

function edit2_Callback(hObject, eventdata, handles)

function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton9_Callback(hObject, eventdata, handles)

function closeBtn_Callback(hObject, eventdata, handles)

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
global initModData;
initModData=get(handles.uitable1,'Data');
id=eventdata.Indices;

%Damping Ratio
if id(2)==4
    if initModData(id(1),4)<=1000
        initModData(id(1),10)=(1/(2*0.06*initModData(id(1),4)))/2;
    end;
    if  initModData(id(1),4)>1000 && initModData(id(1),4)<2000
        initModData(id(1),10)=(1/(2*0.04*initModData(id(1),4)))/2;
    end;
    if initModData(id(1),4)>=2000
        initModData(id(1),10)=(1/(2*0.16*initModData(id(1),4)))/2;
    end;
end;
if id(2)==5
    if initModData(id(1),5)<=1000
        initModData(id(1),11)=(1/(2*0.06*initModData(id(1),5)))*2;
    end;
    if  initModData(id(1),5)>1000 && initModData(id(1),5)<2000
        initModData(id(1),11)=(1/(2*0.04*initModData(id(1),5)))*2;
    end;
    if initModData(id(1),5)>=2000
        initModData(id(1),11)=(1/(2*0.16*initModData(id(1),5)))*2;
    end;
end;

%Density
if id(2)==4
    initModData(id(1),7)=0.85*initModData(id(1),4)^0.14;
end;
if id(2)==5
    initModData(id(1),8)=0.85*initModData(id(1),5)^0.14;
end;

set(handles.uitable1,'Data',initModData);

function checkbox1_Callback(hObject, eventdata, handles)

function edit5_Callback(hObject, eventdata, handles)

function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit6_Callback(hObject, eventdata, handles)

function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton20_Callback(hObject, eventdata, handles)
global initModData;
global HVSR;

[file,path] = uigetfile('*.txt');
if isequal(file,0) || isequal(path,0)
else
   file=fullfile(path,file);
   f=fopen(file);
   data1 = textscan(f,'%s%d',1,'Delimiter',' ');
   data3 = textscan(f,'%s%f',1,'Delimiter',' ');
   data4 = textscan(f,'%s%f',1,'Delimiter',' ');
   initModData=[];
   for i=1:cell2mat(data1(2))
       data = textscan(f,'%s%d',1,'Delimiter',' ');
       data = textscan(f,'%f%f%d%f%f%d%f%f%d%f%f%d',1,'Delimiter',' ');
       initModData(i,1)=cell2mat(data(1));
       initModData(i,2)=cell2mat(data(2));
       initModData(i,3)=cell2mat(data(3));
       initModData(i,4)=cell2mat(data(4));
       initModData(i,5)=cell2mat(data(5));
       initModData(i,6)=cell2mat(data(6));
       initModData(i,7)=cell2mat(data(7));
       initModData(i,8)=cell2mat(data(8));
       initModData(i,9)=cell2mat(data(9));
       initModData(i,10)=cell2mat(data(10));
       initModData(i,11)=cell2mat(data(11));
       initModData(i,12)=cell2mat(data(12));
   end;   
   fclose(f);
   set(handles.edit1,'String',cell2mat(data1(2)));
   set(handles.edit3,'String',cell2mat(data3(2)));
   set(handles.edit4,'String',cell2mat(data4(2)));
   
   set(handles.uitable1,'Data',cell(cell2mat(data1(2)),12))
   set(handles.uitable1,'Data',initModData);
   set(handles.uitable1,'enable','on');
   
   set(handles.pushbutton21,'enable','on');
   
   if ~isempty(initModData) && ~isempty(HVSR)
    set(handles.startForwardBtn,'enable','on');
   end;   
end;

function pushbutton21_Callback(hObject, eventdata, handles)
global initModData;

layerNum=0;
freqMin=0;
freqMax=0;

S = get(handles.edit1, 'String');
if ~isempty(S)
    if ~all(ismember(S, '1234567890'))
        set(handles.edit1,'String','');  
    else
        if str2num(S)<2
            f=msgbox('Number of layers must be greater than 1');
            return;
        else
            layerNum=str2num(S);
            set(handles.uitable1,'Data',cell(layerNum,12))
        end;
    end;
else
    f=msgbox('Please, enter the number of layers');    
    return;
end;

if layerNum>1   
    %Check minimum frequency textbox
    S = get(handles.edit3, 'String');
    if ~isempty(S)
        if ~all(ismember(S, '.1234567890'))
            set(handles.edit3,'String','');
            f=msgbox('Minimum frequency must be numeric');
            set(handles.uitable1,'Data',initModData);
            return;
        else
            freqMin=str2num(S);
            if freqMin<=0
                f=msgbox('Minimum frequency must be greater than 0');
                set(handles.uitable1,'Data',initModData);
                return;
            end;
        end;
    else
        f=msgbox('Please, enter the minimum frequency');
        set(handles.uitable1,'Data',initModData);
        return;
    end;
    
    %Check maximum frequency textbox
    S = get(handles.edit4, 'String');
    if ~isempty(S)
        if ~all(ismember(S, '.1234567890'))
            set(handles.edit4,'String','');
            f=msgbox('Maximum frequency must be numeric');
            set(handles.uitable1,'Data',initModData);
            return;
        else
            freqMax=str2num(S);
            if freqMax<=0
                f=msgbox('Maximum frequency must be greater than 0');
                set(handles.uitable1,'Data',initModData);
                return;
            end;
        end;
    else
       f=msgbox('Please, enter the maximum frequency');
       set(handles.uitable1,'Data',initModData);
       return;
    end;    
    
    for i=1:layerNum
        S=initModData(i,:);        
        if isempty(S(:))
            f=msgbox('Please, enter all parameters');
            set(handles.uitable1,'Data',initModData);
            return;
        end;
        if S(3)<1 || S(6)<1 || S(9)<1 || S(12)<1
            f=msgbox('Number of Genes can not be less than 1');
            set(handles.uitable1,'Data',initModData);
            return;
        end;
    end;

[file,path] = uiputfile('*.txt');
if isequal(file,0) || isequal(path,0)
else
    file=fullfile(path,file);
    f=fopen(file,'wt');
    fprintf(f,'Number_of_Layers: %d\n',layerNum);
    fprintf(f,'Minimum_Frequency: %2.3f\n',freqMin);
    fprintf(f,'Maximum_Frequency: %2.3f\n',freqMax);
    for i=1:layerNum
        S=initModData(i,:);
        fprintf(f,'Layer_No: %d\n',i);
        fprintf(f,'%1.3f %1.3f %d %1.3f %1.3f %d %1.3f %1.3f %d %1.3f %1.3f %d\n',S(1),S(2),S(3),S(4),S(5),S(6),S(7),S(8),S(9),S(10),S(11),S(12));
    end;
    fclose(f);
    
    set(handles.uitable1,'Data',initModData);
end;   
end;

function loadHVSRBtn_Callback(hObject, eventdata, handles)
global freqs;
global HVSR;
global initModData;

cla(handles.axes1);
cla(handles.axes2);

freqs=[];
HVSR=[];

[file,path] = uigetfile('*.txt');
if isequal(file,0) || isequal(path,0)
else
   file=fullfile(path,file);
   data=load(file);
   freqs=data(:,1);
   HVSR=data(:,2);
   
   axes(handles.axes2);
   semilogx(freqs,HVSR,'linewidth',2,'color','k');
   xlabel('Frequency (Hz)');
   ylabel('Amplitude (HVSR)');
   xlim([min(freqs) max(freqs)]);
   set(gca,'FontSize',11);
   grid on  
   
   axes(handles.axes1);
   xlabel('Velocity (ms^{-1})');
   ylabel('Depth (m)');
   set(gca,'FontSize',11)
   grid on
   
   if ~isempty(initModData) && ~isempty(HVSR)
    set(handles.startForwardBtn,'enable','on');
   end;   
end;

function pushbutton23_Callback(hObject, eventdata, handles)
global freqs;
global HVSR;
global freqs2;
global HVSR2;
global freqMin; 
global freqMax;
global invNum;
global initModData;
global par;

[file,path] = uiputfile('*.png,*.fig');
if isequal(file,0) || isequal(path,0)
else
    file=fullfile(path,file);
    
    fig=figure(1);
    semilogx(freqs,HVSR,'k','linewidth',1.5),hold on
    semilogx(freqs2,HVSR2,'--r','linewidth',2),hold off
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    xlim([freqMin,freqMax]);
    set(gca,'FontSize',14);
    if invNum>1
        legend('HVSR','Estimated Mean HVSR','Location','northeast');
    else
        legend('HVSR','Estimated HVSR','Location','northwest');
    end;
    grid on

    saveas(fig,file);
    close(fig);    
end;

[file,path] = uiputfile('*.png,*.fig');
if isequal(file,0) || isequal(path,0)
else
    file=fullfile(path,file);    
    fig2=figure(2); 
    
    sz=size(par);
    sz2=sz(2)/4;
    
    H=zeros(1,sz2);
    Vs=zeros(1,sz2);
    
    velmin=0;
    velmax=initModData(end,5);    
    depthmax=sum(initModData(:,2));
    
    for j=1:sz(1)
        k=1;
        for i=1:sz2
            H2(i)=par(j,k);
            Vs2(i)=par(j,k+1);
            k=k+4;
        end;
        [modelx2 modely2]=SetArray(H2,Vs2,depthmax);
        
        plot(modelx2,modely2,'linewidth',2,'color',[.7 .7 .7]),hold on;
        
        H=H+H2;
        Vs=Vs+Vs2;
    end;    
    
    H=H/sz(1);
    Vs=Vs/sz(1);
    
    [modelx modely]=SetArray(H,Vs,depthmax);    
    
    plot(modelx,modely,'linewidth',4,'color','r');
    xlabel('Velocity (ms^{-1})');
    ylabel('Depth (m)');

    set(gca, 'YDir','reverse')
    xlim([velmin velmax]);
    ylim([0 depthmax]);
            
    set(gca,'FontSize',14)
    grid on

    saveas(fig2,file);
    close(fig2);    
end;

function pushbutton24_Callback(hObject, eventdata, handles)

function edit8_Callback(hObject, eventdata, handles)

function edit8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function figure1_CreateFcn(hObject, eventdata, handles)

function edit9_Callback(hObject, eventdata, handles)

function edit9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function uitable2_CreateFcn(hObject, eventdata, handles)