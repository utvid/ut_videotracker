function [PCAmodel_rot, Rext] = rotatePCA(PCAmodel, X, nMar,n)
% This function performs a rotation of the PCA model such that its
% orientation matches the one as measured in the current frames. Note that
% no translation is performed, as the translation vector can be freely
% determined by the estimation step.
% 
% Inputs:   PCAmodel:   The to-be-rotated PCA model structure
%           vecRot:     3xM matrix, defining the 3D coordinates of the
%                       M facial markers of the current frame
%           settings:   The settings of the system
% 
% Outputs:  PCAmodel_rot:   A rotated copy of the PCA model structure
%           Rext:           NxN matrix, defining the transformation of the
%                           3D coordinates resulting from 'PCAmodel'
%                           towards the 'PCAmodel_rot' coordinates
% 
% % % % or = X(:,:,1)'; new  = X(:,:,n)';
or = X(:,:,1); new  = X(:,:,n);
T  = rigid_transform_3D(new,or); R = T(1:3,1:3);
Rext = getRext(R, nMar);    
PCAmodel_rot = PCAmodel;
PCAmodel_rot.meanShape = Rext*PCAmodel_rot.meanShape;
PCAmodel_rot.V = Rext*PCAmodel_rot.V;