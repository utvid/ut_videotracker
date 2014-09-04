function [utvid,ptsCorr,c] = outlierCorrectionMMSE(utvid,z)
N = utvid.settings.nrMarkers;
% [V,S,~] = svd(utvid.pca.PCAcoords,'econ');
utvid.pca.S = diag(utvid.pca.SM);

Cb = utvid.pca.Cb;
zCor = z-utvid.pca.meanX;
if utvid.pca.Normed == 1
    zCor = zCor./diag(utvid.pca.Gamma);
end

if exist('utvid.settings.nrOutlier','var')==0
    utvid.settings.nrOutlier = 3;
end
A = nchoosek(1:utvid.settings.nrMarkers,utvid.settings.nrMarkers-utvid.settings.nrOutlier);

for i = 1:size(A,1)
    p = [];
    p = A(i,:);
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
    if exist('utvid.pca.thres','var')==0
        utvid.pca.thres = 1;
    end
     utvid.pca.thres = 1;
    %     M = markCntMasked_ext(1:end/2);
    C{i} = PCAreconEr > utvid.pca.thres;       %determine outliers
    D{i} = PCAreconEr <= utvid.pca.thres;       %determine inliers
    
    %Determine new coefficient vector based on inliers
    pn = find(D{i}); pn = [pn;pn+utvid.settings.nrMarkers;pn+2*utvid.settings.nrMarkers];
    bN{i} =  inv(utvid.pca.V(pn,1:utvid.settings.PCs)'*utvid.pca.V(pn,1:utvid.settings.PCs)+...
        (utvid.pca.sigv^2*inv(Cb(1:utvid.settings.PCs,1:utvid.settings.PCs))))...
        *utvid.pca.V(pn,1:utvid.settings.PCs)'*zCor(pn);
    
    alfa = 1; beta = .25;
    % nieuwe gereconstrueeerde vector
    reconVec = utvid.pca.V(:,1:utvid.settings.PCs)*bN{i};
    reconVecN2(:,i) = utvid.pca.Gamma * reconVec + utvid.pca.meanX;
    
    if exist('utvid.pca.errMethod','var') == 0; utvid.pca.errMethod = 'MahDist'; end
    if strcmpi(utvid.pca.errMethod,'MahDist')==1
        MahDist(i) = bN{i}'*inv(Cb(1:utvid.settings.PCs,1:utvid.settings.PCs))*bN{i};
        benefit(i) = alfa*length(find(D{i})) - beta*MahDist(i);
    elseif strcmpi(utvid.pca.errMethod,'3Ddist')==1
        reconVecN3D{i} = [reconVecN2(1:end/3),reconVecN2(end/3+1:end/3*2),reconVecN2(end/3*2+1:end)];
        PCAreconEr2 = sqrt(sum([reconVecN{i}-origN(1:utvid.settings.nrMarkers,:)].^2,2));
        residualSum(i) = sum(PCAreconEr(D{i}));
        benefit(i) = length(find(D{i})) - beta*residualSum(i);
    end
    
    
end

[~, maxInd] = max(benefit);
% disp(['Number of inliers: ' num2str(length(find(D{maxInd})))]);
% disp(['Number of outliers: ' num2str(length(find(C{maxInd})))]);
pcaVec = reconVecN2(:,maxInd);
% reconVecN = reconVecN{maxInd}(:);

c = find(C{maxInd});
ptsCorr = z;
disp(['Corrected by OD: ' num2str(c')])
if ~isempty(c)
    
    for cc = 1:length(c)%c = find(C{maxInd})%(C{maxInd}<=N)
        
        ptsCorr(c(cc):N:N*2+c(cc)) = (pcaVec(c(cc):N:N*2+c(cc)));
        
    end
end
% if size(C{maxInd},1)~= 0

%         if c == 1
%             ptsCorr(1:N:N*2+1) = (reconVecN(1:N:N*2+1));
%         else

%         end

%     end
% else
%     ptsCorr = z;
% end
end