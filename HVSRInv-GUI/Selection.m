function output = Selection(Fit,Pop)
%input parameters
%Fit    : Fitness values of the individuals
%Pop    : Population

m=0;
[fitb,x]=sort(Fit,'descend');
Fit=fitb*size(Pop,1)/sum(fitb);
fitt=round(Fit-.49);
fitk=Fit-fitt;
if sum(fitt)>=size(Pop,1)
    don=size(Pop,1);
else
    don=sum(fitt);
end

for is=1:don;
    output(is,:)=Pop(x(1,is-m),:);
    if sum(fitt(1,1:is-m))==is;
       m=m;
    else
       m=m+1;
    end
end
        
if size(output,1)<size(Pop,1)
    [yf,xf]=sort(Fit,'descend');
    for ih=1:size(Pop,1)-size(output,1)
       output(is+ih,:)=Pop(x(xf(ih)),:);
    end
end
end