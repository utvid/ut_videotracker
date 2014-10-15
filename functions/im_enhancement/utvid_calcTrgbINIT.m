function [Trgb2gray,imring,imdil] = utvid_calcTrgbINIT(im,coords,r_marker,r_outer,r_inner)
% find rgb transform based on 2 class separation problem
%% create rings around selected points to get rgb's of the neighbourhood of markers
ind = sub2ind([size(im,1),size(im,2)],round(coords.y),round(coords.x));

    immask = zeros(size(im,1),size(im,2));
    immask(ind) = 1;
    imdil1 = imdilate(immask, strel('disk',round(r_inner)));    % inner radius
    imdil2 = imdilate(immask, strel('disk',round(r_outer)));    % outer radiuls
    imring = imdil2 & ~imdil1;
    
    %% collect the data inside the ring
    goo = reshape(im,numel(immask),3);
    data2 = goo(imring==1,:);
    
    %% create disk around selected points to get rgb's of markers
    imdil0 = imdilate(immask,strel('disk',round(r_marker)));      % radius marker
    imdil1 = imdilate(immask,strel('disk',round(r_marker)-2));
    imdil = imdil0 - imdil1;
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



