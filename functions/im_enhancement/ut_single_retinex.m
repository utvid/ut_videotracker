function [refl,illum] = ut_single_retinex(im,sigma,alpha)

im = im2double(im);
if ndims(im)==3
    imgray = rgb2gray(im);
    L = ut_gauss(log(imgray+alpha),sigma);
    IM = log(im+alpha) - cat(3,L,L,L);
    refl = exp(IM)-alpha;
    illum = exp(L)-alpha;

else
    IM = log(im+alpha);
    L = ut_gauss(IM,sigma);
    R = IM - L;
    refl = exp(R)-alpha;
    illum = exp(L)-alpha;
end
