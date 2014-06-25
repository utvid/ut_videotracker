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

Pext        = utvid.Pstruct.Pext;
% nrMarkers   = handles.nMar;
N           = 2*3*utvid.settings.nrMarkers;
M           = 6*utvid.settings.nrMarkers;
nrOfFrames  = sum(utvid.Tracking.NoF);

% utvid.Tracking.sigMeas = 3;    %measurement error expressed in pixels

%create state variables
utvid.Tracking.Kal.meas     = zeros(N, nrOfFrames);
utvid.Tracking.Kal.z        = zeros(N, nrOfFrames);
utvid.Tracking.Kal.Xest     = zeros(M, nrOfFrames);
utvid.Tracking.Kal.Xpred    = zeros(M, nrOfFrames);
utvid.Tracking.Kal.Xest_b   = zeros(M, nrOfFrames);
utvid.Tracking.Kal.Cest     = zeros(M, M, nrOfFrames);
utvid.Tracking.Kal.Cpred    = zeros(M, M, nrOfFrames);
utvid.Tracking.Kal.Cest_b   = zeros(M, M, nrOfFrames);
utvid.Tracking.Kal.Cn       = zeros(N, N, nrOfFrames);

%initializes first measurement vector
measVecX = []; measVecY = [];
% for i=1:3
%     measVecX = [measVecX; handles.xm((i-1)*7+1:(i-1)*7+7)'];
%     measVecY = [measVecY; handles.ym((i-1)*7+1:(i-1)*7+7)'];
% end
i = utvid.Tracking.instr; % eerste filmpje 
utvid.Tracking.Kal.meas(:,1) = [utvid.coords.shape.left.x(:,i);utvid.coords.shape.right.x(:,i);...
    utvid.coords.shape.center.x(:,i);utvid.coords.shape.left.y(:,i);utvid.coords.shape.right.y(:,i);...
    utvid.coords.shape.center.y(:,i)];

%define measurement matrix, which is determined every new iteration
utvid.Tracking.Kal.H = zeros(N, M, nrOfFrames);

%define measurement noise
Ppart1          = sum(Pext(N+1:end, 3*utvid.settings.nrMarkers+1:end), 2);
Ppart2          = Pext(N+1:end, 1:3*utvid.settings.nrMarkers);
utvid.Tracking.Kal.CnBase      = utvid.Tracking.sigMeas.^2*diag([Ppart1; Ppart1]).^2;
utvid.Tracking.Kal.Cn(:,:,1)   = utvid.Tracking.Kal.CnBase;
utvid.Tracking.Kal.CnPart      = utvid.Tracking.sigMeas*[Ppart2; Ppart2];    

%define process matrix
T = 1/utvid.Tracking.FrameRate;
utvid.Tracking.Kal.F = eye(M); 
utvid.Tracking.Kal.F(1:3*utvid.settings.nrMarkers,3*utvid.settings.nrMarkers+1:end) = T*eye(3*utvid.settings.nrMarkers);

%define process noise
utvid.Tracking.Kal.Cw = zeros(M);

utvid.Tracking.Kal.Cw(3*utvid.settings.nrMarkers+1:end, 3*utvid.settings.nrMarkers+1:end) = ...      %Only process noise is added to the velocity-part of the state vector
    diag([utvid.Tracking.sigVx^2*ones(utvid.settings.nrMarkers,1); utvid.Tracking.sigVy^2*ones(utvid.settings.nrMarkers,1); utvid.Tracking.sigVz^2*ones(utvid.settings.nrMarkers,1)]);

%perform initial prediction based on selected markers
utvid.Tracking.Kal.Cest(:,:,1) = 1E10*eye(M);
utvid.Tracking.Kal.Cpred(:,:,1) = 1E10*eye(M);
utvid.Tracking.Kal.Cpred(:,:,2) = 1E10*eye(M);

if utvid.settings.nrcams == 3
    [utvid.Tracking.Kal.Xest(1:end/2,1), utvid.Tracking.Kal.Cest(1:end/2,1:end/2,1)] = twoDto3D_3cam(utvid.Tracking.Kal.meas(:,1), utvid.Tracking.sigMeas^2, Pext);
    [utvid.Tracking.Kal.Xpred(1:end/2,2), ~] = twoDto3D_3cam(utvid.Tracking.Kal.meas(:,1), utvid.Tracking.sigMeas^2, Pext); 
else
    [utvid.Tracking.Kal.Xest(1:end/2,1), utvid.Tracking.Kal.Cest(1:end/2,1:end/2,1)] = twoDto3D(utvid.Tracking.Kal.meas(:,1), utvid.Tracking.sigMeas^2, Pext);
    [utvid.Tracking.Kal.Xpred(1:end/2,2), ~] = twoDto3D(utvid.Tracking.Kal.meas(:,1), utvid.Tracking.sigMeas^2, Pext);        
end

end