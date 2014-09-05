function [utvid,ptsCorr,c] = outlierCorrectionMMSE(utvid,z)
N = utvid.settings.nrMarkers;
% [V,S,~] = svd(utvid.pca.PCAcoords,'econ');
utvid.pca.S = diag(utvid.pca.SM);

Cb = utvid.pca.Cb;
zCor = z-utvid.pca.meanX;
if utvid.pca.Normed == 1
    zCor = zCor./diag(utvid.pca.Gamma);
end

iter = 150;
for i = 1:iter
    p = sort(randperm(utvid.settings.nrMarkers,round(0.7*utvid.settings.nrMarkers)));
    p = [p,p+utvid.settings.nrMarkers,p+2*utvid.settings.nrMarkers];
       
    bEst{i} = inv(utvid.pca.V(p,1:utvid.settings.PCs)'*utvid.pca.V(p,1:utvid.settings.PCs)+...
        (utvid.pca.sigv^2*inv(Cb(1:utvid.settings.PCs,1:utvid.settings.PCs))))...
        *utvid.pca.V(p,1:utvid.settings.PCs)'*zCor(p);
    reconVec = utvid.pca.V(:,1:utvid.settings.PCs)*bEst{i};
    if utvid.pca.Normed == 1
        reconVec = utvid.pca.Gamma * reconVec + utvid.pca.meanX;
    else
        reconVec = reconVec + utvid.pca.meanX;
    end
    
    %Reconstruction error
    reconVecN{i} = [reconVec(1:end/3),reconVec(end/3+1:end/3*2),reconVec(end/3*2+1:end)];
    origN = [z(1:end/3),z(end/3+1:(end/3*2)),z(end/3*2+1:end)];

    PCAreconEr = sqrt(sum([reconVecN{i}-origN(1:utvid.settings.nrMarkers,:)].^2,2));
    
    %Calculation of benefit
    thres =2;     %threshold (euclidian distance for labeling marker as outlier)
%     M = markCntMasked_ext(1:end/2);
    C{i} = PCAreconEr > thres;       %determine outliers
    D{i} = PCAreconEr <= thres;       %determine inliers
    residualSum(i) = sum(PCAreconEr); %sum(PCAreconEr(D{i}));
    beta = 1/6;
    benefit(i) = length(D{i}) - beta*residualSum(i);
end

[~, maxInd] = max(benefit);
disp(['Number of inliers: ' num2str(length(find(D{maxInd})))]);
disp(['Number of outliers: ' num2str(length(find(C{maxInd})))]);
reconVecN = reconVecN{maxInd}(:);
c = find(C{maxInd});
if size(C{maxInd},1)~= 0
    ptsCorr = z;
    for cc = 1:length(c)%c = find(C{maxInd})%(C{maxInd}<=N)
        disp('Corrected marker: ')
        c(cc)
%         if c == 1
%             ptsCorr(1:N:N*2+1) = (reconVecN(1:N:N*2+1));
%         else
        ptsCorr(c(cc):N:N*2+c(cc)) = (reconVecN(c(cc):N:N*2+c(cc)));
%         end
        
    end
else
    ptsCorr = z;
end

% % %     figure(111);
% % %     subplot(2,2,1);
% % %     plot3(ptsCorr(1:10),ptsCorr(11:20),ptsCorr(21:30),'og')
% % %     hold on;
% % %     plot3(z(1:10),z(11:20),z(21:30),'*r')
% % %     hold off;
% % %     view(2)
% % %     subplot(2,2,2); imshow(utvid.Tracking.FrameL,[]);
% % %     hold on; plot(utvid.Tracking.Xest.x1(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x1(:,2,utvid.Tracking.n),'*r')
% % %     hold on; plot(utvid.Tracking.Kal.meas(1:10,utvid.Tracking.n),utvid.Tracking.Kal.meas(31:40,utvid.Tracking.n),'+g')
% % %     subplot(2,2,3); imshow(utvid.Tracking.FrameR,[]);
% % %     hold on; plot(utvid.Tracking.Xest.x2(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x2(:,2,utvid.Tracking.n),'*r')
% % %     hold on; plot(utvid.Tracking.Kal.meas(11:20,utvid.Tracking.n),utvid.Tracking.Kal.meas(41:50,utvid.Tracking.n),'+g')
% % %     subplot(2,2,4); imshow(utvid.Tracking.FrameM,[]);
% % %     hold on; plot(utvid.Tracking.Xest.x3(:,1,utvid.Tracking.n),utvid.Tracking.Xest.x3(:,2,utvid.Tracking.n),'*r')
% % %     hold on; plot(utvid.Tracking.Kal.meas(21:30,utvid.Tracking.n),utvid.Tracking.Kal.meas(51:60,utvid.Tracking.n),'+g')
end