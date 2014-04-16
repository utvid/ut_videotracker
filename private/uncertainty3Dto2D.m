function C_2D = uncertainty3Dto2D(C_3D, P, X)
%Transforms a 3D-uncertainty to a 2D-uncertainty, based on a given point


% %calculates jacobian of projection of 3D onto 2D
% syms x y z p11 p12 p13 p14 p21 p22 p23 p24 p31 p32 p33 p34
% f = [   (p11*x + p12*y + p13*z + p14) / (p31*x + p32*y + p33*z + p34);
%         (p21*x + p22*y + p23*z + p24) / (p31*x + p32*y + p33*z + p34)];
% v = [x,y,z];
% F = jacobian(f,v);
% 
% %evaluates in given 3D-position
% p11 = P(1,1); p12 = P(1,2); p13 = P(1,3); p14 = P(1,4);
% p21 = P(2,1); p22 = P(2,2); p23 = P(2,3); p24 = P(2,4);
% p31 = P(3,1); p32 = P(3,2); p33 = P(3,3); p34 = P(3,4);
% x = X(1); y = X(2); z = X(3);
% 
% F = eval(F);

%Performs the same calculations as above, but more speedy by direct
%evaluation
F(1,1) = P(1,1)/(P(3,4) + P(3,1)*X(1) + P(3,2)*X(2) + P(3,3)*X(3)) - (P(3,1)*(P(1,4) + P(1,1)*X(1) + P(1,2)*X(2) + P(1,3)*X(3)))/(P(3,4) + P(3,1)*X(1) + P(3,2)*X(2) + P(3,3)*X(3))^2;
F(1,2) = P(1,2)/(P(3,4) + P(3,1)*X(1) + P(3,2)*X(2) + P(3,3)*X(3)) - (P(3,2)*(P(1,4) + P(1,1)*X(1) + P(1,2)*X(2) + P(1,3)*X(3)))/(P(3,4) + P(3,1)*X(1) + P(3,2)*X(2) + P(3,3)*X(3))^2;
F(1,3) = P(1,3)/(P(3,4) + P(3,1)*X(1) + P(3,2)*X(2) + P(3,3)*X(3)) - (P(3,3)*(P(1,4) + P(1,1)*X(1) + P(1,2)*X(2) + P(1,3)*X(3)))/(P(3,4) + P(3,1)*X(1) + P(3,2)*X(2) + P(3,3)*X(3))^2;
F(2,1) = P(2,1)/(P(3,4) + P(3,1)*X(1) + P(3,2)*X(2) + P(3,3)*X(3)) - (P(3,1)*(P(2,4) + P(2,1)*X(1) + P(2,2)*X(2) + P(2,3)*X(3)))/(P(3,4) + P(3,1)*X(1) + P(3,2)*X(2) + P(3,3)*X(3))^2;
F(2,2) = P(2,2)/(P(3,4) + P(3,1)*X(1) + P(3,2)*X(2) + P(3,3)*X(3)) - (P(3,2)*(P(2,4) + P(2,1)*X(1) + P(2,2)*X(2) + P(2,3)*X(3)))/(P(3,4) + P(3,1)*X(1) + P(3,2)*X(2) + P(3,3)*X(3))^2;
F(2,3) = P(2,3)/(P(3,4) + P(3,1)*X(1) + P(3,2)*X(2) + P(3,3)*X(3)) - (P(3,3)*(P(2,4) + P(2,1)*X(1) + P(2,2)*X(2) + P(2,3)*X(3)))/(P(3,4) + P(3,1)*X(1) + P(3,2)*X(2) + P(3,3)*X(3))^2;

%calculates 2D-uncertainty
C_2D = F*C_3D*F';