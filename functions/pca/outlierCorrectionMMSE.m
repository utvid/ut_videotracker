function utvid = outlierCorrectionMMSE(utvid,z)

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
    thres = 5;     %threshold (euclidian distance for labeling marker as outlier)
%     M = markCntMasked_ext(1:end/2);
    C{i} = PCAreconEr > thres;        %determine outliers
    D{i} = PCAreconEr <= thres;       %determine inliers
    residualSum(i) = sum(PCAreconEr(D{i}));
    beta = 1/6;
    benefit(i) = length(D{i}) - beta*residualSum(i);
end

[~, maxInd] = max(benefit);
reconVecN = reconVecN{maxInd}(:);

if size(C{maxInd},1)~= 0
    ptsCorr = z;
    for c = find(C{maxInd})%(C{maxInd}<=N)
        if c == 1
            ptsCorr(1:N:N*2+1) = (reconVecN(1:N:N*2+1));
        else
            ptsCorr(c:N:N*2+c) = (reconVecN(c:N:N*2+c));
        end

    end
else
    ptsCorr = z;
end

utvid.Tracking.Kal.Xest(1:end/2,utvid.Tracking.n) = ptsCorr;
end