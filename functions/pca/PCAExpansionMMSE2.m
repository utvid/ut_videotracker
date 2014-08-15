function [utvid] = PCAExpansionMMSE2(utvid)

imnL = utvid.Tracking.FrameL; imnR = utvid.Tracking.FrameR; imnM = utvid.Tracking.FrameM;
n = utvid.Tracking.n;
c1 = [];
c2 = [];
c3 = [];
if utvid.settings.nrOrMar ~= 0
    figure(111)
    subplot(1,3,1), set(gcf, 'Position', get(0,'Screensize'));
    imshow(imnL,[]),
    hold on, plot(utvid.Tracking.Xest_or.x1(:,1,n),utvid.Tracking.Xest_or.x1(:,2,n),'r*');
    mins = min(utvid.Tracking.Xest_or.x1);
    maxs = max(utvid.Tracking.Xest_or.x1);
    xlim([mins(1)-25 maxs(1)+25]);
    ylim([mins(2)-25 maxs(2)+25])
    
    subplot(1,3,2), imshow(imnR,[]),
    hold on, plot(utvid.Tracking.Xest_or.x2(:,1,n),utvid.Tracking.Xest_or.x2(:,2,n),'r*');
    mins = min(utvid.Tracking.Xest_or.x2);
    maxs = max(utvid.Tracking.Xest_or.x2);
    xlim([mins(1)-25 maxs(1)+25]);
    ylim([mins(2)-25 maxs(2)+25])
    
    subplot(1,3,3), imshow(imnM,[]),
    hold on, plot(utvid.Tracking.Xest_or.x3(:,1,n),utvid.Tracking.Xest_or.x3(:,2,n),'r*');
    mins = min(utvid.Tracking.Xest_or.x3);
    maxs = max(utvid.Tracking.Xest_or.x3);
    xlim([mins(1)-25 maxs(1)+25]);
    ylim([mins(2)-25 maxs(2)+25]);
    
    choice = questdlg('Orientation markers located correct', 'User input', ...
        'Yes','No','No');
    switch choice
        case 'Yes'
            close(111)
        case 'No'
            close(111)
            [utvid.Tracking.Xest_or.x1(:,:,n),c1] = correctPoints(imnL,utvid.settings.nrOrMar,utvid.Tracking.Xest_or.x1(:,:,n),'orientation');
            [utvid.Tracking.Xest_or.x2(:,:,n),c2] = correctPoints(imnR,utvid.settings.nrOrMar,utvid.Tracking.Xest_or.x2(:,:,n),'orientation');
            [utvid.Tracking.Xest_or.x3(:,:,n),c3] = correctPoints(imnM,utvid.settings.nrOrMar,utvid.Tracking.Xest_or.x3(:,:,n),'orientation');
            
            %% Correct markers
            c = unique([c1,c2,c3]);
            if length(c)>0
                
                % correct Kal.meas
                utvid.Tracking.Kal_or.meas(:,utvid.Tracking.n) = [utvid.Tracking.Xest_or.x1(:,1,utvid.Tracking.n); ...
                    utvid.Tracking.Xest_or.x2(:,1,utvid.Tracking.n);...
                    utvid.Tracking.Xest_or.x3(:,1,utvid.Tracking.n);...
                    utvid.Tracking.Xest_or.x1(:,2,utvid.Tracking.n);...
                    utvid.Tracking.Xest_or.x2(:,2,utvid.Tracking.n);...
                    utvid.Tracking.Xest_or.x3(:,2,utvid.Tracking.n)];
                
                %
                [vec3d,~] = twoDto3D_3cam(utvid.Tracking.Kal_or.meas(:,utvid.Tracking.n),0,utvid.Pstruct_or.Pext);
                
                % zet predictie naar de gecorrigeerde versie
                utvid.Tracking.Kal_or.Xpred(1:3*utvid.settings.nrOrMar,utvid.Tracking.n)= vec3d;
                
                % update Kal or structure
                utvid.Tracking.Kal_or = prepareKalman3D(utvid.Tracking.Kal_or, utvid.Pstruct_or,n);
                utvid.Tracking.Kal_or = updateKal(utvid.Tracking.Kal_or,n);
                
                % %                 for cc = 1:length(c)
                % %
                % %                     utvid.Tracking.Kal_or.Xpred(c(cc),utvid.Tracking.n+1)= vec3d(c(cc));
                % %                     utvid.Tracking.Kal_or.Xpred(utvid.settings.nrOrMar+c(cc),utvid.Tracking.n+1)= vec3d(c(cc)+utvid.settings.nrOrMar);
                % %                     utvid.Tracking.Kal_or.Xpred(2*utvid.settings.nrOrMar+c(cc),utvid.Tracking.n+1)= vec3d(c(cc)+2*utvid.settings.nrOrMar);
                % %
                % %                     % % %                 utvid.Tracking.Kal_or.Xpred(3*utvid.settings.nrOrMar+c(cc),utvid.Tracking.n) = 0;
                % %                     % % %                 utvid.Tracking.Kal_or.Xpred(4*utvid.settings.nrOrMar+c(cc),utvid.Tracking.n) = 0;
                % %                     % % %                 utvid.Tracking.Kal_or.Xpred(5*utvid.settings.nrOrMar+c(cc),utvid.Tracking.n) = 0;
                % %                     % % %
                % %                     % % %                 utvid.Tracking.Kal_or.Xpred(3*utvid.settings.nrOrMar+c(cc),utvid.Tracking.n+1) = 0;
                % %                     % % %                 utvid.Tracking.Kal_or.Xpred(4*utvid.settings.nrOrMar+c(cc),utvid.Tracking.n+1) = 0;
                % %                     % % %                 utvid.Tracking.Kal_or.Xpred(5*utvid.settings.nrOrMar+c(cc),utvid.Tracking.n+1) = 0;
                % %                     % % %
                % %                     % % %                 utvid.Tracking.Kal_or.Xest(3*utvid.settings.nrOrMar+c(cc),utvid.Tracking.n) = 0;
                % %                     % % %                 utvid.Tracking.Kal_or.Xest(4*utvid.settings.nrOrMar+c(cc),utvid.Tracking.n) = 0;
                % %                     % % %                 utvid.Tracking.Kal_or.Xest(5*utvid.settings.nrOrMar+c(cc),utvid.Tracking.n) = 0;
                % %
                % %                     % zet estimate naar de gecorrigeerde versie
                % %                     utvid.Tracking.Kal_or.Xest(c(cc),utvid.Tracking.n)= vec3d(c(cc));
                % %                     utvid.Tracking.Kal_or.Xest(utvid.settings.nrOrMar+c(cc),utvid.Tracking.n)= vec3d(c(cc)+utvid.settings.nrOrMar);
                % %                     utvid.Tracking.Kal_or.Xest(2*utvid.settings.nrOrMar+c(cc),utvid.Tracking.n)= vec3d(c(cc)+2*utvid.settings.nrOrMar);
                % %
                % %
                % %                 end
            end
            utvid.Tracking.Xest_or     = getSpatialRep(utvid.Tracking.Xest_or, n, utvid.Tracking.Kal_or.Xest(1:end/2,n), utvid.Tracking.Kal_or.Cest(1:end/2,1:end/2,n), utvid.Pstruct_or);
            utvid.Tracking.Xpred_or     = getSpatialRep(utvid.Tracking.Xpred_or, n, utvid.Tracking.Kal_or.Xpred(1:end/2,n), utvid.Tracking.Kal_or.Cest(1:end/2,1:end/2,n), utvid.Pstruct_or);
            utvid.Tracking.Xpred_or     = getSpatialRep(utvid.Tracking.Xpred_or, n+1, utvid.Tracking.Kal_or.Xpred(1:end/2,n), utvid.Tracking.Kal_or.Cest(1:end/2,1:end/2,n), utvid.Pstruct_or);
            
            
    end
    
    
end

c =[];
c1 = [];
c2 = [];
c3 = [];

h1 = figure; set(gcf, 'Position', get(0,'Screensize'));
imshow(imnL,[]); hold on
h2 = plot(utvid.Tracking.Xest.x1(:,1,n),utvid.Tracking.Xest.x1(:,2,n),'*r');
mins = min(utvid.Tracking.Xest.x1(:,:,n));
maxs = max(utvid.Tracking.Xest.x1(:,:,n));
xlim([mins(1)-25 maxs(1)+25]);
ylim([mins(2)-25 maxs(2)+25])
set(h1,'Position',get(0,'screensize'));

choice = questdlg('Markers located correct', 'User input', ...
    'Yes','No','No');
switch choice
    case 'Yes'
        close(h1)
    case 'No'
        close(h1)
        [utvid.Tracking.Xest.x1(:,:,n),c1] = correctPoints(imnL,utvid.settings.nrMarkers,utvid.Tracking.Xest.x1(:,:,n),'shape');
        
end

h1 = figure; set(gcf, 'Position', get(0,'Screensize'));
imshow(imnR,[]);  hold on
h2 = plot(utvid.Tracking.Xest.x2(:,1,n),utvid.Tracking.Xest.x2(:,2,n),'*r');
mins = min(utvid.Tracking.Xest.x2(:,:,n));
maxs = max(utvid.Tracking.Xest.x2(:,:,n));
xlim([mins(1)-25 maxs(1)+25]);
ylim([mins(2)-25 maxs(2)+25])
set(h1,'Position',get(0,'screensize'));

choice = questdlg('Markers located correct', 'User input', ...
    'Yes','No','No');
switch choice
    case 'Yes'
        close(h1)
    case 'No'
        close(h1)
        [utvid.Tracking.Xest.x2(:,:,n),c2] = correctPoints(imnR,utvid.settings.nrMarkers,utvid.Tracking.Xest.x2(:,:,n),'shape');
        
end

h1 = figure; set(gcf, 'Position', get(0,'Screensize'));
imshow(imnM,[]);  hold on
h2 = plot(utvid.Tracking.Xest.x3(:,1,n),utvid.Tracking.Xest.x3(:,2,n),'*r');
mins = min(utvid.Tracking.Xest.x3(:,:,n));
maxs = max(utvid.Tracking.Xest.x3(:,:,n));
xlim([mins(1)-25 maxs(1)+25]);
ylim([mins(2)-25 maxs(2)+25])
set(h1,'Position',get(0,'screensize'));

choice = questdlg('Markers located correct', 'User input', ...
    'Yes','No','No');
switch choice
    case 'Yes'
        close(h1)
    case 'No'
        close(h1)
        [utvid.Tracking.Xest.x3(:,:,n),c3] = correctPoints(imnM,utvid.settings.nrMarkers,utvid.Tracking.Xest.x3(:,:,n),'shape');
        
end


c = unique([c1,c2,c3]);
%% correct shape markers
if length(c)>0
    
    % correct kal.meas
    utvid.Tracking.Kal.meas(:,utvid.Tracking.n) = [utvid.Tracking.Xest.x1(:,1,utvid.Tracking.n); ...
        utvid.Tracking.Xest.x2(:,1,utvid.Tracking.n);...
        utvid.Tracking.Xest.x3(:,1,utvid.Tracking.n);...
        utvid.Tracking.Xest.x1(:,2,utvid.Tracking.n);...
        utvid.Tracking.Xest.x2(:,2,utvid.Tracking.n);...
        utvid.Tracking.Xest.x3(:,2,utvid.Tracking.n)];
    
    [vec3d,~] = twoDto3D_3cam(utvid.Tracking.Kal.meas(:,utvid.Tracking.n),0,utvid.Pstruct.Pext);
    
    % zet predictie naar de gecorrigeerde versie
    utvid.Tracking.Kal.Xpred(1:3*utvid.settings.nrMarkers,utvid.Tracking.n)= vec3d;
    
    % update Kal or structure
    utvid.Tracking.Kal = prepareKalman3D(utvid.Tracking.Kal, utvid.Pstruct,n);
    utvid.Tracking.Kal = updateKal(utvid.Tracking.Kal,n);
    
    
    % %     for cc = 1:length(c)
    % %
    % % %         utvid.Tracking.Kal.Xpred(c(cc),utvid.Tracking.n+1)= vec3d(c(cc));
    % % %         utvid.Tracking.Kal.Xpred(utvid.settings.nrMarkers+c(cc),utvid.Tracking.n+1)= vec3d(c(cc)+utvid.settings.nrMarkers);
    % % %         utvid.Tracking.Kal.Xpred(2*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n+1)= vec3d(c(cc)+2*utvid.settings.nrMarkers);
    % %
    % %         % % %         utvid.Tracking.Kal.Xpred(3*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
    % %         % % %         utvid.Tracking.Kal.Xpred(4*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
    % %         % % %         utvid.Tracking.Kal.Xpred(5*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
    % %         % % %
    % %         % % %         utvid.Tracking.Kal.Xest(3*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
    % %         % % %         utvid.Tracking.Kal.Xest(4*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
    % %         % % %         utvid.Tracking.Kal.Xest(5*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
    % %
    % % % %         % zet estimate naar de gecorrigeerde versie
    % % % %         utvid.Tracking.Kal.Xest(c(cc),utvid.Tracking.n)= vec3d(c(cc));
    % % % %         utvid.Tracking.Kal.Xest(utvid.settings.nrMarkers+c(cc),utvid.Tracking.n)= vec3d(c(cc)+utvid.settings.nrMarkers);
    % % % %         utvid.Tracking.Kal.Xest(2*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n)= vec3d(c(cc)+2*utvid.settings.nrMarkers);
    % %     end
end

            
%% update Trackin Xest and Tracking Xpred structures current frame
utvid.Tracking.Xest = getAllRep(utvid.Tracking.Xest,utvid.Tracking.n, utvid.Tracking.Kal.Xest(1:end/2,utvid.Tracking.n), utvid.Tracking.Kal.Cest(1:end/2,1:end/2,utvid.Tracking.n), utvid.Pstruct);
utvid.Tracking.Xpred= getSpatialRep(utvid.Tracking.Xpred, n, utvid.Tracking.Kal.Xpred(1:end/2,n), utvid.Tracking.Kal.Cest(1:end/2,1:end/2,n), utvid.Pstruct);
          

%% compare new coordinates with PCA model
compVec = [utvid.Tracking.Kal.Xest(1:end/6,utvid.Tracking.n)';utvid.Tracking.Kal.Xest(end/6+1:end/6*2,utvid.Tracking.n)';utvid.Tracking.Kal.Xest(end/6*2+1:end/6*3,utvid.Tracking.n)';ones(1,utvid.settings.nrMarkers)];
% rotate and translate
if utvid.settings.nrOrMar ~=0
    compVec = utvid.Tracking.T(:,:,utvid.Tracking.instr,utvid.Tracking.n)*compVec;
end
compVec = transpose(compVec(1:3,:)); compVec = compVec(:);
Dn = min(pdist2(compVec',utvid.pca.PCAcoords'));

pcainfo = utvid.pca.info;
pcacoords = utvid.pca.PCAcoords;
% if Dn > utvid.Tracking.lim/2 || utvid.pca.outlier == 0
%         PCAcoords = [PCAcoords,Kal.Xest(1:end/2,n)];
pcainfo = [pcainfo,[utvid.Tracking.instr;utvid.Tracking.n]];
pcacoords = [pcacoords,compVec];
utvid.pca.info = pcainfo;
utvid.pca.PCAcoords = pcacoords;
%         utvid.pca.PCAmodel = getPCAmodel(utvid);
% end

end