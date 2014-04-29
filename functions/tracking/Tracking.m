function utvid = Tracking(utvid)
utvid.Tracking.n
%% Update PCA model (IK ZAL DIT OOK IN EEN FUNCTIE GIETEN
%construct PCA model (if enough measurements in training set)
if size(utvid.pca.PCAcoords,2) > 3*utvid.pca>PCs
PCAmodel = getPCAmodel(utvid.pca.PCAcoords);

%take reduced set and add translation (and scaling) vectors
PCAmodel_red = reducePCAmodel(PCAmodel, settings);
end

% Load corresponding frames
if strcmp(utvid.version,'R2012') %version control
    FrameL = read(ObjL,n+1); FrameL = im2double(bayerfilter(FrameL(:,:,1)));
    FrameR = read(ObjR,n+1); FrameR = im2double(bayerfilter(FrameR(:,:,1)));
    FrameM = read(ObjM,n+1); FrameM = im2double(bayerfilter(FrameM(:,:,1)));
elseif strcmp(utvid.version,'R2013')
    FrameL = read(ObjL,n); FrameL = im2double(bayerfilter(FrameL(:,:,1)));
    FrameR = read(ObjR,n); FrameR = im2double(bayerfilter(FrameR(:,:,1)));
    FrameM = read(ObjM,n); FrameM = im2double(bayerfilter(FrameM(:,:,1)));
else
    disp('Version not yet implemented')
end

%Orientation DIT GAAT OOK IN EEN FUNCTIE, moet nog uitgewerkt worden voor
%met en zonder orientatie markers etc.
if utvid.nOrMar ~= 0
    [Xinit_or, ~] = reconstruct3D([orientationSets{1}.initX'; orientationSets{1}.initY'], [orientationSets{2}.initX'; orientationSets{2}.initY'], Pstruct.P{1}, Pstruct.P{2}, 4);
    [PCAmodel_rot, R_init] = rotatePCA(PCAmodel_red, Xinit_or, settings);
else
    PCAmodel_rot = PCAmodel;
end

%Measurement

%Outlier Detection

%Prepare and update Kalman
    
%Space representations Estimations

%PCA Expansion

%Space representations Prediction


end

