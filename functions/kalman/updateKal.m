function Kal = updateKal(Kal, i)
% Performs the Kalman update, updating the current state estimation and the
% state prediction for the next frame.
% 
% Inputs:   Kal:    The Kalman filter structure
%           i:      The current frame number
% 
% Outputs:  Kal:    The updated Kalman structure
% 

%estimation step
Kal.Cest(:,:,i) = inv( inv(Kal.Cpred(:,:,i)) + Kal.H(:,:,i)'/Kal.Cn(:,:,i)*Kal.H(:,:,i) );
Kal.Xest(:,i)   = Kal.Cest(:,:,i) * (Kal.Cpred(:,:,i)\Kal.Xpred(:,i) ...
    + Kal.H(:,:,i)'/Kal.Cn(:,:,i)*Kal.z(:,i));
disp('Kal.Xest en Kal.Xpred');
[Kal.Xest(:,i),Kal.Xpred(:,i)]
%prediction step
Kal.Cpred(:,:,i+1)  = Kal.F*Kal.Cest(:,:,i)*Kal.F' + Kal.Cw;
Kal.Xpred(:,i+1)    = Kal.F*Kal.Xest(:,i);

disp('Kal.Xest en Kal.Xpred+1');
[Kal.Xest(:,i),Kal.Xpred(:,i+1)]
