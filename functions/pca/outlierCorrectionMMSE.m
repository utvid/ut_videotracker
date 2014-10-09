function [utvid,ptsCorr,c] = outlierCorrectionMMSE(utvid,z)
N = utvid.settings.nrMarkers;
% [V,S,~] = svd(utvid.pca.PCAcoords,'econ');
utvid.pca.S = diag(utvid.pca.SM);  % eigenvalues

Cb = utvid.pca.Cb; % covariance
zCor = z-utvid.pca.meanX;
if utvid.pca.Normed == 1
    zCor = utvid.pca.Gamma\zCor; % normalised coordinates
end

% number of outliers in hypothesis
if exist('utvid.settings.nrOutlier','var')==0
    utvid.settings.nrOutlier = 3;
end

% number of possible hypothesis
A = nchoosek(1:utvid.settings.nrMarkers,utvid.settings.nrMarkers-utvid.settings.nrOutlier);

for i = 1:size(A,1)
    p = [];
    p = A(i,:);
    p = [p,p+utvid.settings.nrMarkers,p+2*utvid.settings.nrMarkers]; % x, y, and z coordinates of hypothesis i
    
    % estimation based on hypothesis, with coordinates p
    bEst(:,i) = inv(utvid.pca.V(p,1:utvid.settings.PCs)'*utvid.pca.V(p,1:utvid.settings.PCs)+...
        (utvid.pca.sigv^2*inv(Cb(1:utvid.settings.PCs,1:utvid.settings.PCs))))...
        *utvid.pca.V(p,1:utvid.settings.PCs)'*zCor(p);
    
    % reconstruction vector back to normal coordinate system
    reconVec = utvid.pca.V(:,1:utvid.settings.PCs)*bEst(:,i);
    if utvid.pca.Normed == 1
        reconVec = utvid.pca.Gamma * reconVec + utvid.pca.meanX;
    else
        reconVec = reconVec + utvid.pca.meanX;
    end
    
    reconVecN(:,:,i) = [reconVec(1:end/3),reconVec(end/3+1:end/3*2),reconVec(end/3*2+1:end)]; % reshape reconstruction vector
    origN = [z(1:end/3),z(end/3+1:(end/3*2)),z(end/3*2+1:end)]; % original coordinates
    PCAreconEr = sqrt(sum([reconVecN(:,:,i)-origN(1:utvid.settings.nrMarkers,:)].^2,2)); %Calculate reconstruction error (euclidean distance)
    
  
  
        C(:,i) = PCAreconEr > utvid.pca.thres';       %determine outliers
        D(:,i) = PCAreconEr <= utvid.pca.thres';       %determine inliers
    
    
    pn = find(D(:,i)); pn = [pn;pn+utvid.settings.nrMarkers;pn+2*utvid.settings.nrMarkers]; % x,y,z coordinates of inliers
    %Determine new coefficient vector based on inliers (MMSE)
    bN(:,i) =  inv(utvid.pca.V(pn,1:utvid.settings.PCs)'*utvid.pca.V(pn,1:utvid.settings.PCs)+...
        (utvid.pca.sigv^2*inv(Cb(1:utvid.settings.PCs,1:utvid.settings.PCs))))...
        *utvid.pca.V(pn,1:utvid.settings.PCs)'*zCor(pn);
    
    
    % new reconstructed vector and transformation back to normal coordinate system
    reconVec = utvid.pca.V(:,1:utvid.settings.PCs)*bN(:,i);
    reconVecN2(:,i) = utvid.pca.Gamma * reconVec + utvid.pca.meanX;
    reconVecN3(:,:,i) = [reconVecN2(1:end/3,i),reconVecN2(end/3+1:end/3*2,i),reconVecN2(end/3*2+1:end,i)];
    
    % reconstruction error of reconstructed vector based on inliers
    % (euclidean distance)
    PCAreconEr3 = sqrt(sum([reconVecN3(:,:,i)-origN(1:utvid.settings.nrMarkers,:)].^2,2));
    C2(:,i) = PCAreconEr3 > utvid.pca.thres';       %determine outliers
    D2(:,i) = PCAreconEr3 <= utvid.pca.thres';
    OutlierSeq(i) = length(strfind(C2(:,i)',[1 1 1]));
    
    inliers(i) = sum(D2(:,i)); % number of inliers in new reconstruction
    if exist('utvid.pca.errMethod','var') == 0; utvid.pca.errMethod = 'MahDist'; end
    if strcmpi(utvid.pca.errMethod,'MahDist')==1
        
        % calculate mahalanobis distance
        MahDist(i) = bN(:,i)'*inv(Cb(1:utvid.settings.PCs,1:utvid.settings.PCs))*bN(:,i);
        alfa = 1; beta = 0.25; % measure of importance number of inliers/mah dist
        % calculate benefit
        benefit2(i) = alfa*length(find(D2(:,i))) - beta*MahDist(i);
        % calculate cost function
        costMah(i) = length(find(C2(:,i)))^2 + 1.5*MahDist(i)+20*OutlierSeq(i);
        
    elseif strcmpi(utvid.pca.errMethod,'3Ddist')==1
        PCAreconEr2 = sqrt(sum([reconVecN3(:,:,i)-origN(1:utvid.settings.nrMarkers,:)].^2,2));
        residualSum(i) = sum(PCAreconEr2(D(:,i)));
        benefit3D(i) = length(find(D2(:,i))) - beta*residualSum(i);
    end
    
end

% [mB, maxInd] = max(benefit2); % find the max benefit index
% pcaVec = reconVecN2(:,maxInd); % get the coordinates at max benefit
%
% c = find(C2{maxInd}); % find the outliers in this hypothesis

% [~,minInd] = min(costMah);
% c = find(C2{minInd});

[bb ix] = sort(costMah);
c=find(C2(:,ix(1)));
pcaVec = reconVecN2(:,ix(1));

    ptsCorr = z;
    disp(['Corrected markers by MahDist: ' num2str(c')])
    
    % correct the outliers
    if ~isempty(c)
        
        if length(c)>.5*utvid.settings.nrMarkers
            disp('Manual correction of outliers')
            %         utvid = PCAExpansionMMSE2(utvid);
        else
            
            for cc = 1:length(c)%c = find(C{maxInd})%(C{maxInd}<=N)
                ptsCorr(c(cc):N:N*2+c(cc)) = (pcaVec(c(cc):N:N*2+c(cc)));
            end
        end
    end
end