function output=GoodnessofFit(SynData,ObsData)
% SynData  : Synthetic Data
% ObsData  : Observed Data
    if size(ObsData,2)>1
        if size(ObsData,1)>1
            error('Invalid Format');
        else
            ObsData=ObsData';
        end;
    end;

    for in=1:length(ObsData)
        y(in,:)=(SynData(in,:)-ObsData(in,1));
    end;

    if length(ObsData)==1
        output=sqrt((y.^2)/length(ObsData));
    else
        output=sqrt(sum(y.^2)/length(ObsData));
    end;
end