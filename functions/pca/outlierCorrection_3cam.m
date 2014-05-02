function [ptsCorr, outliers] = outlierCorrection_3cam(dataVec, PCAmodel, Pstruct, ptsMask, handles,Xest)
% Function which tries to detect and correct erronous measured marker
% positions. The used method takes an approach similar to RANSAC; it takes
% multiple subsets of the data vector, hypothesizing that these contain
% only inliers. Only these values are used to estimate the PCA components,
% which is used to reconstruct ALL image coordinates. A threshold decides
% which of the reconstructed markers are outliers considering the Euclidian
% error of the reconstruction with respect to the original data vector.
% Then, the subset is given a score, balancing between the number of
% inliers and the reconstruction error of only the inliers. The
% reconstruction based on the subset with the most fortunate score will be
% chosen as the corrected set.
% 
% Inputs:   dataVec:    2CNx1 vector, containing measured marker positions
%                       of N markers measured with C cameras. Ordering:
%                       [x1; x2...xC; y1; y2...yC]
%           PCAmodel:   The PCA model
%           Pstruct:    The structure containing the camera calibration
%                       matrices
%           ptsMask:    C-element cell arrays containing arrays with
%                       numbers of markers which need to be masked (because
%                       of occlusion)
%           settings:   settings of the program
% 
% Outputs:  ptsCorr:    4N vector, containing corrected marker positions
%           outliers:   C-element cell arrays containing markers which are
%                       marked as 'outliers'
% 
%Edited by Maarten v Alphen, 4-4-2014
%svd implemented with MMSE algorithm

% nrCam = 3;
N = handles.nMar;
subsetNr = round(0.7*N);

vec3D = twoDto3D_3cam(dataVec, 0, Pstruct.Pext);
zNormed = PCAmodel.Gamma\(vec3D-PCAmodel.meanX);

clear reconError t zEst
for D = 1:size(PCAmodel.U,2)
    q = 1;
    for sigv = 0:0.0001:0.02
        for i = 1:100
            K = sort(randperm(N,subsetNr));
            K = [K,K+N,K+2*N];
            z = zNormed(K,:);
            Y = PCAmodel.U(K,1:D);
            b = inv(Y'*Y+(sigv^2*inv(PCAmodel.Cb(1:D,1:D))))*Y'*z;

            zEstNorm = PCAmodel.U(:,1:D)*b;
            zEst = Gamma*zEstNorm+PCAmodel.meanX;
            reconError = zEst-vec3D;
            t(i,q,D) = mean(abs(reconError));
        end
          q = q+1;
    end
end
T = squeeze(mean(t,1));
[sigvo ,Do]=find(T==min(T(:)));
subplot(121), plot(T(sigvo,:))
subplot(122), plot([T(2,Do) ;T(2:end,Do)]);

for i = 1:30
    figure(i), plot(zEst(i,:,1))
end
    

%Select solution with highest benefit
[~, maxInd] = max(benefit);
PCAscore(:,maxInd)
ptsCorr = dataVec_recon(:,maxInd);

%Determine outliers
outliers{1} = C{maxInd}(C{maxInd}<=N);
outliers{2} = C{maxInd}(C{maxInd}>N & C{maxInd}<=2*N)-N;
outliers{3} = C{maxInd}(C{maxInd}>2*N)-2*N;

% OLD TIJMEN/MERIJN
% %Defines the set of non-occluded markers
% markCntMasked = cell(nrCam,1);
% for i=1:nrCam
%     markCntMasked{i} = 1:N;
%     markCntMasked{i}(ptsMask{i}) = [];
% end
% markCntMasked_ext = [markCntMasked{1}, markCntMasked{2}+N, markCntMasked{3}+2*N, markCntMasked{1}+3*N, markCntMasked{2}+4*N, markCntMasked{3}+5*N]';
% 
% nrIter = 50;
% PCAscore = zeros(handles.nrPCs, nrIter);
% dataVec_recon = zeros(6*N, nrIter);
% residualSum = zeros(nrIter, 1);
% benefit = zeros(nrIter, 1);
% 
% PCAmodel_sub = PCAmodel;
% 
% %Define and evaluate hypothesis
% for i=1:nrIter
%     
%     %From the set of non-occluded markers, takes a subselection
%     markCntMaskedInd{1} = randperm(length(markCntMasked{1}), subsetNr);
%     markCntMaskedInd{1} = sort(markCntMaskedInd{1},'ascend');
%     markCntSub{1} = markCntMasked{1}(markCntMaskedInd{1});
%     markCntMaskedInd{2} = randperm(length(markCntMasked{2}), subsetNr);
%     markCntMaskedInd{2} = sort(markCntMaskedInd{2},'ascend');
%     markCntSub{2} = markCntMasked{2}(markCntMaskedInd{2});
%     markCntMaskedInd{3} = randperm(length(markCntMasked{3}), subsetNr);
%     markCntMaskedInd{3} = sort(markCntMaskedInd{3},'ascend');
%     markCntSub{3} = markCntMasked{3}(markCntMaskedInd{3});
%     ind_sub = [markCntSub{1}, markCntSub{2}+N, markCntSub{3}+2*N, markCntSub{1}+3*N, markCntSub{2}+4*N, markCntSub{3}+5*N]';
%     dataVec_sub = dataVec(ind_sub);
%     
%     %changes the PCA model accordingly
%     ind_sub_P = [markCntSub{1}, markCntSub{2}+N, markCntSub{3}+2*N, markCntSub{1}+3*N, ...
%         markCntSub{2}+4*N, markCntSub{3}+5*N, markCntSub{1}+6*N, markCntSub{2}+7*N, markCntSub{3}+8*N]';
%     Pstruct_sub = Pstruct;
%     Pstruct_sub.Pext = Pstruct.Pext(ind_sub_P, :);
%               
%     %Least squares estimation   
%     [PCAscore(:,i), ~] = twoDtoPCA_3cam(dataVec_sub, 2, PCAmodel_sub, Pstruct_sub);
%     
%     [pts2D_1, pts2D_2, pts2D_3, ~, ~, ~] = PCAto2D_3cam(PCAscore(:,i), eye(handles.nrPCs), PCAmodel, Pstruct);
%     dataVec_recon(:,i) = [pts2D_1(1,:), pts2D_2(1,:), pts2D_3(1,:), pts2D_1(2,:), pts2D_2(2,:), pts2D_3(2,:)]';
%     if i == 1
% %         tt = 1
%     end
%    
%     %Reconstruction error
%     PCAreconEr = sqrt(sum(( ...
%         [dataVec_recon(1:end/2,i), dataVec_recon(end/2+1:end,i)] - ...
%         [dataVec(1:end/2), dataVec(end/2+1:end)] ...
%         ).^2, 2));
%     
%     %Calculation of benefit
%     thres = 17;     %threshold (euclidian distance for labeling marker as outlier)
%     M = markCntMasked_ext(1:end/2);
%     C{i} = M(PCAreconEr(M) > thres);        %determine outliers
%     D{i} = M(PCAreconEr(M) <= thres);       %determine inliers
%     residualSum(i) = sum(PCAreconEr(D{i}));
%     beta = 1/6;
%     benefit(i) = length(D{i}) - beta*residualSum(i);
%     
% end

