function utvid = Tracking(utvid,handles)
utvid.Tracking.n
%% Update PCA model (if enough measurements regarding number of Principal components)
if size(utvid.pca.PCAcoords,2) > 3*utvid.pca.PCs
    utvid = PCAmodelUpdate(utvid);
end

% Load and show corresponding frames
utvid = loadFrames(utvid,handles);

%Measurement
utvid = measurement(utvid);
%Outlier Detection

%Prepare and update Kalman
    
%Space representations Estimations

%PCA Expansion

%Space representations Prediction


end

