function [PCAmodel,Y,Varcum,meanX,Gamma,Xnormed,Cb] = getPCAmodel2(x,handles)

meanX = mean(x,2);
Gamma = diag(std(x,1,2));
Xnormed = Gamma\(x-repmat(meanX,1,size(x,2)));
[Y,S,~] = svd(Xnormed);

s = diag(S).^2/(size(x,2)-1);
Varcum = cumsum(s)/sum(s);

Cb = (1/(size(x,2)-1))*S.^2;

PCAmodel.meanShape = meanX;
PCAmodel.V = Y;
if size(PCAmodel.V,2)>handles.nrPCs
    PCAmodel.V = PCAmodel.V(:,1:handles.nrPCs);
end
PCAmodel.eigVal = S;
PCAmodel.y = [];

end
