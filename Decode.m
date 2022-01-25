function output=Decode(Pop,Lim1,Lim2)
% Pop   : Population Matrix
% Lim1  : Lower limits for model parameters
% Lim2  : Upper limits for model parameters
    val=2.^((size(Pop,2)-1)-abs(0:size(Pop,2)-1));
    for l=1:size(Pop,1)
        Tx(l,:)=val.*Pop(l,:);
    end;
    dx=(Lim2-Lim1)/(2.^size(Pop,2)-1);
    output=Lim1+dx*(sum(Tx'));
end

