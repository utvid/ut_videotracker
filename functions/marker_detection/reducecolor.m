function [xnew,ynew] = reducecolor(x,y,im,roi)

%% check boundaries
% roi is number of pixels to left, right, up and down of center pixel
yy = 2;
xx = 2;

imsize = size(im);
y(y>imsize(1)-yy*roi) = imsize(1)-(yy*roi+1);
x(x>imsize(2)-xx*roi) = imsize(2)-(xx*roi+1);
y(y<1+yy*roi) = 1+(yy*roi+1);
x(x<1+xx*roi) = 1+(xx*roi+1);

%% marker detection
Opt(:,:,1) = 0; Opt(:,:,2) = 0; Opt(:,:,3) = 1;
opt = repmat(Opt,[2*yy*roi+1,2*xx*roi+1,1]);

for i = 1:size(x,1)
    imfoo = im(round(y(i))-yy*roi:round(y(i))+yy*roi,round(x(i))-xx*roi:round(x(i))+xx*roi,:);
    imfoo2 = imfoo - opt;
    imfoo11= rgb2ind(imfoo2,12,'nodither');
    imfoo1 = im2double(imfoo11);
    imfoo1(imfoo1>min(imfoo1(:)))=1;
    BW = im2bw(imfoo1);
    BW = imcomplement(imfoo1);
% %     BW = imclearborder(BW);
    cc = bwconncomp(BW);
    numPixels = cellfun(@numel,cc.PixelIdxList);
    [~,idx] = max(numPixels);
    centroids = regionprops(cc,'centroid');
    
% %     mtd1 = 0;
% %     if isempty(idx)==0
        % find most centered centriods
        CC = [];
        for jj = 1:size(centroids,1)
            CC(jj) = pdist2(centroids(jj).Centroid,[(2*xx*roi+1)/2,(2*yy*roi+1)/2]);
        end
        [v,ind] = min(CC);
        if idx ~= ind
            if numPixels(ind)>15
                idx = ind;
            end
        end
        xnew1(i) = x(i)-(xx*roi+1) +  centroids(idx).Centroid(1);
        ynew1(i) = y(i)-(yy*roi+1) +  centroids(idx).Centroid(2);
% % %     else
% % %         %%
% % %         mtd1 = 1;
% % %         xnew1(i) = 0;
% % %         ynew1(i) = 0;
% % %     end
% % %     %% extra test find blue
% % %     imfoo_ssd = sum(imfoo2.^2,3);
% % %     th = graythresh(imfoo_ssd);
% % %     BW2 = imfoo_ssd>th;
% % %     BW2 = imclearborder(BW2);
% % %     cc2 = bwconncomp(BW2);
% % %     numPixels2 = cellfun(@numel,cc2.PixelIdxList);
% % %     [~,idx2] = max(numPixels2);
% % %     centroids2 = regionprops(cc2,'centroid');
% % %     %     figure;
% % %     %     subplot(1,2,1);imshow(imfoo_ssd,[]);
% % %     %     subplot(1,2,2);imshow(BW2,[]);
% % %     
% % %     % find most centered centriods
% % %     mtd2 = 0;
% % %     if isempty(idx2)==0
% % %         CC2 = [];
% % %         for jj = 1:size(centroids2,1)
% % %             CC2(jj) = pdist2(centroids2(jj).Centroid,[(2*xx*roi+1)/2,(2*yy*roi+1)/2]);
% % %         end
% % %         [v2,ind2] = min(CC2);
% % %         if idx2 ~= ind2
% % %             if numPixels2(ind2)>15
% % %                 idx2 = ind2;
% % %             end
% % %         end
% % %         xnew2(i) = x(i)-(xx*roi+1) +  centroids2(idx2).Centroid(1);
% % %         ynew2(i) = y(i)-(yy*roi+1) +  centroids2(idx2).Centroid(2);
% % %     else
% % %         mtd2 = 1;
% % %         xnew2(i) = 0;
% % %         ynew2(i) = 0;
% % %     end
% % %     
% % %     %% choose optimal location
% % %     if mtd1==1 && mtd2==1
% % % %         [x1,y1] = getPoints(imfoo,1,'select marker');
% % % %         xnew(i) = x(i)-(xx*roi+1) + x1;
% % % %         ynew(i) = y(i)-(yy*roi+1) + y1;
% % %         xnew(i) = x(i);
% % %         ynew(i) = y(i);
% % %     elseif mtd1==1 && mtd2==0
% % %         xnew(i) = xnew2(i);
% % %         ynew(i) = ynew2(i);
% % %     elseif mtd1==0 && mtd2==1;
        xnew(i) = xnew1(i);
        ynew(i) = ynew1(i);
% % %     else
% % %         if CC(ind) < CC2(ind2)
% % %             xnew(i) = xnew1(i);
% % %             ynew(i) = ynew1(i);
% % %         else
% % %             xnew(i) = xnew2(i);
% % %             ynew(i) = ynew2(i);
% % %         end
% % %     end
    
    
    %%
%     figure(22);subplot(2,3,1);imshow(imfoo,[]);title('Original');xlabel(num2str(numPixels))
%     subplot(2,3,2);imshow(imfoo2,[]); title('blue');
%     subplot(2,3,3);imshow(imfoo11,[]);title('Reduced colors');
%     subplot(2,3,4);imshow(BW,[]);title('Black and white');
%     try hold on; plot(centroids(idx).Centroid(1),centroids(idx).Centroid(2),'*r','linewidth',3);hold off;catch;end
%     try hold on; plot(centroids2(idx2).Centroid(1),centroids2(idx2).Centroid(2),'+b','linewidth',3); hold off;catch;end
%     try hold on; plot(x1,y1,'og','linewidth',3); hold off;catch; end
%     subplot(2,3,5);imshow(imfoo_ssd,[]);title('SSD Blue');
%     subplot(2,3,6);imshow(BW2,[]);title('BW SSD Blue');
%     try hold on; plot(centroids(idx).Centroid(1),centroids(idx).Centroid(2),'*r','linewidth',3);hold off;catch; end
%     try hold on; plot(centroids2(idx2).Centroid(1),centroids2(idx2).Centroid(2),'+b','linewidth',3); hold off;catch;end
%     try hold on; plot(x1,y1,'og','linewidth',3); hold off;catch; end
%     clear x1 y1
%     xlabel(num2str(i))
%     drawnow
%     pause(.5);
end
xnew = xnew'; ynew = ynew';
end