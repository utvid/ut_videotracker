function [vecOut] = nonhomoToHomo(vecIn, type)

if strcmp(type, '3D')
    N = size(vecIn,1)/3;
    vecOut = [vecIn; ones(N, size(vecIn,2))];
elseif strcmp(type, '2D')
    N = size(vecIn,1)/2;
    vecOut = [vecIn; ones(N, size(vecIn,2))];
end