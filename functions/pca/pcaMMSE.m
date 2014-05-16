function utvid = pcaMMSE(utvid)

X = utvid.pca.PCAcoords;
utvid.pca.Gamma = diag(ones(size(X,1),1));
utvid.pca.meanX = mean(X,2);

if utvid.pca.Normed == 1
Xnormed = utvid.pca.Gamma\(X(:,1:end)-repmat(utvid.pca.meanX,1,size(X,2)));
else
Xnormed = X-repmat(utvid.pca.meanX,1,size(X,2));
end

[utvid.pca.V,utvid.pca.S,~] = svd(PCAmodel.Xnormed,'econ');
utvid.pca.Cb = (1/(size(PCAmodel.Xnormed,2)))*PCAmodel.S.^2;