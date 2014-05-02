function [utvid] = measurement(utvid)
% inputs:    utvid,
%            frames = {FrameL,FrameR,FrameM}
%            str = or / shape
%            n = framenumber

if utvid.settings.nrOrMar ~= 0
    jmax = 2;
else
    jmax = 1;
end

for j = 1:jmax % j = 1 is shape, j = 2 is or markers
    frames = {utvid.Tracking.FrameL,utvid.Tracking.FrameR,utvid.Tracking.FrameM};
    cam = {'left','right','center'};
    if isfield(utvid.settings,'Measmethod')~=1
        utvid.settings.Measmethod = 'minsearch';
    end
    
    Xstacked = []; Ystacked = [];
    
    for i = 1:utvid.settings.nrcams
        im  = frames{i};
        if j == 1
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
            if i == 1
                x   = utvid.Tracking.Xpredor.x1(:,1,utvid.Tracking.n) ;
                y   = utvid.Tracking.Xpredor.x1(:,2,utvid.Tracking.n) ;
            elseif i == 2
                x   = utvid.Tracking.Xpredor.x2(:,1,utvid.Tracking.n) ;
                y   = utvid.Tracking.Xpredor.x2(:,2,utvid.Tracking.n) ;
            elseif i == 3
                x   = utvid.Tracking.Xpredor.x3(:,1,utvid.Tracking.n) ;
                y   = utvid.Tracking.Xpredor.x3(:,2,utvid.Tracking.n) ;
            end
        end
        
        switch utvid.settings.Measmethod
            case 'findblue'
                [x,y] = findblue(x,y,im,utvid.Tracking.roi);
            case 'minsearch'
                [x,y] = minsearch(x,y,im,utvid.Tracking.roi);
            case 'templatematching'
                [x,y] = templatematching(x,y,im,utvid.Tracking.roi);
            case 'findcircle'
                [x,y] = findcircle(x,y,im,utvid.Tracking.roi);
            otherwise
                disp('No valid measurement setting selected');
        end
        Xstacked = [Xstacked; x];
        Ystacked = [Ystacked; y];
    end
    
    if j == 1
        utvid.Tracking.Kal.meas(:,utvid.Tracking.n) = [Xstacked; Ystacked];
    elseif j == 2
        utvid.Tracking.Kal.measor(:,utvid.Tracking.n) = [Xstacked; Ystacked];
    end

end

end