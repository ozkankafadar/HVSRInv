function output=Crossover(A)
% A : Input Matrix
    for m=1:size(A,1)/2
        output(2*m-1,1:2:size(A,2))=A(2*m-1,1:2:size(A,2));
        output(2*m-1,2:2:size(A,2))=A(2*m,2:2:size(A,2));
        output(2*m,1:2:size(A,2))=A(2*m,1:2:size(A,2));
        output(2*m,2:2:size(A,2))=A(2*m-1,2:2:size(A,2));
    end;
end