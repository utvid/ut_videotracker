function [Kal, Xest] = RTSsmoother(Kal, Pstruct)
% This function performs Rauch-Tung-Striebel smoothing on the Kalman
% filtering result. This updates the current frame-dependent state
% estimation such that the estimation is dependent on ALL measurements
% instead of only the preceding measurements.
% 
% Inputs:   Kal:        The Kalman filter structure
%           Xest_or:    The structure containing all states of the
%                       orientational markers. Must at least contain the
%                       .Rext-variable, which is the frame-dependent
%                       rotation matrix
%           PCAmodel:   The (unrotated) PCA model structure
%           Pstruct:    The structure containing the camera calibration
%                       matrices
%           settings:   The system settings
% 
% Outputs:  Kal:        The Kalman filter structure with updated state
%                       estimation
%           Xest:       The structure containing all representations, based
%                       on the updated Kalman filtered results
% 

endFrame = size(Kal.Xest,2);

Kal.Xest_b(:,endFrame) = Kal.Xest(:,endFrame);
Kal.Cest_b(:,:,endFrame) = .1*eye(size(Kal.Cest,1));
Xest = [];

for i = endFrame-1:-1:1
    %updates the smoothened Kalman state vector
    A                   = Kal.Cest(:,:,i)*Kal.F'/Kal.Cpred(:,:,i+1);
    Kal.Xest_b(:,i)     = Kal.Xest(:,i) + A * (Kal.Xest_b(:,i+1) - Kal.Xpred(:,i+1));
    Kal.Cest_b(:,:,i)   = Kal.Cest(:,:,i) + A * (Kal.Cest_b(:,:,i+1) - Kal.Cpred(:,:,i+1)) * A';
    
    %adapts PCAmodel 
%     PCAmodel_rot = PCAmodel;
%     PCAmodel_rot.V = Xest_or.Rext(:,:,i)*PCAmodel.V;
%     PCAmodel_rot.meanShape = Xest_or.Rext(:,:,i)*PCAmodel.meanShape;
    
    %updates state variables
    Xest = getAllRep(Xest, i, Kal.Xest_b(1:end/2,i), Kal.Cest_b(1:end/2,1:end/2,i), Pstruct);
end

