function [vec3D, unc3D] = twoDto3D_3cam(vec2D, unc2D, Pext)
% Uses a LSE estimate to estimate the PCA score of a point configuration
% using the following model: A-B*Xmean = B*V*y such that A = B*X.
% Furthermore, calculates the uncertainty.
% 
% Inputs:   vec2D:      6N vector, ordered like [x1; x2; x3; y1; y2; y3]
%           unc2D:      scalar, measurement uncertainty (variance!) assumed 
%                       equal everywhere
%           Pext:       9Nx4N matrix for converting the complete 3D-set to 2D-images
% 
% Outputs:  vec3D:      3xN matrix, ordered like [X; Y; Z]
%           unc3D:      3x3xN uncertainty matrix
% 

Nx= length(vec2D)/6;
NX = Nx;
Xlen = 3*NX;

%calculate z and H such that z=H*X, where X is the 3D representation of the
%measured 2D points
P16_4 = Pext(1:6*Nx,      3*NX+1:4*NX);
P79_4 = Pext(6*Nx+1:9*Nx, 3*NX+1:4*NX);

z = sum(P16_4,2) - vec2D.*sum([P79_4; P79_4],2);
   
P16_13 = Pext(1:6*Nx,       1:3*NX);      
P79_13 = Pext(6*Nx+1:9*Nx,  1:3*NX);    

H = repmat(vec2D, 1, Xlen).*[P79_13; P79_13] - P16_13;
    
%calculates the z and H matrices such that z=H*X, X being the PCs
pseudoInv = (H'*H)\H';

%calculate the principal components using a LSE estimate
vec3D = pseudoInv*z;

%calculate the uncertainty using the pseudo-inverse
Ppart1 =    sum(    Pext(6*Nx+1:end, 3*NX+1:end), 2);
Ppart2 =            Pext(6*Nx+1:end, 1:3*NX);
Cn =    unc2D*diag([Ppart1;Ppart1]).^2 + ...
        unc2D*diag([Ppart2;Ppart2]*vec3D).^2;

unc3D = pseudoInv*Cn*pseudoInv';