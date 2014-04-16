function [Meas] = minsearch(im,Xpred,n,Meas,nMar,utvid)

coord = round(Xpred(:,:,n));

% check boundaries
coord(coord>(size(im,1)-utvid.settings.searchregion-1)) = size(im,1)-utvid.settings.searchregion-1;
coord(coord<1+utvid.settings.searchregion) = 1+utvid.settings.searchregion;

% marker detection
for i = 1:nMar
    imfoo = im(coord(2,i)-utvid.settings.searchregion:coord(2,i)+utvid.settings.searchregion,...
        coord(1,i)-utvid.settings.searchregion:coord(1,i)+utvid.settings.searchregion);
    [~,imin]= min(imfoo(:));
    [rmin,cmin] = ind2sub(size(imfoo),imin);
    
    x(i) = coord(1,i)-utvid.settings.searchregion-1+cmin;
    y(i) = coord(2,i)-utvid.settings.searchregion-1+rmin;
end
Meas.coor(:,:,n) = [x;y];
 
end