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
frames = {utvid.Tracking.FrameL,utvid.Tracking.FrameR,utvid.Tracking.FrameM};
if utvid.settings.nrOrMar~=0; % in case of orientation markers
    frames_or = {utvid.Tracking.FrameLor,utvid.Tracking.FrameRor,utvid.Tracking.FrameMor};
end

%% get the camera titles
cam =  fieldnames(utvid.settings.cam);

%% loop through orientation and shape markers
for j = 1:jmax % j = 1 is shape, j = 2 is or markers
    
    Xstacked = []; Ystacked = [];
    
    % loop through number of cameras
    for i = 1:utvid.settings.nrcams
        
        if j == 1
            im  = frames{i};
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
            im = frames_or{i};
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