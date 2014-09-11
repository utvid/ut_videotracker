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
     utvid.pca.thres = 2;
    %     M = markCntMasked_ext(1:end/2);
    C{i} = PCAreconEr > utvid.pca.thres;       %determine outliers
    D{i} = PCAreconEr <= utvid.pca.thres;       %determine inliers
    
    %Determine new coefficient vector based on inliers
    pn = find(D{i}); pn = [pn;pn+utvid.settings.nrMarkers;pn+2*utvid.settings.nrMarkers];
    bN{i} =  inv(utvid.pca.V(pn,1:utvid.settings.PCs)'*utvid.pca.V(pn,1:utvid.settings.PCs)+...
        (utvid.pca.sigv^2*inv(Cb(1:utvid.settings.PCs,1:utvid.settings.PCs))))...
        *utvid.pca.V(pn,1:utvid.settings.PCs)'*zCor(pn);
    
    alfa = 1; beta = 0.25;
    % nieuwe gereconstrueeerde vector
    reconVec = utvid.pca.V(:,1:utvid.settings.PCs)*bN{i};
    reconVecN2(:,i) = utvid.pca.Gamma * reconVec + utvid.pca.meanX; 
    reconVecN3{i} = [reconVecN2(1:end/3,i),reconVecN2(end/3+1:end/3*2,i),reconVecN2(end/3*2+1:end,i)];
    
    PCAreconEr3 = sqrt(sum([reconVecN3{i}-origN(1:utvid.settings.nrMarkers,:)].^2,2));
    D2{i} = PCAreconEr3 <= utvid.pca.thres;       
    
    inliers(i) = sum(D2{i});
    if exist('utvid.pca.errMethod','var') == 0; utvid.pca.errMethod = 'MahDist'; end
    if strcmpi(utvid.pca.errMethod,'MahDist')==1
        MahDist(i) = bN{i}'*inv(Cb(1:utvid.settings.PCs,1:utvid.settings.PCs))*bN{i};
%         benefit(i) = alfa*length(find(D{i})) - beta*MahDist(i);
        benefit2(i) = alfa*length(find(D2{i})) - beta*MahDist(i);
    elseif strcmpi(utvid.pca.errMethod,'3Ddist')==1
        PCAreconEr2 = sqrt(sum([reconVecN3{i}-origN(1:utvid.settings.nrMarkers,:)].^2,2));
        residualSum(i) = sum(PCAreconEr2(D{i}));
        benefit3D(i) = length(find(D2{i})) - beta*residualSum(i);
    end
    
end
% figure; plot(benefit2);
% figure; plot(benefit3D);


% om te corrigeren voor kleine foutjes in de benefit
% zoek de benefit die het meest voorkomt (soort van)

%max benefit
[mB, maxInd] = max(benefit2);
% 90 procent benefits lijn
gamma = .9;
% ii = find(benefit2>mB*gamma);
%  unieke nummers bepalen
% [vv ii] = sort(benefit2);
[vv,~,ii] = unique(benefit2);
% vindt de indices van de unieke benefitswaarden boven de gamma lijn
Q = find(vv>=gamma*mB);
% als benefit2 niet boven 0 uitkomt dan is Q leeg
if isempty(Q)==1
    Q = find(vv==mB);
end
    
% aantal waarden van dezelfde benefit boven de gamma lijn bepalen
for pp = 1:length(Q)
    numBen(pp) = length(find(benefit2==vv(Q(pp))));
end
% meest voorkomende hoge benefit bepalen
[~,iii] = max(numBen);
% indices van benefit2 met meeste voorkomende hoge benefit
[~,iiii] = find(benefit2==vv(Q(iii)));
% kijken of er verschillende opties (qua correcties) zijn
for ppp = 1:length(iiii)
    cc(:,ppp) = C{iiii(ppp)};
    dd(:,ppp) = D2{iiii(ppp)};
end
% bepaal de correctie met minste outliers
[mv,mi] = min(sum(cc));
minInd = iiii(mi);
% bepaal de meeste voorkomende setting qua correcties
[xx yy zz] = unique(cc','rows');
counts = histc(zz,[1:length(yy)]);
[vc,ic] = max(counts);
% bepaal de corresponderende benefit
ids = find(zz==ic,1,'first');
maxInd = iiii(ids);

if maxInd ~= minInd
    maxInd = minInd;
end

% [~, maxInd3D] = max(benefit3D);
% disp(['Number of inliers: ' num2str(length(find(D{maxInd})))]);
% disp(['Number of outliers: ' num2str(length(find(C{maxInd})))]);
pcaVec = reconVecN2(:,maxInd);
% reconVecN = reconVecN{maxInd}(:);

c = find(C{maxInd});
% c3D = find(C{maxInd3D});
ptsCorr = z;
disp(['Corrected by MahDist: ' num2str(c')])
% disp(['Corrected by 3Ddist: ' num2str(c3D')])
if ~isempty(c)
    
    if length(c)>.5*utvid.settings.nrMarkers
            
    else
    
    for cc = 1:length(c)%c = find(C{maxInd})%(C{maxInd}<=N)
        
        ptsCorr(c(cc):N:N*2+c(cc)) = (pcaVec(c(cc):N:N*2+c(cc)));
        
    end
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