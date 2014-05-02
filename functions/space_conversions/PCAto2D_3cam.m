function [pts2D_1, pts2D_2, pts2D_3, unc2D_1, unc2D_2, unc2D_3] = PCAto2D_3cam(vec, unc, PCAmodel, Pstruct)
% Function which calculates the 2D image coordinates given a PCA state.
% 
% Inputs:   vec:    M element vector containing PCA components
%           unc:    MxM matrix containing PCA uncertainty
%           PCAmodel: PCA model
% 
% Outputs:  pts2D_1:    2xN matrix containing 3D representation [x1; y1];
%           pts2D_2:    2xN matrix containing 3D representation [x2; y2];
%           pts2D_3:    2xN matrix containing 3D representation [x3; y3];
%           unc2D_1:    2x2xN matrix containing 3D uncertainty
%           unc2D_2:    2x2xN matrix containing 3D uncertainty
%           unc2D_3:    2x2xN matrix containing 3D uncertainty
% 

%calculate 2D points and -uncertainty
vec3D = PCAmodel.meanShape + PCAmodel.V*vec;
unc3D = PCAmodel.V*unc*PCAmodel.V';
[pts2D_1, pts2D_2, pts2D_3, unc2D_1, unc2D_2, unc2D_3] = threeDto2D_3cam(vec3D, unc3D, Pstruct);