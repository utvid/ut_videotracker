function [ptsCorr, outliers] = outlierCorrection_3cam(dataVec, PCAmodel, Pstruct, ptsMask, handles)
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

nrCam = 3;
N = handles.nMar;
subsetNr = round(1*N);

%Defines the set of non-occluded markers
markCntMasked = cell(nrCam,1);
for i=1:nrCam
    markCntMasked{i} = 1:N;
    markCntMasked{i}(ptsMask{i}) = [];
end
markCntMasked_ext = [markCntMasked{1}, markCntMasked{2}+N, markCntMasked{3}+2*N, markCntMasked{1}+3*N, markCntMasked{2}+4*N, markCntMasked{3}+5*N]';

nrIter = 500;
PCAscore = zeros(handles.nrPCs, nrIter);
dataVec_recon = zeros(6*N, nrIter);
residualSum = zeros(nrIter, 1);
benefit = zeros(nrIter, 1);

PCAmodel_sub = PCAmodel;

%Define and evaluate hypothesis
for i=1:nrIter
    
    %From the set of non-occluded markers, takes a subselection
    markCntMaskedInd{1} = randperm(length(markCntMasked{1}), subsetNr);
    markCntMaskedInd{1} = sort(markCntMaskedInd{1},'ascend');
    markCntSub{1} = markCntMasked{1}(markCntMaskedInd{1});
    markCntMaskedInd{2} = randperm(length(markCntMasked{2}), subsetNr);
    markCntMaskedInd{2} = sort(markCntMaskedInd{2},'ascend');
    markCntSub{2} = markCntMasked{2}(markCntMaskedInd{2});
    markCntMaskedInd{3} = randperm(length(markCntMasked{3}), subsetNr);
    markCntMaskedInd{3} = sort(markCntMaskedInd{3},'ascend');
    markCntSub{3} = markCntMasked{3}(markCntMaskedInd{3});
    ind_sub = [markCntSub{1}, markCntSub{2}+N, markCntSub{3}+2*N, markCntSub{1}+3*N, markCntSub{2}+4*N, markCntSub{3}+5*N]';
    dataVec_sub = dataVec(ind_sub);
    
    %changes the PCA model accordingly
    ind_sub_P = [markCntSub{1}, markCntSub{2}+N, markCntSub{3}+2*N, markCntSub{1}+3*N, ...
        markCntSub{2}+4*N, markCntSub{3}+5*N, markCntSub{1}+6*N, markCntSub{2}+7*N, markCntSub{3}+8*N]';
    Pstruct_sub = Pstruct;
    Pstruct_sub.Pext = Pstruct.Pext(ind_sub_P, :);
              
    %Least squares estimation   
    [PCAscore(:,i), ~] = twoDtoPCA_3cam(dataVec_sub, 2, PCAmodel_sub, Pstruct_sub,'MMSE');
    [pts2D_1, pts2D_2, pts2D_3, ~, ~, ~] = PCAto2D_3cam(PCAscore(:,i), eye(handles.nrPCs), PCAmodel, Pstruct);
    dataVec_recon(:,i) = [pts2D_1(1,:), pts2D_2(1,:), pts2D_3(1,:), pts2D_1(2,:), pts2D_2(2,:), pts2D_3(2,:)]';
   
    %Reconstruction error
    PCAreconEr = sqrt(sum(( ...
        [dataVec_recon(1:end/2,i), dataVec_recon(end/2+1:end,i)] - ...
        [dataVec(1:end/2), dataVec(end/2+1:end)] ...
        ).^2, 2));
    
    %Calculation of benefit
    thres = 20;     %threshold (euclidian distance for labeling marker as outlier)
    M = markCntMasked_ext(1:end/2);
    C{i} = M(PCAreconEr(M) > thres);        %determine outliers
    D{i} = M(PCAreconEr(M) <= thres);       %determine inliers
    residualSum(i) = sum(PCAreconEr(D{i}));
    beta = 1/6;
    benefit(i) = length(D{i}) - beta*residualSum(i);
    
end

%Select solution with highest benefit
[~, maxInd] = max(benefit);
if size(C{maxInd},1)~= 0
    ptsCorr = dataVec;
    for c = C{maxInd}'%(C{maxInd}<=N)
        ptsCorr(c:N*3:N*3+c) = (dataVec_recon(c:N*3:N*3+c,maxInd));
    end
else
    ptsCorr = dataVec;
end

%Determine outliers
outliers{1} = C{maxInd}(C{maxInd}<=N);
outliers{2} = C{maxInd}(C{maxInd}>N & C{maxInd}<=2*N)-N;
outliers{3} = C{maxInd}(C{maxInd}>2*N)-2*N;