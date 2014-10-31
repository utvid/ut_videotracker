function [xnew,ynew] = minsearch(x,y,im,roi)
roi = roi/2;
if length(x) == 6
    roi = round(roi*.5);
end
%% check boundaries
% roi is number of pixels to left, right, up and down of center pixel
imsize = size(im);
y(y>imsize(1)-roi) = imsize(1)-(roi+1);
x(x>imsize(2)-roi) = imsize(2)-(roi+1);
y(y<1+roi) = 1+(roi+1);
x(x<1+roi) = 1+(roi+1);

%% marker detection
for i = 1:size(x,1)
%     imfoo = im(ceil(y(i))-roi:floor(y(i))+roi,ceil(x(i))-roi:floor(x(i))+roi,:);
    imfoo = im(round(y(i))-roi:round(y(i))+roi,round(x(i))-roi:round(x(i))+roi,:);
    if size(imfoo,3) ~= 1
        imfoo = sqrt(mean(imfoo.^2,3));
    end
    [~,imin]= min(imfoo(:));
    [rmin,cmin] = ind2sub(size(imfoo),imin);
    xnew(i) = x(i)-(roi+1)+cmin;
    ynew(i) = y(i)-(roi+1)+rmin;
% %     figure; imshow(log(imfoo),[]);
% %     hold on;plot(cmin,rmin,'*r');
end
xnew = xnew'; ynew = ynew';
end