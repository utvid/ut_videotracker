function [K, R, T, P,Ximage,avgEr,stdEr] = ut_camera_calibration_cube2(Ximage, vertSiz)
%ut_camera_calibrate_cube2	camera calibration using a cube 
%
%   [K, R, T, P] = UT_CAMERA_CALIBRATION_CUBE2(IM, VERTSIZ, PLOTRESULTS) is
%   an interactive  tool for finding the calibration parameters of a
%   pinhole camera based on an image of a cube-shaped object consisting of
%   3x3x3 points. IM is the 2D input image that must contain the image of
%   the cube-like object. VERTSIZ gives the length of the vertex between
%   two points in [mm]. K is the 3x3 intrinsic calibration matrix of the camera.
%   R is the 3x3 rotation matrix that defines the orientation of the camera
%   with respect to the world coordinate system defined by the cube. T is
%   the position of the camera with respect to the center of the cube
%   (after rotation). The world coordinate system is assumed to be centered
%   in the center of the cube, oriented along the dimensions of the cube.
%   The calibration matrix P can be decomposed into internal and external
%   calibration matrices: P = K*[R,T];
%
%   UT_CAMERA_CALIBRATION_CUBE opens an overview window of the image IM.
%   The user has to interactively select the point of the cube as shown in
%   an example window, taking into account the desired orientation of the
%   cube in its reference frame.
% 
%   The resulting selected points correspond to real-world points of the
%   cube. The algorithm uses a 'direct linear transform' method with
%   normalization to calculate the transformation projecting the real-world
%   points onto the image locations selected by the user. This is the
%   linearized camera calibration matrix P.
% 
%   The internal camera parameters are calculated by virtually casting
%   lines along the vertices of the cube, and calculating their vanishing
%   points. From these, the focal distance and camera center (principal
%   point) are calculated, both in units of pixel periods (assuming square
%   pixels). The internal calibration K is then constructed from these
%   parameters.
% 
%   Then, by using the information of the internal calibration result, the
%   external parameters (rotation matrix R and translation vector T) are
%   determined from P and K.
%
%   Copyright:  F. van der Heijden, F.vanderHeijden@utwente.nl
%               T.A.G. Hageman, t.a.g.hageman@alumnus.utwente.nl
%   Signals and Systems Group
%   University of Twente, the Netherlands
%   Version 1.0, date: 05-07-2012
%
% Reference: R. Hartley, A. Zisserman, Multiple View Geometry in Computer
% Vision, Cambridge University Press, 2000

testing = false;

figure(100); imshow(Ximage,[]); title('Cube image');
set(gca,'YDir','normal');
if ~testing
    %Lets user select point after point
    Ximage = [];
    for i=1:27
        title('Select a point and press ENTER');
        [Xim, Yim] = getpts(100); 
        Ximage = [Ximage, [Xim(1); Yim(1)]];
    end    
else
    %If testing, then loads data from memory
    load IMexampleData.mat;
end

%defines world coordinates (first iterating along Z, then along Y, then
%along X)
figure(100);
[Yw, Zw, Xw] = meshgrid(-vertSiz:vertSiz:vertSiz, -vertSiz:vertSiz:vertSiz, -vertSiz:vertSiz:vertSiz);
Xworld = [Xw(:)'; Yw(:)'; Zw(:)'];

%performs calibration
[P, Xim_appr, avgEr, stdEr] = calibCameraDLTF(Xworld, Ximage);

%plot the results
figure(100); hold on;
%plot reconstructed points
plot(Ximage(1,:), Ximage(2,:), '.b');
plot(Xim_appr(1,:), Xim_appr(2,:), '.r');
title(sprintf('Calibration using all selected points\nAverage error: %.2f pixels, Standard deviation error: %.2f pixels', avgEr, stdEr));
legend('Selected points', 'Reconstructed points');
%define and plot x-, y- and z- axis
Xvec = [0,vertSiz;0,0;0,0;1,1];    
Yvec = [0,0;0,vertSiz;0,0;1,1];
Zvec = [0,0;0,0;0,vertSiz;1,1];
XvecIM = P*Xvec; XvecIM = XvecIM./(ones(3,1)*XvecIM(3,:));
YvecIM = P*Yvec; YvecIM = YvecIM./(ones(3,1)*YvecIM(3,:));
ZvecIM = P*Zvec; ZvecIM = ZvecIM./(ones(3,1)*ZvecIM(3,:));
quiver(XvecIM(1,1), XvecIM(2,1), XvecIM(1,2)-XvecIM(1,1), XvecIM(2,2)-XvecIM(2,1), 'b'); 
text(mean(XvecIM(1,:)), mean(XvecIM(2,:)), 'X', 'color', 'blue');
quiver(YvecIM(1,1), YvecIM(2,1), YvecIM(1,2)-YvecIM(1,1), YvecIM(2,2)-YvecIM(2,1), 'r'); 
text(mean(YvecIM(1,:)), mean(YvecIM(2,:)), 'Y', 'color', 'red');
quiver(ZvecIM(1,1), ZvecIM(2,1), ZvecIM(1,2)-ZvecIM(1,1), ZvecIM(2,2)-ZvecIM(2,1), 'g'); 
text(mean(ZvecIM(1,:)), mean(ZvecIM(2,:)), 'Z', 'color', 'green');

%Transforms world-coordinates of cube to image coordinates
for i = 1:3
    for j = 1:3
        for k = 1:3
            w2im(i,j,k,:) = P*[Xw(i,j,k); Yw(i,j,k); Zw(i,j,k); 1];
            w2im(i,j,k,:) = w2im(i,j,k,:)/w2im(i,j,k,3);
            Xw2im(i,j,k,:) = w2im(i,j,k,1);
            Yw2im(i,j,k,:) = w2im(i,j,k,2);
        end
    end
end

%Defines coordinates on parallel lines (marked by 2 points)
h = []; v = []; d = [];
for l = 1:3
    for m = 1:3
        %Format:    [x1;            y1;             x2;             y2          ]
        h = [   h,  [Xw2im(l,1,m);  Yw2im(l,1,m);   Xw2im(l,3,m);   Yw2im(l,3,m)]  ];
        v = [   v,  [Xw2im(1,l,m);  Yw2im(1,l,m);   Xw2im(3,l,m);   Yw2im(3,l,m)]  ];
        d = [   d,  [Xw2im(m,l,1);  Yw2im(m,l,1);   Xw2im(m,l,3);   Yw2im(m,l,3)]  ];
    end
end

%calculate the vanishing points
[vanishPt1,C1] = intersect_svd(h);
[vanishPt2,C2] = intersect_svd(d);
[vanishPt3,C3] = intersect_svd(v);

%calculate the principle point, focal point and K-matrix through use of the 
%vanishing points
p = principlepoint(vanishPt1, vanishPt2, vanishPt3);
q = sqrt(-(p-vanishPt1)'*(p-vanishPt2));
K = [q 0 p(1); 0 -q p(2); 0 0 1];

%calculates the external calibration matrix
extCalib = K\P;
R = extCalib(1:3,1:3);
T = extCalib(1:3,4);

end

%%

function [P, Xi_appr, avgEr, stdEr] = calibCameraDLTF(Xw, Xi)
    % Calibrates a camera using a single image using the Direct Linear
    % Transform Algorithm. The result is the camera calibration matrix P, given
    % corresponding points in world- and image-coordinates. Includes
    % normalization of coordinates in both domains.
    % 
    % Inputs:   Xw:     3xN matrix corresponding to N points in world
    %                   coordinates. Column structure: [X Y Z]'
    %           Xi:     2xN matrix corresponding to N points in image
    %                   coordinates (pixel positions). These points MUST be in
    %                   the same order as their corresponding world
    %                   coordinates. Column structure: [x y]'
    % 
    % Outputs:  P:      3x4 Camera calibration matrix
    %           Xi_appr:2xN matrix of the image coordinates resulting from
    %                   P*Xw. Column structure: [x y]'
    %           avgEr:  The average error between the resulting P*Xw and Xi
    %           stdEr:  The standard deviation of the error

    nPts = size(Xw, 2);

    %Normalizes image coordinates
    [Xi_norm, Ti] = normalize_coordinates_2D(Xi);
    Xi_n = Xi_norm(1,:);
    Yi_n = Xi_norm(2,:);

    %Normalizes world coordinates
    [Xw_norm, Tw] = normalize_coordinates_3D(Xw);
    Xw_n = Xw_norm(1,:);
    Yw_n = Xw_norm(2,:);
    Zw_n = Xw_norm(3,:);

    %Construct H (H*P_vec = 0, where P_vec is a 12x1 vector containing the 
    %elements of P)
    H = [];
    for i = 1:nPts
        H = [   H; ... 
                -Xw_n(i), -Yw_n(i), -Zw_n(i), -1, 0, 0, 0, 0, Xi_n(i)*Xw_n(i), Xi_n(i)*Yw_n(i), Xi_n(i)*Zw_n(i), Xi_n(i); ...
                0, 0, 0, 0, -Xw_n(i), -Yw_n(i), -Zw_n(i), -1, Yi_n(i)*Xw_n(i), Yi_n(i)*Yw_n(i), Yi_n(i)*Zw_n(i), Yi_n(i)];
    end

    %Calculate P using singular value decomposition (direct linear transform
    %algorithm)
    [~,~,V] = svd(H);
    P_vec = V(:,end);
    P = [P_vec(1:4)'; P_vec(5:8)'; P_vec(9:12)'];
    P = Ti\P*Tw; %denormalizes
    P = P/norm(P(3,1:3)); %scales

    %Calculate error
    Xi_appr = P*[Xw; ones(1,size(Xw,2))];
    Xi_appr = Xi_appr./(ones(3,1)*Xi_appr(3,:));
    error = Xi - Xi_appr(1:2, :);
    avgEr = mean(sqrt(error(1,:).^2 + error(2,:).^2));
    stdEr = std(sqrt(error(1,:).^2 + error(2,:).^2));

end

%%

function [Xout, T] = normalize_coordinates_2D(Xin)
    % Function which normalizes 2D-coordinates towards an average distance of
    % sqrt(2) and places their center of gravity in the origin.
    % 
    % Inputs:   Xin:    2xN variable containing the x- and y-coordinates of the
    %                   originial points. First row represents x-coordinates,
    %                   second row the y-coordinates.
    % 
    % Outputs:  Xout:   2xN variable containing the x- and y-coordinates of the
    %                   normalized points. First row represents x-coordinates,
    %                   second row the y-coordinates.
    %           T:      Transform describing the relation: Xout_h=T*Xin_h,
    %                   where Xout_h and Xin_h represent the homogeneous
    %                   representation of respectively Xout and Xin.

    %center of gravity (COG)
    COG = [mean(Xin(1,:)); mean(Xin(2,:))];
    %average distance from Xin to COG
    dist_mean = mean(sqrt((Xin(1,:)-COG(1)).^2 + (Xin(2,:)-COG(2)).^2));
    %factor for scaling length of coordinates
    f_scale = sqrt(2)/dist_mean;

    %calculates T
    T = [   f_scale,    0,          -COG(1)*f_scale;    ...
            0,          f_scale,    -COG(2)*f_scale;    ...
            0,          0,          1                   ];

    %calculates output
    Xout = T*[Xin; ones(1,size(Xin,2))];
    Xout(3,:) = [];

end

%%

function [Xout, T] = normalize_coordinates_3D(Xin)
    % Function which normalizes 3D-coordinates towards an average distance of
    % sqrt(3) and places their center of gravity in the origin.
    % 
    % Inputs:   Xin:    3xN variable containing the x-, and y- and z-
    %                   coordinates of the originial points. First row 
    %                   represents x-coordinates, second row the y-coordinates,
    %                   third row the z-coordinates.
    % 
    % Outputs:  Xout:   3xN variable containing the x-, y- and z-coordinates of 
    %                   the normalized points. First row represents x-
    %                   coordinates, second row the y-coordinates, third row
    %                   the z-coordinates
    %           T:      Transform describing the relation: Xout_h=T*Xin_h,
    %                   where Xout_h and Xin_h represent the homogeneous
    %                   representation of respectively Xout and Xin.

    %center of gravity (COG)
    COG = [mean(Xin(1,:)); mean(Xin(2,:)); mean(Xin(3,:))];
    %average distance from Xin to COG
    dist_mean = mean(sqrt((Xin(1,:)-COG(1)).^2 + (Xin(2,:)-COG(2)).^2 + (Xin(3,:)-COG(3)).^2));
    %factor for scaling length of coordinates
    f_scale = sqrt(3)/dist_mean;

    %calculates T
    T = [   f_scale,    0,          0,          -COG(1)*f_scale;    ...
            0,          f_scale,    0,          -COG(2)*f_scale;    ...
            0,          0,          f_scale,    -COG(3)*f_scale;    ...
            0,          0,          0,          1                   ];

    %calculates output
    Xout = T*[Xin; ones(1,size(Xin,2))];
    Xout(4,:) = [];

end

%%

function w = principlepoint(x, y, z)

    rc = inline('(x(2) - y(2))/(x(1) - y(1))','x','y'); % richtingscoefficient

    m1 = [1;rc(x, y)];      % Bereken richtingscoefficient xy
    p1 = [-m1(2); m1(1)];   % Bereken vector loodrecht op xy

    m2 = [1;rc(x, z)];      % Bereken richtingscoefficient xz
    p2 = [-m2(2); m2(1)];   % Bereken vector loodrecht op xz

    m3 = [1;rc(y, z)];      % Bereken richtingscoefficient yz
    p3 = [-m3(2); m3(1)];   % Bereken vector loodrecht op yz

    v1 = intersectp(x, y, z+p1,z);  % Bereken intersectionpunt v1
    v2 = intersectp(x, z, y+p2, y); % Bereken intersectionpunt v2
    v3 = intersectp(y, z, x+p3, x); % Bereken intersectionpunt v3

    s1 = intersectp(v1, z, v2, y);  % Bereken intersectionpunt s1 van v1-z met v2-y
    s2 = intersectp(v1, z, v3, x);  % Bereken intersectionpunt s2 van v1-z met v3-x
    s3 = intersectp(v2, y, v3, x);  % Bereken intersectionpunt s3 van v2-y met v3-x

    w = [(s1(1) + s2(1) + s3(1))/3; (s1(2) + s2(2) + s3(2))/3];
end

%%

function x = intersectp(x1, x2, x3, x4)
    % INTERSECTP Find the intersection of two lines, given by four points
    %   X = INTERSECTP(X1, X2, X3, X4) returns the point (as a 2-element
    %   column vector) that lies at the intersection of a line through
    %   X1 and X2 and a line through X3 and X4.
    v1=x2-x1;   % direction of line 1
    v2=x4-x3;   % direction of line 2
    L = [v1(2)  -v1(1);
        v2(2) -v2(1)];
    R = [v1(2)*x1(1)-v1(1)*x1(2);
        v2(2)*x3(1)-v2(1)*x3(2)];
    x = inv(L) * R;
end

%%

function [x, C] = intersect_svd(h)
    nlines = size(h,2);
    for i = 1:nlines
        x1 = h(1,i);
        y1 = h(2,i);
        x2 = h(3,i);
        y2 = h(4,i);
        d = norm([x2-x1;y2-y1]);
        co = (x2-x1)/d;
        si = (y2-y1)/d;
        H(i,:) = [-si co];
        R(i) = co*y1 - si*x1;
    end
    x = (H'*H)\(H'*R');
    r=R'-H*x;
    C = cov([r.*H(:,1) r.*H(:,2)]);
end




