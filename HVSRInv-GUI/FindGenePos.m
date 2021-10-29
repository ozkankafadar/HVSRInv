function output=FindGenePos(C)
% This function finds the gene positions 
% C : Position vector

if size(C,2)>1
   C=[0;C'];
else
   C=[0;C];
end
for m=1:length(C)-1
   output(2*m-1)=sum(C(1:m))+1;
   output(2*m)=sum(C(1:m+1));
end
