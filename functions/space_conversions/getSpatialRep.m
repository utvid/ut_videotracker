function X = getSpatialRep(X, iter, vec, unc, Pstruct)
% In the system, three differen 'spaces' are considered: the 2D space, the
% 3D space and the PCA space. Conversion from one space to the others is
% possible. This function calculates the state of the two spatial spaces
% (2D and 3D) given the representation in either one of these spaces. This
% is then stored in the variable X, which keeps track of these states in
% time.
% 
% Inputs:   X:      structure containing the following:
%                      - X.x1:      2xNxI 2D vector (rows correspond to x1, y1) 
%                      - X.x2:      2xNxI 2D vector (rows correspond to x2, y2) 
%                      - X.x3:      2xNxI 2D vector (rows correspond to x3, y3)
%                                   Only exists if settings.nrCam==3
%                      - X.X:       3xNxI 3D vector (rows correspond to X, Y, Z)
%                      - X.C_x1:    2x2xNxI 2D uncertainty 
%                      - X.C_x2:    2x2xNxI 2D uncertainty 
%                      - X.C_x3:    2x2xNxI 2D uncertainty. Only exists if
%                                   settings.nrCam==3;
%                      - X.C_X:     3x3xNxI 3D uncertainty 
%           iter:   number of iteration
%           vec:    supplied update vector (no rate of change included)
%                      - if 2D:     Depending on number of cameras, 4Nx1 (2) or 6Nx1 (3) vector
%                      - if 3D:     3Nx1 vector
%           unc:    supplied uncertainty matrix
%                      - if 2D:     Depending on number of cameras, 4Nx4N (2) or 6Nx6N (3) matrix
%                      - if 3D:     3Nx3N matrix
%           rep:    representation: either '2D' or '3D'
%           Pstruct:    structure containing Pext, and calibration matrices
%           settings:   system settings
% 
% Outputs:  X:      updated structure
% 

% if strcmp(rep, '2D') %not yet implemented
%     
% %defines 2D state
% %     if settings.nrCam==3
%         N = length(vec)/6;
%         X.x1(1,:,iter) = vec(1:N);
%         X.x1(2,:,iter) = vec(3*N+1:4*N);
%         X.x2(1,:,iter) = vec(N+1:2*N);
%         X.x2(2,:,iter) = vec(4*N+1:5*N);
%         X.x3(1,:,iter) = vec(2*N+1:3*N);
%         X.x3(2,:,iter) = vec(5*N+1:6*N);
%         for n=1:N
%             X.C_X(:,:,n,iter) = unc([n, n+N, n+2*N, n+3*N, n+4*N, n+5*N], [n, n+N, n+2*N, n+3*N, n+4*N, n+5*N]);
%         end
% %     else
% %         N = length(vec)/4;
% %         X.x1(1,:,iter) = vec(1:N);
% %         X.x1(2,:,iter) = vec(2*N+1:3*N);
% %         X.x2(1,:,iter) = vec(N+1:2*N);
% %         X.x2(2,:,iter) = vec(3*N+1:4*N);
% %         for n=1:N
% %             X.C_X(:,:,n,iter) = unc([n, n+N, n+2*N, n+3*N], [n, n+N, n+2*N, n+3*N]);
% %         end
% %     end
%     
%     %defines 3D state
% %     if settings.nrCam==3
%         [X.X(:,:,iter), X.C_X(:,:,:,iter)] = twoDto3D_3cam(vec, unc, Pstruct.Pext);
% %     else
% %         [X.X(:,:,iter), X.C_X(:,:,:,iter)] = twoDto3D(vec, unc, Pstruct.Pext);
% %     end

% elseif strcmp(rep, '3D')
    
    %defines 2D state
%     if settings.nrCam==3
% % % % % % %         [X.x1(:,:,iter), X.x2(:,:,iter), X.x3(:,:,iter), X.C_x1(:,:,:,iter), X.C_x2(:,:,:,iter), X.C_x3(:,:,:,iter)] = ...
% % % % % % %             threeDto2D_3cam(vec, unc, Pstruct);
%     else
%         [X.x1(:,:,iter), X.x2(:,:,iter), X.C_x1(:,:,:,iter), X.C_x2(:,:,:,iter)] = ...
%             threeDto2D(vec, unc, Pstruct);
%     end
vec
       [x1,x2,x3,X.Cx_1(:,:,:,iter),X.Cx_2(:,:,:,iter),X.Cx_3(:,:,:,iter)] ...
           = threeDto2D_3cam(vec, unc, Pstruct);

        X.x1(:,:,iter) = x1';
        X.x2(:,:,iter) = x2'; 
        X.x3(:,:,iter) = x3'; 
    

    %defines 3D state
    N = length(vec)/3;
    X.X(:,1,iter) = vec(1:N);
    X.X(:,2,iter) = vec(N+1:2*N);
    X.X(:,3,iter) = vec(2*N+1:end); 
    for n=1:N
        X.C_X(:,:,n,iter) = unc([n, n+N, n+2*N], [n, n+N, n+2*N]);
    end

end