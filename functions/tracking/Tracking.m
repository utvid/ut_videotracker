function utvid = Tracking(utvid,handles)
utvid.Tracking.n

% Update PCA model (if enough measurements regarding number of Principal components)
% if size(utvid.pca.PCAcoords,2) > 3*utvid.settings.PCs
    utvid = PCAmodelUpdate(utvid);
% end

% Load and show corresponding frames
%HET PLOTTEN MOET NOG NETJES IN EEN FUNCTIE GEZET WORDEN
utvid = loadFrames(utvid,handles);

axes(handles.hax{1}), hold on
plot(utvid.Tracking.Xpred.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x1(:,2,utvid.Tracking.n),'ob')

axes(handles.hax{2}), hold on
plot(utvid.Tracking.Xpred.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x2(:,2,utvid.Tracking.n),'ob')

axes(handles.hax{3}), hold on
plot(utvid.Tracking.Xpred.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x3(:,2,utvid.Tracking.n),'ob')

%Measurement
%HET PLOTTEN MOET NOG NETJES IN EEN FUNCTIE GEZET WORDEN

utvid = measurement(utvid);

axes(handles.hax{1}), hold on
plot(utvid.Tracking.Kal.meas(1:utvid.settings.nrMarkers,utvid.Tracking.n), ...
    utvid.Tracking.Kal.meas(utvid.settings.nrMarkers*3+1:utvid.settings.nrMarkers*4,utvid.Tracking.n),'r*')

axes(handles.hax{2}), hold on
plot(utvid.Tracking.Kal.meas(utvid.settings.nrMarkers+1:utvid.settings.nrMarkers*2,utvid.Tracking.n),...
    utvid.Tracking.Kal.meas(utvid.settings.nrMarkers*4+1:utvid.settings.nrMarkers*5,utvid.Tracking.n),'r*')

axes(handles.hax{3}), hold on
plot(utvid.Tracking.Kal.meas(utvid.settings.nrMarkers*2+1:utvid.settings.nrMarkers*3,utvid.Tracking.n),...
    utvid.Tracking.Kal.meas(utvid.settings.nrMarkers*5+1:utvid.settings.nrMarkers*6,utvid.Tracking.n),'r*')

if utvid.settings.nrOrMar ~= 0
    %Head orientation
    %3D estimation of orientational markers
    % DIT ZIJN DE SCRIPTS VAN TIJMEN, AANPASSEN AAN ONZE SETUP
    %     Kal_or      = prepareKalman3D(Kal_or, Pstruct_or, i, settings);
    %     Kal_or      = updateKal(Kal_or, i);
    %     Xest_or     = getSpatialRep(Xest_or, i, Kal_or.Xest(1:end/2,i), Kal_or.Cest(1:end/2,1:end/2,i), '3D', Pstruct_or, settings);
    %     Xpred_or    = getSpatialRep(Xpred_or, i+1, Kal_or.Xpred(1:end/2,i+1), Kal_or.Cpred(1:end/2,1:end/2,i+1), '3D', Pstruct_or, settings);
    
    %determine orientation of head and create a rotated PCA model
    %     [PCAmodel_rot, Xest_or.Rext(:,:,i)] = rotatePCA(PCAmodel, Xest_or.X(:,:,i), settings);
end

%Outlier Detection 
%{
    Outlier detection moet na Kalman update etc, ga ik aanpassen
%}
if size(utvid.pca.PCAcoords,2) > 3*utvid.settings.PCs
    ptsMask{1} = []; ptsMask{2} = []; ptsMask{3} = [];
    [utvid] = outlierCorrection_3cam(utvid);
end

%Prepare and update Kalman
utvid.Tracking.Kal = prepareKalman3D(utvid.Tracking.Kal, utvid.Pstruct, utvid.Tracking.n);
utvid.Tracking.Kal = updateKal(utvid.Tracking.Kal, utvid.Tracking.n);

%Space representations Estimations
utvid.Tracking.Xest  = getAllRep( utvid.Tracking.Xest, utvid.Tracking.n, utvid.Tracking.Kal.Xest(1:end/2,utvid.Tracking.n), ...
    utvid.Tracking.Kal.Cest(1:end/2,1:end/2,utvid.Tracking.n), utvid.Pstruct);

%PCA Expansion
% lim should be set in GUI
D = min(pdist2(utvid.Tracking.Kal.Xest(1:end/2,utvid.Tracking.n)',utvid.pca.PCAcoords'));
if D > utvid.Tracking.lim
    [utvid.pca.PCAcoords,utvid.pca_rot,utvid.Tracking.Xest,utvid.Tracking.Kal] ...
        = PCAExpansion(utvid.Tracking.FrameL,utvid.Tracking.FrameR,...
        utvid.Tracking.FrameM,utvid.Tracking.n,utvid.pca.PCAcoords,...
        utvid.Tracking.Kal,utvid.Tracking.Xest,utvid.pca_rot,utvid.Pstruct,utvid.Tracking.lim,utvid);
end

%Space representations Prediction
utvid.Tracking.Xpred = getAllRep( utvid.Tracking.Xpred, utvid.Tracking.n+1, utvid.Tracking.Kal.Xpred(1:end/2,utvid.Tracking.n+1), ...
    utvid.Tracking.Kal.Cpred(1:end/2,1:end/2,utvid.Tracking.n+1), utvid.Pstruct);

end

