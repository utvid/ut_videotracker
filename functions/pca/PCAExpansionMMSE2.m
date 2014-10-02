function [utvid] = PCAExpansionMMSE2(utvid)

imnL = utvid.Tracking.FrameLorig; imnR = utvid.Tracking.FrameRorig; imnM = utvid.Tracking.FrameMorig;
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
                % make 2D vector of new clicked coordinates
                vec2d = [utvid.Tracking.Xest_or.x1(:,1,n);utvid.Tracking.Xest_or.x2(:,1,n);utvid.Tracking.Xest_or.x3(:,1,n);....
                    utvid.Tracking.Xest_or.x1(:,2,n);utvid.Tracking.Xest_or.x2(:,2,n);utvid.Tracking.Xest_or.x3(:,2,n)];
                % 2D to 3D transform into Kalman structure estimate
                utvid.Tracking.Kal_or.Xest(1:30,utvid.Tracking.n) = twoDto3D_3cam(vec2d,0,utvid.Pstruct_or.Pext);
                
                % update Kal or structure
                utvid.Tracking.Kal_or.Cpred(:,:,utvid.Tracking.n+1)  = utvid.Tracking.Kal_or.F*utvid.Tracking.Kal_or.Cest(:,:,utvid.Tracking.n)*utvid.Tracking.Kal_or.F' + utvid.Tracking.Kal_or.Cw;
                utvid.Tracking.Kal_or.Xpred(:,utvid.Tracking.n+1)    = utvid.Tracking.Kal_or.F*utvid.Tracking.Kal_or.Xest(:,utvid.Tracking.n);
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
    
    vec2d = [utvid.Tracking.Xest.x1(:,1,n);utvid.Tracking.Xest.x2(:,1,n);utvid.Tracking.Xest.x3(:,1,n);....
        utvid.Tracking.Xest.x1(:,2,n);utvid.Tracking.Xest.x2(:,2,n);utvid.Tracking.Xest.x3(:,2,n)];
    utvid.Tracking.Kal.Xest(1:30,utvid.Tracking.n) = twoDto3D_3cam(vec2d,0,utvid.Pstruct.Pext);
    
    utvid.Tracking.Kal.Cpred(c+30,c+30,utvid.Tracking.n+1) = 1e6;
    
    % update Kal or structure
    %     utvid.Tracking.Kal.Cpred(:,:,utvid.Tracking.n+1)  = utvid.Tracking.Kal.F*utvid.Tracking.Kal.Cest(:,:,utvid.Tracking.n)*utvid.Tracking.Kal.F' + utvid.Tracking.Kal.Cw;
    utvid.Tracking.Kal.Xpred(:,utvid.Tracking.n+1)    = utvid.Tracking.Kal.F*utvid.Tracking.Kal.Xest(:,utvid.Tracking.n);
    
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

% calculate mahalonobis distance
zCor = compVec-utvid.pca.meanX;
if utvid.pca.Normed == 1
    zCor = utvid.pca.Gamma\zCor;
end
% bN =  inv(utvid.pca.V(:,1:utvid.settings.PCs)'*utvid.pca.V(:,1:utvid.settings.PCs)+...
%         (utvid.pca.sigv^2*inv(utvid.pca.Cb(1:utvid.settings.PCs,1:utvid.settings.PCs))))...
%         *utvid.pca.V(:,1:utvid.settings.PCs)'*zCor;
% Dn = bN'*inv(utvid.pca.Cb(1:utvid.settings.PCs,1:utvid.settings.PCs))*bN;

bN = utvid.pca.V(:,1:utvid.settings.PCs)' * zCor;
Dn = bN'*inv(utvid.pca.Cb(1:utvid.settings.PCs,1:utvid.settings.PCs))*bN;

pcainfo = utvid.pca.info;
pcacoords = utvid.pca.PCAcoords;
if Dn >  chi2inv(0.75,utvid.settings.PCs) || utvid.pca.outlier == 0
    pcainfo = [pcainfo,[utvid.Tracking.instr;utvid.Tracking.n]];
    pcacoords = [pcacoords,compVec];
    utvid.pca.info = pcainfo;
    utvid.pca.PCAcoords = pcacoords;
end

end