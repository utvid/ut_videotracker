function utvid = createKalmanFilter3D(utvid)
% Creates a Kalman filter structure when using a state vector based on 3D 
% coordinates.
% 
% Inputs:   markerSets: 2- or 3-element cell array containing a set of
%                       markers (among which templates)
%           Pstruct:    Structure containing the camera calibration
%                       information.
%           frameRate:  The frame rate of the used camera's in Hz
%           settings:   The system settings
% 
% Outputs:  Kal:        A structure containing the following variables:
% 
%                       - meas:     NxF matrix, measured 2D coordinates
%                       - z:        NxF matrix, modified measurements such
%                                   that z=HX, where X the nonhomogeneous 
%                                   3D coordinate vector
%                       - H:        NxMxF matrix, see z
%                       - Cn:       NxN matrix, modeling measurement noise
%                       - CnBase:   NxN matrix, modeling (non-time-dependent) part of the measurement noise
%                       - CnPart:   NxL matrix, containing information to complete the time-dependent part of the measurement noise
%                       - F:        MxM matrix, system matrix
%                       - Cw:       MxM matrix, modeling system noise
%                       - Xest:     MxF matrix, estimated state vector
%                       - Xpred:    MxF+1 matrix, predicted state vector
%                       - Xest_b:   MxF matrix, Rauch-Tung-Striebel-filtered
%                                   state vector
%                       - Cest:     MxMxF matrix, estimation uncertainty
%                       - Cpred:    MxMxF+1 matrix, prediction uncertainty
%                       - Cest_b:   MxMxF matrix, Rauch-Tung-Striebel-filtered
%                                   estimation uncertainty
%                       
%                       Here:       N = 2*nrCam*nrMarkers
%                                   M = 6*nrMarkers
%                                   F = nrOfFrames
%                                   L = 3*nrMarkers
% 

Pext        = utvid.Pstruct_or.Pext;
% nrMarkers   = handles.nMar;
N           = 2*3*utvid.settings.nrOrMar;
M           = 6*utvid.settings.nrOrMar;
% nrOfFrames  = ObjM.NumberOfFrames;

% utvid.Tracking.sigMeas = 3;    %measurement error expressed in pixels

%create state variables
utvid.Tracking.Kal_or.meas     = zeros(N, utvid.Tracking.NoF);
utvid.Tracking.Kal_or.z        = zeros(N, utvid.Tracking.NoF);
utvid.Tracking.Kal_or.Xest     = zeros(M, utvid.Tracking.NoF);
utvid.Tracking.Kal_or.Xpred    = zeros(M, utvid.Tracking.NoF);
utvid.Tracking.Kal_or.Xest_b   = zeros(M, utvid.Tracking.NoF);
utvid.Tracking.Kal_or.Cest     = zeros(M, M, utvid.Tracking.NoF);
utvid.Tracking.Kal_or.Cpred    = zeros(M, M, utvid.Tracking.NoF);
utvid.Tracking.Kal_or.Cest_b   = zeros(M, M, utvid.Tracking.NoF);
utvid.Tracking.Kal_or.Cn       = zeros(N, N, utvid.Tracking.NoF);

%initializes first measurement vector
measVecX = []; measVecY = [];
% for i=1:3
%     measVecX = [measVecX; handles.xm((i-1)*7+1:(i-1)*7+7)'];
%     measVecY = [measVecY; handles.ym((i-1)*7+1:(i-1)*7+7)'];
% end

i = 1; % eerste filmpje nog aanpassen
utvid.Tracking.Kal_or.meas(:,1) = [utvid.coords.or.left.x(:,i);utvid.coords.or.right.x(:,i);...
    utvid.coords.or.center.x(:,i);utvid.coords.or.left.y(:,i);utvid.coords.or.right.y(:,i);...
    utvid.coords.or.center.y(:,i)];

%define measurement matrix, which is determined every new iteration
utvid.Tracking.Kal_or.H = zeros(N, M, utvid.Tracking.NoF);

%define measurement noise
Ppart1          = sum(Pext(N+1:end, 3*utvid.settings.nrOrMar+1:end), 2);
Ppart2          = Pext(N+1:end, 1:3*utvid.settings.nrOrMar);
utvid.Tracking.Kal_or.CnBase      = utvid.Tracking.sigMeas.^2*diag([Ppart1; Ppart1]).^2;
utvid.Tracking.Kal_or.Cn(:,:,1)   = utvid.Tracking.Kal_or.CnBase;
utvid.Tracking.Kal_or.CnPart      = utvid.Tracking.sigMeas*[Ppart2; Ppart2];    

%define process matrix
T = 1/utvid.Tracking.FrameRate;
utvid.Tracking.Kal_or.F = eye(M); 
utvid.Tracking.Kal_or.F(1:3*utvid.settings.nrOrMar,3*utvid.settings.nrOrMar+1:end) = T*eye(3*utvid.settings.nrOrMar);

%define process noise
utvid.Tracking.Kal_or.Cw = zeros(M);

utvid.Tracking.Kal_or.Cw(3*utvid.settings.nrOrMar+1:end, 3*utvid.settings.nrOrMar+1:end) = ...      %Only process noise is added to the velocity-part of the state vector
    diag([utvid.Tracking.sigVx^2*ones(utvid.settings.nrOrMar,1); ...
    utvid.Tracking.sigVy^2*ones(utvid.settings.nrOrMar,1); ...
    utvid.Tracking.sigVz^2*ones(utvid.settings.nrOrMar,1)]);

%perform initial prediction based on selected markers
utvid.Tracking.Kal_or.Cest(:,:,1) = 1E10*eye(M);
utvid.Tracking.Kal_or.Cpred(:,:,1) = 1E10*eye(M);
utvid.Tracking.Kal_or.Cpred(:,:,2) = 1E10*eye(M);

if utvid.settings.nrcams == 3
    [utvid.Tracking.Kal_or.Xest(1:end/2,1), utvid.Tracking.Kal_or.Cest(1:end/2,1:end/2,1)] = twoDto3D_3cam(utvid.Tracking.Kal_or.meas(:,1), utvid.Tracking.sigMeas^2, Pext);
    [utvid.Tracking.Kal_or.Xpred(1:end/2,2), ~] = twoDto3D_3cam(utvid.Tracking.Kal_or.meas(:,1), utvid.Tracking.sigMeas^2, Pext); 
else
    [utvid.Tracking.Kal_or.Xest(1:end/2,1), utvid.Tracking.Kal_or.Cest(1:end/2,1:end/2,1)] = twoDto3D(utvid.Tracking.Kal_or.meas(:,1), utvid.Tracking.sigMeas^2, Pext);
    [utvid.Tracking.Kal_or.Xpred(1:end/2,2), ~] = twoDto3D(utvid.Tracking.Kal_or.meas(:,1), utvid.Tracking.sigMeas^2, Pext);        
end

end