function PCAmodel = getPCAmodel(utvid)
% Generates a PCA model of the markers on the tongue based on selected
% marker locations in various frames of the tongue. Method is based on
% taking several frames of a movie incorporating tongue motion. The
% selected points are loaded from memory, then converted to 3D, and finally
% normalized with respect to translation and orientation. Then, a PCA
% analysis generates the model.
% 
% Inputs:   settings:   The settings of the system
%           plotted:    If nonzero, plots the effect of varying the first
%                       four subtracted PCA components
% 
% Outputs:  PCAmodel:   The PCA model, including the following variables:
%                       - meanShape:    average shape of the trainingsset
%                       - V:            matrix of PCA vectors
%                       - y:            PCA component weights
%                       - eigVal:       Eigenvalues corresponding to the
%                                       PCA vectors
% 

%PCA component subtraction of the 3D tongue-shapes
utvid.pca.meanShape = mean(utvid.pca.PCAcoords,2);
%principal component subtraction
[utvid.pca.V, utvid.pca.y, utvid.pca.eigVal] = princomp(utvid.pca.PCAcoords'- repmat(utvid.pca.meanShape,1,size(utvid.pca.PCAcoords,2))','econ'); 
if size(PCAmodel.V,2)>handles.nrPCs
    PCAmodel.V = PCAmodel.V(:,1:handles.nrPCs);
end

end          