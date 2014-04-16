function Rext = getRext(R, N)
% Function constructing an extended rotation matrix based on the 3x3
% rotation matrix R, such that the PCA model can be rotated in its
% entirely following the expression V_rot = Rext*V.
% 
% Inputs:   R:      The 3x3 rotation matrix as determined from the facial
%                   markers
%           N:      The number of tongue markers
% 
% Outputs:  Rext:   The 3Nx3N rotation matrix
% 

Rext = zeros(3*N);
for i=1:3
    Rtemp = [   R(1,i)*eye(N);  R(2,i)*eye(N);  R(3,i)*eye(N)   ];   
    Rext(:,N*(i-1)+1:N*i) = Rtemp;
end