function [Pstruct, Pstruct_or] = getPstruct(mov, utvid)
% Function loading the calibration matrices and constructing a larger form
% of it needed for the Kalman filter and 3D reconstruction in general
% 
% Inputs:   mov:        Cell array containing the movies.
%           settings:   The system settings structure.
% 
% Outputs:  Pstruct:    Structure containing the following elements:
%                       - P:    Cell array containing the 3x4 calibration
%                               matrices of each (2 or 3) camera
%                       - Pext: Larger version of the calibration matrices
%                               such that u_h=Pext*U_h, where u_h is the
%                               vector containing the homogeneous 2D image 
%                               coordinates and U_h the homogeneous 3D
%                               coordinates
%           Pstruct_or: Similar to Pstruct, but having a different Pext
%                       matrix, as this is the version used for the facial
%                       markers

nrCam        = utvid.settings.nrcams;
try
nrMarkers    = utvid.coords.nMar;
nrMarkers_or = utvid.coords.nOrMar;
catch 
    disp('using defaults');
    nrMarkers = 10;
    nrMarkers_or = 6;
end

%creation of Pext is performed in four steps, each step creating only a
%fourth part of the matrix
Pext    = zeros(3*nrCam*nrMarkers,4*nrMarkers);
Pext_or = zeros(3*nrCam*nrMarkers_or,   4*nrMarkers_or);
for i=1:4
    %in the case of 2 cameras
    if nrCam == 2
        Ptemp = [   mov{1}.P(1,i)*eye(nrMarkers); ...
                    mov{2}.P(1,i)*eye(nrMarkers); ...
                    mov{1}.P(2,i)*eye(nrMarkers); ...
                    mov{2}.P(2,i)*eye(nrMarkers); ...
                    mov{1}.P(3,i)*eye(nrMarkers); ...
                    mov{2}.P(3,i)*eye(nrMarkers)];
        Ptemp_or = [mov{1}.P(1,i)*eye(nrMarkers_or); ...
                    mov{2}.P(1,i)*eye(nrMarkers_or); ...
                    mov{1}.P(2,i)*eye(nrMarkers_or); ...
                    mov{2}.P(2,i)*eye(nrMarkers_or); ...
                    mov{1}.P(3,i)*eye(nrMarkers_or); ...
                    mov{2}.P(3,i)*eye(nrMarkers_or)];
    %in the case of 3 cameras
    elseif nrCam == 3
        Ptemp = [   mov{1}.P(1,i)*eye(nrMarkers); ...
                    mov{2}.P(1,i)*eye(nrMarkers); ...
                    mov{3}.P(1,i)*eye(nrMarkers); ...
                    mov{1}.P(2,i)*eye(nrMarkers); ...
                    mov{2}.P(2,i)*eye(nrMarkers); ...
                    mov{3}.P(2,i)*eye(nrMarkers); ...
                    mov{1}.P(3,i)*eye(nrMarkers); ...
                    mov{2}.P(3,i)*eye(nrMarkers); ...
                    mov{3}.P(3,i)*eye(nrMarkers)];
        Ptemp_or = [mov{1}.P(1,i)*eye(nrMarkers_or); ...
                    mov{2}.P(1,i)*eye(nrMarkers_or); ...
                    mov{3}.P(1,i)*eye(nrMarkers_or); ...
                    mov{1}.P(2,i)*eye(nrMarkers_or); ...
                    mov{2}.P(2,i)*eye(nrMarkers_or); ...
                    mov{3}.P(2,i)*eye(nrMarkers_or); ...
                    mov{1}.P(3,i)*eye(nrMarkers_or); ...
                    mov{2}.P(3,i)*eye(nrMarkers_or); ...
                    mov{3}.P(3,i)*eye(nrMarkers_or)];
    end
    Pext(   :, nrMarkers*(i-1)+1:nrMarkers*i)       = Ptemp;
    Pext_or(:, nrMarkers_or*(i-1)+1:nrMarkers_or*i) = Ptemp_or;
end

%saves the standard P-matrices
for i=1:nrCam
    Pstruct.P{i} = mov{i}.P;
end
Pstruct_or = Pstruct;
Pstruct.Pext    = Pext;
Pstruct_or.Pext = Pext_or; 