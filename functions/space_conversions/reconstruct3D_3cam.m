function [X, C_X] = reconstruct3D_3cam(x1, x2, x3, P1, P2, P3, C_x)
% Reconstructs 3D-state of an object detected at coordinates x1 in image 1,
% coordinates x2 in image 2 and coordinates x3 in image 3. Camera
% calibration matrices are P1, P2 and P3.
% 
% Inputs:   x1:     2xN matrix, coordinates of N points in first image [x;y]
%           x2:     2xN matrix, coordinates of N points in second image [x;y]
%           x3:     2xN matrix, coordinates of N points in third image [x;y]
%           P1:     3x4 camera calibration matrix of first camera
%           P2:     3x4 camera calibration matrix of second camera
%           P3:     3x4 camera calibration matrix of third cameras
%           C_x:    Scalar. Uncertainty (variance) of coordinates expressed
%                   in pixels
% 
% Outputs:  X:      3xN vector, estimated coordinates of N points in 3D
%                   [x;y;z]
%           C_X:    3x3xN matrix, estimation uncertainty (variance) of N
%                   points

nrPts = size(x1,2);

%pre-defines variables
X = zeros(3,nrPts);
C_X = zeros(3,3,nrPts);

%3D-estimation
for i=1:nrPts
    H_3D = [x1(1,i) * P1(3,1:3) - P1(1,1:3) ; ...
            x1(2,i) * P1(3,1:3) - P1(2,1:3) ; ...
            x2(1,i) * P2(3,1:3) - P2(1,1:3) ; ...
            x2(2,i) * P2(3,1:3) - P2(2,1:3) ; ...
            x3(1,i) * P3(3,1:3) - P3(1,1:3) ; ...
            x3(2,i) * P3(3,1:3) - P3(2,1:3) ];
    z = [   P1(1,4) - x1(1,i) * P1(3,4) ; ...
            P1(2,4) - x1(2,i) * P1(3,4) ; ...
            P2(1,4) - x2(1,i) * P2(3,4) ; ...
            P2(2,4) - x2(2,i) * P2(3,4) ; ...
            P3(1,4) - x3(1,i) * P3(3,4) ; ...
            P3(2,4) - x3(2,i) * P3(3,4) ];
        
    X(:,i) = (H_3D'*H_3D)\H_3D'*z;
    
    Ct = C_x * diag([P1(3,4), P1(3,4), P2(3,4), P2(3,4), P3(3,4), P3(3,4)]).^2 + ...
         C_x * diag([P1(3,1:3); P1(3,1:3); P2(3,1:3); P2(3,1:3); P3(3,1:3); P3(3,1:3)] * X(:,i)).^2;
    C_X(:,:,i) = inv(H_3D'/Ct*H_3D);   
end

         