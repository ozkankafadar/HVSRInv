function output=Decode(Population,LowerModelParam,UpperModelParam)
% B     : Matrix
% lim1  : Lower limits for model parameters
% lim2  : Upper limits for model parameters
    val=2.^((size(Population,2)-1)-abs(0:size(Population,2)-1));
    for l=1:size(Population,1)
        Tx(l,:)=val.*Population(l,:);
    end;
    dx=(UpperModelParam-LowerModelParam)/(2.^size(Population,2)-1);
    output=LowerModelParam+dx*(sum(Tx'));
end

