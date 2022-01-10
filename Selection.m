function output = Selection(Fitness,Population)
%Fit    : Fitness values of the individuals
%Pop    : Population
    m=0;
    [fitb,x]=sort(Fitness,'descend');
    Fitness=fitb*size(Population,1)/sum(fitb);
    fitt=round(Fitness-.49);

    if sum(fitt)>=size(Population,1)
        don=size(Population,1);
    else
        don=sum(fitt);
    end;

    for is=1:don;
        output(is,:)=Population(x(1,is-m),:);
        if sum(fitt(1,1:is-m))==is;
        else
            m=m+1;
        end;
    end;
        
    if size(output,1)<size(Population,1)
        [yf,xf]=sort(Fitness,'descend');
        for ih=1:size(Population,1)-size(output,1)
            output(is+ih,:)=Population(x(xf(ih)),:);
        end;
    end;
end