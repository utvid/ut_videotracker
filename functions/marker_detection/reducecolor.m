function [xnew,ynew] = reducecolor(x,y,im,roi)

%% check boundaries
% roi is number of pixels to left, right, up and down of center pixel
imsize = size(im);
y(y>imsize(1)-roi) = imsize(1)-(roi+1);
x(x>imsize(2)-roi) = imsize(2)-(roi+1);
y(y<1+roi) = 1+(roi+1);
x(x<1+roi) = 1+(roi+1);

%% marker detection
for i = 1:size(x,1)
    imfoo = im(round(y(i))-roi:round(y(i))+roi,round(x(i))-roi:round(x(i))+roi,:);
    imfoo1= rgb2ind(imfoo,12,'nodither');
    imfoo1 = im2double(imfoo1);
    imfoo1(imfoo1>min(imfoo1(:)))=1;
    BW =im2bw(imfoo1);
    BW = imcomplement(imfoo1);   
    cc = bwconncomp(BW); 
    numPixels = cellfun(@numel,cc.PixelIdxList);
    [~,idx] = max(numPixels);
    centroids = regionprops(cc,'centroid');

    xnew(i) = x(i)-(roi+1) +  centroids(idx).Centroid(1);
    ynew(i) = y(i)-(roi+1) +  centroids(idx).Centroid(2);
%     figure;subplot(2,2,1);imshow(BW,[]);subplot(2,2,2);imshow(imfoo,[]);
%     subplot(2,2,3);imshow(imfoo1,[]);title(num2str(i))
end
xnew = xnew'; ynew = ynew';
end