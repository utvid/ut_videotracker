function [Kal] = prepareKalman3D(Kal, Pstruct, i)
% Prepares the Kalman filter for a Kalman update. For this purpose the
% vector z and matrix H are determined, describing the relation z=HX, X
% being the state vector
% 
% Inputs:   Kal:        The Kalman filter structure
%           Pstruct:    The structure containing the camera calibration
%                       matrices
%           i:          The frame number
% 
% Outputs:  Kal:        The updated Kalman filter structure
% 

Pext = Pstruct.Pext;

%pre-declaration of variables
N = size(Kal.Xest,1)/6;
Xlen = 3*N;

% if settings.nrCam == 2
%     %calculate the z- and H-matrices such that z=HX
%     P14_4 = Pext(1:4*N,     3*N+1:4*N);
%     P56_4 = Pext(4*N+1:6*N, 3*N+1:4*N);
% 
%     Kal.z(:,i) = sum(P14_4,2) - Kal.meas(:,i).*sum([P56_4; P56_4],2);
% 
%     P14_13 = Pext(1:4*N,        1:3*N);    
%     P56_13 = Pext(4*N+1:6*N,    1:3*N);    
% 
%     Htemp = repmat(Kal.meas(:,i), 1, Xlen).*[P56_13; P56_13] - P14_13;
%     Kal.H(:,:,i) = [Htemp, zeros(size(Htemp))];
% else
    %calculate the z- and H-matrices such that z=HX
    P16_4 = Pext(1:6*N,     3*N+1:4*N);
    P79_4 = Pext(6*N+1:9*N, 3*N+1:4*N);

    Kal.z(:,i) = sum(P16_4,2) - Kal.meas(:,i).*sum([P79_4; P79_4],2);

    P16_13 = Pext(1:6*N,        1:3*N);    
    P79_13 = Pext(6*N+1:9*N,    1:3*N);    

    Htemp = repmat(Kal.meas(:,i), 1, Xlen).*[P79_13; P79_13] - P16_13;
    Kal.H(:,:,i) = [Htemp, zeros(size(Htemp))];
% end

%refines measurement noise
XPred = Kal.Xpred(1:end/2, i);
Kal.Cn(:,:,i) = Kal.CnBase + diag(Kal.CnPart*XPred).^2;  