function [out] = functie(in)
warning off

C_x = 5; % Scalar. Uncertainty (variance) of coordinates expressed in pixels
sigMeas = 10;  % Scalar, Measurement error in pixels (Kalman filter)
sigV = [25,25,25]  % 3 column vector containing process noise X, Y, Z (Kalmanfilter)
utvid.settings.searchregion = 15; % marker localisation search region
lim = 10; % dustance limit for pca expansion modus
utvid.pca.PCAcoords = [];
%% Process videos
for v = 1:size(utvid.movs.left,2)
    % read video objects
    ObjL = VideoReader([utvid.settings.dir_data '\Video\NEW' utvid.movs.list(utvid.movs.left(v)).name]);
    ObjR = VideoReader([utvid.settings.dir_data '\Video\NEW' utvid.movs.list(utvid.movs.right(v)).name]);
    ObjM = VideoReader([utvid.settings.dir_data '\Video\NEW' utvid.movs.list(utvid.movs.center(v)).name]);
    
    % Every instruction start video
    if isempty(find(v==utvid.movs.instrstart))==0
        NoF = min([ObjL.NumberOfFrames,ObjR.NumberOfFrames,ObjM.NumberOfFrames]); % number of frames
        f = 1;

        % initial head orientation
        orleft = [utvid.coords.or.left.x(find(v==utvid.movs.instrstart),:); utvid.coords.or.left.y(find(v==utvid.movs.instrstart),:)];
        orright = [utvid.coords.or.right.x(find(v==utvid.movs.instrstart),:); utvid.coords.or.right.y(find(v==utvid.movs.instrstart),:)];
        orcenter = [utvid.coords.or.center.x(find(v==utvid.movs.instrstart),:); utvid.coords.or.center.y(find(v==utvid.movs.instrstart),:)];
        [Xinit_or,C_Xor] = reconstruct3D_3cam(orleft,orright,orcenter,utvid.Pstruct_or.P{1},utvid.Pstruct_or.P{2},utvid.Pstruct_or.P{3},C_x);
        
        orientationSets = [orleft,orright,orcenter]';
        orientationSets = [orientationSets(:,1);orientationSets(:,2)];
        markerSets = [  utvid.coords.lip.left.x(find(v==utvid.movs.instrstart),:)'; ...
            utvid.coords.lip.right.x(find(v==utvid.movs.instrstart),:)'; ...
            utvid.coords.lip.center.x(find(v==utvid.movs.instrstart),:)';
            utvid.coords.lip.left.y(find(v==utvid.movs.instrstart),:)';
            utvid.coords.lip.right.y(find(v==utvid.movs.instrstart),:)';
            utvid.coords.lip.center.y(find(v==utvid.movs.instrstart),:)'];
        
        % Kalman filter initialisation
        Kal = createKalmanFilter3D(markerSets,utvid.coords.nMar,utvid.Pstruct,ObjM.framerate,NoF,sigMeas,sigV);
        Kal_or  = createKalmanFilter3D(orientationSets,utvid.coords.nOrMar,utvid.Pstruct_or, ObjM.frameRate,NoF,sigMeas,sigV);
        
        % State variables initialisation
        Xest =  [];
        Xpred = [];
        Xest_or = [];
        Xpred_or= [];
        Xest = getAllRep(Xest, f, Kal.Xest(1:end/2,1), Kal.Cest(1:end/2,1:end/2,1), utvid.Pstruct);
        Xpred = getAllRep(Xpred, f+1, Kal.Xpred(1:end/2,2), Kal.Cpred(1:end/2,1:end/2,2), utvid.Pstruct);
        Xest_or = getSpatialRep(Xest_or,1,Kal_or.Xest(1:end/2,1), Kal_or.Cest(1:end/2,1:end/2,1),utvid.Pstruct_or);
        Xpred_or = getSpatialRep(Xpred_or, 2, Kal_or.Xpred(1:end/2,2), Kal_or.Cpred(1:end/2,1:end/2,2), utvid.Pstruct_or);
        
        % Set initial coordinates to selected coordinates
        Meas1.coor(:,:,1) = [utvid.coords.lip.left.x(find(v==utvid.movs.instrstart),:); utvid.coords.lip.left.y(find(v==utvid.movs.instrstart),:)];
        Meas2.coor(:,:,1) = [utvid.coords.lip.right.x(find(v==utvid.movs.instrstart),:); utvid.coords.lip.right.y(find(v==utvid.movs.instrstart),:)];
        Meas3.coor(:,:,1) = [utvid.coords.lip.center.x(find(v==utvid.movs.instrstart),:); utvid.coords.lip.center.y(find(v==utvid.movs.instrstart),:)];
        Meas1_or.coor(:,:,1) = [utvid.coords.or.left.x(find(v==utvid.movs.instrstart),:); utvid.coords.or.left.y(find(v==utvid.movs.instrstart),:)];
        Meas2_or.coor(:,:,1) = [utvid.coords.or.right.x(find(v==utvid.movs.instrstart),:); utvid.coords.or.right.y(find(v==utvid.movs.instrstart),:)];
        Meas3_or.coor(:,:,1) = [utvid.coords.or.center.x(find(v==utvid.movs.instrstart),:); utvid.coords.or.center.y(find(v==utvid.movs.instrstart),:)];
        
        % set base orientation
        if v == 1
            utvid.coords.baseor = Xest_or.X(:,:,1)';
        end
        
        % setup PCA model
        Tt  = rigid_transform_3D(Xest_or.X(:,:,1)',utvid.coords.baseor); Rr = Tt(1:3,1:3);
        Rrext = getRext(Rr, utvid.coords.nMar);
        rot_coor = Rrext*Kal.Xest(1:utvid.coords.nMar*3,1);
        utvid.pca.PCAcoords = [utvid.pca.PCAcoords,rot_coor];
        
        utvid.pca.nrPCs = 8;
        utvid.pca.PCAmodel = getPCAmodel(utvid.pca.PCAcoords,utvid.pca);
        if length(utvid.pca.PCAmodel.eigVal) > utvid.pca.nrPCs - 4
            utvid.pca.PCAmodel_red = reducePCAmodel(utvid.pca.PCAmodel,utvid.pca);
            [utvid.pca.PCAmodel_rot, R_init] = rotatePCA(utvid.pca.PCAmodel_red, Xest_or.X, utvid.coords.nMar,Q+1);
        else
            utvid.pca.PCAmodel_rot = utvid.pca.PCAmodel;
        end
        
        q = 2; % set first frame to 2
        Q = 0;
    else
        q =NoF+1; % set first frame to number of frames of previous video+1
        Q = NoF;
    end
    
    % check for missing frames and set number of frames to (new/current) video
    NoF = min([ObjL.NumberOfFrames,ObjR.NumberOfFrames,ObjM.NumberOfFrames]); % number of frames
    
    %%  Process frames
    for f = q:NoF;
        f
        % read frames
        FrameL = im2double(read(ObjL,f));
        FrameR = im2double(read(ObjR,f));
        FrameM = im2double(read(ObjM,f));
        
        % optimise images
        %         FrameL = imoptimizer();
        %         FrameR = imoptimizer();
        %         FrameM = imoptimizer();
        
        % Lip Marker detection
        Meas1 = minsearch(FrameL,Xpred.x1,Q+f,Meas1,utvid.coords.nMar,utvid);
        Meas2 = minsearch(FrameR,Xpred.x2,Q+f,Meas2,utvid.coords.nMar,utvid);
        Meas3 = minsearch(FrameM,Xpred.x3,Q+f,Meas3,utvid.coords.nMar,utvid);
        Kal.meas(:,Q+f) = [Meas1.coor(1,:,Q+f),Meas2.coor(1,:,Q+f),Meas3.coor(1,:,Q+f),Meas1.coor(2,:,Q+f),Meas2.coor(2,:,Q+f),Meas3.coor(2,:,Q+f)]';
        
        % Orientation Marker detection
        Meas1_or = minsearch(FrameL,Xpred_or.x1,Q+f,Meas1_or,utvid.coords.nOrMar,utvid);
        Meas2_or = minsearch(FrameR,Xpred_or.x2,Q+f,Meas2_or,utvid.coords.nOrMar,utvid);
        Meas3_or = minsearch(FrameM,Xpred_or.x3,Q+f,Meas3_or,utvid.coords.nOrMar,utvid);
        Kal_or.meas(:,Q+f) =  [Meas1_or.coor(1,:,Q+f),Meas2_or.coor(1,:,Q+f),Meas3_or.coor(1,:,Q+f),Meas1_or.coor(2,:,Q+f),Meas2_or.coor(2,:,Q+f),Meas3_or.coor(2,:,Q+f)]';
        
        % 3D estimation of orientatioon Markers
        Kal_or      = prepareKalman3D(Kal_or, utvid.Pstruct_or, Q+f);
        Kal_or      = updateKal(Kal_or, Q+f);
        Xest_or     = getSpatialRep(Xest_or, Q+f, Kal_or.Xest(1:end/2, Q+f), Kal_or.Cest(1:end/2,1:end/2, Q+f), utvid.Pstruct_or);
        Xpred_or    = getSpatialRep(Xpred_or,  Q+f+1, Kal_or.Xpred(1:end/2, Q+f+1), Kal_or.Cpred(1:end/2,1:end/2, Q+f+1), utvid.Pstruct_or);
        
        % outlier detection and correction
        % set masked marker to none
        ptsMask{1} = []; ptsMask{2} = []; ptsMask{3} = [];
        Meas1.outliers{Q+f} = [];
        Meas2.outliers{Q+f} = [];
        Meas3.outliers{Q+f} = [];
        Meas1.masked{Q+f} = [];
        Meas2.masked{Q+f} = [];
        Meas3.masked{Q+f} = [];

        if size(utvid.pca.PCAmodel.V,2) >= utvid.pca.nrPCs
            utvid.pca.PCAmodel_red = reducePCAmodel(utvid.pca.PCAmodel,handles);
            [utvid.pca.PCAmodel_rot, R_init] = rotatePCA(utvid.pca.PCAmodel_red, Xest_or.X, handles.nMar,Q+f);
            utvid.pca.PCAmodel_rot.y = utvid.pca.PCAmodel.y;
            utvid.pca.PCAmodel_rot.eigVal = utvid.pca.PCAmodel.eigVal;
            [Kal.meas(:,Q+f), outliers]   = outlierCorrection_3cam(Kal.meas(:,Q+f), utvid.pca.PCAmodel_rot, utvid.Pstruct, ptsMask, utvid);
            Meas1.outliers{Q+f}           = outliers{1};
            Meas2.outliers{Q+f}           = outliers{2};
            Meas3.outliers{Q+f}           = outliers{3};
            Meas1.masked{Q+f}             = ptsMask{1};
            Meas2.masked{Q+f}             = ptsMask{2};
            Meas3.masked{Q+f}             = ptsMask{3};
        end
        
        %   display outliers
        try
            if isempty(outliers{1}) == 0 || isempty(outliers{2}) == 0 || isempty(outliers{3}) == 0
                outliers{1}
                outliers{2}
                outliers{3}
            end
        catch
            disp('no outliers detected');
        end
        
        % State estimation and prediction
        Kal = prepareKalman3D(Kal, utvid.Pstruct, Q+f);
        Kal = updateKal(Kal, Q+f);
        
        % Calculate rigid transformation
        T = rigid_transform_3D([Kal_or.Xest(1:end/6,Q+f)';Kal_or.Xest(end/6+1:end/6*2,Q+f)';Kal_or.Xest(end/6*2+1:end/6*3,Q+f)']',[Kal_or.Xest(1:end/6,1)';Kal_or.Xest(end/6+1:end/6*2,1)';Kal_or.Xest(end/6*2+1:end/6*3,1)']');
        
        % Create a vector to compare with the pcamodel
        compVec = T*[Kal.Xest(1:end/6,Q+f)'; ...
                     Kal.Xest(end/6+1:end/6*2,Q+f)'; ...
                     Kal.Xest(end/6*2+1:end/6*3,Q+f)'; ...
                     ones(1,utvid.coords.nMar)]; 
        compVec = transpose(compVec(1:3,:)); compVec = compVec(:);
        
        % calculate the distance between compVec and PCA coordinates
        D = min(pdist2(compVec',PCAcoords'));
        
        Xest = getAllRep(Xest, Q+f, Kal.Xest(1:end/2,Q+f), Kal.Cest(1:end/2,1:end/2,Q+f), utvid.Pstruct);
        
        % When D exceeds a predefined limit go into PCA expansion modus
        if D > lim
            [utvid.pca.PCAcoords,utvid.pca.PCAmodel,Xest,Kal] = PCAExpansion(FrameL,FrameR,FrameM,utvid.coords.nMar,Q+f,utvid.pca.PCAcoords,Kal,Kal_or,Xest,Xest_or,utvid.pca.PCAmodel,utvid.Pstruct,utvid.Pstruct_or,T,lim);
        end
        Xpred   = getAllRep(Xpred,  Q+f+1,    Kal.Xpred(1:end/2,Q+f+1), Kal.Cpred(1:end/2,1:end/2,Q+f+1), utvid.Pstruct);
        
        
        
    end
    
end


