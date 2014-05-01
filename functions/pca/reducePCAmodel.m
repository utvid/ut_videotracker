function PCAmodel_red = reducePCAmodel(PCAmodel, settings)
% Reduces the set of PCA components for reduction of dimensionality by
% removing an amount of least significant eigenvectors of the V-matrix.
% Furthermore adds three translation vectors and possibly a scaling vector.
% 
% Inputs:   PCAmodel:       The current PCA model
%           settings:       The settings of the system
% 
% Outputs:  PCAmodel_red:   The resulting PCA model with less components
% 

if settings.allowPCAscaling
    %4 less 'free' components due to scaling and translation
    nrShapePCs = settings.nrPCs-4;

    %adapts PCA model
    onesVec = ones(settings.nrMarkers, 1);
    PCAmodel_red.eigVal = PCAmodel.eigVal(1:nrShapePCs);
    PCAmodel_red.meanShape = zeros(settings.nrMarkers*3,1);
    PCAmodel_red.V = [PCAmodel.V(:,1:nrShapePCs), blkdiag(onesVec, onesVec, onesVec), PCAmodel.meanShape];
else
    %3 less 'free' components due to translation
    nrShapePCs = settings.nrPCs-3;

    %adapts PCA model
    onesVec = ones(settings.nrMarkers, 1);
    PCAmodel_red.eigVal = PCAmodel.eigVal(1:nrShapePCs);
    PCAmodel_red.meanShape = PCAmodel.meanShape;
    PCAmodel_red.V = [PCAmodel.V(:,1:nrShapePCs), blkdiag(onesVec, onesVec, onesVec)];
end