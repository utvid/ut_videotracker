function Trgb2gray = utvid_calcTrgb(im,coords,ver,hor)
% find rgb transform based on 2 class separation problem


% for i = 1:size(im,3)
%     data1(:,i) = diag(im(round(coords.y'),round(coords.x'),i));
%     data2(:,i) = diag(im(round(coords.y')+ver,round(coords.x')+hor,i));
% end
% 
% mu1 = mean(data1);
% mu2 = mean(data2);
% C1 = cov(data1);
% C2 = cov(data2);
% C = (C1+C2)/2;
% Trgb2gray = inv(C+0.005*eye(3))\(mu2-mu1)';

%% create rings around selected points to get rgb's of the neighbourhood of markers
immask = zeros(size(im,1),size(im,2));
ind = sub2ind(size(immask),round(coords.y),round(coords.x));
immask(ind) = 1;
imdil1 = imdilate(immask, strel('disk',10));    % inner radius is 10
imdil2 = imdilate(immask, strel('disk',15));    % outer radiuls is 15
imring = imdil2 & ~imdil1;

%% collect the data inside the ring
goo = reshape(im,numel(immask),3);
data2 = goo(imring==1,:);

%% create disk around selected points to get rgb's of markers
imdil0 = imdilate(immask,strel('disk',3));      % radius marker
data1 = goo(imdil0==1,:);

%% get the statistics
mu1 = mean(data1);
mu2 = mean(data2);
C1 = cov(data1);
C2 = cov(data2);

%% get the parameters for two-class separation
w1 = 2*inv(C1)*mu1';
w2 = 2*inv(C2)*mu2';
W1 = -inv(C1);
W2 = -inv(C2);
Trgb2gray.w = w2-w1;
Trgb2gray.W = W2-W1;
