function utvid = Tracking(utvid,handles)
disp(['Frame: ' num2str(utvid.Tracking.n)])
% Update PCA model (if enough measurements regarding number of Principal components)
% if size(utvid.pca.PCAcoords,2) > 2*utvid.settings.PCs
% %     utvid = PCAmodelUpdate(utvid)
%
% end

% The original PCA model did not work for some reason. I implemented know
% our MMSE method. Original should be fixed and be available as an option.


%% Load frames 
% Load and show corresponding frames
utvid = loadFrames(utvid,handles);

%% Perform Measurment
%Measurement
utvid = measurement(utvid);
% % % try
% % % figure(1111);suptitle('Tracking.Xpred before update and outlier');
% % % subplot(1,3,1);imshow(utvid.Tracking.FrameL);hold on; plot(utvid.Tracking.Xpred.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x1(:,2,utvid.Tracking.n),'*r');
% % % plot(utvid.Tracking.Xpred.x1(:,1,utvid.Tracking.n+1),utvid.Tracking.Xpred.x1(:,2,utvid.Tracking.n+1),'+b');
% % % plot(utvid.Tracking.Kal.meas(1:10,utvid.Tracking.n),utvid.Tracking.Kal.meas(31:40,utvid.Tracking.n),'og');
% % % subplot(1,3,2);imshow(utvid.Tracking.FrameR);hold on; plot(utvid.Tracking.Xpred.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x2(:,2,utvid.Tracking.n),'*r');
% % % plot(utvid.Tracking.Xpred.x2(:,1,utvid.Tracking.n+1),utvid.Tracking.Xpred.x2(:,2,utvid.Tracking.n+1),'+b');
% % % plot(utvid.Tracking.Kal.meas(11:20,utvid.Tracking.n),utvid.Tracking.Kal.meas(41:50,utvid.Tracking.n),'og');
% % % subplot(1,3,3);imshow(utvid.Tracking.FrameM);hold on; plot(utvid.Tracking.Xpred.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x3(:,2,utvid.Tracking.n),'*r');
% % % plot(utvid.Tracking.Xpred.x3(:,1,utvid.Tracking.n+1),utvid.Tracking.Xpred.x3(:,2,utvid.Tracking.n+1),'+b');
% % % plot(utvid.Tracking.Kal.meas(21:30,utvid.Tracking.n),utvid.Tracking.Kal.meas(51:60,utvid.Tracking.n),'og');
% % % legend('Xpred','Xpred+1','Kal.meas');
% % % catch
% % % end


%% Update Kalman for orientation markers
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
    %             [utvid.pca.PCAmodel_rot, utvid.Tracking.Xest_or.Rext] = rotatePCA(utvid.pca.PCAmodel, utvid.Tracking.Xest_or.X,utvid.Tracking.n);
end

%% Update Kalman shape markers
%Prepare and update Kalman (estimaion is found here)
utvid.Tracking.Kal = prepareKalman3D(utvid.Tracking.Kal, utvid.Pstruct, utvid.Tracking.n);
utvid.Tracking.Kal = updateKal(utvid.Tracking.Kal, utvid.Tracking.n);

utvid.Tracking.Xest = getAllRep( utvid.Tracking.Xest, utvid.Tracking.n, utvid.Tracking.Kal.Xest(1:end/2,utvid.Tracking.n), ...
    utvid.Tracking.Kal.Cest(1:end/2,1:end/2,utvid.Tracking.n), utvid.Pstruct);

%% rotate shape markers to base_or
if utvid.settings.nrOrMar ~= 0
    % PCA rotation
    utvid.Tracking.T(:,:,utvid.Tracking.instr,utvid.Tracking.n) = rigid_transform_3D(utvid.Tracking.Xest_or.X(:,:,utvid.Tracking.n),utvid.Tracking.base_or);
    R = utvid.Tracking.T(1:3,1:3,utvid.Tracking.instr,utvid.Tracking.n);
    Rrext = getRext(R, utvid.settings.nrMarkers);
    % coor = [utvid.Tracking.Xest.X(:,1,utvid.Tracking.n);utvid.Tracking.Xest.X(:,2,utvid.Tracking.n);utvid.Tracking.Xest.X(:,3,utvid.Tracking.n)];
    coor = utvid.Tracking.Kal.Xest(1:utvid.settings.nrcams*utvid.settings.nrMarkers,utvid.Tracking.n);
    rot_coor = Rrext*coor;
    % add translation
    utvid.Tracking.rt_coor(:,utvid.Tracking.n) = [rot_coor(1:utvid.settings.nrMarkers)+utvid.Tracking.T(1,4,utvid.Tracking.instr,utvid.Tracking.n); ...
        rot_coor(utvid.settings.nrMarkers+1:2*utvid.settings.nrMarkers)+  utvid.Tracking.T(2,4,utvid.Tracking.instr,utvid.Tracking.n);...
        rot_coor(2*utvid.settings.nrMarkers+1:3*utvid.settings.nrMarkers)+utvid.Tracking.T(3,4,utvid.Tracking.instr,utvid.Tracking.n)];
end

%% perform outlier detection
if size(utvid.pca.PCAcoords,2) > 2*utvid.settings.PCs
    if utvid.pca.outlier == 0, disp('Outlier detection performed'), utvid.pca.outlier = 1; end
    if utvid.settings.nrOrMar ~= 0
        
        % MMSE outlierdetection
        [utvid,utvid.Tracking.rt_coor(:,utvid.Tracking.n),c] = outlierCorrectionMMSE(utvid,utvid.Tracking.rt_coor(:,utvid.Tracking.n));
        
        % back to original coordinate system in Kal.Xest - translation and - rotation
        rot_back = [utvid.Tracking.rt_coor(1:utvid.settings.nrMarkers,utvid.Tracking.n)-utvid.Tracking.T(1,4,utvid.Tracking.instr,utvid.Tracking.n); ...
            utvid.Tracking.rt_coor(utvid.settings.nrMarkers+1:2*utvid.settings.nrMarkers,utvid.Tracking.n)-  utvid.Tracking.T(2,4,utvid.Tracking.instr,utvid.Tracking.n);...
            utvid.Tracking.rt_coor(2*utvid.settings.nrMarkers+1:3*utvid.settings.nrMarkers,utvid.Tracking.n)-utvid.Tracking.T(3,4,utvid.Tracking.instr,utvid.Tracking.n)];
        coor_back = inv(Rrext)*rot_back;
        
        %     utvid.Tracking.Xest.X(:,1,utvid.Tracking.n)= [coor_back(1:utvid.settings.nrMarkers)
        %     utvid.Tracking.Xest.X(:,2,utvid.Tracking.n)= [coor_back(utvid.settings.nrMarkers+1:2*utvid.settings.nrMarkers)
        %     utvid.Tracking.Xest.X(:,3,utvid.Tracking.n)= [coor_back(2*utvid.settings.nrMarkers+1:3*utvid.settings.nrMarkers)
        %     test.Xpred = utvid.Tracking.Xpred;
        %     test.Xest = utvid.Tracking.Xest;
        %     test.Kal.meas = utvid.Tracking.Kal.meas(:,utvid.Tracking.n);
    
        % check for erroneous markers, if c is empty, no outliers detected
        if isempty(c) == 0  
            
        % zet predictie huidige frame naar de gecorrigeerde versie
% % %         utvid.Tracking.Kal.Xpred(1:3*utvid.settings.nrMarkers,utvid.Tracking.n)= coor_back;
        
        % 3D coordinates to 2D
        [c1,c2,c3,~,~,~]=threeDto2D_3cam(coor_back,utvid.Tracking.Kal.Cest(1:end/2,1:end/2),utvid.Pstruct);
        
        % correct measurement
        utvid.Tracking.Kal.meas(1:utvid.settings.nrMarkers,utvid.Tracking.n) = c1(1,:)';
        utvid.Tracking.Kal.meas(utvid.settings.nrMarkers+1:2*utvid.settings.nrMarkers,utvid.Tracking.n) = c2(1,:)';
        utvid.Tracking.Kal.meas(2*utvid.settings.nrMarkers+1:3*utvid.settings.nrMarkers,utvid.Tracking.n) = c3(1,:)';
        utvid.Tracking.Kal.meas(3*utvid.settings.nrMarkers+1:4*utvid.settings.nrMarkers,utvid.Tracking.n) = c1(2,:)';
        utvid.Tracking.Kal.meas(4*utvid.settings.nrMarkers+1:5*utvid.settings.nrMarkers,utvid.Tracking.n) = c2(2,:)';
        utvid.Tracking.Kal.meas(5*utvid.settings.nrMarkers+1:6*utvid.settings.nrMarkers,utvid.Tracking.n) = c3(2,:)';
   
      
        % update Kalman structure
        utvid.Tracking.Kal = prepareKalman3D(utvid.Tracking.Kal, utvid.Pstruct,utvid.Tracking.n);
        utvid.Tracking.Kal = updateKal(utvid.Tracking.Kal,utvid.Tracking.n);
       
   
        
        % only correct the outliers
% %         for cc = 1:length(c)
% %             % Correct prediction current frame
% %             utvid.Tracking.Kal.Xpred(c(cc),utvid.Tracking.n)= coor_back(c(cc),1);
% %             utvid.Tracking.Kal.Xpred(c(cc)+utvid.settings.nrMarkers,utvid.Tracking.n)= coor_back(c(cc)+utvid.settings.nrMarkers,1);
% %             utvid.Tracking.Kal.Xpred(c(cc)+2*utvid.settings.nrMarkers,utvid.Tracking.n)= coor_back(c(cc)+2*utvid.settings.nrMarkers,1);
% %             % Correct prediction current frame + 1
% %             utvid.Tracking.Kal.Xpred(c(cc),utvid.Tracking.n+1)= coor_back(c(cc),1);
% %             utvid.Tracking.Kal.Xpred(c(cc)+utvid.settings.nrMarkers,utvid.Tracking.n+1)= coor_back(c(cc)+utvid.settings.nrMarkers,1);
% %             utvid.Tracking.Kal.Xpred(c(cc)+2*utvid.settings.nrMarkers,utvid.Tracking.n+1)= coor_back(c(cc)+2*utvid.settings.nrMarkers,1);
% %     
% %             % Correct estimate
% %             utvid.Tracking.Kal.Xest(c(cc),utvid.Tracking.n) = coor_back(c(cc),1);
% %             utvid.Tracking.Kal.Xest(c(cc)+utvid.settings.nrMarkers,utvid.Tracking.n)= coor_back(c(cc)+utvid.settings.nrMarkers,1);
% %             utvid.Tracking.Kal.Xest(c(cc)+2*utvid.settings.nrMarkers,utvid.Tracking.n)= coor_back(c(cc)+2*utvid.settings.nrMarkers,1);
% % 
% %             % of willen we een Kalman update geven die de estimate aan de
% %             % hand van een verbeterde meting (en predictie) geeft?
% %             % Volgens mij gaat het door de onderstaande code mis; waarbij
% %             % je opeens de versnelling op 0 zet.
% %             
% % % % %             % Correct prediction acceleration; set to zero
% % % % %             utvid.Tracking.Kal.Xpred(3*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
% % % % %             utvid.Tracking.Kal.Xpred(4*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
% % % % %             utvid.Tracking.Kal.Xpred(5*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
% % 
% % % % %             % Correct estimation acceleration; set to zero
% % % % %             utvid.Tracking.Kal.Xest(3*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
% % % % %             utvid.Tracking.Kal.Xest(4*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
% % % % %             utvid.Tracking.Kal.Xest(5*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
% %         end
        
        end
    else
        [utvid,utvid.Tracking.Kal.Xest(:,utvid.Tracking.n)] = outlierCorrectionMMSE(utvid,utvid.Tracking.Kal.Xest(:,utvid.Tracking.n));
        utvid.Tracking.rt_coor = utvid.Tracking.Kal.Xest(1:utvid.settings.nrcams*utvid.settings.nrMarkers,:);
    end
end

% % % try
% % % figure(222);suptitle('Tracking.Xpred before update')
% % % subplot(2,3,1);imshow(utvid.Tracking.FrameL);hold on; plot(utvid.Tracking.Xpred.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x1(:,2,utvid.Tracking.n),'*r');
% % % plot(utvid.Tracking.Xpred.x1(:,1,utvid.Tracking.n+1),utvid.Tracking.Xpred.x1(:,2,utvid.Tracking.n+1),'+b');
% % % subplot(2,3,2);imshow(utvid.Tracking.FrameR);hold on; plot(utvid.Tracking.Xpred.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x2(:,2,utvid.Tracking.n),'*r');
% % % plot(utvid.Tracking.Xpred.x2(:,1,utvid.Tracking.n+1),utvid.Tracking.Xpred.x2(:,2,utvid.Tracking.n+1),'+b');
% % % subplot(2,3,3);imshow(utvid.Tracking.FrameM);hold on; plot(utvid.Tracking.Xpred.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x3(:,2,utvid.Tracking.n),'*r');
% % % plot(utvid.Tracking.Xpred.x3(:,1,utvid.Tracking.n+1),utvid.Tracking.Xpred.x3(:,2,utvid.Tracking.n+1),'+b');
% % % catch 
% % % end

%% Space representations Estimations
% Transform Kal.Xest to Tracking.Xest structure
utvid.Tracking.Xest  = getAllRep( utvid.Tracking.Xest, utvid.Tracking.n, utvid.Tracking.Kal.Xest(1:end/2,utvid.Tracking.n), ...
    utvid.Tracking.Kal.Cest(1:end/2,1:end/2,utvid.Tracking.n), utvid.Pstruct);

% Transform Kal.Xpred current frame to Tracking.Xpred structure
utvid.Tracking.Xpred = getAllRep( utvid.Tracking.Xpred, utvid.Tracking.n, utvid.Tracking.Kal.Xpred(1:end/2,utvid.Tracking.n), ...
    utvid.Tracking.Kal.Cpred(1:end/2,1:end/2,utvid.Tracking.n), utvid.Pstruct);

% Transform Kal.Xpred current frame + 1 to Tracking.Xpred structure
utvid.Tracking.Xpred = getAllRep( utvid.Tracking.Xpred, utvid.Tracking.n+1, utvid.Tracking.Kal.Xpred(1:end/2,utvid.Tracking.n+1), ...
    utvid.Tracking.Kal.Cpred(1:end/2,1:end/2,utvid.Tracking.n+1), utvid.Pstruct);

% % % % try
% % % % subplot(2,3,4);imshow(utvid.Tracking.FrameL);hold on; plot(utvid.Tracking.Xpred.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x1(:,2,utvid.Tracking.n),'+g');
% % % % plot(utvid.Tracking.Xpred.x1(:,1,utvid.Tracking.n+1),utvid.Tracking.Xpred.x1(:,2,utvid.Tracking.n+1),'+b');
% % % % subplot(2,3,5);imshow(utvid.Tracking.FrameR);hold on; plot(utvid.Tracking.Xpred.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x2(:,2,utvid.Tracking.n),'+g');
% % % % plot(utvid.Tracking.Xpred.x2(:,1,utvid.Tracking.n+1),utvid.Tracking.Xpred.x2(:,2,utvid.Tracking.n+1),'+b');
% % % % subplot(2,3,6);imshow(utvid.Tracking.FrameM);hold on; plot(utvid.Tracking.Xpred.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x3(:,2,utvid.Tracking.n),'+g');
% % % % plot(utvid.Tracking.Xpred.x3(:,1,utvid.Tracking.n+1),utvid.Tracking.Xpred.x3(:,2,utvid.Tracking.n+1),'+b');
% % % % catch
% % % % end


%% plotting
if utvid.Tracking.plotting == 1
    
    %     try delete(handles.hax{1,1},handles.hax{1,2},handles.hax{1,3}); catch ;end
    cla(handles.hax{1,1});
    axes(handles.hax{1,1}), hold on
    h11 = imshow(utvid.Tracking.FrameL,[]);
    h12 = plot(utvid.Tracking.Xest.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x1(:,2,utvid.Tracking.n),'y+','linewidth',2);
    h13 = plot(utvid.Tracking.Xpred.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x1(:,2,utvid.Tracking.n),'ob');
    h14 = plot(utvid.Tracking.Kal.meas(1:utvid.settings.nrMarkers,utvid.Tracking.n), ...
        utvid.Tracking.Kal.meas(utvid.settings.nrMarkers*3+1:utvid.settings.nrMarkers*4,utvid.Tracking.n),'r.');
    %     plot(utvid.Tracking.Xest.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x1(:,2,utvid.Tracking.n),'go')
    %      plot(test.Xest.x1(:,1,utvid.Tracking.n),test.Xest.x1(:,2,utvid.Tracking.n),'m+','linewidth',2);
    %      plot(test.Xpred.x1(:,1,utvid.Tracking.n),test.Xpred.x1(:,2,utvid.Tracking.n),'oc');
    %      plot(test.Kal.meas(1:utvid.settings.nrMarkers), ...
    %        test.Kal.meas(utvid.settings.nrMarkers*3+1:utvid.settings.nrMarkers*4),'g.');
    %
    mins = min(utvid.Tracking.Xest.x1(:,:,utvid.Tracking.n));
    maxs = max(utvid.Tracking.Xest.x1(:,:,utvid.Tracking.n));
    xlim([mins(1)-25 maxs(1)+25]);
    ylim([mins(2)-25 maxs(2)+25]);
    drawnow
    
    %     utvid.Tracking.Xest.x1(6,:,utvid.Tracking.n)
    %     utvid.Tracking.Xpred.x1(6,:,utvid.Tracking.n)
    %     [utvid.Tracking.Kal.meas(6,utvid.Tracking.n),utvid.Tracking.Kal.meas(36,utvid.Tracking.n)]
    
    cla(handles.hax{1,2});
    axes(handles.hax{1,2}), hold on
    h21 = imshow(utvid.Tracking.FrameR,[]);
    h22 = plot(utvid.Tracking.Xest.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x2(:,2,utvid.Tracking.n),'y+');
    h23 = plot(utvid.Tracking.Xpred.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x2(:,2,utvid.Tracking.n),'ob');
    h24 = plot(utvid.Tracking.Kal.meas(utvid.settings.nrMarkers+1:utvid.settings.nrMarkers*2,utvid.Tracking.n),...
        utvid.Tracking.Kal.meas(utvid.settings.nrMarkers*4+1:utvid.settings.nrMarkers*5,utvid.Tracking.n),'r.');
    %     plot(utvid.Tracking.Xest.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x2(:,2,utvid.Tracking.n),'go')
    mins = min(utvid.Tracking.Xest.x2(:,:,utvid.Tracking.n));
    maxs = max(utvid.Tracking.Xest.x2(:,:,utvid.Tracking.n));
    xlim([mins(1)-25 maxs(1)+25]);
    ylim([mins(2)-25 maxs(2)+25]);
    drawnow
    
    cla(handles.hax{1,3});
    axes(handles.hax{1,3}), hold on
    h31 = imshow(utvid.Tracking.FrameM,[]);
    h32 = plot(utvid.Tracking.Xest.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x3(:,2,utvid.Tracking.n),'y+');
    h33 = plot(utvid.Tracking.Xpred.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xpred.x3(:,2,utvid.Tracking.n),'ob');
    h34 = plot(utvid.Tracking.Kal.meas(utvid.settings.nrMarkers*2+1:utvid.settings.nrMarkers*3,utvid.Tracking.n),...
        utvid.Tracking.Kal.meas(utvid.settings.nrMarkers*5+1:utvid.settings.nrMarkers*6,utvid.Tracking.n),'r.');
    %     plot(utvid.Tracking.Xest.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x3(:,2,utvid.Tracking.n),'go')
    mins = min(utvid.Tracking.Xest.x3(:,:,utvid.Tracking.n));
    maxs = max(utvid.Tracking.Xest.x3(:,:,utvid.Tracking.n));
    xlim([mins(1)-25 maxs(1)+25]);
    ylim([mins(2)-25 maxs(2)+25]);
    drawnow
    
    if utvid.settings.nrOrMar ~=0
        %         try delete(handles.hax{2,1},handles.hax{2,2},handles.hax{2,3}); catch ;end
        cla(handles.hax{2,1});
        axes(handles.hax{2,1}), hold on
        h41 = imshow(utvid.Tracking.FrameL,[]);
        h42 = plot(utvid.Tracking.Xest_or.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xest_or.x1(:,2,utvid.Tracking.n),'y+');
        h43 = plot(utvid.Tracking.Xpred_or.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xpred_or.x1(:,2,utvid.Tracking.n),'ob');
        h44 = plot(utvid.Tracking.Kal_or.meas(1:utvid.settings.nrOrMar,utvid.Tracking.n), ...
            utvid.Tracking.Kal_or.meas(utvid.settings.nrOrMar*3+1:utvid.settings.nrOrMar*4,utvid.Tracking.n),'r.');
        %         plot(utvid.Tracking.Xest_or.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xest_or.x1(:,2,utvid.Tracking.n),'go')
        mins = min(utvid.Tracking.Xest_or.x1(:,:,utvid.Tracking.n));
        maxs = max(utvid.Tracking.Xest_or.x1(:,:,utvid.Tracking.n));
        xlim([mins(1)-25 maxs(1)+25]);
        ylim([mins(2)-25 maxs(2)+25]);
        drawnow
        
        cla(handles.hax{2,2});
        axes(handles.hax{2,2}), hold on
        h51 = imshow(utvid.Tracking.FrameR,[]);
        h52 = plot(utvid.Tracking.Xest_or.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xest_or.x2(:,2,utvid.Tracking.n),'y+');
        h53 = plot(utvid.Tracking.Xpred_or.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xpred_or.x2(:,2,utvid.Tracking.n),'ob');
        h54 = plot(utvid.Tracking.Kal_or.meas(utvid.settings.nrOrMar+1:utvid.settings.nrOrMar*2,utvid.Tracking.n),...
            utvid.Tracking.Kal_or.meas(utvid.settings.nrOrMar*4+1:utvid.settings.nrOrMar*5,utvid.Tracking.n),'r.');
        %         plot(utvid.Tracking.Xest_or.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xest_or.x2(:,2,utvid.Tracking.n),'go')
        mins = min(utvid.Tracking.Xest_or.x2(:,:,utvid.Tracking.n));
        maxs = max(utvid.Tracking.Xest_or.x2(:,:,utvid.Tracking.n));
        xlim([mins(1)-25 maxs(1)+25]);
        ylim([mins(2)-25 maxs(2)+25]);
        drawnow
        
        cla(handles.hax{2,3});
        axes(handles.hax{2,3}), hold on
        h61 = imshow(utvid.Tracking.FrameM,[]);
        h62 = plot(utvid.Tracking.Xest_or.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xest_or.x3(:,2,utvid.Tracking.n),'y+');
        h63 = plot(utvid.Tracking.Xpred_or.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xpred_or.x3(:,2,utvid.Tracking.n),'ob');
        h64 = plot(utvid.Tracking.Kal_or.meas(utvid.settings.nrOrMar*2+1:utvid.settings.nrOrMar*3,utvid.Tracking.n),...
            utvid.Tracking.Kal_or.meas(utvid.settings.nrOrMar*5+1:utvid.settings.nrOrMar*6,utvid.Tracking.n),'r.');
        %         plot(utvid.Tracking.Xest_or.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xest_or.x3(:,2,utvid.Tracking.n),'go')
        mins = min(utvid.Tracking.Xest_or.x3(:,:,utvid.Tracking.n));
        maxs = max(utvid.Tracking.Xest_or.x3(:,:,utvid.Tracking.n));
        xlim([mins(1)-25 maxs(1)+25]);
        ylim([mins(2)-25 maxs(2)+25]);
        drawnow
    end
    
end

%% PCA Expansion
% lim should be set in GUI
D = min(pdist2(utvid.Tracking.rt_coor(:,utvid.Tracking.n)',utvid.pca.PCAcoords'));

disp(['PCAsize: ' num2str(size(utvid.pca.PCAcoords,2))])
disp(['PCs: ' num2str(utvid.settings.PCs)])
disp(['Error: ' num2str(D)]);
disp(['Lim: ' num2str(utvid.Tracking.lim)]);
if D > utvid.Tracking.lim
    % Correct possible faulty markers
    utvid = PCAExpansionMMSE2(utvid);
    
    %     [utvid.pca.PCAcoords,utvid.Tracking.Xest,utvid.Tracking.Kal,utvid.pca.info] ...
    %         = PCAExpansionMMSE(utvid.Tracking.FrameL,utvid.Tracking.FrameR,...
    %         utvid.Tracking.FrameM,utvid.Tracking.n,utvid.pca.PCAcoords,...
    %         utvid.Tracking.Kal,utvid.Tracking.Xest,utvid.Pstruct,utvid.Tracking.lim,utvid);
    % update PCA model
    utvid = pcaMMSE(utvid);
   
    %Space representations Prediction
    utvid.Tracking.Xpred = getAllRep( utvid.Tracking.Xpred, utvid.Tracking.n+1, utvid.Tracking.Kal.Xpred(1:end/2,utvid.Tracking.n+1), ...
    utvid.Tracking.Kal.Cpred(1:end/2,1:end/2,utvid.Tracking.n+1), utvid.Pstruct);

end


end

