function utvid = PCAmodelUpdate(utvid)
%construct PCA model (if enough measurements in training set)
utvid.pca.PCAmodel = getPCAmodel(utvid.pca.PCAcoords);

% Rotate PCA model, when using orientation markers
if utvid.nOrMar ~= 0
    [utvid.pca.PCAmodel_rot, utvid.pca.R_init] = rotatePCA(PCAmodel_red, Xinit_or, settings);
else
    utvid.pca.PCAmodel_rot = PCAmodel; utvid.Tracking.R_init = eye(3);
end

end