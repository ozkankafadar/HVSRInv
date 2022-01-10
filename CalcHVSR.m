function output=CalcHVSR(Velocity,Thickness,Density,DampingRatio,Freqs)
% V    : Shear wave velocities of layers
% T    : Thicknesses of layers
% Den  : Densities of layers
% Damp : Damping ratios of layers
% Freq : Frequency array
    A=ones(1,length(Freqs));B=A;
    for jm=1:length(Velocity)-1
        a1=Density(jm,1);
        a2=Density(jm+1,1);   
        alfa(jm,1)=(a1*Velocity(jm,1)*(1+1i*DampingRatio(jm,1)))/(a2*Velocity(jm+1,1)*(1+1i*DampingRatio(jm+1,1))); 
        ksH(jm,:)=2*pi*Freqs*Thickness(jm,1)/(Velocity(jm,1)+DampingRatio(jm,1)*1i*Velocity(jm,1));                            
        A(jm+1,:)=.5.*A(jm,:).*(1+alfa(jm,1)).*exp(1i*ksH(jm,:))+.5*B(jm,:).*(1-alfa(jm,1)).*exp(-1i*ksH(jm,:));
        B(jm+1,:)=.5.*A(jm,:).*(1-alfa(jm,1)).*exp(1i*ksH(jm,:))+.5*B(jm,:).*(1+alfa(jm,1)).*exp(-1i*ksH(jm,:));
    end
    output=(abs(1./A(jm+1,:)))';
end