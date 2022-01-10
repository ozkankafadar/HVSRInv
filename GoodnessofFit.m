function output=GoodnessofFit(SyntheticData,ObservedData)
% Syn  : Synthetic Data
% Obs  : Observed Data
    if size(ObservedData,2)>1
        if size(ObservedData,1)>1
            error('Invalid Format');
        else
            ObservedData=ObservedData';
        end;
    end;

    for in=1:length(ObservedData)
        y(in,:)=(SyntheticData(in,:)-ObservedData(in,1));
    end;

    if length(ObservedData)==1
        output=sqrt((y.^2)/length(ObservedData));
    else
        output=sqrt(sum(y.^2)/length(ObservedData));
    end;
end