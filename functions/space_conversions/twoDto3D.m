function [vec3D, unc3D] = twoDto3D(vec2D, unc2D, Pext)
% Uses a LSE estimate to estimate the PCA score of a point configuration
% using the following model: A-B*Xmean = B*V*y such that A = B*X.
% Furthermore, calculates the uncertainty.
% 
% Inputs:   vec2D:      4N vector, ordered like [x1; x2; y1; y2]
%           unc2D:      scalar, measurement uncertainty (variance!) assumed 
%                       equal everywhere
%           Pext:       6Nx4N matrix for converting the complete 3D-set to 2D-images
% 
% Outputs:  vec3D:      3xN matrix, ordered like [X; Y; Z]
%           unc3D:      3x3xN uncertainty matrix
% 

N = length(vec2D)/4;
Xlen = 3*N;

%calculate z and H such that z=H*X, where X is the 3D representation of the
%measured 2D points
P14_4 = Pext(1:4*N,     3*N+1:4*N);
P56_4 = Pext(4*N+1:6*N, 3*N+1:4*N);

z = sum(P14_4,2) - vec2D.*sum([P56_4; P56_4],2);

P14_13 = Pext(1:4*N,        1:3*N);    
P56_13 = Pext(4*N+1:6*N,    1:3*N);    

H = repmat(vec2D, 1, Xlen).*[P56_13; P56_13] - P14_13;
    
%calculates the z and H matrices such that z=H*X, X being the PCs
pseudoInv = (H'*H)\H';

%calculate the principal components using a LSE estimate
vec3D = pseudoInv*z;

%calculate the uncertainty using the pseudo-inverse
Ppart1 =    sum(    Pext(4*N+1:end, 3*N+1:end), 2);
Ppart2 =            Pext(4*N+1:end, 1:3*N);
Cn =    unc2D*diag([Ppart1;Ppart1]).^2 + ...
        unc2D*diag([Ppart2;Ppart2]*vec3D).^2;

unc3D = pseudoInv*Cn*pseudoInv';