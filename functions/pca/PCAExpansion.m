function [PCAcoords,Xest,Kal] = PCAExpansion(FrameL,FrameR,FrameM,n,PCAcoords,Kal,Xest,Pstruct,lim,utvid)

imnL = FrameL; imnR = FrameR; imnM = FrameM;

if utvid.settings.nrOrMar ~= 0
    subplot(1,3,1), set(gcf, 'Position', get(0,'Screensize'));
    imshow(imnL,[]),  
    hold on, plot(Xest_or.x1(1,:,n),Xest_or.x1(2,:,n),'r*');

    subplot(1,3,2), imshow(imnR,[]),
    hold on, plot(Xest_or.x2(1,:,n),Xest_or.x2(2,:,n),'r*');

    subplot(1,3,3), imshow(imnM,[]), 
    hold on, plot(Xest_or.x3(1,:,n),Xest_or.x3(2,:,n),'r*');


choice = questdlg('Orientation markers located correct', 'User input', ...
'Yes','No','No');
switch choice
    case 'Yes'
        close
    case 'No'
        close
        Xest_or.x1(:,:,n) = correctPoints(imnL,utvid.settings.nrOrMar,Xest_or.x1(:,:,n),'orientation');
        Xest_or.x2(:,:,n) = correctPoints(imnR,utvid.settings.nrOrMar,Xest_or.x2(:,:,n),'orientation'); 
        Xest_or.x3(:,:,n) = correctPoints(imnM,utvid.settings.nrOrMar,Xest_or.x3(:,:,n),'orientation');

        Kal_or.meas(:,n) = [Xest_or.x1(1,:,n)';Xest_or.x2(1,:,n)';Xest_or.x3(1,:,n)';Xest_or.x1(2,:,n)';Xest_or.x2(2,:,n)';Xest_or.x3(2,:,n)'];
        Kal_or      = prepareKalman3D(Kal_or, Pstruct_or, n);
        Kal_or      = updateKal(Kal_or, n);
        Xest_or     = getSpatialRep(Xest_or, n, Kal_or.Xest(1:end/2,n), Kal_or.Cest(1:end/2,1:end/2,n), Pstruct_or);
        T = rigid_transform_3D([Kal_or.Xest(1:end/6,n)';Kal_or.Xest(end/6+1:end/6*2,n)';Kal_or.Xest(end/6*2+1:end/6*3,n)']',[Kal_or.Xest(1:end/6,1)';Kal_or.Xest(end/6+1:end/6*2,1)';Kal_or.Xest(end/6*2+1:end/6*3,1)']');
end
close
end
size(Xest.x1)
h1 = figure; set(gcf, 'Position', get(0,'Screensize'));
imshow(imnL,[]); hold on
h2 = plot(Xest.x1(:,1,n),Xest.x1(:,2,n),'*r');
choice = questdlg('Markers located correct', 'User input', ...
    'Yes','No','No');
switch choice
    case 'Yes'
        close
    case 'No'
        close
        [Xest.x1(:,:,n)] = correctPoints(imnL,utvid.settings.nrMarkers,Xest.x1(:,:,n),'shape');

end

h1 = figure; set(gcf, 'Position', get(0,'Screensize'));
imshow(imnR,[]);  hold on
h2 = plot(Xest.x2(:,1,n),Xest.x2(:,2,n),'*r');
choice = questdlg('Markers located correct', 'User input', ...
    'Yes','No','No');
switch choice
    case 'Yes'
        close
    case 'No'
        close
        [Xest.x2(:,:,n)] = correctPoints(imnR,utvid.settings.nrMarkers,Xest.x2(:,:,n),'shape');

end

h1 = figure; set(gcf, 'Position', get(0,'Screensize'));
imshow(imnM,[]);  hold on
h2 = plot(Xest.x3(:,1,n),Xest.x3(:,2,n),'*r');
choice = questdlg('Markers located correct', 'User input', ...
    'Yes','No','No');
switch choice
    case 'Yes'
        close
    case 'No'
        close
        [Xest.x3(:,:,n)] = correctPoints(imnM,utvid.settings.nrMarkers,Xest.x3(:,:,n),'shape');

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