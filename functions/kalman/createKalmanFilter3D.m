function Kal = createKalmanFilter3D(markers,nrMarkers, Pstruct, frameRate, nrOfFrames,sigMeas,sigV)
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

Pext        = Pstruct.Pext;
% nrMarkers   = handles.nMar;
N           = 2*3*nrMarkers;
M           = 6*nrMarkers;
% nrOfFrames  = ObjM.NumberOfFrames;

% sigMeas = 10;    %measurement error expressed in pixels

%create state variables
Kal.meas     = zeros(N, nrOfFrames);
Kal.z        = zeros(N, nrOfFrames);
Kal.Xest     = zeros(M, nrOfFrames);
Kal.Xpred    = zeros(M, nrOfFrames);
Kal.Xest_b   = zeros(M, nrOfFrames);
Kal.Cest     = zeros(M, M, nrOfFrames);
Kal.Cpred    = zeros(M, M, nrOfFrames);
Kal.Cest_b   = zeros(M, M, nrOfFrames);
Kal.Cn       = zeros(N, N, nrOfFrames);

%initializes first measurement vector
measVecX = []; measVecY = [];
% for i=1:3
%     measVecX = [measVecX; handles.xm((i-1)*7+1:(i-1)*7+7)'];
%     measVecY = [measVecY; handles.ym((i-1)*7+1:(i-1)*7+7)'];
% end
Kal.meas(:,1) = markers;

%define measurement matrix, which is determined every new iteration
Kal.H = zeros(N, M, nrOfFrames);

%define measurement noise
Ppart1          = sum(Pext(N+1:end, 3*nrMarkers+1:end), 2);
Ppart2          = Pext(N+1:end, 1:3*nrMarkers);
Kal.CnBase      = sigMeas.^2*diag([Ppart1; Ppart1]).^2;
Kal.Cn(:,:,1)   = Kal.CnBase;
Kal.CnPart      = sigMeas*[Ppart2; Ppart2];    

%define process matrix
T = 1/frameRate;
Kal.F = eye(M); 
Kal.F(1:3*nrMarkers,3*nrMarkers+1:end) = T*eye(3*nrMarkers);

%define process noise
Kal.Cw = zeros(M);
if exist('sigV','var') ==1
    sigVx = sigV(1);
    sigVy = sigV(2);
    sigVz = sigV(3);
else
    sigVx = 25;
    sigVy = 25;
    sigVz = 25;
end
Kal.Cw(3*nrMarkers+1:end, 3*nrMarkers+1:end) = ...      %Only process noise is added to the velocity-part of the state vector
    diag([sigVx^2*ones(nrMarkers,1); sigVy^2*ones(nrMarkers,1); sigVz^2*ones(nrMarkers,1)]);

%perform initial prediction based on selected markers
Kal.Cest(:,:,1) = 1E10*eye(M);
Kal.Cpred(:,:,1) = 1E10*eye(M);
Kal.Cpred(:,:,2) = 1E10*eye(M);
% if settings.nrCam == 3
    [Kal.Xest(1:end/2,1), Kal.Cest(1:end/2,1:end/2,1)] = twoDto3D_3cam(Kal.meas(:,1), sigMeas^2, Pext);
    [Kal.Xpred(1:end/2,2), ~] = twoDto3D_3cam(Kal.meas(:,1), sigMeas^2, Pext); 
    [test1, test2, test3] = threeDto2D_3cam(Kal.Xest(1:end/2,1),Kal.Cest(1:end/2,1:end/2,1),Pstruct)
% else
%     [Kal.Xest(1:end/2,1), Kal.Cest(1:end/2,1:end/2,1)] = twoDto3D(Kal.meas(:,1), sigMeas^2, Pext);
%     [Kal.Xpred(1:end/2,2), ~] = twoDto3D(Kal.meas(:,1), sigMeas^2, Pext);        
% end