function [utvid] = measurement(utvid)
% inputs:    utvid
% outputs:   utvid

%% variable when orientation exist is set two
if utvid.settings.nrOrMar ~= 0
    jmax = 2; % j = 2 in case of orientation markers
else
    jmax = 1;
end

%% get the enhanced images
if isfield(utvid.Tracking,'frames')==0
fnames = fieldnames(utvid.Tracking);
ii = 1;
for i = 1:length(fnames)
    fl = strcmp(fnames{i},'FrameL');
    if fl == 1; utvid.Tracking.frames{ii} = 'FrameL';
       utvid.Tracking.frames_or{ii} = 'FrameLor';
       ii=ii+1; end
    fr = strcmp(fnames{i},'FrameR');
    if fr == 1; utvid.Tracking.frames{ii} = 'FrameR';
       utvid.Tracking.frames_or{ii} = 'FrameRor';
       ii=ii+1; end
    fm = strcmp(fnames{i},'FrameM');
    if fm == 1; utvid.Tracking.frames{ii} = 'FrameM'; 
    utvid.Tracking.frames_or{ii} = 'FrameMor';
    ii=ii+1; end
end
end

%% loop through orientation and shape markers
for j = 1:jmax % j = 1 is shape, j = 2 is or markers
    
    Xstacked = []; Ystacked = [];
    
    % loop through number of cameras
    for i = 1:utvid.Tracking.nrcams
        x = [];
        y = [];
        if j == 1
            im  = utvid.Tracking.(utvid.Tracking.frames{i});
            % using Xpred coordinates for region of interest
            if i == 1
                x   = utvid.Tracking.Xpred.x1(:,1,utvid.Tracking.n) ;
                y   = utvid.Tracking.Xpred.x1(:,2,utvid.Tracking.n) ;
            elseif i == 2
                x   = utvid.Tracking.Xpred.x2(:,1,utvid.Tracking.n) ;
                y   = utvid.Tracking.Xpred.x2(:,2,utvid.Tracking.n) ;
            elseif i == 3
                x   = utvid.Tracking.Xpred.x3(:,1,utvid.Tracking.n) ;
                y   = utvid.Tracking.Xpred.x3(:,2,utvid.Tracking.n) ;
            end
        elseif j == 2
            im = utvid.Tracking.(utvid.Tracking.frames_or{i});
            if i == 1
                x   = utvid.Tracking.Xpred_or.x1(:,1,utvid.Tracking.n) ;
                y   = utvid.Tracking.Xpred_or.x1(:,2,utvid.Tracking.n) ;
            elseif i == 2
                x   = utvid.Tracking.Xpred_or.x2(:,1,utvid.Tracking.n) ;
                y   = utvid.Tracking.Xpred_or.x2(:,2,utvid.Tracking.n) ;
            elseif i == 3
                x   = utvid.Tracking.Xpred_or.x3(:,1,utvid.Tracking.n) ;
                y   = utvid.Tracking.Xpred_or.x3(:,2,utvid.Tracking.n) ;
            end
        end
        
        % switch between measurement method
        switch utvid.settings.Measmethod
            case 'findblue'
                [x,y] = findblue(x,y,im,utvid.Tracking.roi,1);
            case 'minsearch'
                [x,y] = minsearch(x,y,im,utvid.Tracking.roi);
            case 'templatematching'
                [x,y] = templatematching(x,y,im,utvid.Tracking.roi);
            case 'findcircle'
                [x,y] = findcircle(x,y,im,utvid.Tracking.roi);
            case 'reducecolor'
                [x,y] = reducecolor(x,y,im,utvid.Tracking.roi);
            otherwise
                disp('No valid measurement setting selected');
        end
        Xstacked = [Xstacked; x];
        Ystacked = [Ystacked; y];
    end
    
    % update the kalman measurement with the found pixel coordinates
    if j == 1
        utvid.Tracking.Kal.meas(:,utvid.Tracking.n) = [Xstacked; Ystacked];
    elseif j == 2
        utvid.Tracking.Kal_or.meas(:,utvid.Tracking.n) = [Xstacked; Ystacked];
    end
    
end

end