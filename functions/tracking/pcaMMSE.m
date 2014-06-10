function utvid = pcaMMSE(utvid)

X = utvid.pca.PCAcoords;
utvid.pca.Gamma = diag(ones(size(X,1),1));
utvid.pca.meanX = mean(X,2);

if utvid.pca.Normed == 1
Xnormed = utvid.pca.Gamma\(X(:,1:end)-repmat(utvid.pca.meanX,1,size(X,2)));
else
Xnormed = X-repmat(utvid.pca.meanX,1,size(X,2));
end

[utvid.pca.V,utvid.pca.SM,~] = svd(Xnormed,'econ');
utvid.pca.Cb = (1/(size(Xnormed,2)))*utvid.pca.SM.^2;
end