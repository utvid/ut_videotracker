function [PCs, PCunc] = twoDtoPCA_3cam(vec2D, unc2D, PCAmodel, Pstruct)
% Uses a LSE estimate to estimate the PCA score of a point configuration
% using the following model: A-B*Xmean = B*V*y such that A = B*X.
% Furthermore, calculates the uncertainty
% 
% Inputs:   vec2D:      6N vector, ordered like [x1; x2; x3; y1; y2; y3]
%           unc2D:      scalar, measurement uncertainty (variance!) assumed 
%                       equal everywhere
%           PCAmodel:   Structure containing PCA-related info, with at
%                       least the following variables:
%                       - meanShape:  3N vector, ordered like [X1;X2...XN;Y1;Y2...YN;Z1;Z2...ZN]
%                       - V:          3NxM coefficient vector
%           Pstruct:    Structure containing Pext: 9Nx4N matrix for 
%                       converting the complete 3D-set to 2D-images
% 
% Outputs:  PCs:        The resulting estimated PCA score (M elements)
%           PCunc:      The resulting MxM uncertainty matrix
% 

Pext = Pstruct.Pext;
Nx = length(vec2D)/6;
NX = size(PCAmodel.V,1)/3;
Xlen = 3*NX;
meanShape = PCAmodel.meanShape;
V = PCAmodel.V;

%calculate A and B such that A=B*X, where X is the 3D representation of the
%measured 2D points
P16_4 = Pext(1:6*Nx,      3*NX+1:4*NX);
P79_4 = Pext(6*Nx+1:9*Nx, 3*NX+1:4*NX);

A = sum(P16_4,2) - vec2D.*sum([P79_4; P79_4],2);

P16_13 = Pext(1:6*Nx,       1:3*NX);      
P79_13 = Pext(6*Nx+1:9*Nx,  1:3*NX);    

B = repmat(vec2D, 1, Xlen).*[P79_13; P79_13] - P16_13;
    
%calculates the z and H matrices such that z=H*y, y being the PCs
z = A-B*meanShape;
H = B*V;
pseudoInv = (H'*H)\H';

%calculate the principal components using a LSE estimate
PCs = pseudoInv*z;

%calculate the uncertainty using the pseudo-inverse
Ppart1 =    sum(    Pext(6*Nx+1:end, 3*NX+1:end), 2);
Ppart2 =            Pext(6*Nx+1:end, 1:3*NX);
Cn =    unc2D*diag([Ppart1;Ppart1]).^2 + ...
        unc2D*diag([Ppart2;Ppart2]*PCAmodel.meanShape).^2 + ...
        unc2D*diag([Ppart2;Ppart2]*PCAmodel.V*PCs).^2;

PCunc = pseudoInv*Cn*pseudoInv';