function output=Crossover(Population)
% A : Input Matrix
    for m=1:size(Population,1)/2
        output(2*m-1,1:2:size(Population,2))=Population(2*m-1,1:2:size(Population,2));
        output(2*m-1,2:2:size(Population,2))=Population(2*m,2:2:size(Population,2));
        output(2*m,1:2:size(Population,2))=Population(2*m,1:2:size(Population,2));
        output(2*m,2:2:size(Population,2))=Population(2*m-1,2:2:size(Population,2));
    end;
end