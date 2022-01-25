function output=CalcHVSR(Vel,Thi,Den,Damp,Freq)
% Vel  : Shear wave velocities of layers
% Thi  : Thicknesses of layers
% Den  : Densities of layers
% Damp : Damping ratios of layers
% Freq : Frequency array
    A=ones(1,length(Freq));B=A;
    for jm=1:length(Vel)-1
        a1=Den(jm,1);
        a2=Den(jm+1,1);   
        alfa(jm,1)=(a1*Vel(jm,1)*(1+1i*Damp(jm,1)))/(a2*Vel(jm+1,1)*(1+1i*Damp(jm+1,1))); 
        ksH(jm,:)=2*pi*Freq*Thi(jm,1)/(Vel(jm,1)+Damp(jm,1)*1i*Vel(jm,1));                            
        A(jm+1,:)=.5.*A(jm,:).*(1+alfa(jm,1)).*exp(1i*ksH(jm,:))+.5*B(jm,:).*(1-alfa(jm,1)).*exp(-1i*ksH(jm,:));
        B(jm+1,:)=.5.*A(jm,:).*(1-alfa(jm,1)).*exp(1i*ksH(jm,:))+.5*B(jm,:).*(1+alfa(jm,1)).*exp(-1i*ksH(jm,:));
    end
    output=(abs(1./A(jm+1,:)))';
end