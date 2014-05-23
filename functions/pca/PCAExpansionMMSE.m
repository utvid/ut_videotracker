function [PCAcoords,Xest,Kal] = PCAExpansionMMSE(FrameL,FrameR,FrameM,n,PCAcoords,Kal,Xest,Pstruct,lim,utvid)

imnL = FrameL; imnR = FrameR; imnM = FrameM;

if utvid.settings.nrOrMar ~= 0

    subplot(1,3,1), set(gcf, 'Position', get(0,'Screensize'));
    imshow(imnL,[]),  
    hold on, plot(utvid.Tracking.Xest_or.x1(1,:,n),utvid.Tracking.Xest_or.x1(2,:,n),'r*');

    subplot(1,3,2), imshow(imnR,[]),
    hold on, plot(utvid.Tracking.Xest_or.x2(1,:,n),utvid.Tracking.Xest_or.x2(2,:,n),'r*');

    subplot(1,3,3), imshow(imnM,[]), 
    hold on, plot(utvid.Tracking.Xest_or.x3(1,:,n),utvid.Tracking.Xest_or.x3(2,:,n),'r*');


choice = questdlg('Orientation markers located correct', 'User input', ...
'Yes','No','No');
switch choice
    case 'Yes'
        close
    case 'No'
        close
        utvid.Tracking.Xest_or.x1(:,:,n) = correctPoints(imnL,utvid.settings.nrOrMar,utvid.Tracking.Xest_or.x1(:,:,n),'orientation');
        utvid.Tracking.Xest_or.x2(:,:,n) = correctPoints(imnR,utvid.settings.nrOrMar,utvid.Tracking.Xest_or.x2(:,:,n),'orientation'); 
        utvid.Tracking.Xest_or.x3(:,:,n) = correctPoints(imnM,utvid.settings.nrOrMar,utvid.Tracking.Xest_or.x3(:,:,n),'orientation');

        Kal_or.meas(:,n) = [utvid.Tracking.Xest_or.x1(1,:,n)';utvid.Tracking.Xest_or.x2(1,:,n)';utvid.Tracking.Xest_or.x3(1,:,n)';utvid.Tracking.Xest_or.x1(2,:,n)';utvid.Tracking.Xest_or.x2(2,:,n)';utvid.Tracking.Xest_or.x3(2,:,n)'];
        Kal_or      = prepareKalman3D(Kal_or, Pstruct_or, n);
        Kal_or      = updateKal(Kal_or, n);
        utvid.Tracking.Xest_or     = getSpatialRep(utvid.Tracking.Xest_or, n, Kal_or.Xest(1:end/2,n), Kal_or.Cest(1:end/2,1:end/2,n), Pstruct_or);
        T = rigid_transform_3D([Kal_or.Xest(1:end/6,n)';Kal_or.Xest(end/6+1:end/6*2,n)';Kal_or.Xest(end/6*2+1:end/6*3,n)']',[Kal_or.Xest(1:end/6,1)';Kal_or.Xest(end/6+1:end/6*2,1)';Kal_or.Xest(end/6*2+1:end/6*3,1)']');
end
close
end

h1 = figure; set(gcf, 'Position', get(0,'Screensize'));
imshow(imnL,[]); hold on  
mins = min(utvid.Tracking.Xest.x1); 
maxs = max(utvid.Tracking.Xest.x1);
xlim([mins(1)-25 maxs(1)+25]);
ylim([mins(2)-25 maxs(2)+25]);

h2 = plot(Xest.x1(:,1,n),Xest.x1(:,2,n),'*r');
choice = questdlg('Markers located correct', 'User input', ...
    'Yes','No','No');
switch choice
    case 'Yes'
        close
    case 'No'
        close
        [Xest.x1(:,:,n)] = correctPoints(imnL,utvid.settings.nrMarkers,Xest.x1(:,:,n),'shape',mins,maxs);

end

h1 = figure; set(gcf, 'Position', get(0,'Screensize'));
imshow(imnR,[]);  hold on
mins = min(utvid.Tracking.Xest.x2);
maxs = max(utvid.Tracking.Xest.x2);
xlim([mins(1)-25 maxs(1)+25]);
ylim([mins(2)-25 maxs(2)+25]);
    
h2 = plot(Xest.x2(:,1,n),Xest.x2(:,2,n),'*r');
choice = questdlg('Markers located correct', 'User input', ...
    'Yes','No','No');
switch choice
    case 'Yes'
        close
    case 'No'
        close
        [Xest.x2(:,:,n)] = correctPoints(imnR,utvid.settings.nrMarkers,Xest.x2(:,:,n),'shape',mins,maxs);

end

h1 = figure; set(gcf, 'Position', get(0,'Screensize'));
imshow(imnM,[]);  hold on
mins = min(utvid.Tracking.Xest.x3);
maxs = max(utvid.Tracking.Xest.x3);
xlim([mins(1)-25 maxs(1)+25]);
ylim([mins(2)-25 maxs(2)+25]);
    
h2 = plot(Xest.x3(:,1,n),Xest.x3(:,2,n),'*r');
choice = questdlg('Markers located correct', 'User input', ...
    'Yes','No','No');
switch choice
    case 'Yes'
        close
    case 'No'
        close
        [Xest.x3(:,:,n)] = correctPoints(imnM,utvid.settings.nrMarkers,Xest.x3(:,:,n),'shape',mins,maxs);

end

Kal.meas(:,n) = [Xest.x1(:,1,n);Xest.x2(:,1,n);Xest.x3(:,1,n);Xest.x1(:,2,n);Xest.x2(:,2,n);Xest.x3(:,2,n)];
Kal = prepareKalman3D(Kal, Pstruct,n);
Kal = updateKal(Kal,n);

Xest = getAllRep(Xest,n, Kal.Xest(1:end/2,n), Kal.Cest(1:end/2,1:end/2,n), Pstruct);

compVec = [Kal.Xest(1:end/6,n)';Kal.Xest(end/6+1:end/6*2,n)';Kal.Xest(end/6*2+1:end/6*3,n)';ones(1,utvid.settings.nrMarkers)]; 
compVec = transpose(compVec(1:3,:)); compVec = compVec(:);
Dn = min(pdist2(compVec',PCAcoords'));

if Dn > lim
%     PCAcoords = [PCAcoords,Kal.Xest(1:end/2,n)];
    PCAcoords = [PCAcoords,compVec];
%     PCAmodel = getPCAmodel(utvid);
end

end