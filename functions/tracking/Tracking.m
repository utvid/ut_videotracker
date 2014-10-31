function utvid = Tracking(utvid,handles)
% display current frame number
disp(['Frame: ' num2str(utvid.Tracking.n)])
disp(['Roi: ' num2str(utvid.Tracking.roi)])
%% Load frames
% Load images and perform image enhancement
% image enhancement can be improved
utvid = loadFrames(utvid,handles);

%% Perform Measurement
% detect markers in current frames both shape as optional orientation
% markers
% template matching needs to be created
utvid = measurement(utvid);

%% Update Kalman for orientation markers
% Currently the orientation markers do not undergo outlier detection!!
if utvid.settings.nrOrMar ~= 0
    % prepare the kalman filter structure of a kalman update
    utvid.Tracking.Kal_or      = prepareKalman3D(utvid.Tracking.Kal_or, utvid.Pstruct_or, utvid.Tracking.n);
    % perform kalman update
    utvid.Tracking.Kal_or      = updateKal(utvid.Tracking.Kal_or, utvid.Tracking.n);
    % transform kalman 3D coordinates to 2D
    utvid.Tracking.Xest_or     = getSpatialRep(utvid.Tracking.Xest_or, utvid.Tracking.n, utvid.Tracking.Kal_or.Xest(1:end/2,utvid.Tracking.n), ...
        utvid.Tracking.Kal_or.Cest(1:end/2,1:end/2,utvid.Tracking.n), utvid.Pstruct_or);
    utvid.Tracking.Xpred_or    = getSpatialRep(utvid.Tracking.Xpred_or, utvid.Tracking.n+1, utvid.Tracking.Kal_or.Xpred(1:end/2,utvid.Tracking.n+1),...
        utvid.Tracking.Kal_or.Cpred(1:end/2,1:end/2,utvid.Tracking.n+1), utvid.Pstruct_or);
    % save orientation coordinates in Xinit_or
    utvid.coords.Xinit_or(:,utvid.Tracking.n) =  [utvid.Tracking.Xest_or.X(:,1,utvid.Tracking.n);utvid.Tracking.Xest_or.X(:,2,utvid.Tracking.n);utvid.Tracking.Xest_or.X(:,3,utvid.Tracking.n)];
end

%% rotate shape markers to base_or
% Uncertainty is set to zero!!
% Kalman 2D measured coordinates are transformed to 3D
if utvid.Tracking.nrcams == 2
    Meas3D = twoDto3D(utvid.Tracking.Kal.meas(:,utvid.Tracking.n),0,utvid.Pstruct.Pext);
else
    Meas3D = twoDto3D_3cam(utvid.Tracking.Kal.meas(:,utvid.Tracking.n),0,utvid.Pstruct.Pext);
end
if utvid.settings.nrOrMar ~= 0
    % PCA rotation using rigid transform
    utvid.Tracking.T(:,:,utvid.Tracking.instr,utvid.Tracking.n) = rigid_transform_3D(utvid.Tracking.Xest_or.X(:,:,utvid.Tracking.n),utvid.Tracking.base_or);
    % Rotation
    R = utvid.Tracking.T(1:3,1:3,utvid.Tracking.instr,utvid.Tracking.n);
    % Extended rotation matrix
    Rrext = getRext(R, utvid.settings.nrMarkers);
    % Rotated measured 3D coordinates
    rot_coor = Rrext*Meas3D;
    % Add translation
    utvid.Tracking.rt_coor(:,utvid.Tracking.n) = [rot_coor(1:utvid.settings.nrMarkers)+utvid.Tracking.T(1,4,utvid.Tracking.instr,utvid.Tracking.n); ...
        rot_coor(utvid.settings.nrMarkers+1:2*utvid.settings.nrMarkers)+  utvid.Tracking.T(2,4,utvid.Tracking.instr,utvid.Tracking.n);...
        rot_coor(2*utvid.settings.nrMarkers+1:3*utvid.settings.nrMarkers)+utvid.Tracking.T(3,4,utvid.Tracking.instr,utvid.Tracking.n)];
end

%% perform outlier detection
% check if the number of PCA coordinates in the models is greater than two
% times the number of principle components
if isfield(utvid.pca,'PCAcoords')==1
    if size(utvid.pca.PCAcoords,2) > 2*utvid.settings.PCs
        if utvid.pca.outlier == 0, disp('Outlier detection performed'), utvid.pca.outlier = 1; end
        if utvid.settings.nrOrMar ~= 0
            
            % MMSE outlierdetection on rotated and translated 3D Kalman
            % measurement coordinates, in c the detected outliers
            [utvid,utvid.Tracking.rt_coor(:,utvid.Tracking.n),c] = outlierCorrectionMMSE(utvid,utvid.Tracking.rt_coor(:,utvid.Tracking.n));
            
            % back to original coordinate system in Kal.Xest - translation and - rotation
            rot_back = [utvid.Tracking.rt_coor(1:utvid.settings.nrMarkers,utvid.Tracking.n)-utvid.Tracking.T(1,4,utvid.Tracking.instr,utvid.Tracking.n); ...
                utvid.Tracking.rt_coor(utvid.settings.nrMarkers+1:2*utvid.settings.nrMarkers,utvid.Tracking.n)-  utvid.Tracking.T(2,4,utvid.Tracking.instr,utvid.Tracking.n);...
                utvid.Tracking.rt_coor(2*utvid.settings.nrMarkers+1:3*utvid.settings.nrMarkers,utvid.Tracking.n)-utvid.Tracking.T(3,4,utvid.Tracking.instr,utvid.Tracking.n)];
            coor_back = inv(Rrext)*rot_back;
            
            % check for erroneous markers, if c is empty, no outliers detected
            if isempty(c) == 0
                
                % Transform 3D coordinates to 2D
                if utvid.Tracking.nrcams == 3
                [c1,c2,c3,~,~,~]=threeDto2D_3cam(coor_back,utvid.Tracking.Kal.Cest(1:end/2,1:end/2,utvid.Tracking.n),utvid.Pstruct);
                    c1 = c1';
                    c2 = c2';
                    c3 = c3';
                else 
                    [c1,c2,~,~] = threeDto2D(coor_back,utvid.Tracking.Kal.Cest(1:end/2,1:end/2,utvid.Tracking.n),utvid.Pstruct);
                end
                
                % correct Kalman measurement marker positions
                utvid.Tracking.Kal.meas(1:utvid.settings.nrMarkers,utvid.Tracking.n) = c1(:,1);      % x camera 1
                utvid.Tracking.Kal.meas(1+utvid.settings.nrMarkers:2*utvid.settings.nrMarkers,utvid.Tracking.n) = c2(:,1); % x camera 2
                utvid.Tracking.Kal.meas(1+utvid.settings.nrMarkers*utvid.Tracking.nrcams:utvid.settings.nrMarkers*utvid.Tracking.nrcams+utvid.settings.nrMarkers,utvid.Tracking.n) = c1(:,2); % y camera 1
                utvid.Tracking.Kal.meas(1+utvid.settings.nrMarkers*utvid.Tracking.nrcams+utvid.settings.nrMarkers:  ....
                                        utvid.settings.nrMarkers*utvid.Tracking.nrcams+2*utvid.settings.nrMarkers,utvid.Tracking.n) = c2(:,2); % y camera 2
                if utvid.Tracking.nrcams ==3
                utvid.Tracking.Kal.meas(1+2*utvid.settings.nrMarkers:3*utvid.settings.nrMarkers,utvid.Tracking.n) = c3(:,1); % x camera 3
                utvid.Tracking.Kal.meas(1+utvid.settings.nrMarkers*utvid.Tracking.nrcams+utvid.settings.nrMarkers*2:  ....
                                        utvid.settings.nrMarkers*utvid.Tracking.nrcams+3*utvid.settings.nrMarkers,utvid.Tracking.n) = c3(:,2); % y camera 3
                end
                % reset uncertainty corrected markers; should be done here!
                % set prediction uncertainty to 1e6;
                for iii = 1:length(c)
                    utvid.Tracking.Kal.Cpred(c(iii)+30,c(iii)+30,utvid.Tracking.n) = 1e10;
                end
            end
        else
            % when not using orientation markers; probably does not function at
            % the moment
            [utvid,utvid.Tracking.Kal.Xest(:,utvid.Tracking.n)] = outlierCorrectionMMSE(utvid,utvid.Tracking.Kal.Xest(:,utvid.Tracking.n));
            utvid.Tracking.rt_coor = utvid.Tracking.Kal.Xest(1:utvid.settings.nrcams*utvid.settings.nrMarkers,:);
        end
    end
end
% prepare the kalman filter for an update and perform the Kalman update
utvid.Tracking.Kal = prepareKalman3D(utvid.Tracking.Kal, utvid.Pstruct,utvid.Tracking.n);
utvid.Tracking.Kal = updateKal(utvid.Tracking.Kal,utvid.Tracking.n);

%% Space representations Estimations
% Transform Kal.Xest to Tracking.Xest structure
% 3D --> 2D
utvid.Tracking.Xest  = getAllRep( utvid.Tracking.Xest, utvid.Tracking.n, utvid.Tracking.Kal.Xest(1:end/2,utvid.Tracking.n), ...
    utvid.Tracking.Kal.Cest(1:end/2,1:end/2,utvid.Tracking.n), utvid.Pstruct);

% Transform Kal.Xpred current frame to Tracking.Xpred structure
% 3D --> 2D
utvid.Tracking.Xpred = getAllRep( utvid.Tracking.Xpred, utvid.Tracking.n, utvid.Tracking.Kal.Xpred(1:end/2,utvid.Tracking.n), ...
    utvid.Tracking.Kal.Cpred(1:end/2,1:end/2,utvid.Tracking.n), utvid.Pstruct);

% Transform Kal.Xpred current frame + 1 to Tracking.Xpred structure
% 3D --> 2D
utvid.Tracking.Xpred = getAllRep( utvid.Tracking.Xpred, utvid.Tracking.n+1, utvid.Tracking.Kal.Xpred(1:end/2,utvid.Tracking.n+1), ...
    utvid.Tracking.Kal.Cpred(1:end/2,1:end/2,utvid.Tracking.n+1), utvid.Pstruct);

%% plotting the new frames in the GUI
space = 50; % extra space x, and y for plotting

if utvid.Tracking.plotting == 1
    % plotting shape markers
    cla(handles.hax{1,1});
    axes(handles.hax{1,1}), hold on
    nmar = utvid.settings.nrMarkers;
    ncam = utvid.Tracking.nrcams;
    
    h11 = imshow(utvid.Tracking.(utvid.Tracking.frames{1}),[]);
% %         h11 = imshow(utvid.Tracking.([utvid.Tracking.frames{1} 'orig']),[]);

    h12 = plot(utvid.Tracking.Xest.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x1(:,2,utvid.Tracking.n),'y+','linewidth',2);
    h13 = plot(utvid.Tracking.Xpred.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x1(:,2,utvid.Tracking.n),'ob');
    h14 = plot(utvid.Tracking.Kal.meas(1:nmar,utvid.Tracking.n), ...
               utvid.Tracking.Kal.meas(1+nmar*ncam:nmar*ncam+nmar,utvid.Tracking.n),'r.');
    
%     h14 = plot(utvid.Tracking.Kal.meas(1:utvid.settings.nrMarkers,utvid.Tracking.n), ...
%         utvid.Tracking.Kal.meas(utvid.settings.nrMarkers*utvid.Tracking.nrcams+1: ...
%         utvid.settings.nrMarkers*utvid.Tracking.nrcams+utvid.settings.nrMarkers,utvid.Tracking.n),'r.');
    mins = min(utvid.Tracking.Xest.x1(:,:,utvid.Tracking.n));
    maxs = max(utvid.Tracking.Xest.x1(:,:,utvid.Tracking.n));
    xlim([mins(1)-space maxs(1)+space]);
    ylim([mins(2)-space maxs(2)+space]);
    drawnow
    
    cla(handles.hax{1,2});
    axes(handles.hax{1,2}), hold on
    h21 = imshow(utvid.Tracking.(utvid.Tracking.frames{2}),[]);
% %         h21 = imshow(utvid.Tracking.([utvid.Tracking.frames{2}, 'orig']),[]);

    h22 = plot(utvid.Tracking.Xest.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x2(:,2,utvid.Tracking.n),'y+');
    h23 = plot(utvid.Tracking.Xpred.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x2(:,2,utvid.Tracking.n),'ob');
    h24 = plot(utvid.Tracking.Kal.meas(1+nmar:nmar*2,utvid.Tracking.n), ...
               utvid.Tracking.Kal.meas(1+nmar*ncam+nmar:nmar*ncam+2*nmar,utvid.Tracking.n),'r.');
    mins = min(utvid.Tracking.Xest.x2(:,:,utvid.Tracking.n));
    maxs = max(utvid.Tracking.Xest.x2(:,:,utvid.Tracking.n));
    xlim([mins(1)-space maxs(1)+space]);
    ylim([mins(2)-space maxs(2)+space]);
    drawnow
    
    if length(utvid.Tracking.frames)==3
        cla(handles.hax{1,3});
        axes(handles.hax{1,3}), hold on
        h31 = imshow(utvid.Tracking.(utvid.Tracking.frames{3}),[]);
% %                 h31 = imshow(utvid.Tracking.([utvid.Tracking.frames{3} 'orig']),[]);

        h32 = plot(utvid.Tracking.Xest.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x3(:,2,utvid.Tracking.n),'y+');
        h33 = plot(utvid.Tracking.Xpred.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x3(:,2,utvid.Tracking.n),'ob');
        h34 = plot(utvid.Tracking.Kal.meas(1+nmar*2:nmar*3,utvid.Tracking.n), ...
               utvid.Tracking.Kal.meas(1+nmar*ncam+nmar*2:nmar*ncam+3*nmar,utvid.Tracking.n),'r.');
        mins = min(utvid.Tracking.Xest.x3(:,:,utvid.Tracking.n));
        maxs = max(utvid.Tracking.Xest.x3(:,:,utvid.Tracking.n));
        xlim([mins(1)-space maxs(1)+space]);
        ylim([mins(2)-space maxs(2)+space]);
        drawnow
    end
    
    %% in case of orientation markers; plotting the orientation markers
    if utvid.settings.nrOrMar ~=0
        nmar = utvid.settings.nrOrMar;
        
        cla(handles.hax{2,1});
        axes(handles.hax{2,1}), hold on
%         h41 = imshow(utvid.Tracking.(utvid.Tracking.frames_or{1}),[]);
                 h41 = imshow(utvid.Tracking.([utvid.Tracking.frames{1}, 'orig']),[]);

        h42 = plot(utvid.Tracking.Xest_or.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xest_or.x1(:,2,utvid.Tracking.n),'y+');
        h43 = plot(utvid.Tracking.Xpred_or.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xpred_or.x1(:,2,utvid.Tracking.n),'ob');
        h44 = plot(utvid.Tracking.Kal_or.meas(1:nmar,utvid.Tracking.n), ...
               utvid.Tracking.Kal_or.meas(1+nmar*ncam:nmar*ncam+nmar,utvid.Tracking.n),'r.');
    
        mins = min(utvid.Tracking.Xest_or.x1(:,:,utvid.Tracking.n));
        maxs = max(utvid.Tracking.Xest_or.x1(:,:,utvid.Tracking.n));
        xlim([mins(1)-space maxs(1)+space]);
        ylim([mins(2)-space maxs(2)+space]);
        drawnow
        
        cla(handles.hax{2,2});
        axes(handles.hax{2,2}), hold on
%         h51 = imshow(utvid.Tracking.(utvid.Tracking.frames_or{2}),[]);
        h51 = imshow(utvid.Tracking.([utvid.Tracking.frames{2}, 'orig']),[]);
        
        h52 = plot(utvid.Tracking.Xest_or.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xest_or.x2(:,2,utvid.Tracking.n),'y+');
        h53 = plot(utvid.Tracking.Xpred_or.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xpred_or.x2(:,2,utvid.Tracking.n),'ob');
        h54 =  plot(utvid.Tracking.Kal_or.meas(1+nmar:nmar*2,utvid.Tracking.n), ...
               utvid.Tracking.Kal_or.meas(1+nmar*ncam+nmar:nmar*ncam+2*nmar,utvid.Tracking.n),'r.');
        mins = min(utvid.Tracking.Xest_or.x2(:,:,utvid.Tracking.n));
        maxs = max(utvid.Tracking.Xest_or.x2(:,:,utvid.Tracking.n));
        xlim([mins(1)-space maxs(1)+space]);
        ylim([mins(2)-space maxs(2)+space]);
        drawnow
        
        if length(utvid.Tracking.frames_or) == 3
            cla(handles.hax{2,3});
            axes(handles.hax{2,3}), hold on
%             h61 = imshow(utvid.Tracking.(utvid.Tracking.frames_or{3}),[]);
            h61 = imshow(utvid.Tracking.([utvid.Tracking.frames{3}, 'orig']),[]);
            
            h62 = plot(utvid.Tracking.Xest_or.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xest_or.x3(:,2,utvid.Tracking.n),'y+');
            h63 = plot(utvid.Tracking.Xpred_or.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xpred_or.x3(:,2,utvid.Tracking.n),'ob');
            h64 =   plot(utvid.Tracking.Kal_or.meas(1+nmar*2:nmar*3,utvid.Tracking.n), ...
               utvid.Tracking.Kal_or.meas(1+nmar*ncam+nmar*2:nmar*ncam+3*nmar,utvid.Tracking.n),'r.');
            mins = min(utvid.Tracking.Xest_or.x3(:,:,utvid.Tracking.n));
            maxs = max(utvid.Tracking.Xest_or.x3(:,:,utvid.Tracking.n));
            xlim([mins(1)-space maxs(1)+space]);
            ylim([mins(2)-space maxs(2)+space]);
            drawnow
        end
    end
    
end

%% PCA Expansion
% Use estimated shape markers for pca expansion
z = utvid.Tracking.Xest.X(:,:,utvid.Tracking.n); % get estimated coordinates
z = reshape(z,[size(z,1)*size(z,2),1]); % reshape to one vector
% get Rotation
R = utvid.Tracking.T(1:3,1:3,utvid.Tracking.instr,utvid.Tracking.n);
% get extended Rotation
Rrext = getRext(R, utvid.settings.nrMarkers);
% Rotated measured 3D coordinates
zR = Rrext*z;
% Add translation
zCor = [zR(1:utvid.settings.nrMarkers)+utvid.Tracking.T(1,4,utvid.Tracking.instr,utvid.Tracking.n); ...
    zR(utvid.settings.nrMarkers+1:2*utvid.settings.nrMarkers)+  utvid.Tracking.T(2,4,utvid.Tracking.instr,utvid.Tracking.n);...
    zR(2*utvid.settings.nrMarkers+1:3*utvid.settings.nrMarkers)+utvid.Tracking.T(3,4,utvid.Tracking.instr,utvid.Tracking.n)];
% normalize zCor
zCor = zCor-utvid.pca.meanX;
if utvid.pca.Normed == 1
    zCor = utvid.pca.Gamma\zCor;
end
% calculate mahalonobis distance
bN = utvid.pca.V(:,1:utvid.settings.PCs)' * zCor;
D = bN'*inv(utvid.pca.Cb(1:utvid.settings.PCs,1:utvid.settings.PCs))*bN;

% Display the number of frames in PCA model, and the of the current frame
% to the PCA model
disp(['PCA size: ' num2str(size(utvid.pca.PCAcoords,2))])
disp(['PCA distance: ' num2str(D)]);

% Limit of accepting new frames in the PCA model. Using the chi squared
% distribution. The number of principle components is used as the degrees
% of freedom. The probability is set to 0.9.
if D >  utvid.Tracking.lim;
    % open pca expansion, show the measured coordinates and in case of
    % misplaced markers, correct them to assure the correct shape to be
    % added in the PCA model
    utvid = PCAExpansionMMSE2(utvid);
    
    % update PCA model
    utvid = pcaMMSE(utvid);
    
    %     %Space representations Prediction for next frame update.
    %     utvid.Tracking.Xpred = getAllRep( utvid.Tracking.Xpred, utvid.Tracking.n+1, utvid.Tracking.Kal.Xpred(1:end/2,utvid.Tracking.n+1), ...
    %         utvid.Tracking.Kal.Cpred(1:end/2,1:end/2,utvid.Tracking.n+1), utvid.Pstruct);
    %
end


end

