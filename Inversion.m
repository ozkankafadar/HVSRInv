function [parameters] = Inversion( layerNum,invNum,iterNum,popNum,geneNum,freqs,HVSR,freqMin,freqMax,sampleNum,initModData,handle)
% layerNum   : Number of layers
% invNumber  : Number of inversions
% iterNum    : Number of iterations
% geneNum    : number of genes
% popNum     : Number of Populations
% freqs      : Frequency array
% HVSR       : Horizontal-to-vertical spectral ratio data
% freqMin    : Mimimum frequency for analysis
% freqMax    : Maximum frequency for analysis
% sampleNum  : Number of samples
% initModData: Initial parameters for analysis
% handle     : Axes name
    param=zeros(layerNum*4-1,3);
    k=1;
    for i=1:layerNum
        S=initModData(i,:);    
        param(k,1)=S(3);param(k,2)=S(4);param(k,3)=geneNum;
        k=k+1;
        param(k,1)=S(5);param(k,2)=S(6);param(k,3)=geneNum;
        k=k+1;
        param(k,1)=S(7);param(k,2)=S(8);param(k,3)=geneNum;
        k=k+1;
        if i<layerNum
            param(k,1)=S(1);param(k,2)=S(2);param(k,3)=geneNum;
            k=k+1;
        end;
    end;

    minParam=param(:,1);
    maxParam=param(:,2);
    genePos=FindGenePos(param(:,3));
    freq=linspace(0,freqMax,sampleNum);    
    hvsr=interp1(freqs,HVSR,freq);
    
    [val,idx]=min(abs(freq-freqMin));
    point1=idx;    
    [val,idx]=min(abs(freq-freqMax));
    point2=idx;
    
    for j=1:invNum    
        rand('twister',sum(100*rand*clock));    
        pop=round(rand(popNum,max(genePos)));      
    
        fp = waitbar(0,'Please wait ...');
        fdb_count=1.0/(iterNum);
        fdb_inc=0;  
    
        for jm=1:iterNum        
            %High-order Mutation        
            if jm>=iterNum*0.3
                if sum(abs(diff(gof(1,jm-iterNum*0.1:jm-1))))<1e-4;
                    prob=rand(1,1);%Probability
                    newPop=Mutation(pop,prob);%New Population
                    pop=newPop;   
                end;
            end;
        
            %Decode Operation
            for jk=1:layerNum
                Velocity(jk,:)=round(Decode(pop(:,genePos(8*(jk-1)+1):genePos(8*(jk-1)+2)),minParam(4*(jk-1)+1),maxParam(4*(jk-1)+1)));
                Density(jk,:)=round(Decode(pop(:,genePos(8*(jk-1)+3):genePos(8*(jk-1)+4)),minParam(4*(jk-1)+2),maxParam(4*(jk-1)+2)),4);
                Damping(jk,:)=Decode(pop(:,genePos(8*(jk-1)+5):genePos(8*(jk-1)+6)),minParam(4*(jk-1)+3),maxParam(4*(jk-1)+3));
                if jk<layerNum
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
                end;            
            end;        
        
            if jm==iterNum
                results=zeros(layerNum,4);
                for i=1:layerNum                
                    if i<layerNum
                        results(i,1)=Thickness2(i);
                    else
                        results(i,1)=0;
                    end;
                    results(i,2)=Velocity2(i);
                    results(i,3)=Density2(i);
                    results(i,4)=Damping2(i); 
                end;
            
                velmin=0;
                velmax=initModData(end,4);
                depthmin=min(initModData(:,1));
                depthmax=sum(initModData(:,2));
        
                mm=1;
                for mr=1:layerNum
                    for o=1:4
                        parameters(j,mm)=results(mr,o);
                        mm=mm+1;
                    end;
                end;          
            
                [modelx,modely]=SetArray(Thickness2,Velocity2,depthmax);
            
                axes(handle);       
                plot(handle,modelx,modely,'linewidth',2,'color',[.7 .7 .7]),hold on;
                xlabel('Velocity (ms^{-1})');
                ylabel('Depth (m)');
                xlim([velmin velmax]);
                ylim([depthmin depthmax]);
                set(handle, 'YDir','reverse')
                set(handle,'FontSize',12) 
            end;
        
            sel=Selection(fit,pop);%Selection
            cross=Crossover(sel);%CrossOver
            mut=Mutation(cross,.007);%Mutation
            pop=[elite;mut(1:popNum-1,:)]; %Elitism and new population
            gof(1,jm)=min(goodnessFit);
        
            sel=[];cross=[];mut=[];
        
            fdb_inc=fdb_inc+fdb_count;
            waitbar(fdb_inc,fp,sprintf('Progress: %d %%, (%d in %d)', floor(jm/(iterNum)*100),j,invNum));
        end        
        close(fp); 
    end;
end