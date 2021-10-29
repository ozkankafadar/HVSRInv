function output=Decode(B,Lim1,Lim2)
% This function decodes the parameters
% B      : Matrix
% lim1  : Lower limits for parameters
% lim2  : Upper limits for parameters
val=2.^((size(B,2)-1)-abs(0:size(B,2)-1));
for l=1:size(B,1)
   Tx(l,:)=val.*B(l,:);
end
dx=(Lim2-Lim1)/(2.^size(B,2)-1);
output=Lim1+dx*(sum(Tx'));

