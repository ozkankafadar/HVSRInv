function [ x,y ] = SetArray( Thickness,Velocity,depthmax )
% T          : Thickness array
% V          : Velocity array
% depthmax   : Maximum depth
    if length(Thickness)<length(Velocity)
        Thickness(end+1)=0;
    end;
    j=1;
    x(j)=Velocity(1);
    y(j)=0;
    j=j+1;
    x(j)=Velocity(1);
    y(j)=Thickness(1);
    j=j+1;
    for i=2:length(Velocity)
        x(j)=Velocity(i);
        y(j)=y(j-1);
        j=j+1;
        x(j)=Velocity(i);
        y(j)=y(j-1)+Thickness(i);
        j=j+1;
    end;
    y(j-1)=depthmax;
end