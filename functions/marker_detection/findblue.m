function [x,y] = findblue(x,y,im,roi,method);

%% check boundaries
% roi is number of pixels to left, right, up and down of center pixel
imsize = size(im);
y(y>imsize(1)-roi) = imsize(1)-(roi+1);
x(x>imsize(2)-roi) = imsize(2)-(roi+1);
y(y<1+roi) = 1+(roi+1);
x(x<1+roi) = 1+(roi+1);

%% marker detection
if method == 1
    tic
    %% based on one pixel
    Opt(:,:,1) = 0; Opt(:,:,2) = 0; Opt(:,:,3) = 1;
    opt = repmat(Opt,[2*roi+1,2*roi+1,1]);
    for i = 1:size(x,1)
        imfoo = im(round(y(i))-roi:round(y(i))+roi,round(x(i))-roi:round(x(i))+roi,:);
        imfoo1 = imfoo-opt;
        imfoo_ssd = sum(imfoo1.^2,3);
        [rmin,cmin] = find(imfoo_ssd == min(imfoo_ssd(:)),1,'first');
        
        x(i) = x(i)-(roi+1)+cmin;
        y(i) = y(i)-(roi+1)+rmin; 
    end
    toc
elseif method == 2
    tic
    %% based on surrounding pixels
    Opt(:,:,1) = 0; Opt(:,:,2) = 0; Opt(:,:,3) = 1;
    opt = repmat(Opt,[2*roi+1,2*roi+1,1]);
    f = fspecial('average',3);
    for i = 1:size(x,1)
        imfoo = im(round(y(i))-roi:round(y(i))+roi,round(x(i))-roi:round(x(i))+roi,:);
        imfoo1 = imfoo-opt;
        imfoo_ssd = sum(imfoo1.^2,3);
        imfoo_ssd2 = imfilter(imfoo_ssd,f,'replicate');
        level = graythresh(imfoo_ssd2);
        BW = im2bw(imfoo_ssd2,level);
        BW = imcomplement(BW);
        cc = bwconncomp(BW); 
        numPixels = cellfun(@numel,cc.PixelIdxList);
        [~,idx] = max(numPixels);
        centroids = regionprops(cc,'centroid');
        
        x(i) = x(i)-(roi+1)+  centroids(idx).Centroid(1);
        y(i) = y(i)-(roi+1)+  centroids(idx).Centroid(2);
    end
    toc
end


end