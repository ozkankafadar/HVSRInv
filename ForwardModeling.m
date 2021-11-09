function varargout = ForwardModeling(varargin)
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

%Figure1 Opening Event 
function ForwardModeling_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    movegui(gcf,'center');

function varargout = ForwardModeling_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;

%COMPUTE HVSR Button Call Event
function computeHVSRBtn_Callback(hObject, eventdata, handles)
    global uitableData;
    global freqs;
    global HVSR;
    global modelx;
    global modely;
    global Vs;
    global layerNum;

    Vs=[];
    modelx=[];
    modely=[];
    HVSR=[];
    freqs=[];

    S = get(handles.layerNumEdit, 'String');
    if ~isempty(S)
        if ~all(ismember(S, '1234567890'))
            set(handles.layerNumEdit,'String','');  
        else
            if str2double(S)<2
                msgbox('Number of layers must be greater than 1');
                return;
            else
                layerNum=str2double(S);
                set(handles.modelPrmTable,'Data',cell(layerNum,4))
            end;
        end;
    else
        msgbox('Please, enter the number of layers');
        return;
    end;

    if layerNum>1
        %Check number of sample textbox    
        S = get(handles.sampleNumEdit, 'String');
        if ~isempty(S)
            if ~all(ismember(S, '1234567890'))
                set(handles.sampleNumEdit,'String','');
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

    cb_value = get(handles.noiseChk, 'Value');
    if cb_value==1
        S=get(handles.noiseEdit,'String');
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
        S=get(handles.noiseEdit,'String');
        Noise=randn(length(freqs),1)*max(HVSR)*str2double(S)/100;
        HVSR=HVSR+Noise;
    end;

    cla(handles.modelAxes);
    cla(handles.HVSRAxes);

    axes(handles.HVSRAxes);
    semilogx(freqs,HVSR,'linewidth',1.5,'color','k'),hold on;
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    set(gca,'FontSize',11)
    xlim([min(freqs) max(freqs)]);
    grid on

    axes(handles.modelAxes);    
    
    if get(handles.coloredLayersChk, 'Value')
        cmap=hot(500);
        newLim = xlim(handles.modelAxes);
        j=1;    
        for i=1:layerNum
            patch([0 newLim(2) newLim(2) 0],[modely(j) modely(j) modely(j+1) modely(j+1)],cmap(i*5),'EdgeColor', 'k', 'FaceAlpha', 0.4);hold on;
            j=j+2;        
        end;
        plot(handles.modelAxes,modelx,modely,'linewidth',4,'color','k');
        grid off;
    else
        plot(handles.modelAxes,modelx,modely,'linewidth',4,'color','k');
        grid on;
    end;
    
    set(handles.modelAxes, 'YDir','reverse')
    set(handles.modelAxes,'FontSize',11)
    xlim([0 max(modelx)+(max(modelx)-min(modelx))*5/100]);
    ylim([0 modely(end)]);
    xlabel('Velocity (ms^{-1})');
    ylabel('Depth (m)');
    
    
    set(handles.modelPrmTable,'Data',uitableData);
    set(handles.saveHVSRBtn,'enable','on');
    set(handles.saveGrpBtn,'enable','on');

%SAVE HVSR DATA Button Call Event
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

%SAVE GRAPHICS Button Call Event
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

%Number of Layers Edit Call Event
function layerNumEdit_Callback(hObject, eventdata, handles)
    global uitableData;

    S = get(handles.layerNumEdit, 'String');
    if ~isempty(S)
        if ~all(ismember(S, '.1234567890'))
            msgbox('Number of layers must be numeric');
            set(handles.layerNumEdit,'String','');  
        else
            if str2double(S)<2
                msgbox('Number of layers must be greater than 1');
                set(handles.layerNumEdit,'String','');
            else
                set(handles.modelPrmTable,'Data',cell(str2double(S),4))
                uitableData=repmat(0,str2double(S),4);
                set(handles.modelPrmTable,'Data',uitableData);
                set(handles.modelPrmTable,'enable','on');
                set(handles.savePrmBtn,'enable','on');
                set(handles.computeHVSRBtn,'enable','on');
            end;
        end;
    else
        msgbox('Please, enter the number of layers');
        return;
    end;

%LOAD Button Call Event
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
        set(handles.layerNumEdit,'String',cell2mat(data1(2)));
        set(handles.sampleNumEdit,'String',cell2mat(data2(2)));
        set(handles.modelPrmTable,'Data',cell(cell2mat(data1(2)),4))
        set(handles.modelPrmTable,'Data',uitableData);
        set(handles.modelPrmTable,'enable','on');
        set(handles.savePrmBtn,'enable','on');
        set(handles.computeHVSRBtn,'enable','on');
    end;

%SAVE Button Call Event
function savePrmBtn_Callback(hObject, eventdata, handles)
    global uitableData;

    layerNum=0;
    sampleNum=0;

    S = get(handles.layerNumEdit, 'String');
    if ~isempty(S)
        if ~all(ismember(S, '1234567890'))
            set(handles.layerNumEdit,'String','');  
        else
            if str2double(S)<2
                msgbox('Number of layers must be greater than 1');
                return;
            else
                layerNum=str2double(S);
                set(handles.modelPrmTable,'Data',cell(layerNum,4))
            end;
        end;
    else
        msgbox('Please, enter the number of layers');
        return;
    end;

    if layerNum>1
        %Check number of samples textbox    
        S = get(handles.sampleNumEdit, 'String');
        if ~isempty(S)
            if ~all(ismember(S, '1234567890'))
                set(handles.sampleNumEdit,'String','');
                msgbox('Number of samples must be integer');
                set(handles.modelPrmTable,'Data',uitableData);
                return;
            else
                sampleNum=str2double(S);
                if sampleNum<=0
                    msgbox('Number of samples must be integer that is greater than 0');
                    set(handles.modelPrmTable,'Data',uitableData);
                    return;
                end;
            end;
        else
            msgbox('Please, enter the number of samples');
            set(handles.modelPrmTable,'Data',uitableData);
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
            set(handles.modelPrmTable,'Data',uitableData);
        end;
    end;

%CLOSE Button Call Event
function closeBtn_Callback(hObject, eventdata, handles)
    close;

%Model Parameters Table Cell Edit Event
function modelPrmTable_CellEditCallback(hObject, eventdata, handles)
    global uitableData;
    uitableData=get(handles.modelPrmTable,'Data');
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
    set(handles.modelPrmTable,'Data',uitableData);

%Colored Layers Checkbox Call Event
function coloredLayersChk_Callback(hObject, eventdata, handles)
    global modelx;
    global modely;
    global layerNum;
    
    cla(handles.modelAxes);
    
    if layerNum>1 & ~isempty(modelx) & ~isempty(modely)
        cmap=hot(500);
        if get(handles.coloredLayersChk, 'Value')
            newLim = xlim(handles.modelAxes);
            j=1;    
            for i=1:layerNum
                patch([0 newLim(2) newLim(2) 0],[modely(j) modely(j) modely(j+1) modely(j+1)],cmap(i*5),'EdgeColor', 'k', 'FaceAlpha', 0.4);hold on;
                j=j+2;        
            end;
            grid off;
        else
            grid on;
        end;   
    
        plot(handles.modelAxes,modelx,modely,'linewidth',4,'color','k');

        xlabel('Velocity (ms^{-1})');
        ylabel('Depth (m)');
        xlim([0 max(modelx)+(max(modelx)-min(modelx))*5/100]);
        ylim([0 modely(end)]);
        set(gca, 'YDir','reverse')
        set(gca,'FontSize',11)
    end;

%figure1 Close Event
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    global uitableData;
    global freqs;
    global HVSR;
    global modelx;
    global modely;
    global Vs;
    global layerNum;

    Vs=[];
    modelx=[];
    modely=[];
    HVSR=[];
    freqs=[];
    uitableData=[];
    layerNum=[];
    
    delete(hObject);