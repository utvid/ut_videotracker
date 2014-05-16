function utvid = PCAmodelUpdate(utvid)
%construct PCA model (if enough measurements in training set)
utvid = getPCAmodel(utvid);

% Rotate PCA model, when using orientation markers
if utvid.settings.nrOrMar ~= 0
    [utvid.pca.PCAmodel_rot, utvid.pca.R_init] = rotatePCA(utvid.pca, utvid.coords.Xinit_or, utvid.settings.nrMarkers, utvid.Tracking.n);
else
    utvid.pca.PCAmodel_rot = utvid.pca; utvid.pca.R_init = eye(3);
end

end