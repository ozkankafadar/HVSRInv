function [ x,y ] = SetArray( T,V,depthmax )

if length(T)<length(V)
    T(end+1)=0;
end;

j=1;
x(j)=V(1);
y(j)=0;
j=j+1;
x(j)=V(1);
y(j)=T(1);
j=j+1;
for i=2:length(V)
    x(j)=V(i);
    y(j)=y(j-1);
    j=j+1;
    x(j)=V(i);
    y(j)=y(j-1)+T(i);
    j=j+1;
end;

%y(j-1)=y(j-1)+sum(y)*2/100;
y(j-1)=depthmax;
end

