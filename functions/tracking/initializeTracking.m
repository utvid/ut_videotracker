function utvid = initializeTracking(utvid,handles)

utvid.Tracking.n = 1; 
if utvid.Tracking.instr < size(utvid.movs.instrstart,2);
    utvid.Tracking.NoV = utvid.movs.instrstart(utvid.Tracking.instr+1)-utvid.movs.instrstart(utvid.Tracking.instr);
elseif utvid.Tracking.instr == size(utvid.movs.instrstart,2);
    utvid.Tracking.NoV = size(utvid.movs.left,2)-utvid.movs.instrstart(utvid.Tracking.instr);
end

utvid.Tracking.ObjL =[];utvid.Tracking.ObjR =[];utvid.Tracking.ObjM =[];
for j = 1:utvid.Tracking.NoV;
    nr = utvid.Tracking.instr+j-1;
    utvid.Tracking.ObjL{j} = VideoReader([utvid.settings.dir_data '\Video\' utvid.settings.stname utvid.movs.list(utvid.movs.left(1,nr)).name]);
    utvid.Tracking.ObjR{j} = VideoReader([utvid.settings.dir_data '\Video\' utvid.settings.stname utvid.movs.list(utvid.movs.right(1,nr)).name]);
    utvid.Tracking.ObjM{j} = VideoReader([utvid.settings.dir_data '\Video\' utvid.settings.stname utvid.movs.list(utvid.movs.center(1,nr)).name]);
    
    NoF(j,1) = utvid.Tracking.ObjL{j}.NumberOfFrames;
    NoF(j,2) = utvid.Tracking.ObjR{j}.NumberOfFrames;
    NoF(j,3) = utvid.Tracking.ObjM{j}.NumberOfFrames;
    utvid.Tracking.NoF = min(NoF,[],2);
end

if strcmp(utvid.settings.version,'R2012')
    utvid.Tracking.NoF = utvid.Tracking.NoF-1;
    axes(handles.hax{1,1}), imshow(read(utvid.Tracking.ObjL{1},utvid.Tracking.n+1),[]);
    axes(handles.hax{1,2}), imshow(read(utvid.Tracking.ObjR{1},utvid.Tracking.n+1),[]);
    axes(handles.hax{1,3}), imshow(read(utvid.Tracking.ObjM{1},utvid.Tracking.n+1),[]);
    
    if utvid.settings.nrOrMar~=0; 
        axes(handles.hax{2,1}), imshow(read(utvid.Tracking.ObjL{1},utvid.Tracking.n),[]);
        axes(handles.hax{2,2}), imshow(read(utvid.Tracking.ObjR{1},utvid.Tracking.n),[]);
        axes(handles.hax{2,3}), imshow(read(utvid.Tracking.ObjM{1},utvid.Tracking.n),[]);
    end
    
elseif strcmp(utvid.settings.version,'R2013')
    axes(handles.hax{1,1}), imshow(read(utvid.Tracking.ObjL{1},utvid.Tracking.n),[]);
    axes(handles.hax{1,2}), imshow(read(utvid.Tracking.ObjR{1},utvid.Tracking.n),[]);
    axes(handles.hax{1,3}), imshow(read(utvid.Tracking.ObjM{1},utvid.Tracking.n),[]);
    if utvid.settings.nrOrMar~=0; 
        axes(handles.hax{2,1}), imshow(read(utvid.Tracking.ObjL{1},utvid.Tracking.n),[]);
        axes(handles.hax{2,2}), imshow(read(utvid.Tracking.ObjR{1},utvid.Tracking.n),[]);
        axes(handles.hax{2,3}), imshow(read(utvid.Tracking.ObjM{1},utvid.Tracking.n),[]);
    end
else
    disp('Version not yet implemented')
end
utvid.Tracking.FrameNum = sum(utvid.Tracking.NoF);
utvid.Tracking.FrameRate = utvid.Tracking.ObjL{1}.FrameRate;
utvid.pca.sigv = 0.1;

%initial head orientation
if utvid.Tracking.instr == 1
if utvid.settings.nrOrMar ~= 0 
    [utvid.coords.Xinit_or, ~] = twoDto3D_3cam([utvid.coords.or.left.x(:,utvid.Tracking.instr);utvid.coords.or.right.x(:,utvid.Tracking.instr);...
        utvid.coords.or.center.x(:,utvid.Tracking.instr); utvid.coords.or.left.y(:,utvid.Tracking.instr);utvid.coords.or.right.y(:,utvid.Tracking.instr);...
        utvid.coords.or.center.y(:,utvid.Tracking.instr)],0, utvid.Pstruct_or.Pext);
    utvid.Tracking.base_or(:,1) = utvid.coords.Xinit_or(1:6,1);
    utvid.Tracking.base_or(:,2) = utvid.coords.Xinit_or(7:12,1);
    utvid.Tracking.base_or(:,3) = utvid.coords.Xinit_or(13:18,1);
end
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
    utvid.Tracking.Xest_or     = []; utvid.Tracking.Xest_or.Rext(:,:,1) = utvid.coords.Xinit_or; % R_init
    utvid.Tracking.Xpred_or    = [];
    utvid.Tracking.Xest_or     = getSpatialRep(utvid.Tracking.Xest_or, 1, utvid.Tracking.Kal_or.Xest(1:end/2,1), utvid.Tracking.Kal_or.Cest(1:end/2,1:end/2,1),utvid.Pstruct_or);
    utvid.Tracking.Xpred_or    = getSpatialRep(utvid.Tracking.Xpred_or, 2, utvid.Tracking.Kal_or.Xpred(1:end/2,2), utvid.Tracking.Kal_or.Cpred(1:end/2,1:end/2,2),utvid.Pstruct_or);
end

utvid.Tracking.Meas1.coor(:,:,1) = [utvid.coords.shape.left.x;utvid.coords.shape.left.y];
utvid.Tracking.Meas2.coor(:,:,1) = [utvid.coords.shape.right.x;utvid.coords.shape.right.y];
utvid.Tracking.Meas3.coor(:,:,1) = [utvid.coords.shape.center.x;utvid.coords.shape.center.y];

end