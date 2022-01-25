function output=FindGenePos(Pos)
%Pos : Position vector
    if size(Pos,2)>1
        Pos=[0;Pos'];
    else
        Pos=[0;Pos];
    end;
    for m=1:length(Pos)-1
        output(2*m-1)=sum(Pos(1:m))+1;
        output(2*m)=sum(Pos(1:m+1));
    end;
end
