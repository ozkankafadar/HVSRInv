function output=GoodnessofFit(Syn,Obs)
% This function calculates the fit between the observed
% and synthetic data
% Syn : Synthetic Data
% Obs  : Real Data
% Y1 : Goodness of Fit

if size(Obs,2)>1
   if size(Obs,1)>1
      error('Invalid Format');
   else
      Obs=Obs';
   end
end

for in=1:length(Obs)
   y(in,:)=(Syn(in,:)-Obs(in,1));
end

if length(Obs)==1
   output=sqrt((y.^2)/length(Obs));
else
   output=sqrt(sum(y.^2)/length(Obs));
end
