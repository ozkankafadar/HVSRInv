function varargout = InverseModeling(varargin)
% Begin initialization code - DO NOT EDIT
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
% End initialization code - DO NOT EDIT

%Figure1 Opening Event 
function InverseModeling_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    movegui(gcf,'center');

function varargout = InverseModeling_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;

%START Button Click Event
function startBtn_Callback(hObject, eventdata, handles)
    global initModData;
    global freqs;
    global HVSR;
    global freqs2;
    global HVSR2;
    global freqMin; 
    global freqMax;
    global invNum;
    global layerNum;
    global file;
    global par;

    results=[];
    set(handles.resultTable,'Data',results);

    %Check geneNum value
    S = get(handles.geneNumEdit, 'String');
    if ~isempty(S)
        if ~all(ismember(S, '1234567890'))
            msgbox('Number of genes must be integer');
            set(handles.geneNumEdit,'String','');  
        else
            if str2double(S)<2
                msgbox('Number of genes must be greater than 0');
                set(handles.geneNumEdit,'String','');
            else
                geneNum=str2double(S);
            end;
        end;
    else
        msgbox('Please, enter the number of genes');
        return;
    end;

    %Check popNum value
    S = get(handles.popNumEdit, 'String');
    if ~isempty(S)
        if ~all(ismember(S, '1234567890'))
            msgbox('Number of Populations must be integer');
            set(handles.popNumEdit,'String','');  
        else
            if str2double(S)<1
                msgbox('Number of Populations must be greater than 0');
                set(handles.popNumEdit,'String','');
            else
                popNum=str2double(S);
            end;
        end;
    else
        msgbox('Please, enter the number of Populations');
        return;
    end;

    %Check iterNum value
    S = get(handles.iterNumEdit, 'String');
    if ~isempty(S)
        if ~all(ismember(S, '1234567890'))
            msgbox('Number of Iterations must be integer');
            set(handles.iterNumEdit,'String','');  
        else
            if str2double(S)<1
                msgbox('Number of Iterations must be greater than 0');
                set(handles.iterNumEdit,'String','');
            else
                iterNum=str2double(S);
            end;
        end;
    else
        msgbox('Please, enter the number of Iterations');
        return;
    end;

    %Check layerNum value
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
            end;
        end;
    else
        msgbox('Please, enter the number of layers');
        return;
    end;

    if layerNum>1    
        %Check minimum frequency textbox
        S = get(handles.freqMinEdit, 'String');
        if ~isempty(S)
            if ~all(ismember(S, '.1234567890'))
                set(handles.freqMinEdit,'String','');
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
        S = get(handles.freqMaxEdit, 'String');
        if ~isempty(S)
            if ~all(ismember(S, '.1234567890'))
                set(handles.freqMaxEdit,'String','');
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
    S = get(handles.invNumEdit, 'String');
    if ~isempty(S)
        if ~all(ismember(S, '1234567890'))
            set(handles.freqMaxEdit,'String','');
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
    
    cla(handles.modelAxes);
    cla(handles.HVSRAxes);

    axes(handles.HVSRAxes);
    semilogx(handles.HVSRAxes,freqs,HVSR,'k','linewidth',2),hold on
    xlabel('Frequency (Hz)');
    ylabel('HVSR');
    xlim([min(freqs) max(freqs)]);
    set(gca,'FontSize',11);
    grid on;
    zoom on;

    [minValue,closestIndex1] = min(abs(freqs-freqMin));
    [minValue,closestIndex2] = min(abs(freqs-freqMax));
    sampleNum=closestIndex2-closestIndex1+1;

    [file1,name1,ext1] = fileparts(file);
    file2=strcat(name1,'_output.txt');
    file3=fullfile('Outputs',file2);
    f=fopen(file3,'wt');
    fprintf(f,'HVSR data file: %s\n',file2);
    fprintf(f,'Inversion parameters\n');
    fprintf(f,'Number_of_Genes: %d\n',geneNum);
    fprintf(f,'Number_of_Populations: %d\n',popNum);
    fprintf(f,'Number_of_Iterations: %d\n',iterNum);
    fprintf(f,'Number_of_Inversions: %d\n',invNum);
    fprintf(f,'Model parameters\n');
    fprintf(f,'Number_of_Layers: %d\n',layerNum);
    fprintf(f,'Minimum_Frequency: %2.3f\n',freqMin);
    fprintf(f,'Maximum_Frequency: %2.3f\n',freqMax);
    for i=1:layerNum
        S=initModData(i,:);
        fprintf(f,'Layer_No: %d\n',i);
        fprintf(f,'HMin HMax VMin VMax DenMin DenMax DampMin DampMax\n');
        fprintf(f,'%1.3f %1.3f %1.3f %1.3f %1.3f %1.3f %1.3f %1.3f\n',S(1),S(2),S(3),S(4),S(5),S(6),S(7),S(8));
    end;

    fprintf(f,'Outputs\n');

    par=Inversion( layerNum,invNum,iterNum,popNum,geneNum,freqs,HVSR,freqMin,freqMax,sampleNum,initModData,handles.modelAxes);

    sz=size(par);

    for i=1:sz(1)
        fprintf(f,'Inversion_No:%d\n',i);
        S=par(i,:);   
        fprintf(f,'H V Den Damp\n');
        a=1;b=4;
        for j=1:sz(2)/4   
            c=S(a:b);
            fprintf(f,'%1.3f %1.3f %1.3f %1.3f\n',c(1),c(2),c(3),c(4));
            a=a+4;b=b+4;
        end; 
    end;

    for i=1:sz(2)
        hMean(1,i)=mean(par(:,i));
    end;

    fprintf(f,'Average Model\n');
    fprintf(f,'H V Den Damp\n');
    
    j=1;i=1;
    while i<sz(2)
        H(j)=round(hMean(i));i=i+1;
        Vs(j)=round(hMean(i));i=i+1;
        Den(j)=round(hMean(i),3);i=i+1;
        Damp(j)=round(hMean(i),3);i=i+1;      
        fprintf(f,'%1.3f %1.3f %1.3f %1.3f\n',H(j),Vs(j),Den(j),Damp(j));
       j=j+1;
    end;

    fclose(f);

    depthmax=sum(initModData(:,2));

    [modelx,modely]=SetArray(H,Vs,depthmax);
   
    axes(handles.modelAxes);

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
    plot(modelx,modely,'linewidth',4,'color','r');

    set(gca, 'YDir','reverse')
    set(gca,'FontSize',11)
    %xlim([0 max(modelx)+max(modelx)*10/100]);
    ylim([0 modely(end)]);
    xlabel('Velocity (ms^{-1})');
    ylabel('Depth (m)');

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
    
    set(handles.resultTable,'Data',results);
    
    frecInt=freqMax/sampleNum;
    f1=freqMin;f2=freqMax;
    freqs2=(f1:frecInt:f2);
    HVSR2=CalcHVSR(Vs',H',Den',Damp',freqs2);
    
    cla(handles.HVSRAxes);    
   
    axes(handles.HVSRAxes);
    semilogx(handles.HVSRAxes,freqs,HVSR,'k','linewidth',1.5),hold on
    semilogx(handles.HVSRAxes,freqs2,HVSR2,'--r','linewidth',2),hold off
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    xlim([freqMin,freqMax]);
    set(gca,'FontSize',11);
    if invNum>1
        legend('HVSR','Estimated Mean HVSR','Location','northeast');
    else
        legend('HVSR','Estimated HVSR','Location','northeast');
    end;
    grid on;
    zoom on;

    set(handles.pushbutton23,'enable','on');

%Number of Layers Edit Call Event
function layerNumEdit_Callback(hObject, eventdata, handles)
    global initModData;
    global HVSR;

    S = get(handles.layerNumEdit, 'String');
    if ~isempty(S)
        if ~all(ismember(S, '.1234567890'))
            f=msgbox('Number of layers must be numeric');
            set(handles.layerNumEdit,'String','');  
        else
            if str2num(S)<2
                f=msgbox('Number of layers must be greater than 1');
                set(handles.layerNumEdit,'String','');
            else
                set(handles.modelPrmTable,'Data',cell(str2num(S),12))
                initModData=repmat(0,str2num(S),8);
            
                set(handles.modelPrmTable,'Data',initModData);
                set(handles.modelPrmTable,'enable','on');            
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

%Model Parameters Table Cell Edit Event
function modelPrmTable_CellEditCallback(hObject, eventdata, handles)
    global initModData;
    initModData=get(handles.modelPrmTable,'Data');
    id=eventdata.Indices;

    %Damping Ratio
    if id(2)==3
        if initModData(id(1),3)<=1000
            initModData(id(1),7)=(1/(2*0.06*initModData(id(1),3)))/2;
        end;
        if  initModData(id(1),3)>1000 && initModData(id(1),3)<2000
            initModData(id(1),7)=(1/(2*0.04*initModData(id(1),3)))/2;
        end;
        if initModData(id(1),3)>=2000
            initModData(id(1),7)=(1/(2*0.16*initModData(id(1),3)))/2;
        end;
    end;
    
    if id(2)==4
        if initModData(id(1),4)<=1000
            initModData(id(1),8)=(1/(2*0.06*initModData(id(1),4)))*2;
        end;
        if  initModData(id(1),4)>1000 && initModData(id(1),4)<2000
            initModData(id(1),8)=(1/(2*0.04*initModData(id(1),4)))*2;
        end;
        if initModData(id(1),4)>=2000
            initModData(id(1),8)=(1/(2*0.16*initModData(id(1),4)))*2;
        end;
    end;

    %Density
    if id(2)==3
        initModData(id(1),5)=0.85*initModData(id(1),3)^0.14;
    end;
    if id(2)==4
        initModData(id(1),6)=0.85*initModData(id(1),4)^0.14;
    end;

    set(handles.modelPrmTable,'Data',initModData);

%LOAD Button Call Event
function loadBtn_Callback(hObject, eventdata, handles)
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
            data = textscan(f,'%f%f%f%f%f%f%f%f',1,'Delimiter',' ');

            initModData(i,1)=cell2mat(data(1));
            initModData(i,2)=cell2mat(data(2));
            initModData(i,3)=cell2mat(data(3));
            initModData(i,4)=cell2mat(data(4));
            initModData(i,5)=cell2mat(data(5));
            initModData(i,6)=cell2mat(data(6));
            initModData(i,7)=cell2mat(data(7));
            initModData(i,8)=cell2mat(data(8));
        end;   
        
        fclose(f);
   
        set(handles.layerNumEdit,'String',cell2mat(data1(2)));
        set(handles.freqMinEdit,'String',cell2mat(data3(2)));
        set(handles.freqMaxEdit,'String',cell2mat(data4(2)));   
        set(handles.modelPrmTable,'Data',cell(cell2mat(data1(2)),8))
        set(handles.modelPrmTable,'Data',initModData);
        set(handles.modelPrmTable,'enable','on');   
        set(handles.pushbutton21,'enable','on');
   
        if ~isempty(initModData) && ~isempty(HVSR)
            set(handles.startForwardBtn,'enable','on');
        end;
    end;

%SAVE Button Call Event
function saveBtn_Callback(hObject, eventdata, handles)
    global initModData;

    layerNum=0;freqMin=0;freqMax=0;

    S = get(handles.layerNumEdit, 'String');
    if ~isempty(S)
        if ~all(ismember(S, '1234567890'))
            set(handles.layerNumEdit,'String','');  
        else
            if str2num(S)<2
                f=msgbox('Number of layers must be greater than 1');
                return;
            else
                layerNum=str2num(S);
                set(handles.modelPrmTable,'Data',cell(layerNum,8))
            end;
        end;
    else
        f=msgbox('Please, enter the number of layers');    
        return;
    end;

    if layerNum>1   
        %Check minimum frequency textbox
        S = get(handles.freqMinEdit, 'String');
        if ~isempty(S)
            if ~all(ismember(S, '.1234567890'))
                set(handles.freqMinEdit,'String','');
                f=msgbox('Minimum frequency must be numeric');
                set(handles.modelPrmTable,'Data',initModData);
                return;
            else
                freqMin=str2num(S);
                if freqMin<=0
                    f=msgbox('Minimum frequency must be greater than 0');
                    set(handles.modelPrmTable,'Data',initModData);
                    return;
                end;
            end;
        else
            f=msgbox('Please, enter the minimum frequency');
            set(handles.modelPrmTable,'Data',initModData);
            return;
        end;
    
        %Check maximum frequency textbox
        S = get(handles.freqMaxEdit, 'String');
        if ~isempty(S)
            if ~all(ismember(S, '.1234567890'))
                set(handles.freqMaxEdit,'String','');
                f=msgbox('Maximum frequency must be numeric');
                set(handles.modelPrmTable,'Data',initModData);
                return;
            else
                freqMax=str2num(S);
                if freqMax<=0
                    f=msgbox('Maximum frequency must be greater than 0');
                    set(handles.modelPrmTable,'Data',initModData);
                    return;
                end;
            end;
        else
            f=msgbox('Please, enter the maximum frequency');
            set(handles.modelPrmTable,'Data',initModData);
            return;
        end;    
    
        for i=1:layerNum
            S=initModData(i,:);        
            if isempty(S(:))
                f=msgbox('Please, enter all parameters');
                set(handles.modelPrmTable,'Data',initModData);
                return;
            end;
        end;

        [file,path] = uiputfile('*.txt');
        if isequal(file,0) || isequal(path,0)   
            set(handles.modelPrmTable,'Data',initModData);
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
            set(handles.modelPrmTable,'Data',initModData);
        end;
    end;

%LOAD HVSR Button Call Event    
function loadHVSRBtn_Callback(hObject, eventdata, handles)
    global freqs;
    global HVSR;
    global initModData;
    global file;

    cla(handles.modelAxes);
    cla(handles.HVSRAxes);

    freqs=[];
    HVSR=[];

    [file,path] = uigetfile('*.txt');
    if isequal(file,0) || isequal(path,0)
    else
        file=fullfile(path,file);
        data=load(file);
        freqs=data(:,1);
        HVSR=data(:,2);
   
        axes(handles.HVSRAxes);
        semilogx(freqs,HVSR,'linewidth',2,'color','k');
        xlabel('Frequency (Hz)');
        ylabel('Amplitude (HVSR)');
        xlim([min(freqs) max(freqs)]);
        set(gca,'FontSize',11);
        grid on  
   
        axes(handles.modelAxes);
        xlabel('Velocity (ms^{-1})');
        ylabel('Depth (m)');
        set(gca,'FontSize',11)
        grid on
   
        if ~isempty(initModData) && ~isempty(HVSR)
            set(handles.startForwardBtn,'enable','on');
        end;   
    end;

%SAVE GRAPHICS Button Call Event
function saveGraphicsBtn_Callback(hObject, eventdata, handles)
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
        velmax=initModData(end,4);    
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
    
        xlabel('Velocity (ms^{-1})');
        ylabel('Depth (m)');
        set(gca, 'YDir','reverse')
        xlim([velmin velmax]);
        ylim([0 depthmax]);
    
        [modelx modely]=SetArray(H,Vs,depthmax);
    
        cmap=hot(500);
        if get(handles.coloredLayersChk, 'Value')
            newLim = xlim(handles.modelAxes);
            j=1;    
            for i=1:5
                patch([0 newLim(2) newLim(2) 0],[modely(j) modely(j) modely(j+1) modely(j+1)],cmap(i*5),'EdgeColor', 'k', 'FaceAlpha', 0.4);hold on;
                j=j+2;        
            end;
        end;
    
        plot(modelx,modely,'linewidth',4,'color','r');

        set(gca, 'YDir','reverse')
        set(gca,'FontSize',11)
        xlim([0 max(modelx)+(max(modelx)-min(modelx))*5/100]);
        ylim([0 modely(end)]);
        xlabel('Velocity (ms^{-1})');
        ylabel('Depth (m)');

        saveas(fig2,file);
        close(fig2);    
    end;

%CLOSE Button Call Event
function closeBtn_Callback(hObject, eventdata, handles)
    close;

%Colored Layers Checkbox Call Event
function coloredLayersChk_Callback(hObject, eventdata, handles)
    global layerNum;

    cmap=hot(500);
    h = findall(handles.modelAxes,'Type','line');
    sz2=length(h);

    if sz2>0
        for i=1:sz2
            x(i,:)=h(i).XData;
            y(i,:)=h(i).YData;
        end;

        cla(handles.modelAxes)
        axes(handles.modelAxes);

        for i=2:sz2
            plot(x(i,:),y(i,:),'linewidth',2,'color',[.7 .7 .7]),hold on;
        end;

        if get(handles.coloredLayersChk, 'Value') 
            newLim = xlim(handles.modelAxes);
            j=1;
            for i=1:layerNum   
                patch([0 newLim(2) newLim(2) 0],[y(1,j) y(1,j) y(1,j+1) y(1,j+1)],cmap(i*5),'EdgeColor', 'k', 'FaceAlpha', 0.4);hold on;
                j=j+2;
            end;
            grid off;
        else
            grid on;
        end;
        plot(x(1,:),y(1,:),'linewidth',4,'color','r');
    end;

%figure1 Close Event
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    global initModData;
    global freqs;
    global HVSR;
    global freqs2;
    global HVSR2;
    global freqMin; 
    global freqMax;
    global invNum;
    global layerNum;
    global file;
    global par;
    
    initModData=[];
    freqs=[];freqs2=[];
    HVSR=[];HVSR2=[];
    freqMin=[];freqMax=[];
    layerNum=[];
    file=[];
    par=[];
    
    delete(hObject);
