function [xnew,ynew] = reducecolor(x,y,im,roi)

%% check boundaries
% roi is number of pixels to left, right, up and down of center pixel
imsize = size(im);
y(y>imsize(1)-roi) = imsize(1)-(roi+1);
x(x>imsize(2)-roi) = imsize(2)-(roi+1);
y(y<1+roi) = 1+(roi+1);
x(x<1+roi) = 1+(roi+1);

%% marker detection
  Opt(:,:,1) = 0; Opt(:,:,2) = 0; Opt(:,:,3) = 1;
  opt = repmat(Opt,[2*roi+1,2*roi+1,1]);

for i = 1:size(x,1)
    imfoo = im(round(y(i))-roi:round(y(i))+roi,round(x(i))-roi:round(x(i))+roi,:);
    imfoo2 = imfoo - opt;
    imfoo11= rgb2ind(imfoo2,12,'nodither');
    imfoo1 = im2double(imfoo11);
    imfoo1(imfoo1>min(imfoo1(:)))=1;
    BW =im2bw(imfoo1);
    BW = imcomplement(imfoo1);   
    cc = bwconncomp(BW); 
    numPixels = cellfun(@numel,cc.PixelIdxList);
    [~,idx] = max(numPixels);
    centroids = regionprops(cc,'centroid');
    
    % find most centered centriods
    CC = [];
    for jj = 1:size(centroids,1)
        CC(jj) = pdist2(centroids(jj).Centroid,[(2*roi+1)/2,(2*roi+1)/2]);
    end
    [v,ind] = min(CC);
    if idx ~= ind
       if numPixels(ind)>25
            idx = ind;
       end
    end
    xnew(i) = x(i)-(roi+1) +  centroids(idx).Centroid(1);
    ynew(i) = y(i)-(roi+1) +  centroids(idx).Centroid(2);

 %     figure(22);subplot(2,2,1);imshow(imfoo,[]);title('Original');xlabel(num2str(numPixels))
%     subplot(2,2,2);imshow(imfoo2,[]); title('blue');
%     subplot(2,2,3);imshow(imfoo11,[]);title('Reduced colors');
%     subplot(2,2,4);imshow(BW,[]);title('Black and white'); 
%     hold on; plot(centroids(idx).Centroid(1),centroids(idx).Centroid(2),'*r','linewidth',3)
%     xlabel(num2str(i))
%     drawnow
%     pause
end
xnew = xnew'; ynew = ynew';
end