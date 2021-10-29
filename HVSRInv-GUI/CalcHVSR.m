function output=CalcHVSR(V,T,Den,Damp,Freq)
% This function calculates the site response
% using the Equivalent Linear Approximation
% V    : Shear wave velocities of layers
% T    : Thicknesses of layers
% Den  : Densities of layers
% Damp : Damping ratios of layers
% Freq : Frequency array

A=ones(1,length(Freq));B=A;
for jm=1:length(V)-1
   a1=Den(jm,1);
   a2=Den(jm+1,1);   
   alfa(jm,1)=(a1*V(jm,1)*(1+1i*Damp(jm,1)))/(a2*V(jm+1,1)*(1+1i*Damp(jm+1,1))); 
   ksH(jm,:)=2*pi*Freq*T(jm,1)/(V(jm,1)+Damp(jm,1)*1i*V(jm,1));                            
   A(jm+1,:)=.5.*A(jm,:).*(1+alfa(jm,1)).*exp(1i*ksH(jm,:))+.5*B(jm,:).*(1-alfa(jm,1)).*exp(-1i*ksH(jm,:));
   B(jm+1,:)=.5.*A(jm,:).*(1-alfa(jm,1)).*exp(1i*ksH(jm,:))+.5*B(jm,:).*(1+alfa(jm,1)).*exp(-1i*ksH(jm,:));
end
output=(abs(1./A(jm+1,:)))';