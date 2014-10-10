function [utvid] = PCAExpansionMMSE2(utvid)
% load the original frames (better visibility of markers)
for i = 1:utvid.Tracking.nrcams
    imn{i} = utvid.Tracking.([utvid.Tracking.frames{i} 'orig']);
end
n = utvid.Tracking.n; % current frame
space = 50;  % extra space for x and y coordinates in plot
% c1 = [];
% c2 = [];
% c3 = [];
%% in case of orientation markers
str = {'x1','x2'};
if utvid.Tracking.nrcams ==3
    str{3} = 'x3';
end
if utvid.settings.nrOrMar ~= 0
    % plot the orientation markers
    figure(111)
    
    for i = 1:utvid.Tracking.nrcams;
        subplot(1,utvid.Tracking.nrcams,i), set(gcf, 'Position', get(0,'Screensize'));
        imshow(imn{i},[]),
        % plot the estimated orientation markers
        hold on, plot(utvid.Tracking.Xest_or.(str{i})(:,1,n),utvid.Tracking.Xest_or.(str{i})(:,2,n),'r*');
        mins = min(utvid.Tracking.Xest_or.(str{i}));
        maxs = max(utvid.Tracking.Xest_or.(str{i}));
        xlim([mins(1)-space maxs(1)+space]);
        ylim([mins(2)-space maxs(2)+space])
        
    end
    
    choice = questdlg('Orientation markers located correct', 'User input', ...
        'Yes','No','No');
    switch choice
        case 'Yes'
            close(111)
        case 'No'
            close(111)
            % When the orientation markers are misplaced; use correctPoints
            % funtion to correct the markers.
            for i = 1:utvid.Tracking.nrcams
                [utvid.Tracking.Xest_or.(str{i})(:,:,n),c{i}] = correctPoints(imn{i},utvid.settings.nrOrMar,utvid.Tracking.Xest_or.(str{i})(:,:,n),'orientation');
            end
            
            %% Correct markers
            c = unique(cell2mat(c));
            if isempty(c)==0
                %% Correction
                % make 2D vector of new clicked coordinates
                vecX=[]; vecY = [];
                for i = 1:utvid.Tracking.nrcams;
                    vecX = [vecX;utvid.Tracking.Xest_or.(str{i})(:,1,n)];
                    vecY = [vecY;utvid.Tracking.Xest_or.(str{i})(:,2,n)];
                end
                vec2d = [vecX;vecY];
                % 2D to 3D transform into Kalman structure estimate
                
                if utvid.Tracking.nrcams ==3
                utvid.Tracking.Kal_or.Xest(1:18,utvid.Tracking.n) = twoDto3D_3cam(vec2d,0,utvid.Pstruct_or.Pext);
                else
                    utvid.Tracking.Kal_or.Xest(1:18,utvid.Tracking.n) = twoDto3D(vec2d,0,utvid.Pstruct_or.Pext);
                end
                utvid.Tracking.Kal_or.Xest(c+utvid.settings.nrcams*utvid.settings.nrOrMar,utvid.Tracking.n) = 0;
                utvid.Tracking.Kal_or.Xest(c+utvid.settings.nrcams*utvid.settings.nrOrMar+utvid.settings.nrOrMar,utvid.Tracking.n) = 0;
                utvid.Tracking.Kal_or.Xest(c+utvid.settings.nrcams*utvid.settings.nrOrMar+utvid.settings.nrOrMar*2,utvid.Tracking.n) = 0;
                
                % set prediction uncertainty to 1e6;
                utvid.Tracking.Kal_or.Cpred(c+18,c+18,utvid.Tracking.n+1) = 1e6;
                
                % update Kal or structure
                utvid.Tracking.Kal_or.Xpred(:,utvid.Tracking.n+1)    = utvid.Tracking.Kal_or.Xest(:,utvid.Tracking.n);
            end
            utvid.Tracking.Xest_or     = getSpatialRep(utvid.Tracking.Xest_or, n, utvid.Tracking.Kal_or.Xest(1:end/2,n), utvid.Tracking.Kal_or.Cest(1:end/2,1:end/2,n), utvid.Pstruct_or);
            utvid.Tracking.Xpred_or     = getSpatialRep(utvid.Tracking.Xpred_or, n, utvid.Tracking.Kal_or.Xpred(1:end/2,n), utvid.Tracking.Kal_or.Cest(1:end/2,1:end/2,n), utvid.Pstruct_or);
            utvid.Tracking.Xpred_or     = getSpatialRep(utvid.Tracking.Xpred_or, n+1, utvid.Tracking.Kal_or.Xpred(1:end/2,n), utvid.Tracking.Kal_or.Cest(1:end/2,1:end/2,n), utvid.Pstruct_or);
            
            
    end
    
    
end
%% The shape markers
c =[];

for i = 1:utvid.Tracking.nrcams
    % plot the shape markers
    h1 = figure; set(gcf, 'Position', get(0,'Screensize'));
    imshow(imn{i},[]); hold on
    h2 = plot(utvid.Tracking.Xest.(str{i})(:,1,n),utvid.Tracking.Xest.(str{i})(:,2,n),'*r');
    mins = min(utvid.Tracking.Xest.(str{i})(:,:,n));
    maxs = max(utvid.Tracking.Xest.(str{i})(:,:,n));
    xlim([mins(1)-space maxs(1)+space]);
    ylim([mins(2)-space maxs(2)+space])
    set(h1,'Position',get(0,'screensize'));
    
    
    choice = questdlg('Markers located correct', 'User input', ...
        'Yes','No','No');
    switch choice
        case 'Yes'
            close(h1)
        case 'No'
            close(h1)
            [utvid.Tracking.Xest.(str{i})(:,:,n),c{i}] = correctPoints(imn{i},utvid.settings.nrMarkers,utvid.Tracking.Xest.(str{i})(:,:,n),'shape');
    end
    
end

c = unique(cell2mat(c));
%% correct shape markers
if isempty(c)==0
    vecX=[]; vecY = [];
    for i = 1:utvid.Tracking.nrcams;
        vecX = [vecX;utvid.Tracking.Xest.(str{i})(:,1,n)];
        vecY = [vecY; utvid.Tracking.Xest.(str{i})(:,2,n)];
    end
    vec2d = [vecX;vecY];
    
    if utvid.Tracking.nrcams == 3;
        utvid.Tracking.Kal.Xest(1:30,utvid.Tracking.n) = twoDto3D_3cam(vec2d,0,utvid.Pstruct.Pext);
    else
        utvid.Tracking.Kal.Xest(1:30,utvid.Tracking.n) = twoDto3D(vec2d,0,utvid.Pstruct.Pext);
    end
        utvid.Tracking.Kal.Xest(c+30,utvid.Tracking.n) = 0;
        utvid.Tracking.Kal.Xest(c+40,utvid.Tracking.n) = 0;
        utvid.Tracking.Kal.Xest(c+50,utvid.Tracking.n) = 0;
        % set prediction uncertainty to 1e6;
        utvid.Tracking.Kal.Cpred(c+30,c+30,utvid.Tracking.n+1) = 1e6;
        % update Kal or structure
        utvid.Tracking.Kal.Xpred(:,utvid.Tracking.n+1)    = utvid.Tracking.Kal.Xest(:,utvid.Tracking.n); 
    end
 
    
    %% update Trackin Xest and Tracking Xpred structures current frame
    utvid.Tracking.Xest = getAllRep(utvid.Tracking.Xest,utvid.Tracking.n, utvid.Tracking.Kal.Xest(1:end/2,utvid.Tracking.n), utvid.Tracking.Kal.Cest(1:end/2,1:end/2,utvid.Tracking.n), utvid.Pstruct);
    utvid.Tracking.Xpred= getSpatialRep(utvid.Tracking.Xpred, n, utvid.Tracking.Kal.Xpred(1:end/2,n), utvid.Tracking.Kal.Cest(1:end/2,1:end/2,n), utvid.Pstruct);
    utvid.Tracking.Xpred= getSpatialRep(utvid.Tracking.Xpred, n+1, utvid.Tracking.Kal.Xpred(1:end/2,n+1), utvid.Tracking.Kal.Cest(1:end/2,1:end/2,n+1), utvid.Pstruct);
    
    
    %% compare new coordinates with PCA model
    compVec = [utvid.Tracking.Kal.Xest(1:end/6,utvid.Tracking.n)';utvid.Tracking.Kal.Xest(end/6+1:end/6*2,utvid.Tracking.n)';utvid.Tracking.Kal.Xest(end/6*2+1:end/6*3,utvid.Tracking.n)';ones(1,utvid.settings.nrMarkers)];
    % rotate and translate
    if utvid.settings.nrOrMar ~=0
        compVec = utvid.Tracking.T(:,:,utvid.Tracking.instr,utvid.Tracking.n)*compVec;
    end
    compVec = transpose(compVec(1:3,:)); compVec = compVec(:);
    
    % calculate mahalonobis distance
    zCor = compVec-utvid.pca.meanX;
    if utvid.pca.Normed == 1
        zCor = utvid.pca.Gamma\zCor;
    end
    bN = utvid.pca.V(:,1:utvid.settings.PCs)' * zCor;
    Dn = bN'*inv(utvid.pca.Cb(1:utvid.settings.PCs,1:utvid.settings.PCs))*bN;
    display(['PCA distance2: '  num2str(Dn)]);
    pcainfo = utvid.pca.info;
    pcacoords = utvid.pca.PCAcoords;
    if Dn >  chi2inv(0.75,utvid.settings.PCs) || utvid.pca.outlier == 0
        pcainfo = [pcainfo,[utvid.Tracking.instr;utvid.Tracking.n]];
        pcacoords = [pcacoords,compVec];
        utvid.pca.info = pcainfo;
        utvid.pca.PCAcoords = pcacoords;
    end
    
end