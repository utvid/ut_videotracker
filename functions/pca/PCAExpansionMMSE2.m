function [utvid] = PCAExpansionMMSE(utvid)

imnL = utvid.Tracking.FrameL; imnR = utvid.Tracking.FrameR; imnM = utvid.Tracking.FrameM;
n = utvid.Tracking.n;
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
            utvid.Tracking.Xest_or.x1(:,:,n) = correctPoints(imnL,utvid.settings.nrOrMar,utvid.Tracking.Xest_or.x1(:,:,n),'orientation');
            utvid.Tracking.Xest_or.x2(:,:,n) = correctPoints(imnR,utvid.settings.nrOrMar,utvid.Tracking.Xest_or.x2(:,:,n),'orientation');
            utvid.Tracking.Xest_or.x3(:,:,n) = correctPoints(imnM,utvid.settings.nrOrMar,utvid.Tracking.Xest_or.x3(:,:,n),'orientation');
            
            Kal_or.meas(:,n) = [utvid.Tracking.Xest_or.x1(1,:,n)';utvid.Tracking.Xest_or.x2(1,:,n)';utvid.Tracking.Xest_or.x3(1,:,n)';utvid.Tracking.Xest_or.x1(2,:,n)';utvid.Tracking.Xest_or.x2(2,:,n)';utvid.Tracking.Xest_or.x3(2,:,n)'];
            Kal_or      = prepareKalman3D(utvid.Tracking.Kal_or, utvid.Pstruct_or, n);
            Kal_or      = updateKal(Kal_or, n);
            utvid.Tracking.Xest_or     = getSpatialRep(utvid.Tracking.Xest_or, n, Kal_or.Xest(1:end/2,n), Kal_or.Cest(1:end/2,1:end/2,n), utvid.Pstruct_or);
    end
    
end

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
c = unique([c1,c2,c3])

utvid.Tracking.Kal.meas(:,utvid.Tracking.n) = [utvid.Tracking.Xest.x1(:,1,utvid.Tracking.n); ...
                                               utvid.Tracking.Xest.x2(:,1,utvid.Tracking.n);...
                                               utvid.Tracking.Xest.x3(:,1,utvid.Tracking.n);...
                                               utvid.Tracking.Xest.x1(:,2,utvid.Tracking.n);...
                                               utvid.Tracking.Xest.x2(:,2,utvid.Tracking.n);...
                                               utvid.Tracking.Xest.x3(:,2,utvid.Tracking.n)];

[vec3d,~] = twoDto3D_3cam(utvid.Tracking.Kal.meas(:,utvid.Tracking.n),0,utvid.Pstruct.Pext);

% zet predictie naar de gecorrigeerde versie
utvid.Tracking.Kal.Xpred(1:3*utvid.settings.nrMarkers,utvid.Tracking.n)= vec3d;
utvid.Tracking.Kal.Xpred(1:3*utvid.settings.nrMarkers,utvid.Tracking.n+1)= vec3d;

for cc = 1:length(c)
    utvid.Tracking.Kal.Xpred(3*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
    utvid.Tracking.Kal.Xpred(4*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
    utvid.Tracking.Kal.Xpred(5*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
    
    utvid.Tracking.Kal.Xest(3*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
    utvid.Tracking.Kal.Xest(4*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
    utvid.Tracking.Kal.Xest(5*utvid.settings.nrMarkers+c(cc),utvid.Tracking.n) = 0;
end

% zet estimate naar de gecorrigeerde versie
utvid.Tracking.Kal.Xest(1:utvid.settings.nrcams*utvid.settings.nrMarkers,utvid.Tracking.n) = vec3d;


% % update prediction
% vec1 = [Xest.x1(:,1,n);Xest.x2(:,1,n);Xest.x3(:,1,n);Xest.x1(:,2,n);Xest.x2(:,2,n);Xest.x3(:,2,n)];
% vec = twoDto3D_3cam(vec1,0,utvid.Pstruct.Pext);
% Kal.Xpred(1:length(vec),n)=vec;
% 
% Kal = prepareKalman3D(Kal, Pstruct,n);
% Kal = updateKal(Kal,n);

utvid.Tracking.Xest = getAllRep(utvid.Tracking.Xest,utvid.Tracking.n, utvid.Tracking.Kal.Xest(1:end/2,utvid.Tracking.n), utvid.Tracking.Kal.Cest(1:end/2,1:end/2,utvid.Tracking.n), utvid.Pstruct);

compVec = [utvid.Tracking.Kal.Xest(1:end/6,utvid.Tracking.n)';utvid.Tracking.Kal.Xest(end/6+1:end/6*2,utvid.Tracking.n)';utvid.Tracking.Kal.Xest(end/6*2+1:end/6*3,utvid.Tracking.n)';ones(1,utvid.settings.nrMarkers)];
% rotate and translate
if utvid.settings.nrOrMar ~=0
    compVec = utvid.Tracking.T(:,:,utvid.Tracking.instr,utvid.Tracking.n)*compVec;
end
compVec = transpose(compVec(1:3,:)); compVec = compVec(:);
Dn = min(pdist2(compVec',utvid.pca.PCAcoords'));

% figure(22);
% plot3(compVec(1:10),compVec(11:20),compVec(21:30),'*r')
% view(2);axis equal
% hold on;
% plot3(PCAcoords(1:10,1),PCAcoords(11:20,1),PCAcoords(21:30,1),'*g');
% plot3(utvid.Tracking.rt_coor(1:10,n),utvid.Tracking.rt_coor(11:20,4),utvid.Tracking.rt_coor(21:30,4),'*c')
if Dn > 1.5%lim
%         PCAcoords = [PCAcoords,Kal.Xest(1:end/2,n)];
        utvid.pca.info = [utvid.pca.info,[utvid.Tracking.instr;utvid.Tracking.n]];
        utvid.pca.PCAcoords = [utvid.pca.PCAcoords,compVec];
        utvid.pca.PCAmodel = getPCAmodel(utvid);
end

end