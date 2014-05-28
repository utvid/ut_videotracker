function utvid = Tracking(utvid,handles)
utvid.Tracking.n
% Update PCA model (if enough measurements regarding number of Principal components)
% if size(utvid.pca.PCAcoords,2) > 3*utvid.settings.PCs
%     utvid = PCAmodelUpdate(utvid);
% end

% The original PCA model did not work for some reason. I implemented know
% our MMSE method. Original should be fixed and be available as an option.

utvid = pcaMMSE(utvid);

% Load and show corresponding frames
%HET PLOTTEN MOET NOG NETJES IN EEN FUNCTIE GEZET WORDEN
utvid = loadFrames(utvid,handles);

%Measurement
%HET PLOTTEN MOET NOG NETJES IN EEN FUNCTIE GEZET WORDEN

utvid = measurement(utvid);

if utvid.settings.nrOrMar ~= 0
    %Head orientation
    %3D estimation of orientational markers
        utvid.Tracking.Kal_or      = prepareKalman3D(utvid.Tracking.Kal_or, utvid.Pstruct_or, utvid.Tracking.n);
        utvid.Tracking.Kal_or      = updateKal(utvid.Tracking.Kal_or, utvid.Tracking.n);
        utvid.Tracking.Xest_or     = getSpatialRep(utvid.Tracking.Xest_or, utvid.Tracking.n, utvid.Tracking.Kal_or.Xest(1:end/2,utvid.Tracking.n), ...
                                                    utvid.Tracking.Kal_or.Cest(1:end/2,1:end/2,utvid.Tracking.n), utvid.Pstruct_or);
        utvid.Tracking.Xpred_or    = getSpatialRep(utvid.Tracking.Xpred_or, utvid.Tracking.n+1, utvid.Tracking.Kal_or.Xpred(1:end/2,utvid.Tracking.n+1),...
                                                    utvid.Tracking.Kal_or.Cpred(1:end/2,1:end/2,utvid.Tracking.n+1), utvid.Pstruct_or);
        utvid.coords.Xinit_or(:,utvid.Tracking.n) =  [utvid.Tracking.Xest_or.X(:,1,utvid.Tracking.n);utvid.Tracking.Xest_or.X(:,2,utvid.Tracking.n);utvid.Tracking.Xest_or.X(:,3,utvid.Tracking.n)];
    % determine orientation of head and create a rotated PCA model
            [utvid.pca.PCAmodel_rot, utvid.Tracking.Xest_or.Rext] = rotatePCA(utvid.pca.PCAmodel, utvid.Tracking.Xest_or.X,utvid.Tracking.n);
end

% Update PCA model (if enough measurements regarding number of Principal components)
% if size(utvid.pca.PCAcoords,2) > 3*utvid.settings.PCs
    utvid = PCAmodelUpdate(utvid);
% end


%Prepare and update Kalman (estimaion is found here)
utvid.Tracking.Kal = prepareKalman3D(utvid.Tracking.Kal, utvid.Pstruct, utvid.Tracking.n);
utvid.Tracking.Kal = updateKal(utvid.Tracking.Kal, utvid.Tracking.n);

utvid.Tracking.Xest = getAllRep( utvid.Tracking.Xest, utvid.Tracking.n, utvid.Tracking.Kal.Xest(1:end/2,utvid.Tracking.n), ...
    utvid.Tracking.Kal.Cest(1:end/2,1:end/2,utvid.Tracking.n), utvid.Pstruct);

%Outlier Detection
if size(utvid.pca.PCAcoords,2) > 4*utvid.settings.PCs
    if utvid.pca.outlier == 0, disp('Outlier detection performed'), utvid.pca.outlier = 1; end
    [utvid] = outlierCorrectionMMSE(utvid,utvid.Tracking.Kal.Xest(1:end/2,utvid.Tracking.n));
end

%Space representations Estimations
utvid.Tracking.Xest  = getAllRep( utvid.Tracking.Xest, utvid.Tracking.n, utvid.Tracking.Kal.Xest(1:end/2,utvid.Tracking.n), ...
    utvid.Tracking.Kal.Cest(1:end/2,1:end/2,utvid.Tracking.n), utvid.Pstruct);

%Plot if tracking is 1
if utvid.Tracking.plotting == 1
    axes(handles.hax{1,1}), hold on
    imshow(utvid.Tracking.FrameL,[]);
    plot(utvid.Tracking.Xest.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x1(:,2,utvid.Tracking.n),'y.')
    plot(utvid.Tracking.Xpred.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x1(:,2,utvid.Tracking.n),'ob')
    plot(utvid.Tracking.Kal.meas(1:utvid.settings.nrMarkers,utvid.Tracking.n), ...
        utvid.Tracking.Kal.meas(utvid.settings.nrMarkers*3+1:utvid.settings.nrMarkers*4,utvid.Tracking.n),'r*')
    plot(utvid.Tracking.Xest.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x1(:,2,utvid.Tracking.n),'go')
    mins = min(utvid.Tracking.Xest.x1(:,:,utvid.Tracking.n));
    maxs = max(utvid.Tracking.Xest.x1(:,:,utvid.Tracking.n));
    xlim([mins(1)-25 maxs(1)+25]);
    ylim([mins(2)-25 maxs(2)+25]);
    
    
    axes(handles.hax{1,2}), hold on
    imshow(utvid.Tracking.FrameR,[]);
    plot(utvid.Tracking.Xest.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x2(:,2,utvid.Tracking.n),'y.')
    plot(utvid.Tracking.Xpred.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x2(:,2,utvid.Tracking.n),'ob')
    plot(utvid.Tracking.Kal.meas(utvid.settings.nrMarkers+1:utvid.settings.nrMarkers*2,utvid.Tracking.n),...
        utvid.Tracking.Kal.meas(utvid.settings.nrMarkers*4+1:utvid.settings.nrMarkers*5,utvid.Tracking.n),'r*')
    plot(utvid.Tracking.Xest.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x2(:,2,utvid.Tracking.n),'go')
    mins = min(utvid.Tracking.Xest.x2(:,:,utvid.Tracking.n));
    maxs = max(utvid.Tracking.Xest.x2(:,:,utvid.Tracking.n));
    xlim([mins(1)-25 maxs(1)+25]);
    ylim([mins(2)-25 maxs(2)+25]);
    
    axes(handles.hax{1,3}), hold on
    imshow(utvid.Tracking.FrameM,[]);
    plot(utvid.Tracking.Xest.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x3(:,2,utvid.Tracking.n),'y.')
    plot(utvid.Tracking.Xpred.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x3(:,2,utvid.Tracking.n),'ob')
    plot(utvid.Tracking.Kal.meas(utvid.settings.nrMarkers*2+1:utvid.settings.nrMarkers*3,utvid.Tracking.n),...
        utvid.Tracking.Kal.meas(utvid.settings.nrMarkers*5+1:utvid.settings.nrMarkers*6,utvid.Tracking.n),'r*')
    plot(utvid.Tracking.Xest.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x3(:,2,utvid.Tracking.n),'go')
    mins = min(utvid.Tracking.Xest.x3(:,:,utvid.Tracking.n));
    maxs = max(utvid.Tracking.Xest.x3(:,:,utvid.Tracking.n));
    xlim([mins(1)-25 maxs(1)+25]);
    ylim([mins(2)-25 maxs(2)+25]);
    drawnow
    
    if utvid.settings.nrOrMar ~=0
          axes(handles.hax{2,1}), hold on
    imshow(utvid.Tracking.FrameL,[]);
    plot(utvid.Tracking.Xest_or.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xest_or.x1(:,2,utvid.Tracking.n),'y.')
    plot(utvid.Tracking.Xpred_or.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xpred_or.x1(:,2,utvid.Tracking.n),'ob')
    plot(utvid.Tracking.Kal_or.meas(1:utvid.settings.nrMarkers,utvid.Tracking.n), ...
        utvid.Tracking.Kal_or.meas(utvid.settings.nrMarkers*3+1:utvid.settings.nrMarkers*4,utvid.Tracking.n),'r*')
    plot(utvid.Tracking.Xest_or.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xest_or.x1(:,2,utvid.Tracking.n),'go')
    mins = min(utvid.Tracking.Xest_or.x1(:,:,utvid.Tracking.n));
    maxs = max(utvid.Tracking.Xest_or.x1(:,:,utvid.Tracking.n));
    xlim([mins(1)-25 maxs(1)+25]);
    ylim([mins(2)-25 maxs(2)+25]);
    
    
    axes(handles.hax{2,2}), hold on
    imshow(utvid.Tracking.FrameR,[]);
    plot(utvid.Tracking.Xest_or.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xest_or.x2(:,2,utvid.Tracking.n),'y.')
    plot(utvid.Tracking.Xpred_or.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xpred_or.x2(:,2,utvid.Tracking.n),'ob')
    plot(utvid.Tracking.Kal_or.meas(utvid.settings.nrMarkers+1:utvid.settings.nrMarkers*2,utvid.Tracking.n),...
        utvid.Tracking.Kal_or.meas(utvid.settings.nrMarkers*4+1:utvid.settings.nrMarkers*5,utvid.Tracking.n),'r*')
    plot(utvid.Tracking.Xest_or.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xest_or.x2(:,2,utvid.Tracking.n),'go')
    mins = min(utvid.Tracking.Xest_or.x2(:,:,utvid.Tracking.n));
    maxs = max(utvid.Tracking.Xest_or.x2(:,:,utvid.Tracking.n));
    xlim([mins(1)-25 maxs(1)+25]);
    ylim([mins(2)-25 maxs(2)+25]);
    
    axes(handles.hax{2,3}), hold on
    imshow(utvid.Tracking.FrameM,[]);
    plot(utvid.Tracking.Xest_or.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xest_or.x3(:,2,utvid.Tracking.n),'y.')
    plot(utvid.Tracking.Xpred_or.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xpred_or.x3(:,2,utvid.Tracking.n),'ob')
    plot(utvid.Tracking.Kal_or.meas(utvid.settings.nrMarkers*2+1:utvid.settings.nrMarkers*3,utvid.Tracking.n),...
        utvid.Tracking.Kal_or.meas(utvid.settings.nrMarkers*5+1:utvid.settings.nrMarkers*6,utvid.Tracking.n),'r*')
    plot(utvid.Tracking.Xest_or.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xest_or.x3(:,2,utvid.Tracking.n),'go')
    mins = min(utvid.Tracking.Xest_or.x3(:,:,utvid.Tracking.n));
    maxs = max(utvid.Tracking.Xest_or.x3(:,:,utvid.Tracking.n));
    xlim([mins(1)-25 maxs(1)+25]);
    ylim([mins(2)-25 maxs(2)+25]);
    drawnow
    end
    
end

%PCA Expansion
% lim should be set in GUI
D = min(pdist2(utvid.Tracking.Kal.Xest(1:end/2,utvid.Tracking.n)',utvid.pca.PCAcoords'));
if D > utvid.Tracking.lim
    [utvid.pca.PCAcoords,utvid.Tracking.Xest,utvid.Tracking.Kal] ...
        = PCAExpansionMMSE(utvid.Tracking.FrameL,utvid.Tracking.FrameR,...
        utvid.Tracking.FrameM,utvid.Tracking.n,utvid.pca.PCAcoords,...
        utvid.Tracking.Kal,utvid.Tracking.Xest,utvid.Pstruct,utvid.Tracking.lim,utvid);
end

%Space representations Prediction
utvid.Tracking.Xpred = getAllRep( utvid.Tracking.Xpred, utvid.Tracking.n+1, utvid.Tracking.Kal.Xpred(1:end/2,utvid.Tracking.n+1), ...
    utvid.Tracking.Kal.Cpred(1:end/2,1:end/2,utvid.Tracking.n+1), utvid.Pstruct);

end

