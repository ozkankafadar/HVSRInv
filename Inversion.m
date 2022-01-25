function [parameters] = Inversion( LayerNum,InvNum,IterNum,PopNum,GeneNum,Freq,HVSRData,FreqMin,FreqMax,SampleNum,InitModData,Handle)
% LayerNum   : Number of layers
% InvNumber  : Number of inversions
% IterNum    : Number of iterations
% GeneNum    : number of genes
% PopNum     : Number of Populations
% Freq       : Frequency array
% HVSRData   : Horizontal-to-vertical spectral ratio data
% FreqMin    : Mimimum frequency for analysis
% FreqMax    : Maximum frequency for analysis
% SampleNum  : Number of samples
% InitModData: Initial parameters for analysis
% Handle     : Axes name
    param=zeros(LayerNum*4-1,3);
    k=1;
    for i=1:LayerNum
        S=InitModData(i,:);    
        param(k,1)=S(3);param(k,2)=S(4);param(k,3)=GeneNum;
        k=k+1;
        param(k,1)=S(5);param(k,2)=S(6);param(k,3)=GeneNum;
        k=k+1;
        param(k,1)=S(7);param(k,2)=S(8);param(k,3)=GeneNum;
        k=k+1;
        if i<LayerNum
            param(k,1)=S(1);param(k,2)=S(2);param(k,3)=GeneNum;
            k=k+1;
        end;
    end;

    minParam=param(:,1);
    maxParam=param(:,2);
    genePos=FindGenePos(param(:,3));
    freq=linspace(0,FreqMax,SampleNum);    
    hvsr=interp1(Freq,HVSRData,freq);
    
    [val,idx]=min(abs(freq-FreqMin));
    point1=idx;    
    [val,idx]=min(abs(freq-FreqMax));
    point2=idx;
    
    for j=1:InvNum    
        rand('twister',sum(100*clock));         
       
        pop=round(rand(PopNum,max(genePos)));      
    
        fp = waitbar(0,'Please wait ...');
        fdb_count=1.0/(IterNum);
        fdb_inc=0;  
    
        for jm=1:IterNum        
            %High-order Mutation        
            if jm>=IterNum*0.3
                if sum(abs(diff(gof(1,jm-IterNum*0.1:jm-1))))<1e-4;
                    prob=rand(1,1);%Probability
                    newPop=Mutation(pop,prob);%New Population
                    pop=newPop;   
                end;
            end;
        
            %Decode Operation
            for jk=1:LayerNum
                Velocity(jk,:)=round(Decode(pop(:,genePos(8*(jk-1)+1):genePos(8*(jk-1)+2)),minParam(4*(jk-1)+1),maxParam(4*(jk-1)+1)));
                Density(jk,:)=round(Decode(pop(:,genePos(8*(jk-1)+3):genePos(8*(jk-1)+4)),minParam(4*(jk-1)+2),maxParam(4*(jk-1)+2)),4);
                Damping(jk,:)=Decode(pop(:,genePos(8*(jk-1)+5):genePos(8*(jk-1)+6)),minParam(4*(jk-1)+3),maxParam(4*(jk-1)+3));
                if jk<LayerNum
                    Thickness(jk,:)=round(Decode(pop(:,genePos(8*(jk-1)+7):genePos(8*(jk-1)+8)),minParam(4*(jk-1)+4),maxParam(4*(jk-1)+4)));
                end;
            end;
        
            for im=1:size(pop,1)
                Fx(:,im)=CalcHVSR(Velocity(:,im),Thickness(:,im),Density(:,im),Damping(:,im),freq);
            end;

            goodnessFit=GoodnessofFit(Fx(point1:point2,:),hvsr(point1:point2));
            dFx=goodnessFit;
            ix=find(dFx==0);
            dFx(ix)=1e-11;
        
            fit=exp(1./(dFx));   
            fitIndex=find(fit==max(fit));
            fitIndex=fitIndex(1);
            elite=pop(fitIndex,:);%Elite individual        
            bestFit(jm)=goodnessFit(fitIndex);   
            
            %Reserve Best Individual
            if jm>1
                if bestFit(jm)<min(bestFit(1:jm-1))
                    Velocity2=Velocity(:,fitIndex);
                    Thickness2=Thickness(:,fitIndex);
                    Density2=Density(:,fitIndex);
                    Damping2=Damping(:,fitIndex);
                    jm2=jm;
                end;            
            end;        
        
            if jm==IterNum                
                %GoodnessofFit
                cla(figure(j));
                figure(j)
                plot(0:IterNum-1,bestFit,'k','LineWidth',1)
                hold on
                plot(jm2,bestFit(jm2),'ro','MarkerFaceColor','r','MarkerSize',10)
                xlim([0 IterNum]);
                
                
                title(['Inversion No: ' num2str(j)])
                xlabel('Generations');
                ylabel('RMSE');
                set(gcf,'position',[100,100,500,300])
                set(gca,'FontSize',22) 
      
                results=zeros(LayerNum,4);
                for i=1:LayerNum                
                    if i<LayerNum
                        results(i,1)=Thickness2(i);
                    else
                        results(i,1)=0;
                    end;
                    results(i,2)=Velocity2(i);
                    results(i,3)=Density2(i);
                    results(i,4)=Damping2(i); 
                end;
            
                velmin=0;
                velmax=InitModData(end,4);
                depthmin=min(InitModData(:,1));
                depthmax=sum(InitModData(:,2));
        
                mm=1;
                for mr=1:LayerNum
                    for o=1:4
                        parameters(j,mm)=results(mr,o);
                        mm=mm+1;
                    end;
                end;
                
                parameters(j,mm)=bestFit(jm2);
            
                [modelx,modely]=SetArray(Thickness2,Velocity2,depthmax);
            
                axes(Handle);       
                plot(Handle,modelx,modely,'linewidth',2,'color',[.7 .7 .7]),hold on;
                xlabel('Velocity (ms^{-1})');
                ylabel('Depth (m)');
                xlim([velmin velmax]);
                ylim([depthmin depthmax]);
                set(Handle, 'YDir','reverse')
                set(Handle,'FontSize',12) 
            end;
        
            sel=Selection(fit,pop);%Selection
            cross=Crossover(sel);%CrossOver
            mut=Mutation(cross,.007);%Mutation
            pop=[elite;mut(1:PopNum-1,:)]; %Elitism and new population
            gof(1,jm)=min(goodnessFit);
        
            sel=[];cross=[];mut=[];
        
            fdb_inc=fdb_inc+fdb_count;
            waitbar(fdb_inc,fp,sprintf('Progress: %d %%, (%d in %d)', floor(jm/(IterNum)*100),j,InvNum));
        end        
        close(fp); 
    end;
end