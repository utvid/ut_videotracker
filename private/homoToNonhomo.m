function [vecOut, alfaVec] = homoToNonhomo(vecIn, type)

if strcmp(type, '3D')
    alfaVec = vecIn(end*3/4+1:end);
    vecOut = vecIn(1:end*3/4) ./ repmat(alfaVec,3,1);
elseif strcmp(type, '2D')
    alfaVec = vecIn(end*2/3+1:end);
    vecOut = vecIn(1:end*2/3) ./ repmat(alfaVec,2,1);
end