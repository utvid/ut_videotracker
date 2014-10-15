function [Im_filtered,Trgb2gray] = utvid_imenhanceLLR(im,coords,r_marker,r_outer,r_inner)
% im(:,:,1) = im(:,:,1).^2; % squared Red channel for enhancing lips

Trgb2gray = utvid_calcTrgbINIT(im,coords,r_marker,r_outer,r_inner);
w = Trgb2gray.w;            % the linear mapping
W = Trgb2gray.W;            % the quadratic mapping

goo = reshape(im,size(im,1)*size(im,2),3);
imlikel= sum(goo.*(W*goo')',2)+goo*w;        % the pixel log-likelihood ratio
imlikel = reshape(imlikel,size(im,1),size(im,2));
Im_filtered = ut_gauss(imlikel,2.5);        % low pass filtering to suppress multiple responses

end
