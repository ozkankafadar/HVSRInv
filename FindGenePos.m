function output=FindGenePos(Position)
% C : Position vector
    if size(Position,2)>1
        Position=[0;Position'];
    else
        Position=[0;Position];
    end;
    for m=1:length(Position)-1
        output(2*m-1)=sum(Position(1:m))+1;
        output(2*m)=sum(Position(1:m+1));
    end;
end
