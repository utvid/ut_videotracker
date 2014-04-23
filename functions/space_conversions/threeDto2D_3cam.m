function [pts2D_1, pts2D_2, pts2D_3, unc2D_1, unc2D_2, unc2D_3] = threeDto2D_3cam(vec3D, unc3D, Pstruct)

% Function calculating a 2D representation given a 3D representation
% 
% Inputs:   vec3D:      3Nx1 vector, representing the 3D coordinates.
%                       Structure: [Xvec; Yvec; Zvec]
%           unc3D:      3Nx3N vector, representing the 3D uncertainty.
%           Pstruct:    Structure containing the P-matrices
% 
% Outputs:  pts2D_1:    2xN matrix, the marker coordinates in the first
%                       image
%           pts2D_2:    2xN matrix, the marker coordinates in the second
%                       image
%           pts2D_3:    2xN matrix, the marker coordinates in the third
%                       image
%           unc2D_1:    2x2xN uncertainty of pts2D_1 matrix
%           unc2D_2:    2x2xN uncertainty of pts2D_2 matrix
%           unc2D_3:    2x2xN uncertainty of pts2D_3 matrix
% 

Pext = Pstruct.Pext;
P1 = Pstruct.P{1};
P2 = Pstruct.P{2};
P3 = Pstruct.P{3};

N = size(vec3D,1)/3;

%calculate 2D points
vec3D_h = nonhomoToHomo(vec3D, '3D');
vec2D_h = Pext*vec3D_h;
vec2D = homoToNonhomo(vec2D_h, '2D');

pts2D_1(1,:) = vec2D(1:N);
pts2D_2(1,:) = vec2D(N+1:2*N);
pts2D_3(1,:) = vec2D(2*N+1:3*N);
pts2D_1(2,:) = vec2D(3*N+1:4*N);
pts2D_2(2,:) = vec2D(4*N+1:5*N);
pts2D_3(2,:) = vec2D(5*N+1:end);

%calculate 2D uncertainty
unc2D_1 = zeros(2,2,N);
unc2D_2 = zeros(2,2,N);
unc2D_3 = zeros(2,2,N);
for i=1:N
    X = vec3D([i, N+i, 2*N+i]);
    unc3Dpart = unc3D([i, i+N, i+2*N], [i, i+N, i+2*N]);
    unc2D_1(:,:,i) = uncertainty3Dto2D(unc3Dpart, P1, X);
    unc2D_2(:,:,i) = uncertainty3Dto2D(unc3Dpart, P2, X);
    unc2D_3(:,:,i) = uncertainty3Dto2D(unc3Dpart, P3, X);    
end