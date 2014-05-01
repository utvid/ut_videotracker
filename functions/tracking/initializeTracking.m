function utvid = initializeTracking(utvid,handles)

utvid.Tracking.n = 1;

utvid.Tracking.ObjL = VideoReader([utvid.settings.dir_data '\Video\' utvid.settings.stname utvid.movs.list(utvid.movs.left(1,1)).name]);
utvid.Tracking.ObjR = VideoReader([utvid.settings.dir_data '\Video\' utvid.settings.stname utvid.movs.list(utvid.movs.right(1,1)).name]);
utvid.Tracking.ObjM = VideoReader([utvid.settings.dir_data '\Video\' utvid.settings.stname utvid.movs.list(utvid.movs.center(1,1)).name]);

if strcmp(utvid.settings.version,'R2012')
    axes(handles.hax{1,1}), imshow(read(utvid.Tracking.ObjL,utvid.Tracking.n+1),[]);
    axes(handles.hax{1,2}), imshow(read(utvid.Tracking.ObjR,utvid.Tracking.n+1),[]);
    axes(handles.hax{1,3}), imshow(read(utvid.Tracking.ObjM,utvid.Tracking.n+1),[]);
    
    % Video characteristics
    utvid.Tracking.NoF = min([utvid.Tracking.ObjL.NumberOfFrames-1,... %NoF (sometimes one movie contains one frame more or less)
        utvid.Tracking.ObjR.NumberOfFrames-1,utvid.Tracking.ObjM.NumberOfFrames-1]);
    
elseif strcmp(utvid.settings.version,'R2013')
    axes(handles.hax{1,1}), imshow(read(utvid.Tracking.ObjL,utvid.Tracking.n),[]);
    axes(handles.hax{1,2}), imshow(read(utvid.Tracking.ObjR,utvid.Tracking.n),[]);
    axes(handles.hax{1,3}), imshow(read(utvid.Tracking.ObjM,utvid.Tracking.n),[]);
    
    % Video characteristics
    utvid.Tracking.NoF = min([utvid.Tracking.ObjL.NumberOfFrames,... %NoF (sometimes one movie contains one frame more or less)
        utvid.Tracking.ObjR.NumberOfFrames,utvid.Tracking.ObjM.NumberOfFrames]);
else
    disp('Version not yet implemented')
end

utvid.Tracking.FrameRate = utvid.Tracking.ObjL.FrameRate;

%initial head orientation
if utvid.settings.nrOrMar ~= 0
    [utvid.Xinit_or, ~] = twoDto3D_3cam([utvid.coords.or.left.x;utvid.coords.or.right.x;...
        utvid.coords.or.center.x; utvid.coords.or.left.y;utvid.coords.or.right.y;...
        utvid.coords.or.center.y],0, utvid.Pstruct_or.Pext);
end

% Create Kalman Filter
%Possible addition could be a kalman filter over the PCA domain
utvid = createKalmanFilter3D(utvid);

if utvid.settings.nrOrMar ~= 0
    utvid = createKalmanFilter3Dor(utvid);
end

%state variables and their initialization
utvid.Tracking.Xest        = [];
utvid.Tracking.Xpred       = [];

utvid.Tracking.Xest  = getAllRep( utvid.Tracking.Xest, 1, utvid.Tracking.Kal.Xest(1:end/2,1), ...
    utvid.Tracking.Kal.Cest(1:end/2,1:end/2,1), utvid.Pstruct);
utvid.Tracking.Xpred = getAllRep( utvid.Tracking.Xpred, 2, utvid.Tracking.Kal.Xpred(1:end/2,2), ...
    utvid.Tracking.Kal.Cpred(1:end/2,1:end/2,2), utvid.Pstruct);

if utvid.settings.nrOrMar ~= 0
    utvid.Tracking.Xest_or     = []; utvid.Tracking.Xest_or.Rext(:,:,1) = R_init;
    utvid.Tracking.Xpred_or    = [];
    utvid.Tracking.Xest_or     = getSpatialRep(utvid.Tracking.Xest_or, 1, utvid.Tracking.Kal.Xestor(1:end/2,1), utvid.Tracking.Kal.Cestor(1:end/2,1:end/2,1),utvid.Pstruct_or);
    utvid.Tracking.Xpred_or    = getSpatialRep(utvid.Tracking.Xpred_or, 2, utvid.Tracking.Kal.Xpredor(1:end/2,2), utvid.Tracking.Kal.Cpredor(1:end/2,1:end/2,2),utvid.Pstruct_or);
end

utvid.Tracking.Meas1.coor(:,:,1) = [utvid.coords.shape.left.x;utvid.coords.shape.left.y];
utvid.Tracking.Meas2.coor(:,:,1) = [utvid.coords.shape.right.x;utvid.coords.shape.right.y];
utvid.Tracking.Meas3.coor(:,:,1) = [utvid.coords.shape.center.x;utvid.coords.shape.center.y];

end