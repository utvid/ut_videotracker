function Trgb2gray = utvid_calcTrgb(im,coords,ver,hor)

for i = 1:size(im,3)
    data1(:,i) = diag(im(round(coords.y'),round(coords.x'),i));
    data2(:,i) = diag(im(round(coords.y')+ver,round(coords.x')+hor,i));
end

mu1 = mean(data1);
mu2 = mean(data2);
C1 = cov(data1);
C2 = cov(data2);
C = (C1+C2)/2;
Trgb2gray = inv(C+0.005*eye(3))\(mu2-mu1)';