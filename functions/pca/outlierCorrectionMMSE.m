function utvid = outlierCorrectionMMSE(utvid,z)

[V,S,~] = svd(utvid.pca.PCAcoords,'econ');
utvid.pca.S = diag(S);
utvid.pca.SM = S;

Cb = (1/size(utvid.pca.PCAcoords-1,2))*utvid.pca.SM.^2;

iter = 150;
for i = 1:iter
    p = sort(randperm(utvid.settings.nrMarkers,round(0.7*utvid.settings.nrMarkers)));
    p = [p,p+utvid.settings.nrMarkers,p+2*utvid.settings.nrMarkers];
    
    bEst{i} = inv(V(p,1:utvid.settings.PCs)'*V(p,1:utvid.settings.PCs)+...
        (utvid.pca.sigv^2*inv(Cb(1:utvid.settings.PCs,1:utvid.settings.PCs))))...
        *V(p,1:utvid.settings.PCs)'*z(p);
    size(V), size(bEst{i})
    reconVec = V*bEst{i};
    %Reconstruction error
    reconVecN = [reconVec(1:end/3),reconVec(end/3+1:end/3*2),reconVec(end/3*2+1:end)];
    origN = [z(1:end/3),z(end/3+1:(end/3*2)),z(end/3*2+1:end)];
    PCAreconEr = sqrt(sum([reconVecN-origN].^2,2));
    
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
if size(C{maxInd},1)~= 0
    ptsCorr = z;
    for c = C{maxInd}'%(C{maxInd}<=N)
        ptsCorr(c:N*3:N*3+c) = (reconVecN(c:N*3:N*3+c,maxInd));
    end
else
    ptsCorr = z;
end
utvid.Tracking.Kal.Xest(:,utvid.Tracking.n) = ptsCorr;
end