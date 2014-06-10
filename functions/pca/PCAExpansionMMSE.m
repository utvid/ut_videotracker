function [PCAcoords,Xest,Kal] = PCAExpansionMMSE(FrameL,FrameR,FrameM,n,PCAcoords,Kal,Xest,Pstruct,lim,utvid)

imnL = FrameL; imnR = FrameR; imnM = FrameM;

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
h2 = plot(Xest.x1(:,1,n),Xest.x1(:,2,n),'*r');
mins = min(Xest.x1(:,:,n));
maxs = max(Xest.x1(:,:,n));
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
        [Xest.x1(:,:,n)] = correctPoints(imnL,utvid.settings.nrMarkers,Xest.x1(:,:,n),'shape');
        
end

h1 = figure; set(gcf, 'Position', get(0,'Screensize'));
imshow(imnR,[]);  hold on
h2 = plot(Xest.x2(:,1,n),Xest.x2(:,2,n),'*r');
mins = min(Xest.x2(:,:,n));
maxs = max(Xest.x2(:,:,n));
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
        [Xest.x2(:,:,n)] = correctPoints(imnR,utvid.settings.nrMarkers,Xest.x2(:,:,n),'shape');
        
end

h1 = figure; set(gcf, 'Position', get(0,'Screensize'));
imshow(imnM,[]);  hold on
h2 = plot(Xest.x3(:,1,n),Xest.x3(:,2,n),'*r');
mins = min(Xest.x3(:,:,n));
maxs = max(Xest.x3(:,:,n));
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
        [Xest.x3(:,:,n)] = correctPoints(imnM,utvid.settings.nrMarkers,Xest.x3(:,:,n),'shape');
        
end

Kal.meas(:,n) = [Xest.x1(:,1,n);Xest.x2(:,1,n);Xest.x3(:,1,n);Xest.x1(:,2,n);Xest.x2(:,2,n);Xest.x3(:,2,n)];

% update prediction
vec1 = [Xest.x1(:,1,n);Xest.x2(:,1,n);Xest.x3(:,1,n);Xest.x1(:,2,n);Xest.x2(:,2,n);Xest.x3(:,2,n)];
vec = twoDto3D_3cam(vec1,0,utvid.Pstruct.Pext);
Kal.Xpred(1:length(vec),n)=vec;

Kal = prepareKalman3D(Kal, Pstruct,n);
Kal = updateKal(Kal,n);

Xest = getAllRep(Xest,n, Kal.Xest(1:end/2,n), Kal.Cest(1:end/2,1:end/2,n), Pstruct);

compVec = [Kal.Xest(1:end/6,n)';Kal.Xest(end/6+1:end/6*2,n)';Kal.Xest(end/6*2+1:end/6*3,n)';ones(1,utvid.settings.nrMarkers)];
% rotate and translate
if utvid.settings.nrOrMar ~=0
    compVec = utvid.Tracking.T(:,:,utvid.Tracking.instr,utvid.Tracking.n)*compVec;
end
compVec = transpose(compVec(1:3,:)); compVec = compVec(:);
% Dn = min(pdist2(compVec',PCAcoords'));

% figure(22);
% plot3(compVec(1:10),compVec(11:20),compVec(21:30),'*r')
% view(2);axis equal
% hold on;
% plot3(PCAcoords(1:10,1),PCAcoords(11:20,1),PCAcoords(21:30,1),'*g');
% plot3(utvid.Tracking.rt_coor(1:10,n),utvid.Tracking.rt_coor(11:20,4),utvid.Tracking.rt_coor(21:30,4),'*c')

% if Dn > lim
    %     PCAcoords = [PCAcoords,Kal.Xest(1:end/2,n)];
    PCAcoords = [PCAcoords,compVec];
    %     PCAmodel = getPCAmodel(utvid);
% end

end